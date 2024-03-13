module dumb_stream_clock_conv #(
		parameter TDATA_WIDTH = 224
	)(
		input  logic M_CLK,
		input  logic S_CLK,

		input  logic [TDATA_WIDTH-1:0] S_AXIS_TDATA,
		input  logic S_AXIS_TVALID,
		output logic S_AXIS_TREADY,

		output logic [TDATA_WIDTH-1:0] M_AXIS_TDATA,
		output logic M_AXIS_TVALID,
		input logic M_AXIS_TREADY
	);

	// This does not actually do any real clock conversion.  It is only
	// suitable when
	//  * the two clocks are related (not asynchronous)
	//  * no width conversion is needed
	//  * up and downstream can handle TVALID and TREADY acting a bit weird
	//
	// If you don't know what you're doing, DON'T USE THIS

	assign M_AXIS_TDATA = S_AXIS_TDATA;
	assign M_AXIS_TVALID = S_AXIS_TVALID;
	assign S_AXIS_TREADY = M_AXIS_TREADY;

endmodule
