module stream_bit_reverse #(
	parameter DATA_WIDTH = 32
	)(
	input  wire clk,
	input  wire aresetn,
	input  wire [DATA_WIDTH-1:0] S_AXIS_TDATA,
	input  wire S_AXIS_TVALID,
	output wire S_AXIS_TREADY,
	output wire [DATA_WIDTH-1:0] M_AXIS_TDATA,
	output wire M_AXIS_TVALID,
	input  wire M_AXIS_TREADY);

	genvar i;
	generate 
		for(i=0; i < DATA_WIDTH; i = i+1) begin
			assign M_AXIS_TDATA[i] = S_AXIS_TDATA[DATA_WIDTH-1-i];
		end
	endgenerate

	assign M_AXIS_TVALID = S_AXIS_TVALID;
	assign S_AXIS_TREADY = M_AXIS_TREADY;
endmodule
