package LFSR_poly;
	logic [31:0] polynomials [99:0] = '{32'h80000057, 32'h80000062,
		32'h8000007A, 32'h80000092, 32'h800000B9, 32'h800000BA, 32'h80000106,
		32'h80000114, 32'h8000012D, 32'h8000014E, 32'h8000016C, 32'h8000019F,
		32'h800001A6, 32'h800001F3, 32'h8000020F, 32'h800002CC, 32'h80000349,
		32'h80000370, 32'h80000375, 32'h80000392, 32'h80000398, 32'h800003BF,
		32'h800003D6, 32'h800003DF, 32'h800003E9, 32'h80000412, 32'h80000414,
		32'h80000417, 32'h80000465, 32'h8000046A, 32'h80000478, 32'h800004D4,
		32'h800004F3, 32'h8000050B, 32'h80000526, 32'h8000054C, 32'h800005B6,
		32'h800005C1, 32'h800005EC, 32'h800005F1, 32'h8000060D, 32'h8000060E,
		32'h80000629, 32'h80000638, 32'h80000662, 32'h8000066D, 32'h80000676,
		32'h800006AE, 32'h800006B0, 32'h800006BC, 32'h800006D6, 32'h8000073C,
		32'h80000748, 32'h80000766, 32'h8000079C, 32'h800007B7, 32'h800007C3,
		32'h800007D4, 32'h800007D8, 32'h80000806, 32'h8000083F, 32'h80000850,
		32'h8000088D, 32'h800008E1, 32'h80000923, 32'h80000931, 32'h80000934,
		32'h8000093B, 32'h80000958, 32'h80000967, 32'h800009D5, 32'h80000A25,
		32'h80000A26, 32'h80000A54, 32'h80000A92, 32'h80000AC4, 32'h80000ACD,
		32'h80000B28, 32'h80000B71, 32'h80000B7B, 32'h80000B84, 32'h80000BA9,
		32'h80000BBE, 32'h80000BC6, 32'h80000C34, 32'h80000C3E, 32'h80000C43,
		32'h80000C7F, 32'h80000CA2, 32'h80000CEC, 32'h80000D0F, 32'h80000D22,
		32'h80000D28, 32'h80000D4E, 32'h80000DD7, 32'h80000E24, 32'h80000E35,
		32'h80000E66, 32'h80000E74, 32'h80000EA6};
	logic [31:0] PRBS15 = 32'h00006000;
	logic [31:0] PRBS7 =  32'h00000060;
endpackage

module multiLFSR #(
		parameter iterations = 1,
		parameter PRBS_type = "32bit",
		parameter polynomial_index = 0,
		parameter Usage = "generator",
		parameter N_CHANNELS = 1
	)(
		input  logic clk = 1'b0,
		input  logic aresetn = 1'b1,
		input  logic [32*N_CHANNELS - 1:0] S_AXIS_TDATA = 32'hffffffff,
		input  logic                       S_AXIS_TVALID = 1'b0,
		output logic                       S_AXIS_TREADY,
		output logic [32*N_CHANNELS - 1:0] data_delay_M_AXIS_TDATA,
		output logic                       data_delay_M_AXIS_TVALID,
		input  logic                       data_delay_M_AXIS_TREADY = 1'b1,
		output logic [32*N_CHANNELS - 1:0] LFSR_M_AXIS_TDATA,
		output logic                       LFSR_M_AXIS_TVALID,
		input  logic                       LFSR_M_AXIS_TREADY = 1'b1
	);
	
	typedef struct {
		logic [N_CHANNELS-1:0][32-1:0] LFSR;
		logic [N_CHANNELS-1:0][32-1:0] data_delay;
		logic M_AXIS_TVALID;
	} reg_type;

	reg_type d, q;

	logic clk_enable;

	assign S_AXIS_TREADY = 1'b1;

	logic [32-1:0] poly = ((PRBS_type == "PRBS15") ? LFSR_poly::PRBS15 : ((PRBS_type == "PRBS7") ? LFSR_poly::PRBS7 : LFSR_poly::polynomials[polynomial_index]));

	always_comb begin
		if (Usage == "generator") begin
			clk_enable = M_AXIS_TREADY;
			d.LFSR = q.LFSR;
			d.data_delay = '0;
		end else begin
			clk_enable = S_AXIS_TVALID;
			for (int j = 0; j < N_CHANNELS; j = j + 1) begin
				d.LFSR[j] = S_AXIS_TDATA[32*j +: 32];
				d.data_delay[j] = S_AXIS_TDATA[32*j +: 32];
			end
		end

		for (int j = 0; j < N_CHANNELS; j = j + 1) begin
			for (int i = 0; i < iterations; i = i + 1) begin
				d.LFSR[j] = {d.LFSR[j][30:0], ^(d.LFSR[j] & poly)};
			end
			LFSR_M_AXIS_TDATA[32*j +: 32] = q.LFSR[j];
			data_delay_M_AXIS_TDATA[32*j +: 32] = q.data_delay[j];
		end

		d.M_AXIS_TVALID = 1'b1;

		LFSR_M_AXIS_TVALID = q.M_AXIS_TVALID;
		data_delay_M_AXIS_TVALID = q.M_AXIS_TVALID;
	end

	always_ff @(posedge clk) begin
		if (aresetn == 0) begin
			q.LFSR <= 32'hFFFFFFFF;
			q.data_delay <= '0;
			q.M_AXIS_TVALID <= 1'b0;
		end else if (clk_enable == 1'b1) begin
			q <= d;
		end
	end
endmodule
