module stream_compare (
	input logic clk,
	input logic aresetn,

	input logic [31:0] S_AXIS_0_TDATA,
	input logic S_AXIS_0_TVALID,
	output logic S_AXIS_0_TREADY,

	input logic [31:0] S_AXIS_1_TDATA,
	input logic S_AXIS_1_TVALID,
	output logic S_AXIS_1_TREADY,

	output logic [31:0] word_count,
	output logic [31:0] err_count);

	typedef struct {
		logic [31:0] word_count;
		logic [31:0] err_count;
	} reg_type;

	reg_type d, q;

	assign S_AXIS_0_TREADY = 1'b1;
	assign S_AXIS_1_TREADY = 1'b1;

	always_comb begin
		d = q;

		if ((S_AXIS_0_TVALID == 1'b1) && (S_AXIS_1_TVALID == 1'b1)) begin
			d.word_count = q.word_count + 1;

		   	if (S_AXIS_0_TDATA != S_AXIS_1_TDATA) begin
				d.err_count = q.err_count + 1;
			end
		end

		word_count = q.word_count;
		err_count = q.err_count;
	end

	always_ff @(posedge clk, negedge aresetn) begin
		if (aresetn == 0) begin
			q.word_count = 0;
			q.err_count = 0;
		end else begin
			q <= d;
		end
	end
endmodule
