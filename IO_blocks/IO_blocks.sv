`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/08/2020 01:18:55 PM
// Design Name:
// Module Name: IO_blocks
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

/*
 Register map:
 Addresses 0 - 3 are global for all links
 [0][0]      (rw) Global reset links (active-low reset)
 [0][1]      (rw) Global reset counters (active-high reset)
 [0][2]      (rw) Global latch counters (Write 1 to save current counter values)

 Link-specific registers start from address 4 and repeat in blocks of 4
 [4][0]      (rw) Reset link (active-low reset)
 [4][1]      (rw) Reset counters (active-high reset)
 [4][2]      (rw) Delay mode: 0=manual delay setting, 1=automatic delay setting (default 0)
 [4][3]      (rw) Delay set: write 1 to this in manual mode to set the delays chosen in "Delay in" and "Delay offset".
 [4][4]      (rw) Bypass IOBUF: 0=use data from IO pin, 1=use data from input stream (default 0)
 [4][5]      (rw) Tristate IOBUF: 0=drive data to IO pin, 1=keep IO pin in high-impedance state (default 0)
 [4][6]      (rw) Latch counters: Write 1 to save current counter values
 [4][16:8]   (rw) Delay in: 9-bit delay to use in manual mode
 [4][25:17]  (rw) Delay offset: offset between P and N side to use in manual mode for bit-error monitoring

 [5]         (ro) Bit counter: 32-bit counter records total number of bits received

 [6]         (ro) Error counter: 32-bit counter records total number of bits that didn't match between P and N side

 [7][0]      (ro) Delay ready
 [7][9:1]    (ro) Delay out: 9-bit delay actually in use right now by P side
 [7][18:10]  (ro) Delay out N: in manual mode: delay used by N side; in automatic mode: size of the "eye" of zero bit errors
 [7][19]     (ro) Waiting for bit transitions

 Note that addresses 4-7 are for link 0.  The same registers are repeated at addresses 8-11 for link 1, 12-15 for link 2, etc.
 */

module IO_blocks#(
		parameter INCLUDE_SYNCHRONIZER = 0,
		parameter DIFF_IO = 1,
		parameter C_S_AXI_DATA_WIDTH = 32,
		parameter integer NLINKS = 12,
		parameter integer WORD_PER_LINK = 4,
		parameter integer DRIVE_ENABLED = 1,
		parameter OUTPUT_STREAMS_ENABLE = 1,
		parameter logic [NLINKS-1:0] INVERT = '0
	) (
		input logic in_clk160,
		input logic in_clk640,

		input logic out_clk160,

		input logic IPIF_clk,

		input  logic [NLINKS*8-1:0] in_tdata,
		input  logic [NLINKS-1:0]   in_tvalid,
		output logic [NLINKS-1:0]   in_tready,

		output logic [NLINKS*8-1:0] out_tdata,
		output logic [NLINKS-1:0]   out_tvalid,
		input  logic [NLINKS-1:0]   out_tready,

		inout logic [NLINKS-1:0] D_IN_OUT,
		inout logic [NLINKS-1:0] D_IN_OUT_P,
		inout logic [NLINKS-1:0] D_IN_OUT_N,

		input logic [NLINKS-1:0] D_IN,
		input logic [NLINKS-1:0] D_IN_P,
		input logic [NLINKS-1:0] D_IN_N,

		output logic [NLINKS-1:0] D_OUT,
		output logic [NLINKS-1:0] D_OUT_P,
		output logic [NLINKS-1:0] D_OUT_N,

		//ipif configuration interface ports
		input logic [31:0] IPIF_bus2ip_addr,  //unused
		input logic [3:0] IPIF_bus2ip_be,  //unused
		input logic [NLINKS:0] IPIF_bus2ip_cs,  //unused
		input logic [31:0] IPIF_bus2ip_data,
		input logic [(NLINKS+1)*WORD_PER_LINK-1:0] IPIF_bus2ip_rdce,
		input logic IPIF_bus2ip_resetn,
		input logic IPIF_bus2ip_rnw,  //unused
		input logic [(NLINKS+1)*WORD_PER_LINK-1:0] IPIF_bus2ip_wrce,
		output logic [31:0] IPIF_ip2bus_data,
		output logic IPIF_ip2bus_error,  //unused
		output logic IPIF_ip2bus_rdack,
		output logic IPIF_ip2bus_wrack
	);

	// Per-link parameter structure
	typedef struct packed
	{
		// Register 3
		logic [12-1:0] padding3;
		logic waiting_for_transition;
		logic [9-1:0] delay_out_N;
		logic [9-1:0] delay_out;
		logic delay_ready;
		// Register 2
		logic [32-1:0] error_counter;
		// Register 1
		logic [32-1:0] bit_counter;
		// Register 0
		logic [6-1:0] padding0;
		logic invert;
		logic [9-1:0] delay_offset;
		logic [9-1:0] delay_in;
		logic latch_counters;
		logic tristate_IObuf;
		logic bypass_IObuf;
		logic delay_set;
		logic delay_mode;
		logic counter_reset;
		logic link_resetn;
	} link_param_t;

	typedef struct packed
	{
		link_param_t [NLINKS-1:0] links;
		// Global register 3
		logic [32-1:0] padding3;
		// Global register 2
		logic [32-1:0] padding2;
		// Global register 1
		logic [32-1:0] padding1;
		// Global register 0
		logic [29-1:0] padding0;
		logic global_counter_latch;
		logic global_counter_reset;
		logic global_resetn;
	} param_t;

	param_t params_from_IP;
	param_t params_from_bus;
	param_t params_to_IP;
	param_t params_to_bus;
	param_t local_params;

	localparam link_param_t link_defaults = '{default:'0, link_resetn:1'b1};
	localparam param_t defaults = '{default:'0,
	                                global_resetn:1'b1,
	                                links:{NLINKS{link_defaults}}};

	localparam link_param_t link_self_reset = '{default:'0, link_resetn:1'b1, counter_reset:1'b1, latch_counters:1'b1, delay_set:1'b1};
	localparam param_t self_reset = '{default:'0,
	                                  global_resetn:1'b1,
	                                  global_counter_reset:1'b1,
	                                  global_counter_latch:1'b1,
	                                  links:{NLINKS{link_self_reset}}};

	//IPIF parmaters are decoded here
	IPIF_parameterDecode #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG((NLINKS+1)*4),
		.PARAM_T(param_t),
		.DEFAULTS(defaults),
		.SELF_RESET(self_reset)
	) parameterDecode (
		.clk(IPIF_clk),

		//ipif configuration interface ports
		.IPIF_bus2ip_data(IPIF_bus2ip_data),
		.IPIF_bus2ip_rdce(IPIF_bus2ip_rdce),
		.IPIF_bus2ip_resetn(IPIF_bus2ip_resetn),
		.IPIF_bus2ip_wrce(IPIF_bus2ip_wrce),
		.IPIF_ip2bus_data(IPIF_ip2bus_data),
		.IPIF_ip2bus_rdack(IPIF_ip2bus_rdack),
		.IPIF_ip2bus_wrack(IPIF_ip2bus_wrack),

		.parameters_in(params_to_bus),
		.parameters_out(params_from_bus)
	);

	IPIF_clock_converter #(
		.INCLUDE_SYNCHRONIZER(INCLUDE_SYNCHRONIZER),
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG((NLINKS+1)*4),
		.PARAM_T(param_t)
	) IPIF_clock_conv (
		.IP_clk(in_clk160),
		.bus_clk(IPIF_clk),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus));
	//
	//ground unused error port
	assign IPIF_ip2bus_error = 0;

	logic [7:0] in_tdata_i [15:0];
	logic [7:0] out_tdata_i [15:0];
	logic [7:0] ISERDES_out [15:0];
	logic [7:0] bypass_in_data [15:0];
	logic [7:0] bypass_out_data [15:0];

	assign in_tready = '1;
	assign out_tvalid = '1;

	logic [32-1:0] error_counter [NLINKS-1:0];
	logic [32-1:0] bit_counter [NLINKS-1:0];

	generate
	genvar i;
		for (i = 0; i < NLINKS; i += 1)
		begin : ioblocks
			assign in_tdata_i[i] = in_tdata[(8*(i+1))-1:8*i];
			assign out_tdata[(8*(i+1))-1:8*i] = out_tdata_i[i];

			logic IOBUFDS_to_ISERDES_P, IOBUFDS_to_ISERDES_N;
			logic DATA_OSERDES_to_IOBUFDS, TRISTATE_OSERDES_to_IOBUFDS;

			OSERDESE3 #(
				.DATA_WIDTH(8),
				.IS_RST_INVERTED(1),
				.SIM_DEVICE("ULTRASCALE_PLUS")
			) oserdes_inst (
				.CLK(in_clk640),
				.CLKDIV(in_clk160),
				.D((INVERT[i] ^ params_to_IP.links[i].invert) ? ~in_tdata_i[i] : in_tdata_i[i]),
				.T(~in_tvalid[i] || params_to_IP.links[i].tristate_IObuf), // T = 1 means tristate, T = 0 means drive data to output
				.OQ(DATA_OSERDES_to_IOBUFDS),
				.T_OUT(TRISTATE_OSERDES_to_IOBUFDS),
				.RST(params_to_IP.global_resetn && params_to_IP.links[i].link_resetn)
			);

			if ((DRIVE_ENABLED == 1) && (OUTPUT_STREAMS_ENABLE == 1)) begin
				// Both FPGA->pin and pin->FPGA are enabled
				// Use an IOBUF
				if (DIFF_IO == 1) begin
					IOBUFDS_DIFF_OUT diff_buf(
						.IO(D_IN_OUT_P[i]), .IOB(D_IN_OUT_N[i]),
						.I(DATA_OSERDES_to_IOBUFDS),
						.O(IOBUFDS_to_ISERDES_P), .OB(IOBUFDS_to_ISERDES_N),
						.TM(TRISTATE_OSERDES_to_IOBUFDS),
						.TS(TRISTATE_OSERDES_to_IOBUFDS));
				end else begin
					IOBUF buf_inst (
						.IO(D_IN_OUT[i]),
						.I(DATA_OSERDES_to_IOBUFDS),
						.O(IOBUFDS_to_ISERDES_P),
						.T(TRISTATE_OSERDES_to_IOBUFDS));
				end
			end else if ((DRIVE_ENABLED == 1) && (OUTPUT_STREAMS_ENABLE == 0)) begin
				// FPGA->pin is enabled, but pin->FPGA is disabled
				// Use an OBUF
				if (DIFF_IO == 1) begin
					OBUFTDS diff_buf(
						.O(D_OUT_P[i]), .OB(D_OUT_N[i]),
						.I(DATA_OSERDES_to_IOBUFDS),
						.T(TRISTATE_OSERDES_to_IOBUFDS));
				end else begin
					OBUFT buf_inst (
						.O(D_OUT[i]),
						.I(DATA_OSERDES_to_IOBUFDS),
						.T(TRISTATE_OSERDES_to_IOBUFDS));
				end
			end else if ((DRIVE_ENABLED == 0) && (OUTPUT_STREAMS_ENABLE == 1)) begin
				// FPGA->pin is disabled, but pin->FPGA is enabled
				// Use an IBUF
				if (DIFF_IO == 1) begin
					IBUFDS_DIFF_OUT diff_buf(
						.I(D_IN_P[i]), .IB(D_IN_N[i]),
						.O(IOBUFDS_to_ISERDES_P), .OB(IOBUFDS_to_ISERDES_N));
				end else begin
					IBUF buf_inst (
						.I(D_IN[i]),
						.O(IOBUFDS_to_ISERDES_P));
				end
			end else if ((DRIVE_ENABLED == 0) && (OUTPUT_STREAMS_ENABLE == 0)) begin
				// FPGA->pin and pin->FPGA are both disabled
				// This is useless and silly and shouldn't ever be done, so
				// don't do anything at all.
			end

			if (OUTPUT_STREAMS_ENABLE) begin
				input_blocks #(
					.DELAY_INIT(0),
					.DIFF_IO(DIFF_IO),
					.COUNTER_WIDTH(32)
				) sigmon (
					.clk640(in_clk640),
					.clk160(in_clk160),
					.fifo_rd_clk(out_clk160),

					.serial_data_P(IOBUFDS_to_ISERDES_P),
					.serial_data_N(IOBUFDS_to_ISERDES_N),

					.D_OUT_P(ISERDES_out[i]),
					.D_OUT_N(),  //intentionally unconnected

					.delay_set               (params_to_IP.links[i].delay_set),
					.delay_mode              (params_to_IP.links[i].delay_mode),
					.delay_in                (params_to_IP.links[i].delay_in),
					.delay_error_offset      (params_to_IP.links[i].delay_offset),

					.delay_out               (local_params.links[i].delay_out),
					.delay_out_N             (local_params.links[i].delay_out_N),
					.delay_ready             (local_params.links[i].delay_ready),
					.waiting_for_transitions (local_params.links[i].waiting_for_transition),

					.error_counter           (error_counter[i]),
					.bit_counter             (bit_counter[i]),

					.reset_counters(params_to_IP.global_counter_reset || params_to_IP.links[i].counter_reset),

					.rstb(params_to_IP.global_resetn && params_to_IP.links[i].link_resetn)
				);

				assign out_tdata_i[i] = (params_to_IP.links[i].bypass_IObuf ?
				                         bypass_out_data[i] : 
				                         ((INVERT[i] ^ params_to_IP.links[i].invert) ?
				                          ~ISERDES_out[i] :
				                          ISERDES_out[i]));
			end
		end
	endgenerate

	// Should probably replace this next part with an instance of
	// xpm_fifo_async...

	// Clock crossing for the bypass mode
	// We do not use an actual xpm_cdc module for this because it should not
	// be necessary.  The input and output 160 MHz clocks should have some
	// relationship, and Vivado should be able to use that relationship to
	// make timing work on this path.

	// Register the data in the input clk160 domain (this register stage
	// roughly mimics OSERDES, which registers the input data)
	always @(posedge in_clk160) begin
		for (int i = 0; i < NLINKS; i = i + 1) begin
			bypass_in_data[i] <= in_tdata_i[i];
		end
	end

	// Register the data in the output clk160 domain (this register stage
	// roughly mimics ISERDES, which registers the output data)
	always @(posedge out_clk160) begin
		for (int i = 0; i < NLINKS; i = i + 1) begin
			bypass_out_data[i] <= bypass_in_data[i];
		end
	end

	// Latching of the counters
	always_ff @(posedge in_clk160) begin
		for (int i = 0; i < NLINKS; i += 1) begin
			if   (params_to_IP.global_counter_reset ||
			      params_to_IP.links[i].counter_reset ||
			      ~params_to_IP.global_resetn ||
			      ~params_to_IP.links[i].link_resetn) begin
				local_params.links[i].error_counter <= '0;
				local_params.links[i].bit_counter <= '0;
			end else if (params_to_IP.global_counter_latch ||
			             params_to_IP.links[i].latch_counters) begin
				local_params.links[i].error_counter <= error_counter[i];
				local_params.links[i].bit_counter <= bit_counter[i];
			end
		end
	end

	always_comb begin
		params_from_IP = params_to_IP;
		for (int i = 0; i < NLINKS; i += 1) begin
			params_from_IP.links[i].waiting_for_transition = local_params.links[i].waiting_for_transition;
			params_from_IP.links[i].delay_out_N            = local_params.links[i].delay_out_N;
			params_from_IP.links[i].delay_out              = local_params.links[i].delay_out;
			params_from_IP.links[i].delay_ready            = local_params.links[i].delay_ready;
			params_from_IP.links[i].error_counter          = local_params.links[i].error_counter;
			params_from_IP.links[i].bit_counter            = local_params.links[i].bit_counter;
			params_from_IP.links[i].padding3               = '0;
			params_from_IP.links[i].padding0               = '0;
		end
		params_from_IP.padding3 = '0;
		params_from_IP.padding2 = '0;
		params_from_IP.padding1 = '0;
		params_from_IP.padding0 = '0;
	end
endmodule
