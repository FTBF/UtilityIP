
//============================================================================
// University of Minnesota
//============================================================================
// Contact: frahm@physics.umn.edu
//============================================================================
// clkRateTool2 - Modified version of Jeremy's clock rate tool
// This version uses an async reset to track clocks that go to 0 Hz.
//============================================================================

module clkRateTool (
	input reset_in,
	input clk100,
	input clktest,
	output reg [31:0] value);

	reg [23:0] refCtr;
	reg [23:0] rateCtr;

	reg async_reset;
	wire async_reset_clktest;
	reg counting1a, counting1b;

	//=======================================================================
	// 100 MHz clock domain
	//=======================================================================

	always @(posedge clk100) begin
		if (reset_in) begin
			refCtr <= 0;
			counting1a <= 0;
			async_reset <= 1;
			value<=32'hffffffff;
		end else begin
			if (refCtr == 24'h800000) refCtr <= 0; // 
			else refCtr <= refCtr+24'h1;

			if (refCtr < 24'd1000000) counting1a <= 1; 
			else counting1a <= 0;

			if (refCtr == 24'h100000) value <= rateCtr;                // 1,048,576
			else if (reset_in) value<=32'hffffffff;
			else value <= value;

			if ((refCtr & 24'hFFFF00) == 24'h110000) async_reset <= 1; // 1,114,112
			else async_reset <= reset_in;
		end
	end

	// If the test clock isn't running, this reset will not deassert, but
	// this is actually just fine.  The result of that is that rateCtr will
	// stay at 0, which is exactly what happens anyway if the test clock
	// isn't running.
	// Anyway, this CDC block should make timing closure a little easier.
	xpm_cdc_async_rst #(
		.DEST_SYNC_FF(2), // DECIMAL; range: 2-10
		.INIT_SYNC_FF(1), // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
		.RST_ACTIVE_HIGH(1) // DECIMAL; 0=active low reset, 1=active high reset
	)
	reset_synchronizer (
		.dest_arst(async_reset_clktest), // 1-bit output: src_arst asynchronous reset signal synchronized to destination
		                                 // clock domain. This output is registered. NOTE: Signal asserts asynchronously
		                                 // but deasserts synchronously to dest_clk. Width of the reset signal is at least
		                                 // (DEST_SYNC_FF*dest_clk) period.
		.dest_clk(clktest), // 1-bit input: Destination clock.
		.src_arst(async_reset) // 1-bit input: Source asynchronous reset signal.
	);

	//=======================================================================
	// test clock domain
	//=======================================================================

	// on for 0.01 s; off for 0.08 s
	always @(posedge clktest) begin
		counting1b <= counting1a; 
	end
	always @(posedge clktest or posedge async_reset_clktest) begin
		if (async_reset_clktest == 1) rateCtr <= 0;
		else if ((counting1b) == 1) rateCtr <= rateCtr+24'h1;
		else rateCtr <= rateCtr;
	end

endmodule
