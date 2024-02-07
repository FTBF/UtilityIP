`default_nettype none
module random_errors #(
        parameter integer C_S_AXI_DATA_WIDTH = 32,
        parameter integer C_S_AXI_ADDR_WIDTH = 11,
		parameter INCLUDE_AXI_SYNC = 1,
		parameter integer WIDTH = 32,
		parameter AXI_STREAM = 1
    )(
		input  wire  clk,
		input  wire  aresetn,
		
		input  wire  fc_BunchCountReset,
		input  wire  fc_OrbitCountReset,
		input  wire  fc_L1A,
		input  wire  fc_NonZeroSuppress,
		input  wire  fc_CalibrationReq_int,
		input  wire  fc_CalibrationReq_ext,
		input  wire  fc_ChipSync,
		input  wire  fc_EventBufferReset,
		input  wire  fc_EventCountReset,
		input  wire  fc_LinkReset_ROCt,
		input  wire  fc_LinkReset_ROCd,
		input  wire  fc_LinkReset_ECONt,
		input  wire  fc_LinkReset_ECONd,
		input  wire  fc_SPARE_0,
		input  wire  fc_SPARE_1,
		input  wire  fc_SPARE_2,
		input  wire  fc_SPARE_3,
		input  wire  fc_SPARE_4,
		input  wire  fc_SPARE_5,
		input  wire  fc_SPARE_6,
		input  wire  fc_SPARE_7,

		output logic [WIDTH-1:0] error_bits,

		input  wire  [WIDTH-1:0] S_AXIS_TDATA,
		input  wire  S_AXIS_TVALID,
		output logic S_AXIS_TREADY,

		output logic [WIDTH-1:0] M_AXIS_TDATA,
		output logic M_AXIS_TVALID,
		input  wire  M_AXIS_TREADY,

        input  wire                                 S_AXI_ACLK,
        input  wire                                 S_AXI_ARESETN,
        input  wire  [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
        input  wire  [2 : 0]                        S_AXI_AWPROT,
        input  wire                                 S_AXI_AWVALID,
        output logic                                S_AXI_AWREADY,
        input  wire  [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
        input  wire  [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
        input  wire                                 S_AXI_WVALID,
        output logic                                S_AXI_WREADY,
        output logic [1 : 0]                        S_AXI_BRESP,
        output logic                                S_AXI_BVALID,
        input  wire                                 S_AXI_BREADY,
        input  wire  [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
        input  wire  [2 : 0]                        S_AXI_ARPROT,
        input  wire                                 S_AXI_ARVALID,
        output logic                                S_AXI_ARREADY,
        output logic [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA,
        output logic [1 : 0]                        S_AXI_RRESP,
        output logic                                S_AXI_RVALID,
        input  wire                                 S_AXI_RREADY
    );

    // First, all of the AXI / IPIF stuff

    localparam N_REG = 8;

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
		// Registers 7
		logic [32-1:0] WIDTH_DENOMINATOR;
		// Register 6
		logic [32-1:0] WIDTH;
        // Register 5
		logic [32-1:0] random_error_seed;
        // Register 4
		logic [32-1:0] bit_select_seed;
        // Register 3
        logic [32-1-1:0] padding3;
		logic reset;
        // Register 2
        logic [32-21-1:0] padding2;
		logic reset_on_SPARE_7;
		logic reset_on_SPARE_6;
		logic reset_on_SPARE_5;
		logic reset_on_SPARE_4;
		logic reset_on_SPARE_3;
		logic reset_on_SPARE_2;
		logic reset_on_SPARE_1;
		logic reset_on_SPARE_0;
		logic reset_on_LinkReset_ECONd;
		logic reset_on_LinkReset_ECONt;
		logic reset_on_LinkReset_ROCd;
		logic reset_on_LinkReset_ROCt;
		logic reset_on_EventCountReset;
		logic reset_on_EventBufferReset;
		logic reset_on_ChipSync;
		logic reset_on_CalibrationReq_ext;
		logic reset_on_CalibrationReq_int;
		logic reset_on_NonZeroSuppress;
		logic reset_on_L1A;
		logic reset_on_OrbitCountReset;
		logic reset_on_BunchCountReset;
		// Register 1
		logic [32-1-1:0] padding1;
		logic enable;
		// Register 0
		logic [32-1:0] random_error_threshold;
    } param_t;

	localparam param_t defaults = '{default:'0, random_error_seed:32'hffffffff, bit_select_seed:32'hffffffff};
	localparam param_t self_reset = '{default:'0, reset: 1'b1};

    param_t params_from_IP;
    param_t params_from_bus;
    param_t params_to_IP;
    param_t params_to_bus;

    //IPIF parameters are decoded here
    IPIF_parameterDecode #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
		.USE_ONEHOT_READ(1),
        .N_REG(N_REG),
        .PARAM_T(param_t),
		.DEFAULTS(defaults),
		.SELF_RESET(self_reset)
    ) parameterDecode (
        .clk(S_AXI_ACLK),

		.IPIF_bus2ip_addr(IPIF_Bus2IP_Addr),
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
		.IP_clk(clk),
		.bus_clk(S_AXI_ACLK),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus));

    always_comb begin
        params_from_IP = params_to_IP;
        params_from_IP.padding1 = '0;
        params_from_IP.padding2 = '0;
        params_from_IP.padding3 = '0;
		params_from_IP.WIDTH = WIDTH;
		params_from_IP.WIDTH_DENOMINATOR = 2**$clog2(WIDTH);
    end

	typedef struct {
		logic [32-1:0] bit_select_LFSR;
		logic [32-1:0] random_error_LFSR;
		logic [2**($clog2(WIDTH))-1:0] error_bits;
	} reg_type;

	localparam reg_type reg_reset = {default: '0, bit_select_LFSR: '1, random_error_LFSR: '1};
	reg_type D, Q;

	localparam logic [32-1:0] random_error_polynomial = 32'h41000000;
	localparam logic [32-1:0] bit_select_polynomial = 32'h48000000;

	logic do_error;
	logic advance;
	logic reset_LFSRs;

	always_comb begin
		D = Q;

		if (AXI_STREAM) begin
			advance = S_AXIS_TVALID && M_AXIS_TREADY;
		end else begin
			advance = 1'b1;
		end

		reset_LFSRs = (
			params_to_IP.reset ||
			(fc_BunchCountReset    && params_to_IP.reset_on_BunchCountReset)    ||
			(fc_OrbitCountReset    && params_to_IP.reset_on_OrbitCountReset)    ||
			(fc_L1A                && params_to_IP.reset_on_L1A)                ||
			(fc_NonZeroSuppress    && params_to_IP.reset_on_NonZeroSuppress)    ||
			(fc_CalibrationReq_int && params_to_IP.reset_on_CalibrationReq_int) ||
			(fc_CalibrationReq_ext && params_to_IP.reset_on_CalibrationReq_ext) ||
			(fc_ChipSync           && params_to_IP.reset_on_ChipSync)           ||
			(fc_EventBufferReset   && params_to_IP.reset_on_EventBufferReset)   ||
			(fc_EventCountReset    && params_to_IP.reset_on_EventCountReset)    ||
			(fc_LinkReset_ROCt     && params_to_IP.reset_on_LinkReset_ROCt)     ||
			(fc_LinkReset_ROCd     && params_to_IP.reset_on_LinkReset_ROCd)     ||
			(fc_LinkReset_ECONt    && params_to_IP.reset_on_LinkReset_ECONt)    ||
			(fc_LinkReset_ECONd    && params_to_IP.reset_on_LinkReset_ECONd)    ||
			(fc_SPARE_0            && params_to_IP.reset_on_SPARE_0)            ||
			(fc_SPARE_1            && params_to_IP.reset_on_SPARE_1)            ||
			(fc_SPARE_2            && params_to_IP.reset_on_SPARE_2)            ||
			(fc_SPARE_3            && params_to_IP.reset_on_SPARE_3)            ||
			(fc_SPARE_4            && params_to_IP.reset_on_SPARE_4)            ||
			(fc_SPARE_5            && params_to_IP.reset_on_SPARE_5)            ||
			(fc_SPARE_6            && params_to_IP.reset_on_SPARE_6)            ||
			(fc_SPARE_7            && params_to_IP.reset_on_SPARE_7)
		);

		if (advance) begin
			for (int i = 0; i < $clog2(WIDTH); i++) begin
				D.bit_select_LFSR = {D.bit_select_LFSR[0 +: 32-1], ^(D.bit_select_LFSR & bit_select_polynomial)};
			end

			for (int i = 0; i < 32; i++) begin
				D.random_error_LFSR = {D.random_error_LFSR[0 +: 32-1], ^(D.random_error_LFSR & random_error_polynomial)};
			end
		end else if (reset_LFSRs) begin
			D.bit_select_LFSR = params_to_IP.bit_select_seed;
			D.random_error_LFSR = params_to_IP.random_error_seed;
		end

		do_error = params_to_IP.enable && (Q.random_error_LFSR < params_to_IP.random_error_threshold);

		D.error_bits = '0;
		D.error_bits[Q.bit_select_LFSR[0 +: $clog2(WIDTH)]] = do_error;

		error_bits = Q.error_bits[0 +: WIDTH];

		M_AXIS_TDATA = (S_AXIS_TDATA ^ Q.error_bits[0 +: WIDTH]);
		M_AXIS_TVALID = S_AXIS_TVALID;
		S_AXIS_TREADY = M_AXIS_TREADY;
	end

	always_ff @(posedge clk) begin
		if (aresetn == 1'b0) begin
			Q <= reg_reset;
		end else begin
			Q <= D;
		end
	end

endmodule
`default_nettype wire
