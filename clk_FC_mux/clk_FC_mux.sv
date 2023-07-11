`timescale 1ns / 1ps

module clk_FC_mux #(
        parameter integer C_S_AXI_DATA_WIDTH = 32,
        parameter integer C_S_AXI_ADDR_WIDTH = 11
    )(
        input  logic clk_ext,
        input  logic clk_int,

		input  logic FC_ext,
		input  logic FC_int,

        output logic clk320_out,
		output logic FC_out,

        input  logic aresetn,

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

	// Maybe add clk_mon stuff in here?
    typedef struct packed {
        // Register 3
        logic [32-24-1:0] padding3;
		logic [24-1:0] clk_ext_rate;
        // Register 2
        logic [32-1-1:0] padding2;
        logic clk_ext_active;
        // Register 1
        logic [32-2-1:0] padding1;
		logic FC_invert;
		logic FC_edgesel;
        // Register 0
        logic [32-2-1:0] padding0;
		logic FC_int_select;
        logic clk_int_select;
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
		.INCLUDE_SYNCHRONIZER(1),
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(param_t)
	) IPIF_clock_conv (
		.IP_clk(clk_int),
		.bus_clk(S_AXI_ACLK),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus));

	logic clk_ext_stopped;
	logic [24-1:0] clk_ext_rate;

    always_comb begin
        params_from_IP = params_to_IP;
        params_from_IP.padding0 = '0;
        params_from_IP.padding1 = '0;
        params_from_IP.padding2 = '0;
        params_from_IP.padding3 = '0;
		params_from_IP.clk_ext_rate = clk_ext_rate;
        params_from_IP.clk_ext_active = !clk_ext_stopped;
    end

    // Clock mux logic begins here

	// The internal and external clocks are both 320 MHz fast command clocks,
	// so we don't need any PLL or MMCM here, just a BUFGCTRL.
	//
	// We run clk_ext into a clkStopTool instance to both measure its
	// frequency and to detect when it has stopped.  When clk_ext has stopped
	// or clk_int is selected, we will use clk_int.  When clk_ext has stopped,
	// we will assert the IGNORE1 input to the BUFGCTRL, so that we are able
	// to switch away from it even without a high-to-low transition.

	clkStopTool #(
		.CLK_REF_RATE_HZ (320000000), // 320 MHz reference clock
		.CLK_TEST_RATE_HZ(320000000), // 320 MHz test clock
		.TOLERANCE_HZ      (1000000), //   1 MHz tolerance
		.MEASURE_PERIOD_s(0.008),     // Measure every 8 ms
		.MEASURE_TIME_s  (0.001)      // Spend 1 ms measuring
	) clk_ext_stopped_checker (
		.reset_in(!aresetn),
		.clk_ref(clk_int),
		.clk_test(clk_ext),
		.value(clk_ext_rate),
		.stopped(clk_ext_stopped)
	);

	logic clk_int_sel;
	always_comb begin
		// Use the external clock unless
		// (a) it is not running, or
		// (b) the internal clock is selected by the user
		clk_int_sel = clk_ext_stopped || params_to_IP.clk_int_select;
	end

	BUFGCTRL #(
		.INIT_OUT(0),
		.PRESELECT_I0("TRUE"),      .PRESELECT_I1("FALSE"),
		.IS_CE0_INVERTED(1'b0),     .IS_CE1_INVERTED(1'b0),
		.IS_I0_INVERTED(1'b0),      .IS_I1_INVERTED(1'b0),
		.IS_IGNORE0_INVERTED(1'b0), .IS_IGNORE1_INVERTED(1'b0),
		.IS_S0_INVERTED(1'b0),      .IS_S1_INVERTED(1'b0),
		.SIM_DEVICE("ULTRASCALE_PLUS")
	) BUFGCTRL_inst (
		.O(clk320_out),
		.CE0(1'b1),
		.CE1(1'b1),
		.I0(clk_int),
		.I1(clk_ext),
		.IGNORE0(1'b0),
		.IGNORE1(clk_ext_stopped),
		.S0(clk_int_sel),
		.S1(!clk_int_sel)
	);

	// Now, we need to select the appropriate fast command input, and
	// synchronize it to the output 320 MHz clock

	// First, we synchronize the internal fast command data to the selected
	// 320 MHz clock
	logic FC_from_int;
	xpm_cdc_single #(
	   .DEST_SYNC_FF(2),
	   .INIT_SYNC_FF(1),
	   .SIM_ASSERT_CHK(0),
	   .SRC_INPUT_REG(1)
	) FC_from_int_CDC (
	   .src_clk(clk_int),
	   .src_in(FC_int),
	   .dest_clk(clk320_out),
	   .dest_out(FC_from_int)
	);

	// Use a DDR input register to capture the external FC data stream on
	// either the rising or falling edge of the selected 320 MHz clock
	logic command_rx320_rise, command_rx320_fall;
	IDDRE1 #(
		.DDR_CLK_EDGE("SAME_EDGE"),
		.IS_C_INVERTED(1'b0),
		.IS_CB_INVERTED(1'b1)
	) IDDRE1_inst (
		.Q1(command_rx320_rise),
		.Q2(command_rx320_fall),
		.C(clk320_out),
		.CB(clk320_out),
		.D(FC_ext),
		.R(!aresetn)
	);

	logic FC_from_ext, FC_temp;
	always_comb begin
		// Pick the rising or falling edge
		if (params_to_IP.FC_edgesel == 1'b1) begin
			FC_temp = command_rx320_fall;
		end else begin
			FC_temp = command_rx320_rise;
		end

		// Optionally invert the fast command data
		if (params_to_IP.FC_invert == 1'b1) begin
			FC_from_ext = !FC_temp;
		end else begin
			FC_from_ext = FC_temp;
		end

		// Send whichever fast command data stream we selected to the output
		if (params_to_IP.FC_int_select == 1'b1) begin
			FC_out = FC_from_int;
		end else begin
			FC_out = FC_from_ext;
		end
	end
endmodule
