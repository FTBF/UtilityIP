`timescale 1ns / 1ps

module Fast_Control_Fanout #(
		parameter INCLUDE_SYNCHRONIZER = 1,
		parameter integer NFANOUT = 1,
		parameter [NFANOUT-1:0] INVERT = 0,
		parameter C_S_AXI_DATA_WIDTH = 32,
		parameter C_S_AXI_ADDR_WIDTH = 13
	) (
		input  logic ext_fast_clock,
		input  logic int_fast_clock,
		input  logic sel_fast_clock,
		output logic clk_int_select,
		input  logic clk_ext_active,

		input  logic int_fast_command,
		input  logic ext_fast_command,
        
		output logic fast_command_out,

		output logic [NFANOUT-1:0] fast_clock_out_P,
		output logic [NFANOUT-1:0] fast_clock_out_N,
		output logic [NFANOUT-1:0] fast_command_out_P,
		output logic [NFANOUT-1:0] fast_command_out_N,

		input  logic aresetn,

		input logic                                S_AXI_ACLK,
		input logic                                S_AXI_ARESETN,
		input logic [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
		input logic [2 : 0]                        S_AXI_AWPROT,
		input logic                                S_AXI_AWVALID,
		output logic                               S_AXI_AWREADY,
		input logic [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
		input logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		input logic                                S_AXI_WVALID,
		output logic                               S_AXI_WREADY,
		output logic [1 : 0]                       S_AXI_BRESP,
		output logic                               S_AXI_BVALID,
		input logic                                S_AXI_BREADY,
		input logic [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
		input logic [2 : 0]                        S_AXI_ARPROT,
		input logic                                S_AXI_ARVALID,
		output logic                               S_AXI_ARREADY,
		output logic [C_S_AXI_DATA_WIDTH-1 : 0]    S_AXI_RDATA,
		output logic [1 : 0]                       S_AXI_RRESP,
		output logic                               S_AXI_RVALID,
		input logic                                S_AXI_RREADY
    );

	localparam N_REG = 2;

	logic                                  IPIF_Bus2IP_resetn;
	logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr;
	logic                                  IPIF_Bus2IP_RNW;
	logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE;     //unused
	logic [0 : 0]                          IPIF_Bus2IP_CS;     //unused
	logic [N_REG-1 : 0]                    IPIF_Bus2IP_RdCE; 
	logic [N_REG-1 : 0]                    IPIF_Bus2IP_WrCE;
	logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data;
	logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data;
	logic                                  IPIF_IP2Bus_WrAck;
	logic                                  IPIF_IP2Bus_RdAck;
	logic                                  IPIF_IP2Bus_Error;

	assign IPIF_IP2Bus_Error = 1'b0;

	axi_to_ipif_mux #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
		.N_CHIP(1),
		.N_REG(N_REG),
		.MUX_BY_CHIP(0)
	) axi_ipif (
		.S_AXI_ACLK(S_AXI_ACLK),
		.S_AXI_ARESETN(S_AXI_ARESETN),
		.S_AXI_AWADDR(S_AXI_AWADDR),
		.S_AXI_AWVALID(S_AXI_AWVALID),
		.S_AXI_AWREADY(S_AXI_AWREADY),
		.S_AXI_WDATA(S_AXI_WDATA),
		.S_AXI_WSTRB(S_AXI_WSTRB),
		.S_AXI_WVALID(S_AXI_WVALID),
		.S_AXI_WREADY(S_AXI_WREADY),
		.S_AXI_BRESP(S_AXI_BRESP),
		.S_AXI_BVALID(S_AXI_BVALID),
		.S_AXI_BREADY(S_AXI_BREADY),
		.S_AXI_ARADDR(S_AXI_ARADDR),
		.S_AXI_ARVALID(S_AXI_ARVALID),
		.S_AXI_ARREADY(S_AXI_ARREADY),
		.S_AXI_RDATA(S_AXI_RDATA),
		.S_AXI_RRESP(S_AXI_RRESP),
		.S_AXI_RVALID(S_AXI_RVALID),
		.S_AXI_RREADY(S_AXI_RREADY),
		.IPIF_Bus2IP_resetn(IPIF_Bus2IP_resetn),
		.IPIF_Bus2IP_Addr(IPIF_Bus2IP_Addr),
		.IPIF_Bus2IP_RNW(IPIF_Bus2IP_RNW),
		.IPIF_Bus2IP_BE(IPIF_Bus2IP_BE),
		.IPIF_Bus2IP_CS(IPIF_Bus2IP_CS),
		.IPIF_Bus2IP_RdCE(IPIF_Bus2IP_RdCE),
		.IPIF_Bus2IP_WrCE(IPIF_Bus2IP_WrCE),
		.IPIF_Bus2IP_Data(IPIF_Bus2IP_Data),
		.IPIF_IP2Bus_Data(IPIF_IP2Bus_Data),
		.IPIF_IP2Bus_WrAck(IPIF_IP2Bus_WrAck),
		.IPIF_IP2Bus_RdAck(IPIF_IP2Bus_RdAck),
		.IPIF_IP2Bus_Error(IPIF_IP2Bus_Error)
	);
    
	typedef struct packed {
		// register 1
		logic [32-3-1:0] padding1;
		logic clk_ext_active;
		logic FC_int_select;
		logic clk_int_select;
		// register 0
		logic [32-2-1:0] padding0;
		logic Polarity;
		logic EdgeSel;
	} param_t;

	param_t params_from_IP;
	param_t params_from_bus;
	param_t params_to_IP;
	param_t params_to_bus;

    //IPIF parameters are decoded here
    IPIF_parameterDecode #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .N_REG(2),
        .PARAM_T(param_t)
    ) parameterDecode (
        .clk(S_AXI_ACLK),

        //ipif configuration interface ports
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
        .N_REG(2),
        .PARAM_T(param_t)
    ) IPIF_clock_conv (
        .IP_clk(sel_fast_clock),
        .bus_clk(S_AXI_ACLK),
        .params_from_IP(params_from_IP),
        .params_from_bus(params_from_bus),
        .params_to_IP(params_to_IP),
        .params_to_bus(params_to_bus)
	);

	always_comb begin
		params_from_IP = params_to_IP;
		params_from_IP.padding0 = '0;
		params_from_IP.padding1 = '0;
		params_from_IP.clk_ext_active = clk_ext_active;

		clk_int_select = params_to_IP.clk_int_select;
	end

    // sync the internal fast commands to the selected clock 
	logic FC_from_int;
	logic FC_from_ext;
	xpm_cdc_single #(
	   .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
	   .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
	   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	   .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
	)
	FC_from_int_CDC (
	   .src_clk(int_fast_clock),  // 1-bit input: optional; required when SRC_INPUT_REG = 1
	   .src_in(int_fast_command), // 1-bit input: Input signal to be synchronized to dest_clk domain.
	   .dest_clk(sel_fast_clock), // 1-bit input: Clock signal for the destination clock domain.
	   .dest_out(FC_from_int)     // 1-bit output: src_in synchronized to the destination clock domain. This output is
	);

	logic command_rx320_rise, command_rx320_fall;
	IDDRE1 #(
		.DDR_CLK_EDGE("SAME_EDGE"),
		.IS_C_INVERTED(1'b0),
		.IS_CB_INVERTED(1'b1)
	) IDDRE1_inst (
		.Q1(command_rx320_rise),
		.Q2(command_rx320_fall),
		.C(sel_fast_clock),
		.CB(sel_fast_clock),
		.D(ext_fast_command),
		.R(!aresetn)
	);
	assign FC_from_ext = (params_to_IP.EdgeSel ? command_rx320_fall : command_rx320_rise);

	logic FC_select;
	always @(posedge sel_fast_clock)
		FC_select <= (~clk_ext_active || params_to_IP.FC_int_select);

	logic FC_sel;
	assign FC_sel = (FC_select ? FC_from_int : FC_from_ext);

	assign fast_command_out = (params_to_IP.Polarity ? ~FC_sel : FC_sel);
    
    generate
        genvar i;
        for(i = 0; i < (NFANOUT?NFANOUT:1); i += 1)  begin
        
           logic clock;
           logic command;
           
           ODDRE1 #(
              .IS_C_INVERTED(1'b0),      // Optional inversion for C
              .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
              .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
              .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                         // ULTRASCALE_PLUS_ES2)
              .SRVAL(1'b0)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
           )
           ODDRE1_clock (
              .Q(clock),   // 1-bit output: Data output to IOB
              .C(sel_fast_clock),   // 1-bit input: High-speed clock input
              .D1(0), // 1-bit input: Parallel data input 1
              .D2(1), // 1-bit input: Parallel data input 2
              .SR(!aresetn)  // 1-bit input: Active High Async Reset
           );

           OBUFDS OBUFDS_clockt (
              .O(fast_clock_out_P[i]),   // 1-bit output: Diff_p output (connect directly to top-level port)
              .OB(fast_clock_out_N[i]), // 1-bit output: Diff_n output (connect directly to top-level port)
              .I(clock)    // 1-bit input: Buffer input
           );
           
           ODDRE1 #(
              .IS_C_INVERTED(1'b0),      // Optional inversion for C
              .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
              .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
              .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                         // ULTRASCALE_PLUS_ES2)
              .SRVAL(1'b0)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
           )
           ODDRE1_inst (
              .Q(command),   // 1-bit output: Data output to IOB
              .C(sel_fast_clock),   // 1-bit input: High-speed clock input
              .D1((INVERT[i])?(!fast_command_out):(fast_command_out)), // 1-bit input: Parallel data input 1
              .D2((INVERT[i])?(!fast_command_out):(fast_command_out)), // 1-bit input: Parallel data input 2
              .SR(!aresetn)  // 1-bit input: Active High Async Reset
           );

           OBUFDS OBUFDS_inst (
              .O(fast_command_out_P[i]),   // 1-bit output: Diff_p output (connect directly to top-level port)
              .OB(fast_command_out_N[i]), // 1-bit output: Diff_n output (connect directly to top-level port)
              .I(command)    // 1-bit input: Buffer input
           );
           
        end
    endgenerate
endmodule
