`timescale 1ns / 1ps

module clk_mux #(
        parameter INPUTFREQ = 40,
        parameter USE_AXI = 0,
        parameter integer C_S_AXI_DATA_WIDTH = 32,
        parameter integer C_S_AXI_ADDR_WIDTH = 11
    )(
        input wire clk_ext,
        input wire clk_int,

        input wire clk_int_select,

        output wire clk320_out,
        output wire clk40_out,
        output wire locked,
        output wire clk_ext_active,

        input wire aresetn,

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
		logic [24-1:0] clk40_ext_rate;
        // Register 2
        logic [32-1-1:0] padding2;
        logic locked;
        // Register 1
        logic [32-1-1:0] padding1;
        logic clk_ext_active;
        // Register 0
        logic [32-1-1:0] padding0;
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
		.bus_clk(IPIF_clk),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus));

	logic clk40_ext_stopped;
	logic [24-1:0] clk40_ext_rate;
	logic locked_sync;

	xpm_cdc_async_rst #(
		.DEST_SYNC_FF(2),
		.INIT_SYNC_FF(1),
		.RST_ACTIVE_HIGH(0)
	) locked_CDC (
		.dest_arst(locked_sync),
		.dest_clk(clk_int),
		.src_arst(locked)
	);

    always_comb begin
        params_from_IP = params_to_IP;
        params_from_IP.padding0 = '0;
        params_from_IP.padding1 = '0;
        params_from_IP.padding2 = '0;
        params_from_IP.padding3 = '0;
		params_from_IP.clk40_ext_rate = clk40_ext_rate;
        params_from_IP.clk_ext_active = !clk40_ext_stopped;
        params_from_IP.locked = locked_sync;
    end

    // Clock mux logic begins here

	// First, we will take clk_int (100 MHz) and run it through a PLL to
	// produce a 40 MHz clock.  We use a PLL instead of an MMCM because they
	// are a more plentiful resource, and we don't need the MMCM's
	// capabilities for this purpose.
	//
	// clk_ext is either 40 MHz or 320 MHz.  If it's 40 MHz, we don't need to
	// do anything.  If it's 320 MHz, then run it through a BUFGCE_DIV to
	// produce 40 MHz.
	//
	// Then we have two 40 MHz clocks.  We can use them as the CLKIN1 and
	// CLKIN0 inputs to an MMCM.
	//
	// We will also run clk_ext into a clkStopTool instance to both measure
	// its frequency and to detect when it has stopped.  When clk_ext has
	// stopped or clk_int is selected, we will use clk_int.  Whenever we
	// switch the clock, we will reset the MMCM

	logic clk40_int;
	logic PLL_clkfbout, PLL_clkfbin;
	logic PLL_locked;
	PLLE4_BASE #(
		.CLKFBOUT_MULT(8),
		.CLKFBOUT_PHASE(0.0),
		.CLKIN_PERIOD(10.0),
		.CLKOUT0_DIVIDE(20),
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE(0.0),
		.DIVCLK_DIVIDE(1),
		.REF_JITTER(0.010),
		.IS_RST_INVERTED(1),
		.STARTUP_WAIT("FALSE")
	) clk_int_PLL_100_to_40_MHz (
		.CLKFBOUT(PLL_clkfbout),
		.CLKOUT0(clk40_int),
		.LOCKED(PLL_locked),
		.CLKFBIN(PLL_clkfbin),
		.CLKIN(clk_int),
		.CLKOUTPHYEN(1'b0),
		.PWRDWN(1'b0),
		.RST(aresetn)
	);

	BUFG PLL_fb_bufg (.I(PLL_clkfbout), .O(PLL_clkfbin));

	logic clk40_ext;
	generate
	if (INPUTFREQ == 40) begin
		assign clk40_ext = clk_ext;
	end else begin
		BUFGCE_DIV #(
			.BUFGCE_DIVIDE(8),
			.SIM_DEVICE("ULTRASCALE_PLUS")
		) divider_320_to_40 (
			.I(clk_ext),
			.CE(1'b1),
			.CLR(1'b0),
			.O(clk40_ext)
		);
	end
	endgenerate

	clkStopTool #(
		.CLK_REF_RATE_HZ(100000000), // 100 MHz reference clock
		.CLK_TEST_RATE_HZ(40000000), //  40 MHz test clock
		.TOLERANCE_HZ     (1000000), //   1 MHz tolerance
		.MEASURE_PERIOD_s(0.001),     // Measure every 1 ms
		.MEASURE_TIME_s  (0.000125)  // Spend 1/8th ms measuring
	) clk_ext_stopped (
		.reset_in(!aresetn),
		.clk_ref(clk_int),
		.clk_test(clk40_ext),
		.value(clk40_ext_rate),
		.stopped(clk40_ext_stopped)
	);


	logic mmcm_clk_sel, mmcm_clk_sel_delay;
	logic mmcm_reset;
	always_comb begin
		// Use the external clock unless
		// (a) it is not running, or
		// (b) the internal clock is selected by the user
		if (USE_AXI == 1) begin
			mmcm_clk_sel = !clk40_ext_stopped && !params_to_IP.clk_int_select;
		end else begin
			mmcm_clk_sel = !clk40_ext_stopped && !clk_int_select;
		end

		// Reset the MMCM whenever mmcm_clk_sel changes, or when we have an
		// external reset signal
		mmcm_reset = (mmcm_clk_sel ^ mmcm_clk_sel_delay) || !aresetn;
	end

	always_ff @(posedge clk_int) begin
		mmcm_clk_sel_delay <= mmcm_clk_sel;
	end

	logic clkfbout, clkfbin;
	logic clk40_mmcm, clk320_mmcm;
	MMCME4_ADV #(
		.BANDWIDTH            ("OPTIMIZED"),
		.CLKOUT4_CASCADE      ("FALSE"),
		.COMPENSATION         ("AUTO"),
		.STARTUP_WAIT         ("FALSE"),
		.DIVCLK_DIVIDE        (1),
		.CLKFBOUT_MULT_F      (32.000),
		.CLKFBOUT_PHASE       (0.000),
		.CLKFBOUT_USE_FINE_PS ("FALSE"),
		.CLKOUT0_DIVIDE_F     (32.000),
		.CLKOUT0_PHASE        (0.000),
		.CLKOUT0_DUTY_CYCLE   (0.500),
		.CLKOUT0_USE_FINE_PS  ("FALSE"),
		.CLKOUT1_DIVIDE       (4),
		.CLKOUT1_PHASE        (0.000),
		.CLKOUT1_DUTY_CYCLE   (0.500),
		.CLKOUT1_USE_FINE_PS  ("FALSE"),
		.CLKIN1_PERIOD        (25.000),
		.CLKIN2_PERIOD        (25.0)
	) mmcme4_adv_inst (
		.CLKFBOUT            (clkfbout),
		.CLKOUT0             (clk40_mmcm),
		.CLKOUT1             (clk320_mmcm),
		.CLKFBIN             (clkfbin),
		.CLKIN1              (clk40_ext),
		.CLKIN2              (clk40_int),
		.CLKINSEL            (mmcm_clk_sel),
		.DADDR               (7'h0),
		.DCLK                (1'b0),
		.DEN                 (1'b0),
		.DI                  (16'h0),
		.DWE                 (1'b0),
		.CDDCREQ             (1'b0),
		.PSCLK               (1'b0),
		.PSEN                (1'b0),
		.PSINCDEC            (1'b0),
		.LOCKED              (locked),
		.PWRDWN              (1'b0),
		.RST                 (mmcm_reset)
	);

	BUFG mmcm_fb_bufg (.O(clkfbin), .I(clkfbout));

	BUFGCE_DIV #(
		.BUFGCE_DIVIDE(1)
	) clk40_buf (
		.I(clk40_mmcm),
		.CE(1'b1),
		.CLR(1'b0),
		.O(clk40_out)
	);

	BUFGCE_DIV #(
		.BUFGCE_DIVIDE(1)
	) clk320_buf (
		.I(clk320_mmcm),
		.CE(1'b1),
		.CLR(1'b0),
		.O(clk320_out)
	);
endmodule
