`timescale 1 ns / 1 ps

/*
The idea of this module is to determine whether an unused pin of the FPGA is
externally connected to +V, to GND, or floating.  So we use an IOBUF and
a KEEPER.  The IOBUF allows us to control whether we drive an output value or
tristate the pin.  The KEEPER should weakly hold the last value driven while
the pin is tristated, but it will not overcome a direct connection to +V or to
GND.

Test procedure:
 1. write 0 to `value_to_drive`
 2. write 0 to `tristate`
 3. wait a short time, maybe a few milliseconds
 4. write 1 to `tristate`
 5. read `value_read`
 6. write 1 to `value_to_drive`
 7. write 0 to `tristate`
 8. wait a short time, maybe a few milliseconds
 9. write 1 to `tristate`
10. read `value_read`

If the value read in steps 5 and 10 are the same, then the pin is connected to +V if both are 1, and connected to GND if both are 0.
If you read 0 in step 5 and 1 in step 10, then the pin is floating.
If you read 1 in step 5 and 0 in step 10, then call an exorcist.
*/

module static_pin_tester #(
		parameter WIDTH = 1,
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer C_S_AXI_ADDR_WIDTH = 11
	) (
		inout  logic [WIDTH-1:0]                    IO,

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

	localparam N_REG = 4;

	logic                                  IPIF_Bus2IP_resetn;
	logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr;
	logic                                  IPIF_Bus2IP_RNW;
	logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE;
	logic [0 : 0]                          IPIF_Bus2IP_CS;
	logic [(N_REG-1) : 0]                  IPIF_Bus2IP_RdCE;
	logic [(N_REG-1) : 0]                  IPIF_Bus2IP_WrCE;
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
		logic [32-1:0] WIDTH_read;
		// Register 2
		logic [32-WIDTH-1:0] padding2;
		logic [WIDTH-1:0] value_read;
		// Register 1
		logic [32-WIDTH-1:0] padding1;
		logic [WIDTH-1:0] tristate;
		// Register 0
		logic [32-WIDTH-1:0] padding0;
		logic [WIDTH-1:0] value_to_drive;
	} param_t;

	localparam param_t defaults = '{default: '0, tristate: '1};

	param_t params_from_IP;
	param_t params_to_IP;

	//IPIF parameters are decoded here
	IPIF_parameterDecode #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
		.USE_ONEHOT_READ(0),
		.N_REG(N_REG),
		.PARAM_T(param_t),
		.DEFAULTS(defaults)
	) parameterDecode (
		.clk(S_AXI_ACLK),

		//ipif configuration interface ports
		.IPIF_bus2ip_addr(IPIF_Bus2IP_Addr),
		.IPIF_bus2ip_data(IPIF_Bus2IP_Data),
		.IPIF_bus2ip_rdce(IPIF_Bus2IP_RdCE),
		.IPIF_bus2ip_resetn(IPIF_Bus2IP_resetn),
		.IPIF_bus2ip_wrce(IPIF_Bus2IP_WrCE),
		.IPIF_ip2bus_data(IPIF_IP2Bus_Data),
		.IPIF_ip2bus_rdack(IPIF_IP2Bus_RdAck),
		.IPIF_ip2bus_wrack(IPIF_IP2Bus_WrAck),

		.parameters_in(params_from_IP),
		.parameters_out(params_to_IP)
	);

	logic [WIDTH-1:0] I;
	logic [WIDTH-1:0] O;
	logic [WIDTH-1:0] T;

	always_comb begin
		params_from_IP = params_to_IP;
		params_from_IP.padding0 = '0;
		params_from_IP.padding1 = '0;
		params_from_IP.padding2 = '0;

		params_from_IP.value_read = O;
		params_from_IP.WIDTH_read = WIDTH;

		I = params_to_IP.value_to_drive;
		T = params_to_IP.tristate;
	end

	genvar i;
	generate
		for(i = 0; i < WIDTH; i++) begin
			KEEPER KEEPER_inst (.O(IO[i]));
			IOBUF IOBUF_inst
			(
				.O(O[i]),
				.I(I[i]),
				.IO(IO[i]),
				.T(T[i])
			);
		end
	endgenerate

endmodule
