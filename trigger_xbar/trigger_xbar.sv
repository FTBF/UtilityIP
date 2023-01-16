`timescale 1 ns / 1 ps

/*
* This module is intended for use in the tileboard tester v2.
* The purpose is to allow the various trigger sources to be routed to the
* various trigger destinations.
*
* The trigger sources include:
*  * fast command decoder L1A out
*  * self_trigger trigger out
*  * ext_l1a[3:0] (when configured as inputs)
* The trigger destinations include:
*  * fast command encoder ext_l1a[3:0]
*  * self_trigger input
*  * ext_l1a[3:0] (when configured as outputs)
*
* Additionally, the four ext_l1a[3:0] pins must be configured as either inputs
* or outputs, which is done by this module.  When a pin is configured as an
* input, its output is tri-stated.  When a pin is configured as an output, it
* is not tri-stated.
*
* Each destination can have only one driver, of course.  Each source can be
* routed to multiple destinations, though.
*
* Register map:
* [15:0]  configuration for outputs 15--0
*         bits 3:0  input select
*               Default: {0, 0, 0, 0, 0, 0, 0, 0, 3, 2, 1, 5, 5, 5, 5, 5}
*               Write '3' to register 0 bits 3:0 to route trigger_inputs[3] to trigger_outputs[0], for example
*               Note that only the first N_OUTS registers are used---any higher registers are ignored
*               Note that only values up to N_INPUTS are meaningful---higher values will hold the output at 0
*         bit 16    direction for external connection
*               Default: 1 (input)
*               1: configure as input (tri-state the output)
*               0: configure as output
*               Note that this is only used for the first N_EXTERNAL registers---any higher registers are ignored
* [16]    bit 0: output enable bar: default 1
*               write 0 to enable the bus transceiver on the misc mezzanine
*               defaults to 1: bus transceiver disabled
*/

module trigger_xbar #(
		parameter N_INPUTS = 6,
		parameter N_OUTPUTS = 9,
		parameter N_EXTERNAL = 4,
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer C_S_AXI_ADDR_WIDTH = 11
	) (
		input  logic [N_INPUTS-1:0]   trigger_inputs,
		output logic [N_OUTPUTS-1:0]  trigger_outputs,
		output logic [N_EXTERNAL-1:0] trigger_dirs,
		output logic                  output_enable_bar,

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

	localparam N_REG = 32;

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
		// registers 31-17
		logic [32*15-1:0] padding17_31;
		// register 16
		logic [32-1-1:0] padding16;
		logic            output_enable_bar;
		// registers 15-0
		logic [16-1-1:0] padding_high;
		logic            direction;
		logic [16-4-1:0] padding_low;
		logic [4-1:0]    input_select;
	} link_param_t;

	typedef struct packed {
		// Registers 15:0 (configuration for links 15--0)
		link_param_t [16-1:0] links;
	} param_t;

	param_t params_from_IP;
	param_t params_to_IP;

	// Set the defaults to match the original behavior of tileboard tester v2
	localparam param_t defaults = param_t'{output_enable_bar: 1'b1,
	                                       links:{link_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd3},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd2},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd1},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd6},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd6},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd6},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd6},
		                                          link_param_t'{default:'0, direction:1'b1, input_select:4'd6}}};

	IPIF_parameterDecode #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(param_t),
		.DEFAULTS(defaults)
	) parameterDecode (
		.clk(S_AXI_ACLK),

		//ipif configuration interface ports
		.IPIF_bus2ip_data(IPIF_bus2ip_data),
		.IPIF_bus2ip_rdce(IPIF_bus2ip_rdce),
		.IPIF_bus2ip_resetn(IPIF_bus2ip_resetn),
		.IPIF_bus2ip_wrce(IPIF_bus2ip_wrce),
		.IPIF_ip2bus_data(IPIF_ip2bus_data),
		.IPIF_ip2bus_rdack(IPIF_ip2bus_rdack),
		.IPIF_ip2bus_wrack(IPIF_ip2bus_wrack),

		.parameters_in(params_to_IP),
		.parameters_out(params_from_IP)
	);

	logic [16-1:0] internal_trigger_inputs;

	always_comb begin
		params_from_IP = params_to_IP;
		params_from_IP.padding16 = '0;
		params_from_IP.padding17_31 = '0;
		for (int i = 0; i < 16; i++) begin
			params_from_IP.links[i].padding_high = '0;
			params_from_IP.links[i].padding_low = '0;
		end

		internal_trigger_inputs = '0;
		for (int i = 0; i < N_INPUTS; i++) begin
			internal_trigger_inputs[i] = trigger_inputs[i];
		end

		for (int i = 0; i < N_OUTPUTS; i++) begin
			trigger_outputs[i] = internal_trigger_inputs[params_to_IP.links[i].input_select];
		end

		for (int i = 0; i < N_EXTERNAL; i++) begin
			trigger_dirs[i] = params_to_IP.links[i].direction;
		end

		output_enable_bar = params_to_IP.output_enable_bar;
	end
endmodule
