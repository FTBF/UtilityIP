module stream_bit_reverse #(
		parameter DATA_WIDTH = 32,
		parameter N_STREAMS = 1
	)(
		input  logic clk,
		input  logic aresetn,
		input  logic [N_STREAMS*DATA_WIDTH-1:0] S_AXIS_TDATA,
		input  logic S_AXIS_TVALID,
		output logic S_AXIS_TREADY,
		output logic [N_STREAMS*DATA_WIDTH-1:0] M_AXIS_TDATA,
		output logic M_AXIS_TVALID,
		input  logic M_AXIS_TREADY
	);

	always_comb begin
		for (int i = 0; i < N_STREAMS; i += 1) begin
			for (int j = 0; j < DATA_WIDTH; j += 1) begin
				M_AXIS_TDATA[DATA_WIDTH*i + j] = S_AXIS_TDATA[DATA_WIDTH*(i+1) - j - 1];
			end
		end
	end

	assign M_AXIS_TVALID = S_AXIS_TVALID;
	assign S_AXIS_TREADY = M_AXIS_TREADY;
endmodule
