`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 05/18/2020 05:36:34 PM
// Design Name:
// Module Name: IPIF_parameterDecode
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module IPIF_parameterDecode #(
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer N_REG = 2,
		parameter type PARAM_T = logic[N_REG*C_S_AXI_DATA_WIDTH-1:0],
		parameter PARAM_T DEFAULTS = {C_S_AXI_DATA_WIDTH*N_REG*{1'b0}},
		parameter PARAM_T SELF_RESET = {C_S_AXI_DATA_WIDTH*N_REG*{1'b0}}
	)(
		input clk,

		input wire [C_S_AXI_DATA_WIDTH-1 : 0]  IPIF_bus2ip_data,
		input wire [N_REG-1 : 0]               IPIF_bus2ip_rdce,
		input wire                             IPIF_bus2ip_resetn,
		input wire [N_REG-1 : 0]               IPIF_bus2ip_wrce,
		output reg [C_S_AXI_DATA_WIDTH-1 : 0]  IPIF_ip2bus_data,
		output reg                             IPIF_ip2bus_rdack,
		output reg                             IPIF_ip2bus_wrack,

		output PARAM_T  parameters_out,
		input PARAM_T parameters_in
	);

	reg [C_S_AXI_DATA_WIDTH-1:0] read_reg;

	typedef union packed {
		PARAM_T param_struct;
		logic [N_REG-1:0][C_S_AXI_DATA_WIDTH-1:0] param_array;
	} param_union_t;

	param_union_t SR_union;
	assign SR_union.param_struct = SELF_RESET;

	param_union_t DEF_union;
	assign DEF_union.param_struct = DEFAULTS;

	param_union_t param_union_in;
	assign param_union_in.param_struct = parameters_in;

	param_union_t param_union_out;
	assign parameters_out = param_union_out.param_struct;

	// send write acknowladge
	always @(posedge clk or negedge IPIF_bus2ip_resetn)
		if(!IPIF_bus2ip_resetn) IPIF_ip2bus_wrack <= 0;
		else                    IPIF_ip2bus_wrack <= |IPIF_bus2ip_wrce;

	always @(posedge clk or negedge IPIF_bus2ip_resetn) begin
		if(!IPIF_bus2ip_resetn) begin
			param_union_out.param_struct <= DEFAULTS;
		end else begin
			for(int i = 0; i < N_REG; i += 1) begin
				if(IPIF_bus2ip_wrce == (1 << i)) begin
					param_union_out.param_array[i] <= IPIF_bus2ip_data;
				end else begin
					for (int j = 0; j < C_S_AXI_DATA_WIDTH; j += 1) begin
						if ((SR_union.param_array[i][j] == 1'b1) &&
						    (param_union_in.param_array[i][j] != DEF_union.param_array[i][j])) begin
							param_union_out.param_array[i][j] <= DEF_union.param_array[i][j];
						end else begin
							param_union_out.param_array[i][j] <= param_union_out.param_array[i][j];
						end
					end
				end
			end
		end
	end

	always @(posedge clk or negedge IPIF_bus2ip_resetn) begin
		if(!IPIF_bus2ip_resetn) begin
			IPIF_ip2bus_data <= 0;
			IPIF_ip2bus_rdack <= 0;
		end else begin
			IPIF_ip2bus_data <= read_reg;
			IPIF_ip2bus_rdack <= |IPIF_bus2ip_rdce;
		end
	end

	always_comb begin
		read_reg = '0;

		//channel readback
		for(int i = 0; i < N_REG; i += 1) begin
			if(IPIF_bus2ip_rdce == (1 << i)) read_reg = param_union_in.param_array[i];
		end
	end
endmodule
