`timescale 1ns / 1ps

/*
* This module takes the IPIF_Bus2IP_RdCE or IPIF_Bus2IP_WrCE control signals,
* and first performs edge detection to get a single clock-cycle pulse, and
* then uses a systemverilog union to produce a struct of type PARAM_T in which
* each RdCE/WrCE bit is mapped onto the register names which are being written
* or read, for better ease of use, improved clarity, and more robust code.
*/

`default_nettype none
module IPIF_control_signals #(
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer N_REG = 2,
		parameter type PARAM_T = logic[N_REG*C_S_AXI_DATA_WIDTH-1:0]
	) (
		input  wire  bus_clk,
		input  wire  [N_REG-1:0] CE_in,
		output PARAM_T CE_out
	);

	typedef union packed {
		logic [N_REG-1:0][C_S_AXI_DATA_WIDTH-1:0] param_array;
		PARAM_T param_struct;
	} param_union_t;

	param_union_t CE_union;

	logic [2-1:0][N_REG-1:0] CE_edge_detect;

	always_ff @(posedge bus_clk) begin
		CE_edge_detect <= {CE_edge_detect[2-2:0], CE_in};
	end

	always_comb begin
		for (int i = 0; i < N_REG; i++) begin
			CE_union.param_array[i] = {C_S_AXI_DATA_WIDTH{CE_edge_detect[0][i] & ~CE_edge_detect[1][i]}};
		end
		CE_out = CE_union.param_struct;
	end
endmodule
`default_nettype wire
