module clkRateTool #(
		parameter integer CLK_REF_RATE_HZ     = 100000000,
		parameter real MEASURE_PERIOD_s = 1,
		parameter real MEASURE_TIME_s   = 0.125
	)(
		input  logic reset_in,
		input  logic clk_ref,
		input  logic clk_test,
		output logic [24-1:0] value
	);

	localparam integer REF_ROLLOVER = (CLK_REF_RATE_HZ * MEASURE_PERIOD_s);
	localparam integer SAMPLE_TIME  = (CLK_REF_RATE_HZ * MEASURE_TIME_s);

	logic [24-1:0] refCtr;
	logic [24-1:0] rateCtr;
	logic [24-1:0] rateCtr_refclk;

	logic async_reset;
	logic async_reset_clk_test;

	//=======================================================================
	// reference clock domain
	//=======================================================================

	always_ff @(posedge clk_ref) begin
		if (reset_in == 1'b1) begin
			refCtr <= 0;
			async_reset <= 1'b1;
			value <= '1;
		end else begin
			// When we start a new measurement cycle, reset the test clock
			// counter and send the ref clock counter
			if (refCtr == REF_ROLLOVER) begin
				refCtr <= 0;
				async_reset <= 1'b1;
			end else begin
				refCtr <= refCtr + 1;
				async_reset <= 1'b0;
			end

			// After we're done measuring, take the value in the test clock counter
			if (refCtr == SAMPLE_TIME) begin
				value <= rateCtr_refclk;
			end
		end
	end

	// If the test clock isn't running, this reset will not deassert, but
	// this is actually just fine.  The result of that is that rateCtr will
	// stay at 0, which is exactly what happens anyway if the test clock
	// isn't running.
	// Anyway, this CDC block should make timing closure a little easier
	xpm_cdc_async_rst #(
		.DEST_SYNC_FF(2),
		.INIT_SYNC_FF(1),
		.RST_ACTIVE_HIGH(1)
	) reset_synchronizer (
		.dest_arst(async_reset_clk_test),
		.dest_clk(clk_test),
		.src_arst(async_reset)
	);

	// This CDC block helps make timing closure easier by moving the rateCtr
	// into the clk_ref domain.
	xpm_cdc_gray #(
		.DEST_SYNC_FF(2),
		.INIT_SYNC_FF(0),
		.REG_OUTPUT(0),
		.SIM_ASSERT_CHK(1),
		.SIM_LOSSLESS_GRAY_CHK(1),
		.WIDTH(24)
	) xpm_cdc_gray_inst (
		.dest_out_bin(rateCtr_refclk),
		.dest_clk(clk_ref),
		.src_clk(clk_test),
		.src_in_bin(rateCtr)
	);

	//=======================================================================
	// test clock domain
	//=======================================================================

	always_ff @(posedge clk_test or posedge async_reset_clk_test) begin
		if (async_reset_clk_test == 1'b1) begin
			rateCtr <= 0;
		end else begin
			rateCtr <= rateCtr + 1;
		end
	end
endmodule
