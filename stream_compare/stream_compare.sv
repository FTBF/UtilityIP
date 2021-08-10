module stream_compare #(
	parameter INCLUDE_SYNCHRONIZER = 0,
    parameter integer C_S_AXI_ADDR_WIDTH = 32,
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer N_REG = 4,
	TDATA_WIDTH = 32

    )(

	input logic IPIF_clk,
	input logic clk,
	input logic aresetn,

	input logic [TDATA_WIDTH-1:0] S_AXIS_0_TDATA,
	input logic S_AXIS_0_TVALID,
	output logic S_AXIS_0_TREADY,

	input logic [TDATA_WIDTH-1:0] S_AXIS_1_TDATA,
	input logic S_AXIS_1_TVALID,
	output logic S_AXIS_1_TREADY,

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
    output logic                                  IPIF_IP2Bus_Error	
	);
	
    typedef struct packed
    {
        logic [31:0]           padding3;
        logic [31:0]           err_count;
        logic [31:0]           word_count;
        logic [29:0]           padding1;
        logic [1:1]            latch;
        logic [0:0]            reset;
    } param_t;
    
    param_t params_to_bus;
    param_t params_to_IP;
    param_t params_from_bus;
    param_t params_from_IP;

	localparam param_t defaults = '{default:'0};
	localparam param_t self_reset = '{default:'0, latch:1'b1, reset:1'b1};
    
    IPIF_parameterDecode #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .N_REG(N_REG),
        .PARAM_T(param_t),
        .DEFAULTS(defaults),
		.SELF_RESET(self_reset)
    ) parameterDecoder (
        .clk(clk),
        
        .IPIF_bus2ip_data(IPIF_Bus2IP_Data),  
        .IPIF_bus2ip_rdce(IPIF_Bus2IP_RdCE),
        .IPIF_bus2ip_resetn(IPIF_Bus2IP_resetn),
        .IPIF_bus2ip_wrce(IPIF_Bus2IP_WrCE),
        .IPIF_ip2bus_data(IPIF_IP2Bus_Data),
        .IPIF_ip2bus_rdack(IPIF_IP2Bus_RdAck),
        .IPIF_ip2bus_wrack(IPIF_IP2Bus_WrAck),
        
        .parameters_out(params_from_bus),
        .parameters_in(params_to_bus)
    );

	IPIF_clock_converter #(
		.INCLUDE_SYNCHRONIZER(INCLUDE_SYNCHRONIZER),
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG((NLINKS+1)*4),
		.PARAM_T(param_t)
	) IPIF_clock_conv (
		.IP_clk(in_clk160),
		.bus_clk(IPIF_clk),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus));
	//
	//ground unused error port
	assign IPIF_IP2Bus_Error = 0;

	typedef struct {
		logic [31:0] word_count;
		logic [31:0] err_count;
	} reg_type;

	reg_type d, q;

	assign S_AXIS_0_TREADY = 1'b1;
	assign S_AXIS_1_TREADY = 1'b1;

	always_comb begin
		d = q;

		if ((S_AXIS_0_TVALID == 1'b1) && (S_AXIS_1_TVALID == 1'b1)) begin
			d.word_count = q.word_count + 1;

		   	if (S_AXIS_0_TDATA != S_AXIS_1_TDATA) begin
				d.err_count = q.err_count + 1;
			end
		end
	end
	
	wire totalReset = aresetn && !params_out.reset;

	always_ff @(posedge clk, negedge totalReset) begin
		if (totalReset == 0) begin
			q.word_count = 0;
			q.err_count = 0;
			
			params_in <= '0;
		end else begin
			q <= d;
			
			params_in <= params_out;
		    if(params_out.latch == 1)
		    begin
		        params_in.word_count <= q.word_count;
		        params_in.err_count <= q.err_count;
	        end
		end
		
	end
endmodule
