`timescale 1ns / 1ps
/*
* This module synthesizes clocks that are nominally 320 and 40 MHz using
* direct digital synthesis (DDS) from a reference clock.
*
* DDS allows us to make fine adjustments to the frequency of the output clocks
* without causing a big phase jump, or an unlock and reset.
*
* We run a counter at 100 MHz, and increment it by a programmable amount.
* Then we use the MSB of that counter as a 20 MHz clock, which we then run
* through an MMCM to do jitter cleaning and synthesis of the 320 and 40 MHz
* clocks that we need. If we change the increment amount, then we change how
* many 100 MHz cycles it takes, on average, to overflow the counter, which
* determines the frequency of the output clocks.
*
* The formula for the increment is
*   increment = (desired frequency / 100 MHz) * 2^32
*
* 2^32 appears because we use a 32-bit counter. So, the default value, to
* produce a 20 MHz clock, is 0x33333333.
*/

module clk_DDS #(
		parameter INCLUDE_SYNCHRONIZER = 0,
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer C_S_AXI_ADDR_WIDTH = 11
	)(
		input  logic clk_ref,
		input  logic clk_ref_aresetn,

		output logic clk320,
		output logic clk40,

		output logic clk320_aresetn,
		output logic clk40_aresetn,

		input  logic                                S_AXI_ACLK,
		input  logic                                S_AXI_ARESETN,
		input  logic [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
		input  logic [2 : 0]                        S_AXI_AWPROT,
		input  logic                                S_AXI_AWVALID,
		output logic                                S_AXI_AWREADY,
		input  logic [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
		input  logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		input  logic                                S_AXI_WVALID,
		output logic                                S_AXI_WREADY,
		output logic [1 : 0]                        S_AXI_BRESP,
		output logic                                S_AXI_BVALID,
		input  logic                                S_AXI_BREADY,
		input  logic [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
		input  logic [2 : 0]                        S_AXI_ARPROT,
		input  logic                                S_AXI_ARVALID,
		output logic                                S_AXI_ARREADY,
		output logic [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA,
		output logic [1 : 0]                        S_AXI_RRESP,
		output logic                                S_AXI_RVALID,
		input  logic                                S_AXI_RREADY
	);

	// First, all of the AXI / IPIF stuff

	localparam N_REG = 4;

	logic                                  IPIF_Bus2IP_resetn;
	logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr;
	logic                                  IPIF_Bus2IP_RNW;
	logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE;
	logic [0 : 0]                          IPIF_Bus2IP_CS;
	logic [N_REG-1 : 0]                    IPIF_Bus2IP_RdCE;
	logic [N_REG-1 : 0]                    IPIF_Bus2IP_WrCE;
	logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data;
	logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data;
	logic                                  IPIF_IP2Bus_WrAck;
	logic                                  IPIF_IP2Bus_RdAck;
	logic                                  IPIF_IP2Bus_Error;

	// ground unused error bit
	assign IPIF_IP2Bus_Error = 0;

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
		// Register 3
		logic [32-1:0] rate_clk40;
		// Register 2
		logic [32-1:0] rate_clk320;
		// Register 1
		logic [32-1:0] rate_clk_ref;
		// Register 0
		logic [32-1:0] increment;
	} param_t;

	param_t params_from_IP;
	param_t params_from_bus;
	param_t params_to_IP;
	param_t params_to_bus;

	//IPIF parameters are decoded here
	IPIF_parameterDecode #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(param_t)
	) parameterDecode (
		.clk(S_AXI_ACLK),

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
		.IP_clk(clk_ref),
		.bus_clk(S_AXI_ACLK),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus));

	assign params_from_IP.increment = params_to_IP.increment;

	/////////////////////////////////////////////////
	// Clock synthesis
	
	// Do the DDS stuff
	logic [32-1:0] DDS_counter;
	(* KEEP = "TRUE" *) logic DDS_clk;
	always @(posedge clk_ref) begin
		DDS_counter <= DDS_counter + params_to_IP.increment;
	end

	// Use the MSB of the DDS counter as a clock
	BUFG bufg_DDS (.I(DDS_counter[32-1]), .O(DDS_clk));

	// Run the DDS clock through MMCM for jitter filtering and to synthesize
	// a 320 MHz clock
	logic feedback_clock;
	logic clk320_internal;
	MMCME4_ADV #(
		.CLKFBOUT_MULT_F(60), // Multiply the 20 MHz clock frequency by 60 to get 1200 MHz
		.DIVCLK_DIVIDE(1), // And don't divide, so we keep the PLL internal VCO clock at a high enough frequency
		.CLKFBOUT_PHASE(0.0),
		.CLKIN1_PERIOD(50.0), // 20 MHz clock period is 50 ns
		.IS_RST_INVERTED(1'b1),
		// CLKOUT0 should be 320 MHz
		.CLKOUT0_DIVIDE_F(3.75), // Divide 1200 MHz by 3.75 so we get 320 MHz output
			.CLKOUT0_DUTY_CYCLE(0.5),
			.CLKOUT0_PHASE(0.0),
		) PLL_inst (
		.RST(aresetn),
		.LOCKED(PLL_locked),
		.CLKIN1(DDS_clk), // 20 MHz clock in
		.CLKOUT0(clk320_internal), // 320 MHz clock out
		.CLKFBOUT(feedback_clock), // PLL feedback loop
		.CLKFBIN(feedback_clock) // PLL feedback loop
	);

	// Use BUFGCE_DIV to turn the 320 MHz clock into 40 MHz, and also buffer
	// the 320 MHz clock with BUFGCE_DIV so there isn't too much skew between
	// the 320 and 40 MHz clocks.
	BUFGCE_DIV #(.BUFGCE_DIVIDE(1)) bufgce_320 (.I(clk320_internal), .CLR(1'b0), .O(clk320), .CE(1));
	BUFGCE_DIV #(.BUFGCE_DIVIDE(8)) bufgce_40  (.I(clk320_internal), .CLR(1'b0), .O(clk40),  .CE(1));

	//////////////////////////////////////////////////
	// Clone the input reset to the output resets (with sync)
	xpm_cdc_sync_rst #(
		.DEST_SYNC_FF(2),
		.INIT(1),
		.INIT_SYNC_FF(1),
		.SIM_ASSERT_CHK(1)
	) clk320_aresetn_sync (
		.dest_rst(clk320_aresetn),
		.dest_clk(clk320),
		.src_rst(clk_ref_aresetn)
	);

	xpm_cdc_sync_rst #(
		.DEST_SYNC_FF(2),
		.INIT(1),
		.INIT_SYNC_FF(1),
		.SIM_ASSERT_CHK(1)
	) clk40_aresetn_sync (
		.dest_rst(clk40_aresetn),
		.dest_clk(clk40),
		.src_rst(clk_ref_aresetn)
	);

	//////////////////////////////////////////////////
	// clock monitoring
	clkRateTool rate_clk_ref (.reset_in(!clk_ref_aresetn), .clk_ref(clk_ref), .clk_test(clk_ref), .value(params_from_IP.rate_clk_ref));
	clkRateTool rate_clk320  (.reset_in(!clk_ref_aresetn), .clk_ref(clk_ref), .clk_test(clk320),  .value(params_from_IP.rate_clk320));
	clkRateTool rate_clk40   (.reset_in(!clk_ref_aresetn), .clk_ref(clk_ref), .clk_test(clk40),   .value(params_from_IP.rate_clk40));
endmodule
