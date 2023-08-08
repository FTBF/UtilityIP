`timescale 1 ns / 1 ps

module AXI_mux #(
		parameter N_INPUTS = 2,
		parameter DATA_WIDTH = 8,
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer C_S_AXI_ADDR_WIDTH = 11
	) (
		input  logic [N_INPUTS*DATA_WIDTH-1:0] data_in,
		output logic [DATA_WIDTH-1:0]          data_out,
		output logic                           data_tristate,

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

	logic                                  IPIF_Bus2IP_resetn;
	logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr;
	logic                                  IPIF_Bus2IP_RNW;
	logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE;
	logic [0 : 0]                          IPIF_Bus2IP_CS;
	logic [1 : 0]                          IPIF_Bus2IP_RdCE;
	logic [1 : 0]                          IPIF_Bus2IP_WrCE;
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
		.N_REG(2),
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
		// Register 1
		logic [32-1-1:0] padding1;
		logic tristate;
		// Register 0
		logic [28-1:0] padding0;
		logic [4-1:0] sel;
	} param_t;

	localparam param_t defaults = '{default: '0, tristate: 1'b1};

	param_t params_from_IP;
	param_t params_to_IP;

	//IPIF parameters are decoded here
	IPIF_parameterDecode #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(2),
		.PARAM_T(param_t),
		.DEFAULTS(defaults)
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

		.parameters_in(params_from_IP),
		.parameters_out(params_to_IP)
	);

	assign data_out = data_in[params_to_IP.sel*DATA_WIDTH +: DATA_WIDTH];
	assign data_tristate = params_to_IP.tristate;

	always_comb begin
		params_from_IP = params_to_IP;
		params_from_IP.padding0 = '0;
		params_from_IP.padding1 = '0;
	end
endmodule
