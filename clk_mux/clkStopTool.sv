module clkStopTool #(
		parameter USE_DSP_REFCNT = 1,
		parameter USE_DSP_TESTCNT = 1,
		parameter USE_DSP_OUTPUT = 1,
		parameter integer CLK_REF_RATE_HZ     = 100000000,
		parameter integer CLK_TEST_RATE_HZ     = 40000000,
		parameter integer TOLERANCE_HZ          = 1000000,
		parameter integer COUNTER_WIDTH = 32,
		parameter real MEASURE_PERIOD_s = 0.125,
		parameter real MEASURE_TIME_s   = 0.125
	)(
		input  logic reset_in,
		input  logic clk_ref,
		input  logic clk_test,
		output logic [COUNTER_WIDTH-1:0] value, // value is synchronous to clk_ref
		output logic stopped
	);

	localparam integer REF_ROLLOVER = (CLK_REF_RATE_HZ * MEASURE_PERIOD_s);
	localparam integer SAMPLE_TIME  = (CLK_REF_RATE_HZ * MEASURE_TIME_s);
	localparam integer MAX_COUNT    = ((CLK_TEST_RATE_HZ + TOLERANCE_HZ) * MEASURE_TIME_s);
	localparam integer MIN_COUNT    = ((CLK_TEST_RATE_HZ - TOLERANCE_HZ) * MEASURE_TIME_s);

	//=======================================================================
	// test clock domain
	//=======================================================================

	(* use_dsp = (USE_DSP_TESTCNT ? "yes" : "no") *) logic [COUNTER_WIDTH-1:0] test_clock_counter;
	always_ff @(posedge clk_test) begin
		test_clock_counter <= test_clock_counter + 1'b1;
	end

	//=======================================================================
	// clock domain crossing: test clock domain to ref clock domain
	//=======================================================================

	logic [COUNTER_WIDTH-1:0] test_clock_counter_ref_clk;

	// This CDC block helps make timing closure easier by moving the test_clock_counter
	// into the clk_ref domain
	xpm_cdc_gray #(
		.DEST_SYNC_FF(2),
		.INIT_SYNC_FF(1),
		.REG_OUTPUT(0),
		.SIM_ASSERT_CHK(1),
		.SIM_LOSSLESS_GRAY_CHK(1),
		.WIDTH(COUNTER_WIDTH)
	) xpm_cdc_gray_inst (
		.dest_out_bin(test_clock_counter_ref_clk),
		.dest_clk(clk_ref),
		.src_clk(clk_test),
		.src_in_bin(test_clock_counter)
	);

	//=======================================================================
	// reference clock domain
	//=======================================================================

	logic rollover;
	logic measure;

	generate if (USE_DSP_REFCNT == 1) begin
		// Set up the reference clock counter using a DSP
		//
		// Use the pattern match feature to implement the rollover.
		//
		// If the measure time is equal to the rollover time, then we use the
		// pattern match for the measurement, otherwise we have to check the
		// actual value of the reference clock counter.

		logic [COUNTER_WIDTH-1:0] reference_clock_counter;
		DSP48E2 #(
			// Feature Control Attributes: Data Path Selection.
			.USE_MULT("NONE"),
			// Pattern Detector Attributes: Pattern Detection Configuration.
			.AUTORESET_PATDET("RESET_MATCH"),  // NO_RESET, RESET_MATCH, RESET_NOT_MATCH
			.AUTORESET_PRIORITY("RESET"),      // Priority of AUTORESET vs. CEP (CEP, RESET).
			.MASK(48'h0),                      // 48-bit mask value for pattern detect (1=ignore)
			.PATTERN(48'(REF_ROLLOVER - 1)),   // 48-bit pattern match for pattern detect
			.SEL_MASK("MASK"),                 // C, MASK, ROUNDING_MODE1, ROUNDING_MODE2
			.SEL_PATTERN("PATTERN"),           // Select pattern value (C, PATTERN)
			.USE_PATTERN_DETECT("PATDET"),     // Enable pattern detect (NO_PATDET, PATDET)
			// Register Control Attributes: Pipeline Register Configuration.
			.ACASCREG(0),                      // Number of pipeline stages between A/ACIN and ACOUT (0-2)
			.ADREG(1),                         // Pipeline stages for pre-adder (0-1)
			.ALUMODEREG(0),                    // Pipeline stages for ALUMODE (0-1)
			.AREG(0),                          // Pipeline stages for A (0-2)
			.BCASCREG(0),                      // Number of pipeline stages between B/BCIN and BCOUT (0-2)
			.BREG(0),                          // Pipeline stages for B (0-2)
			.CARRYINREG(0),                    // Pipeline stages for CARRYIN (0-1)
			.CARRYINSELREG(0),                 // Pipeline stages for CARRYINSEL (0-1)
			.CREG(0),                          // Pipeline stages for C (0-1)
			.DREG(1),                          // Pipeline stages for D (0-1)
			.INMODEREG(0),                     // Pipeline stages for INMODE (0-1)
			.MREG(0),                          // Multiplier pipeline stages (0-1)
			.OPMODEREG(0),                     // Pipeline stages for OPMODE (0-1)
			.PREG(1)                           // Number of pipeline stages for P (0-1)
		) reference_clock_counter_DSP (
			// Control outputs: Control Inputs/Status Bits.
			.PATTERNDETECT(rollover),          // 1-bit output: Pattern detect
			// Control inputs: Control Inputs/Status Bits.
			.ALUMODE(4'b0000),                 // 4-bit input: ALU control
			.CARRYINSEL(3'b000),               // 3-bit input: Carry select
			.CLK(clk_ref),                     // 1-bit input: Clock
			.INMODE(5'b00000),                 // 5-bit input: INMODE control
			.OPMODE(9'b01_000_00_00),          // 9-bit input: Operation mode
			// Data inputs: Data Ports.
			.CARRYIN(1'b1),                    // 1-bit input: Carry-in
			// Data outputs: Data Ports.
			.P(reference_clock_counter),       // 48-bit output: Primary data
			// Reset/Clock Enable inputs: Reset/Clock Enable Inputs.
			.CEP(1'b1),                        // 1-bit input: Clock enable for PREG
			// The following three (CED, CEAD, and RSTD) are recommended by Vivado
			// to be tied to GND when the multiplier is not used, to save power.
			.CED(1'b0),                        // 1-bit input: Clock enable for DREG
			.CEAD(1'b0),                       // 1-bit input: Clock enable for ADREG
			.RSTD(1'b0)                        // 1-bit input: Reset for DREG and ADREG
		);
		if (REF_ROLLOVER == SAMPLE_TIME) begin
			assign measure = rollover;
		end else begin
			assign measure = (reference_clock_counter == (SAMPLE_TIME - 1));
		end
	end else begin

		// The DSP implementation above is equivalent to the following RTL, but
		// this RTL does not infer a DSP instance that uses the DSP48's pattern
		// matching capabilities to implement the rollover signal, which is why we
		// explicitly instantiate the DSP48 above when USE_DSP_REFCNT is 1

		logic [COUNTER_WIDTH-1:0] reference_clock_counter = 0;
		always_ff @(posedge clk_ref) begin
			if (rollover) begin
				reference_clock_counter <= '0;
			end else begin
				reference_clock_counter <= reference_clock_counter + 1'b1;
			end
		end
		assign rollover = (reference_clock_counter == (REF_ROLLOVER - 1));
		if (REF_ROLLOVER == SAMPLE_TIME) begin
			assign measure = rollover;
		end else begin
			assign measure = (reference_clock_counter == (SAMPLE_TIME - 1));
		end
	end endgenerate

	(* use_dsp = (USE_DSP_OUTPUT ? "yes" : "no") *) logic [COUNTER_WIDTH-1:0] value_out = 0;
	logic [COUNTER_WIDTH-1:0] test_clock_counter_pipeline = 0;
	logic [COUNTER_WIDTH-1:0] test_clock_counter_start = 0;

	always_ff @(posedge clk_ref) begin
		// After we're done measuring, take the value in the test clock
		// counter and subtract the starting value of the test clock
		// counter, and set the new starting value to the current value
		// of the test clock counter
		if (measure) begin
			value_out <= test_clock_counter_pipeline - test_clock_counter_start;
			test_clock_counter_start <= test_clock_counter_pipeline;
			// Pipeline the test clock counter
			test_clock_counter_pipeline <= test_clock_counter_ref_clk;
		end
	end
	assign value = value_out;

	logic value_valid0 = 1'b0;
	logic value_valid1 = 1'b0;

	always_ff @(posedge clk_ref) begin
		if (reset_in == 1'b1) begin
			value_valid0 <= 1'b0;
			value_valid1 <= 1'b0;
			stopped <= 1'b0;
		end else begin
			if (measure) begin
				value_valid0 <= 1'b1;
				value_valid1 <= value_valid0;
			end

			// If the clock frequency is out of range, then call it stopped
			stopped <= ((value_valid1 == 1'b1) &&
			            ((value < MIN_COUNT) || (value > MAX_COUNT)));
		end
	end

endmodule
