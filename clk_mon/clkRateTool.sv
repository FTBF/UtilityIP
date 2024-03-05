module clkRateTool #(
		parameter integer CLK_REF_RATE_HZ     = 100000000,
		parameter integer COUNTER_WIDTH = 32,
		parameter real MEASURE_PERIOD_s = 1,
		parameter real MEASURE_TIME_s   = 0.001
	)(
		input  logic reset_in,
		input  logic clk_ref,
		input  logic clk_test,
		output logic [COUNTER_WIDTH-1:0] value
	);

	localparam integer REF_ROLLOVER = (CLK_REF_RATE_HZ * MEASURE_PERIOD_s);
	localparam integer SAMPLE_TIME  = (CLK_REF_RATE_HZ * MEASURE_TIME_s);

	logic [COUNTER_WIDTH-1:0] refCtr;
	logic [COUNTER_WIDTH-1:0] rateCtr;
	logic [COUNTER_WIDTH-1:0] rateCtr_refclk;
	logic [COUNTER_WIDTH-1:0] rateCtr_start;

	//=======================================================================
	// reference clock domain
	//=======================================================================

	always_ff @(posedge clk_ref) begin
		if (reset_in == 1'b1) begin
			refCtr <= 0;
			value <= '1;
			rateCtr_start <= '0;
		end else begin
			// When we start a new measurement cycle, set the ref clock
			// counter to 0 and latch the test clock counter
			if (refCtr == REF_ROLLOVER) begin
				refCtr <= 0;
				rateCtr_start <= rateCtr_refclk;
			end else begin
				refCtr <= refCtr + 1;
			end

			// After we're done measuring, take the value in the test clock
			// counter and subtract the starting value of the test clock
			// counter
			if (refCtr == SAMPLE_TIME) begin
				value <= rateCtr_refclk - rateCtr_refclk;
			end
		end
	end

	// This CDC block helps make timing closure easier by moving the rateCtr
	// into the clk_ref domain.
	xpm_cdc_gray #(
		.DEST_SYNC_FF(2),
		.INIT_SYNC_FF(0),
		.REG_OUTPUT(0),
		.SIM_ASSERT_CHK(1),
		.SIM_LOSSLESS_GRAY_CHK(1),
		.WIDTH(COUNTER_WIDTH)
	) xpm_cdc_gray_inst (
		.dest_out_bin(rateCtr_refclk),
		.dest_clk(clk_ref),
		.src_clk(clk_test),
		.src_in_bin(rateCtr)
	);

	//=======================================================================
	// test clock domain
	//=======================================================================

	always_ff @(posedge clk_test) begin
		rateCtr <= rateCtr + 1;
	end
endmodule
