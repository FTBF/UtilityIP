`timescale 1ns / 1ps
/*
* This module synthesizes clocks that are nominally 320 and 40 MHz using
* direct digital synthesis (DDS) from a reference clock.
*
* DDS allows us to make fine adjustments to the frequency of the output clocks
* without causing a big phase jump, or an unlock and reset.
*
* We run a counter at 600 MHz, and increment it by a programmable amount.
* Then we use the MSB of that counter as a 12 MHz clock, which we then run
* through an MMCM to do jitter cleaning and synthesis of the 320 and 40 MHz
* clocks that we need. If we change the increment amount, then we change how
* many 600 MHz cycles it takes, on average, to overflow the counter, which
* determines the frequency of the output clocks.
*
* The formula for the increment is
*   increment = (desired frequency / 600 MHz) * 2^32
*
* 2^32 appears because we use a 32-bit counter. So, the default value, to
* produce a 12 MHz clock, is 0x051eb852.
*/

module clk_DDS #(
		parameter INCLUDE_SYNCHRONIZER = 0,
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer C_S_AXI_ADDR_WIDTH = 11
	)(
		input  logic clk_ref,
		input  logic clk_ref_aresetn,

		(* KEEP = "TRUE" *) output logic clk320,
		output logic clk40,

		output logic clk320_aresetn,
		output logic clk40_aresetn,

		output logic PLL_locked,

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

	localparam param_t defaults = '{default:'0, increment:32'h051eb852};

	param_t params_from_IP;
	param_t params_from_bus;
	param_t params_to_IP;
	param_t params_to_bus;

	//IPIF parameters are decoded here
	IPIF_parameterDecode #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(param_t),
		.DEFAULTS(defaults)
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
	// First, make a high-frequency clock from the 100 MHz clock
	
	logic feedback_clock_600;
	logic clk600, clk600_unbuffered;
	logic locked600;
	PLLE4_ADV #(
		.CLKFBOUT_MULT(12),         // Multiply 100 MHz input clock by 12 to get 1200 MHz VCO clock
		.CLKIN_PERIOD(10),          // 100 MHz input clock has a period of 10 ns
		.CLKOUT0_DIVIDE(2),         // Divide 1200 MHz VCO clock by 2 to get 600 MHz
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE(0.0),
		.DIVCLK_DIVIDE(1),
		.IS_RST_INVERTED(1'b1)
	) PLL600_inst (
		.RST(clk_ref_aresetn),
		.LOCKED(locked600),
		.CLKIN(clk_ref),
		.CLKOUT0(clk600_unbuffered),
		.CLKFBOUT(feedback_clock_600),
		.CLKFBIN(feedback_clock_600)
	);
	BUFG bufg600 (.I(clk600_unbuffered), .O(clk600));

	/////////////////////////////////////////////////
	// Clock synthesis
	
	// Do the DDS stuff
	logic [32-1:0] DDS_counter;
	(* KEEP = "TRUE" *) logic DDS_clk;
	always @(posedge clk600) begin
		DDS_counter <= DDS_counter + params_to_IP.increment;
	end

	// Use the MSB of the DDS counter as a clock
	BUFG bufg_DDS (.I(DDS_counter[32-1]), .O(DDS_clk));

	// Run the DDS clock through MMCM for jitter filtering and to synthesize
	// a 320 MHz clock
	logic feedback_clock_0, feedback_clock_1;
	logic clk320_noisy, clk_320_noisy_buffered, clk320_internal;
	logic PLL_locked_0, PLL_locked_1;
	MMCME4_ADV #(
		.BANDWIDTH("LOW"),
		.REF_JITTER1(0.02), // The jitter in our 12 MHz "clock" is 1 period of the 600 MHz clock, which is 2% of a unit interval, or about 1600 ps.
		.CLKFBOUT_MULT_F(100), // Multiply the 12 MHz clock frequency by 100 to get 1200 MHz VCO
		.DIVCLK_DIVIDE(1),
		.CLKFBOUT_PHASE(0.0),
		.CLKIN1_PERIOD(83.333), // 12 MHz clock period is 83.333 ns
		.IS_RST_INVERTED(1'b1),
		// CLKOUT0 should be 320 MHz
		.CLKOUT0_DIVIDE_F(3.75), // Divide 1200 MHz by 3.75 so we get 320 MHz output
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE(0.0)
	) MMCM_inst (
		.RST(clk_ref_aresetn),
		.LOCKED(PLL_locked_0),
		.CLKIN1(DDS_clk), // 12 MHz clock in
		.CLKOUT0(clk320_noisy), // 320 MHz clock out
		.CLKFBOUT(feedback_clock_0), // PLL feedback loop
		.CLKFBIN(feedback_clock_0) // PLL feedback loop
	);

	BUFG bufg_clk320_noisy (.I(clk320_noisy), .O(clk320_noisy_buffered));

	// The clock coming from the MMCM is still too noisy/jittery, so we'll run
	// it through a second PLL to clean it more.  According to the Vivado
	// clocking wizard, the MMCM output will have a jitter of 600 to 1200 ps,
	// and the PLL will then have a jitter of 200 to 300 ps.
	PLLE4_ADV #(
		.CLKFBOUT_MULT(3),          // Multiply 320 MHz input clock by 3 to get 960 MHz
		.CLKIN_PERIOD(3.125),       // 320 MHz input clock has a period of 3.125 ns
		.CLKOUT0_DIVIDE(3),         // Divide amount for CLKOUT0
		.CLKOUT0_DUTY_CYCLE(0.5),   // Duty cycle for CLKOUT0
		.CLKOUT0_PHASE(0.0),        // Phase offset for CLKOUT0
		.COMPENSATION("AUTO"),      // Clock input compensation
		.DIVCLK_DIVIDE(1),          // Master division value
		.IS_RST_INVERTED(1'b1),     // Optional inversion for RST
		.REF_JITTER(0.064)          // According to the Vivado clocking wizard, the first MMCM output will have a jitter of 200 ps, which is 0.064 of a 320 MHz cycle
	) PLL_inst (
		.RST(clk_ref_aresetn),
		.LOCKED(PLL_locked_1),
		.CLKIN(clk320_noisy_buffered),
		.CLKOUT0(clk320_internal),
		.CLKFBOUT(feedback_clock_1),
		.CLKFBIN(feedback_clock_1)
	);

	assign PLL_locked = PLL_locked_0 & PLL_locked_1;

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
	) clk40_aresetn_sync (
		.dest_rst(clk40_aresetn),
		.dest_clk(clk40),
		.src_rst(clk_ref_aresetn)
	);

	// Make the 320 reset follow the 40 reset so we have a constant phase of
	// reset release relative to clk40
	xpm_cdc_sync_rst #(
		.DEST_SYNC_FF(2),
		.INIT(1),
		.INIT_SYNC_FF(1),
		.SIM_ASSERT_CHK(1)
	) clk320_aresetn_sync (
		.dest_rst(clk320_aresetn),
		.dest_clk(clk320),
		.src_rst(clk40_aresetn)
	);

	//////////////////////////////////////////////////
	// clock monitoring
	clkRateTool rate_clk_ref (.reset_in(!clk_ref_aresetn), .clk_ref(clk_ref), .clk_test(clk_ref), .value(params_from_IP.rate_clk_ref));
	clkRateTool rate_clk320  (.reset_in(!clk_ref_aresetn), .clk_ref(clk_ref), .clk_test(clk320),  .value(params_from_IP.rate_clk320));
	clkRateTool rate_clk40   (.reset_in(!clk_ref_aresetn), .clk_ref(clk_ref), .clk_test(clk40),   .value(params_from_IP.rate_clk40));
endmodule
