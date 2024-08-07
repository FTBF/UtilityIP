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
		parameter UNIFIED_STREAMS = 0,
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer C_S_AXI_ADDR_WIDTH = 11
	) (
		input  logic [N_INPUTS-1:0]    trigger_inputs,
		output logic [N_OUTPUTS-1:0]   trigger_outputs,
		output logic [N_EXTERNAL-1:0]  trigger_dirs,
		output logic [N_EXTERNAL-1:0]  trigger_Ts,
		output logic                   output_enable_bar,

		input  logic                   clk640,
		input  logic                   clk160,
		input  logic                   clk160_aresetn,
		output logic [N_OUTPUTS*8-1:0] M_AXIS_TDATA,
		output logic [N_OUTPUTS*(1-UNIFIED_STREAMS) + UNIFIED_STREAMS - 1:0]   M_AXIS_TVALID,
		input  logic [N_OUTPUTS*(1-UNIFIED_STREAMS) + UNIFIED_STREAMS - 1:0]   M_AXIS_TREADY, // We ignore TREADY, but need to keep it so IP integrator won't get confused

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

	localparam N_REG = 64;

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
		logic [8-1-1:0] padding_3;
		logic                       current_value;
		logic [8-2-1:0] padding_2;
		logic                       force_value;
		logic                       force_enable;
		logic [8-1-1:0] padding_1;
		logic                       direction;
		logic [8-4-1:0] padding_0;
		logic [4-1:0]               input_select;
	} output_param_t;

	typedef struct packed {
		logic [8-1-1:0]  padding_2;
		logic                       current_value;
		logic [8-2-1:0]  padding_1;
		logic                       force_value;
		logic                       force_enable;
		logic [16-0-1:0] padding_0;
	} input_param_t;

	typedef struct packed {
		// register 63
		logic [32-1:0] block_version;
		// registers 62-36 are all unused
		logic [32*27-1:0] padding62_36;
		// register 35
		logic [32-1:0] N_external;
		// register 34
		logic [32-1:0] N_outputs;
		// register 33
		logic [32-1:0] N_inputs;
		// register 32
		logic [32-1-1:0] padding32;
		logic                       output_enable_bar;
		// registers 31-16
		input_param_t  [16-1:0]     input_links;
		// registers 15-0
		output_param_t [16-1:0]     output_links;
	} param_t;

	param_t params_from_IP;
	param_t params_to_IP;

	localparam input_param_t input_defaults = '{default:'0, force_enable:1'b0, force_value:1'b0};

	localparam logic [32-1:0] block_version = 32'h00010000; // version 1.0.0, encoded as 0001.00.00

	// Set the defaults to match the original behavior of tileboard tester v2
	localparam param_t defaults = param_t'{default:'0,
	                                       output_enable_bar: 1'b1,
										   input_links:{16{input_defaults}},
										   N_inputs:N_INPUTS,
										   N_outputs:N_OUTPUTS,
										   N_external:N_EXTERNAL,
										   block_version:block_version,
	                                       output_links:{output_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd0},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd3},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd2},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd1},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd6},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd6},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd6},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd6},
		                                                 output_param_t'{default:'0, direction:1'b1, input_select:4'd6}}};

	IPIF_parameterDecode #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
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

	logic [16-1:0] internal_trigger_inputs;

	logic [N_OUTPUTS-1:0][8-1:0] trigger_inputs_deserialized;
	logic [N_OUTPUTS-1:0][8-1:0] internal_trigger_inputs_deserialized;

	generate
		genvar i;
		for (i = 0; i < N_INPUTS; i += 1) begin
			logic fifo_empty;
			logic fifo_rd_en;
			assign fifo_rd_en = !fifo_empty;
			if (i < N_EXTERNAL) begin
				ISERDESE3  #(
					.DATA_WIDTH(8),
					.FIFO_ENABLE("TRUE"),
					.FIFO_SYNC_MODE("FALSE"),
					.IS_CLK_B_INVERTED(1),
					.IS_CLK_INVERTED(0),
					.IS_RST_INVERTED(1),
					.SIM_DEVICE("ULTRASCALE_PLUS")
				) iserdes (
					.INTERNAL_DIVCLK(),
					.Q(trigger_inputs_deserialized[i]),
					.CLK(clk640),
					.CLK_B(clk640),
					.CLKDIV(clk160),
					.D(trigger_inputs[i]),
					.FIFO_RD_CLK(clk160),
					.FIFO_EMPTY(fifo_empty),
					.FIFO_RD_EN(fifo_rd_en),
					.RST(clk160_aresetn)
				);
			end else begin
				assign trigger_inputs_deserialized[i] = {8{trigger_inputs[i]}};
			end
		end
	endgenerate

	always_comb begin
		params_from_IP = params_to_IP;
		params_from_IP.padding32 = '0;
		params_from_IP.padding62_36 = '0;

		params_from_IP.block_version = block_version;

		params_from_IP.N_inputs = N_INPUTS;
		params_from_IP.N_outputs = N_OUTPUTS;
		params_from_IP.N_external = N_EXTERNAL;

		for (int i = 0; i < 16; i++) begin
			params_from_IP.output_links[i].padding_0 = '0;
			params_from_IP.output_links[i].padding_1 = '0;
			params_from_IP.output_links[i].padding_2 = '0;
			params_from_IP.output_links[i].padding_3 = '0;
			params_from_IP.input_links[i].padding_0 = '0;
			params_from_IP.input_links[i].padding_1 = '0;
			params_from_IP.input_links[i].padding_2 = '0;
		end

		internal_trigger_inputs = '0;
		for (int i = 0; i < N_INPUTS; i++) begin
			if (params_to_IP.input_links[i].force_enable == 1'b1) begin
				internal_trigger_inputs[i] = params_to_IP.input_links[i].force_value;
				internal_trigger_inputs_deserialized[i] = {8{params_to_IP.input_links[i].force_value}};
			end else begin
				internal_trigger_inputs[i] = trigger_inputs_deserialized[i][0];
				internal_trigger_inputs_deserialized[i] = trigger_inputs_deserialized[i];
			end
			params_from_IP.input_links[i].current_value = internal_trigger_inputs[i];
		end

		for (int i = 0; i < N_OUTPUTS; i++) begin
			if (params_to_IP.output_links[i].force_enable == 1'b1) begin
				trigger_outputs[i] = params_to_IP.output_links[i].force_value;
				M_AXIS_TDATA[8*i +: 8] = {8{params_to_IP.output_links[i].force_value}};
			end else begin
				trigger_outputs[i] = internal_trigger_inputs[params_to_IP.output_links[i].input_select];
				M_AXIS_TDATA[8*i +: 8] = internal_trigger_inputs_deserialized[params_to_IP.output_links[i].input_select];
			end
			M_AXIS_TVALID[i] = 1'b1;
			params_from_IP.output_links[i].current_value = trigger_outputs[i];
		end

		for (int i = 0; i < N_EXTERNAL; i++) begin
			trigger_dirs[i] = ~params_to_IP.output_links[i].direction;
			trigger_Ts[i]   =  params_to_IP.output_links[i].direction;
		end

		output_enable_bar = params_to_IP.output_enable_bar;
	end
endmodule
