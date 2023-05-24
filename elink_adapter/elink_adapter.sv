`timescale 1ns / 1ps

module elink_adapter #(
		parameter N_LINKS = 1,
		parameter INPUT_WIDTH = 32,
		parameter OUTPUT_WIDTH = 8
	)(
		input  logic clk160,
		input  logic clk160_aresetn,

		input  logic [N_LINKS*INPUT_WIDTH-1:0] S_AXIS_tdata,
		input  logic S_AXIS_tvalid,
		output logic S_AXIS_tready,

		output logic [N_LINKS*OUTPUT_WIDTH-1:0] M_AXIS_tdata,
		output logic M_AXIS_tvalid,
		input  logic M_AXIS_tready
	);

	typedef enum {WAIT, BYTE_0, BYTE_1, BYTE_2, BYTE_3} state_type;

	typedef struct {
		state_type state;
		logic [N_LINKS*32-1:0] data;
	} reg_type;
	reg_type D, Q;

	generate
	if          ((INPUT_WIDTH == 32) && (OUTPUT_WIDTH == 32)) begin
		// Nothing to do
		assign M_AXIS_tdata  = S_AXIS_tdata;
		assign M_AXIS_tvalid = S_AXIS_tvalid;
		assign S_AXIS_tready  = M_AXIS_tready;
	end else if ((INPUT_WIDTH == 32) && (OUTPUT_WIDTH ==  8)) begin
		// Downconversion
		always_comb begin
			D = Q;

			case (Q.state)
				WAIT: begin
					S_AXIS_tready = 1'b1;
					M_AXIS_tvalid = 1'b0;
					M_AXIS_tdata = 'X;

					if (S_AXIS_tvalid == 1'b1) begin
						D.data = S_AXIS_tdata;
						D.state = BYTE0;
					end
				end

				BYTE0: begin
					S_AXIS_tready = 1'b0;
					M_AXIS_tvalid = 1'b1;
					for (int link_index = 0; link_index < N_LINKS; link_index++) begin
						M_AXIS_tdata[link_index*8 +: 8] = Q.data[32*link_index + 24 +: 8];
					end

					if (M_AXIS_tready == 1'b1) begin
						D.state = BYTE1;
					end
				end

				BYTE1: begin
					S_AXIS_tready = 1'b0;
					M_AXIS_tvalid = 1'b1;
					for (int link_index = 0; link_index < N_LINKS; link_index++) begin
						M_AXIS_tdata[link_index*8 +: 8] = Q.data[32*link_index + 16 +: 8];
					end

					if (M_AXIS_tready == 1'b1) begin
						D.state = BYTE2;
					end
				end

				BYTE2: begin
					S_AXIS_tready = 1'b0;
					M_AXIS_tvalid = 1'b1;
					for (int link_index = 0; link_index < N_LINKS; link_index++) begin
						M_AXIS_tdata[link_index*8 +: 8] = Q.data[32*link_index +  8 +: 8];
					end

					if (M_AXIS_tready == 1'b1) begin
						D.state = BYTE3;
					end
				end

				BYTE3: begin
					S_AXIS_tready = M_AXIS_tready;
					M_AXIS_tvalid = 1'b1;
					for (int link_index = 0; link_index < N_LINKS; link_index++) begin
						M_AXIS_tdata[link_index*8 +: 8] = Q.data[32*link_index +  0 +: 8];
					end

					if (M_AXIS_tready == 1'b1) begin
						if (S_AXIS_tvalid == 1'b1) begin
							D.data = S_AXIS_tdata;
							D.state = BYTE0;
						end else begin
							D.state = WAIT;
						end
					end
				end
			endcase
		end

		always_ff @(posedge clk160) begin
			if (clk160_aresetn == 1'b0) begin
				Q.state <= WAIT;
				Q.data <= '0;
			end else begin
				Q <= D;
			end
		end
	end else if ((INPUT_WIDTH ==  8) && (OUTPUT_WIDTH == 32)) begin
		// Upconversion
		// FIXME
		always_comb begin
			D = Q;

			case (Q.state)
				BYTE0: begin
					if (S_AXIS_tvalid == 1'b1) begin
						for (int link_index = 0; link_index < N_LINKS; link_index++) begin
							D.data[32*link_index + 24 +: 8] = S_AXIS_tdata[8*link_index +: 8];
						end
						D.state = BYTE1;
					end

					S_AXIS_tready = 1'b1;
					M_AXIS_tvalid = 1'b0;
					M_AXIS_tdata = 'X;
				end

				BYTE1: begin
					if (S_AXIS_tvalid == 1'b1) begin
						for (int link_index = 0; link_index < N_LINKS; link_index++) begin
							D.data[32*link_index + 16 +: 8] = S_AXIS_tdata[8*link_index +: 8];
						end
						D.state = BYTE2;
					end

					S_AXIS_tready = 1'b1;
					M_AXIS_tvalid = 1'b0;
					M_AXIS_tdata = 'X;
				end

				BYTE2: begin
					if (S_AXIS_tvalid == 1'b1) begin
						for (int link_index = 0; link_index < N_LINKS; link_index++) begin
							D.data[32*link_index +  8 +: 8] = S_AXIS_tdata[8*link_index +: 8];
						end
						D.state = BYTE3;
					end

					S_AXIS_tready = 1'b1;
					M_AXIS_tvalid = 1'b0;
					M_AXIS_tdata = 'X;
				end

				BYTE3: begin
					if (S_AXIS_tvalid == 1'b1) begin
						for (int link_index = 0; link_index < N_LINKS; link_index++) begin
							D.data[32*link_index +  8 +: 8] = S_AXIS_tdata[8*link_index +: 8];
						end
						if (M_AXIS_tready == 1'b1) begin
							D.state = BYTE0;
						end else begin
							D.state = WAIT;
						end
					end

					S_AXIS_tready = 1'b1;
					M_AXIS_tvalid = S_AXIS_tvalid;
					M_AXIS_tdata = D.data;
				end

				WAIT: begin
					if (M_AXIS_tready == 1'b1) begin
						D.state = BYTE0;
					end

					S_AXIS_tready = 1'b0;
					M_AXIS_tvalid = 1'b1;
					M_AXIS_tdata = D.data;
				end
			endcase
		end

		always_ff @(posedge clk160) begin
			if (clk160_aresetn == 1'b0) begin
				Q.state <= BYTE0;
				Q.data <= '0;
			end else begin
				Q <= D;
			end
		end
	end else if ((INPUT_WIDTH ==  8) && (OUTPUT_WIDTH ==  8)) begin
		// Nothing to do
		assign M_AXIS_tdata  = S_AXIS_tdata;
		assign M_AXIS_tvalid = S_AXIS_tvalid;
		assign S_AXIS_tready  = M_AXIS_tready;
	end
	endgenerate
endmodule
