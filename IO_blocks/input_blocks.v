`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03/28/2020 10:44:52 AM
// Design Name:
// Module Name: input_blocks
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

module input_blocks #(
		parameter DELAY_INIT = 0,
		parameter DIFF_IO = 1,
		parameter COUNTER_WIDTH = 32
	)(
		input wire          clk640,
		input wire          clk160,
		input wire          fifo_rd_clk,

		input wire serial_data_P,
		input wire serial_data_N,

		output wire [7 : 0] D_OUT_P,
		output wire [7 : 0] D_OUT_N,

		output wire [COUNTER_WIDTH-1:0]   error_counter,
		output wire [COUNTER_WIDTH-1:0]   bit_counter,

		input wire          delay_set,
		input wire          delay_mode,
		input wire [8:0]    delay_in,
		input wire [8:0]    delay_error_offset,
		output wire [8:0]   delay_out,
		output wire [8:0]   delay_out_N,
		output wire         delay_ready,
		output wire         waiting_for_transitions,

		input wire          reset_counters,
		input wire          rstb
	);

	wire [8 : 0]    rx_cntvaluein_P;
	wire            rx_load_P;
	wire [8 : 0]    rx_cntvaluein_N;
	wire            rx_load_N;
	wire            fifo_rd_en_P;
	wire            fifo_rd_en_N;
	wire            fifo_empty_P;
	wire            fifo_empty_N;

	assign fifo_rd_en_P = !fifo_empty_P;
	assign fifo_rd_en_N = !fifo_empty_N;

	wire [5:0] eye_width;
	wire [8:0] delay_out_N_local;

	assign delay_out_N = (delay_mode)?({eye_width, 3'b0}):(delay_out_N_local);

	delay_ctrl dly_ctrl(
		.clk160(clk160),

		.D_OUT_P(D_OUT_P),
		.D_OUT_N(D_OUT_N),

		.delay_mode(delay_mode),
		.delay_set(delay_set),
		.delay_in(delay_in),
		.delay_error_offset(delay_error_offset),

		.error_counter(error_counter),
		.bit_counter(bit_counter),
		.delay_out_P(delay_out),
		.delay_out_N(delay_out_N_local),

		.eye_width(eye_width),

		.fifo_ready(fifo_rd_en_P && fifo_rd_en_N),

		.delay_set_P(rx_cntvaluein_P),
		.delay_set_N(rx_cntvaluein_N),
		.delay_wr_P(rx_load_P),
		.delay_wr_N(rx_load_N),

		.delay_ready(delay_ready),
		.waiting_for_transitions(waiting_for_transitions),

		.reset_counters(reset_counters),
		.rstb(rstb)
	);

	wire link_data_delay_P;
	wire link_data_delay_N;

	IDELAYE3 #(
		.CASCADE("NONE"),
		.DELAY_FORMAT("COUNT"),
		.DELAY_SRC("IDATAIN"),
		.DELAY_TYPE("VAR_LOAD"),
		.DELAY_VALUE(DELAY_INIT),
		.IS_CLK_INVERTED(0),
		.IS_RST_INVERTED(1),
		.UPDATE_MODE("ASYNC"),
		.SIM_DEVICE("ULTRASCALE_PLUS")
	) idelay_P (
		.CASC_OUT(),
		.CNTVALUEOUT(delay_out),
		.DATAOUT(link_data_delay_P),
		.CASC_IN(0),
		.CASC_RETURN(0),
		.CE(0),
		.CLK(clk160),
		.CNTVALUEIN(rx_cntvaluein_P),
		.DATAIN(0),
		.EN_VTC(0),
		.IDATAIN(serial_data_P),
		.INC(0),
		.LOAD(rx_load_P),
		.RST(rstb)
	);


	ISERDESE3  #(
		.DATA_WIDTH(8),
		.FIFO_ENABLE("TRUE"),
		.FIFO_SYNC_MODE("FALSE"),
		.IS_CLK_B_INVERTED(1),
		.IS_CLK_INVERTED(0),
		.IS_RST_INVERTED(1),
		.SIM_DEVICE("ULTRASCALE_PLUS")
	) iserdes_P (
		.INTERNAL_DIVCLK(),
		.Q(D_OUT_P),
		.CLK(clk640),
		.CLK_B(clk640),
		.CLKDIV(clk160),
		.D(link_data_delay_P),
		.FIFO_RD_CLK(fifo_rd_clk),
		.FIFO_EMPTY(fifo_empty_P),
		.FIFO_RD_EN(fifo_rd_en_P),
		.RST(rstb)
	);

	generate
		if (DIFF_IO == 1) begin
			IDELAYE3 #(
				.CASCADE("NONE"),
				.DELAY_FORMAT("COUNT"),
				.DELAY_SRC("IDATAIN"),
				.DELAY_TYPE("VAR_LOAD"),
				.DELAY_VALUE(DELAY_INIT),
				.IS_CLK_INVERTED(0),
				.IS_RST_INVERTED(1),
				.UPDATE_MODE("ASYNC"),
				.SIM_DEVICE("ULTRASCALE_PLUS")
			) idelay_N (
				.CASC_OUT(),
				.CNTVALUEOUT(delay_out_N_local),
				.DATAOUT(link_data_delay_N),
				.CASC_IN(0),
				.CASC_RETURN(0),
				.CE(0),
				.CLK(clk160),
				.CNTVALUEIN(rx_cntvaluein_N),
				.DATAIN(0),
				.EN_VTC(0),
				.IDATAIN(serial_data_N),
				.INC(0),
				.LOAD(rx_load_N),
				.RST(rstb)
			);

			ISERDESE3  #(
				.DATA_WIDTH(8),
				.FIFO_ENABLE("TRUE"),
				.FIFO_SYNC_MODE("FALSE"),
				.IS_CLK_B_INVERTED(1),
				.IS_CLK_INVERTED(0),
				.IS_RST_INVERTED(1),
				.SIM_DEVICE("ULTRASCALE_PLUS")
			) iserdes_N (
				.INTERNAL_DIVCLK(),
				.Q(D_OUT_N),
				.CLK(clk640),
				.CLK_B(clk640),
				.CLKDIV(clk160),
				.D(link_data_delay_N),
				.FIFO_RD_CLK(fifo_rd_clk),
				.FIFO_EMPTY(fifo_empty_N),
				.FIFO_RD_EN(fifo_rd_en_N),
				.RST(rstb)
			);
		end else begin
			assign D_OUT_N = ~D_OUT_P;
			assign delay_out_N_local = rx_cntvaluein_N;
			assign fifo_empty_N = 0;
		end
	endgenerate
endmodule
