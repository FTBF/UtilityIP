module bram_to_stream #(
		parameter INCLUDE_SYNCHRONIZER = 0,
		parameter [15:0] MEM_DEPTH = 2048,
		parameter C_S_AXI_ADDR_WIDTH = 32,
		parameter C_S_AXI_DATA_WIDTH = 32,
		parameter N_REG = 4
	) (

		input logic         IPIF_clk,
		input logic         clk,
		input logic         aresetn,
		
		//configuration parameter interface 
        input  logic                                  IPIF_Bus2IP_resetn,
        input  logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr,   //unused
        input  logic                                  IPIF_Bus2IP_RNW,    //unused
        input  logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE,     //unused
        input  logic [0 : 0]                          IPIF_Bus2IP_CS,     //unused
        input  logic [N_REG-1 : 0]                    IPIF_Bus2IP_RdCE, 
        input  logic [N_REG-1 : 0]                    IPIF_Bus2IP_WrCE,
        input  logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data,
        output logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data,
        output logic                                  IPIF_IP2Bus_WrAck,
        output logic                                  IPIF_IP2Bus_RdAck,
        output logic                                  IPIF_IP2Bus_Error,
        
        //fast comannd input 
        input logic fc_orbitSync,
                                             
		// block RAM access
		output logic        bram_CLK,
		output logic        bram_RST,
		output logic        bram_EN,
		output logic [31:0] bram_ADDR,
		input logic [31:0]  bram_DOUT,

		// output AXI stream
		output logic [31:0] data_stream_TDATA,
		input logic         data_stream_TREADY,
		output logic        data_stream_TVALID
	);

	typedef struct
	{
		logic [$clog2(MEM_DEPTH)-1:0] address;
		logic [31:0] data_stream_out;
		logic data_stream_valid;
	} reg_type;

	reg_type d, q;
    
    logic output_sync;
    
    //IPIF parameter decoding logic 
    typedef struct packed
    {
        logic [31:0]   padding4;   //dummy value
        logic [30:0]   padding3;   //dummy value 
        logic [0:0]    force_sync; // force the logic to reset link value to zero - this is a broadcast register 
        logic [15:0]   padding2;   // dummy value
        logic [15:0]   ram_range;  // in syncmode 1: ram_range determines pattern length in orbits, in syncmode 2: ram_range determines the number of 32 bit words to send
        logic [29:0]   padding1;   // dummy value
        logic [1:0]    sync_mode;  // syncmode; 0: no sync (send entire ram always),  1: orbit synchronous,  2: fixed length repeating mode,  3: reserved
    } param_t;
    
    param_t params_from_bus;
    param_t params_from_IP;
    param_t params_to_bus;
    param_t params_to_IP;
    
	always_comb begin
		params_from_IP = params_to_IP;
		params_from_IP.padding4 = '0;
		params_from_IP.padding3 = '0;
		params_from_IP.padding2 = '0;
		params_from_IP.padding1 = '0;
	end
    	
	IPIF_parameterDecode #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .N_REG(N_REG),
        .PARAM_T(param_t),
        .DEFAULTS({32'b0, 32'b0, 16'b0, MEM_DEPTH, 32'b0})
    ) paramDecoder (
        .clk(clk),
    
        .IPIF_bus2ip_data(IPIF_Bus2IP_Data),  
        .IPIF_bus2ip_rdce(IPIF_Bus2IP_RdCE),
        .IPIF_bus2ip_resetn(IPIF_Bus2IP_resetn),
        .IPIF_bus2ip_wrce(IPIF_Bus2IP_WrCE),
        .IPIF_ip2bus_data(IPIF_IP2Bus_Data),
        .IPIF_ip2bus_rdack(IPIF_IP2Bus_RdAck),
        .IPIF_ip2bus_wrack(IPIF_IP2Bus_WrAck),
    
        .parameters_in(params_to_bus),
        .parameters_out(params_from_bus)
    );
    
	IPIF_clock_converter #(
		.INCLUDE_SYNCHRONIZER(INCLUDE_SYNCHRONIZER),
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(param_t)
	) IPIF_clock_conv (
		.IP_clk(in_clk160),
		.bus_clk(IPIF_clk),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus));
    // ground unused error port
    assign IPIF_IP2Bus_Error = 0;
    
    // interlink synchronization logic 
    // this logic will keep things synchronous for repeats up to 8 orbits long
    // uses counter counting to 840, which is the LCM of 1, 2, ... 8
    
    logic [9:0] orbit_counter;
    
    always_ff @(posedge clk or negedge aresetn)
    begin
        if(!aresetn)             orbit_counter <= 0;
        else
        begin
            if(data_stream_TREADY)
            begin
                if(orbit_counter >= 840)   orbit_counter <= 0;
                else if(fc_orbitSync) orbit_counter <= orbit_counter + 1;
            end
        end
    end
    
    //Select sync mode of operation
    always_comb
    begin
        case(params_to_IP.sync_mode)
            2'd1:   //orbit sync mode
            begin
                output_sync = fc_orbitSync && ((orbit_counter % params_to_IP.ram_range[2:0]) == 0);
            end
            2'd2:   //length limited unsynchronous 
            begin
                output_sync = q.address >= params_to_IP.ram_range - 1 || params_to_IP.force_sync;
            end
            default:  //no sync pulse 
            begin
                output_sync = params_to_IP.force_sync;
            end
        endcase
    end

	always_comb
	begin
		if (data_stream_TREADY == 1)
		    if(output_sync == 1) d.address = 0;
		    else                 d.address = q.address + 1;
		else
			d.address = q.address;

		d.data_stream_out = bram_DOUT;
		d.data_stream_valid = 1'b1;

		bram_CLK = clk;
		bram_RST = !aresetn; // bram requires active-high reset
		bram_ADDR = {19'b0, q.address, 2'b0};
		bram_EN = 1'b1; // combinational output to avoid an extra cycle of latency
		data_stream_TDATA = q.data_stream_out;
		data_stream_TVALID = q.data_stream_valid;;
	end

	always_ff @(posedge clk, negedge aresetn)
	begin
		if (aresetn == 0) begin
			q.address <= 0;
			q.data_stream_out <= 32'b0;
			q.data_stream_valid <= 1'b0;
		end else begin
			q <= d;
		end
	end
endmodule
