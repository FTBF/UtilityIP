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

		output logic mismatch,

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

	localparam NLINKS = TDATA_WIDTH / 32;

	typedef struct packed
	{
		// Register 3
		logic [31-1:0] padding3;
		logic          trigger;
		// Register 2
		logic [32-1:0] err_count;
		// Register 1
		logic [32-1:0] word_count;
		// Register 0
		logic [16-1:0] active_links;
		logic [16-3-1:0] padding0;
		logic          active_links_map;
		logic          latch;
		logic          reset;
	} param_t;

	param_t params_to_bus;
	param_t params_to_IP;
	param_t params_from_bus;
	param_t params_from_IP;

	localparam param_t defaults = '{default:'0, active_links: {NLINKS{1'b1}}};
	localparam param_t self_reset = '{default:'0, latch:1'b1, reset:1'b1};

	IPIF_parameterDecode #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(param_t),
		.DEFAULTS(defaults),
		.SELF_RESET(self_reset)
	) parameterDecoder (
		.clk(IPIF_clk),

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
		.N_REG(N_REG),
		.PARAM_T(param_t)
	) IPIF_clock_conv (
		.IP_clk(clk),
		.bus_clk(IPIF_clk),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus));
	//
	//ground unused error port
	assign IPIF_IP2Bus_Error = 0;

	typedef struct {
		logic mismatch;
		logic [31:0] word_count;
		logic [31:0] err_count;
	} reg_type;

	reg_type d, q;

	logic both_valid;
	logic both_valid_mismatch;
	logic [TDATA_WIDTH-1:0] mask;
	always_comb begin
		d = q;

		for(int i = 0; i < NLINKS; i++) begin
			if (params_to_IP.active_links_map == 1'b0) begin
				mask[32*i +: 32] = (i < params_to_IP.active_links) ? '1 : '0;
			end else begin
				mask[32*i +: 32] = (params_to_IP.active_links[i]) ? 32'hffffffff : 32'h00000000;
			end
		end
		both_valid = (S_AXIS_0_TVALID && S_AXIS_1_TVALID);
		both_valid_mismatch = both_valid && ((S_AXIS_0_TDATA & mask) != (S_AXIS_1_TDATA & mask));

		S_AXIS_0_TREADY = both_valid;
		S_AXIS_1_TREADY = both_valid;

		if (both_valid) begin
			d.word_count = q.word_count + 1;
		end

		if (both_valid_mismatch) begin
			d.err_count = q.err_count + 1;
		end

		d.mismatch = (params_to_IP.trigger && both_valid_mismatch);
	end

	assign mismatch = q.mismatch;

	logic areset;
	assign areset = !aresetn;
	always_ff @(posedge clk) begin
		if (areset || params_to_IP.reset) begin
			q.mismatch   <= 1'b0;
			q.word_count <= '0;
			q.err_count  <= '0;
		end else begin
			q <= d;
		end
	end

	assign params_from_IP.padding0 = '0;
	assign params_from_IP.padding3 = '0;

	always_ff @(posedge clk) begin
		if (areset) begin
			params_from_IP <= defaults;
		end else begin
			params_from_IP <= params_to_IP;
			if(params_to_IP.latch == 1) begin
				params_from_IP.word_count <= q.word_count;
				params_from_IP.err_count  <= q.err_count;
			end else begin
				params_from_IP.word_count <= params_from_IP.word_count;
				params_from_IP.err_count  <= params_from_IP.err_count;
			end
		end
	end
endmodule
