module stream_cat #(
		parameter integer N_LINKS = 12,
		parameter integer DATA_WIDTH = 8
	)
	(
		input logic clk,
		input  logic [DATA_WIDTH-1:0] S_AXIS_00_TDATA,
		input  logic                  S_AXIS_00_TVALID,
		output logic                  S_AXIS_00_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_01_TDATA,
		input  logic                  S_AXIS_01_TVALID,
		output logic                  S_AXIS_01_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_02_TDATA,
		input  logic                  S_AXIS_02_TVALID,
		output logic                  S_AXIS_02_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_03_TDATA,
		input  logic                  S_AXIS_03_TVALID,
		output logic                  S_AXIS_03_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_04_TDATA,
		input  logic                  S_AXIS_04_TVALID,
		output logic                  S_AXIS_04_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_05_TDATA,
		input  logic                  S_AXIS_05_TVALID,
		output logic                  S_AXIS_05_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_06_TDATA,
		input  logic                  S_AXIS_06_TVALID,
		output logic                  S_AXIS_06_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_07_TDATA,
		input  logic                  S_AXIS_07_TVALID,
		output logic                  S_AXIS_07_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_08_TDATA,
		input  logic                  S_AXIS_08_TVALID,
		output logic                  S_AXIS_08_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_09_TDATA,
		input  logic                  S_AXIS_09_TVALID,
		output logic                  S_AXIS_09_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_10_TDATA,
		input  logic                  S_AXIS_10_TVALID,
		output logic                  S_AXIS_10_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_11_TDATA,
		input  logic                  S_AXIS_11_TVALID,
		output logic                  S_AXIS_11_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_12_TDATA,
		input  logic                  S_AXIS_12_TVALID,
		output logic                  S_AXIS_12_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_13_TDATA,
		input  logic                  S_AXIS_13_TVALID,
		output logic                  S_AXIS_13_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_14_TDATA,
		input  logic                  S_AXIS_14_TVALID,
		output logic                  S_AXIS_14_TREADY,
		input  logic [DATA_WIDTH-1:0] S_AXIS_15_TDATA,
		input  logic                  S_AXIS_15_TVALID,
		output logic                  S_AXIS_15_TREADY,
		output logic [N_LINKS*DATA_WIDTH - 1 : 0] data_out
	);

	logic [16*DATA_WIDTH-1:0] data_internal;

	assign data_internal = {S_AXIS_15_TDATA,
	                        S_AXIS_14_TDATA,
	                        S_AXIS_13_TDATA,
	                        S_AXIS_12_TDATA,
	                        S_AXIS_11_TDATA,
	                        S_AXIS_10_TDATA,
	                        S_AXIS_09_TDATA,
	                        S_AXIS_08_TDATA,
	                        S_AXIS_07_TDATA,
	                        S_AXIS_06_TDATA,
	                        S_AXIS_05_TDATA,
	                        S_AXIS_04_TDATA,
	                        S_AXIS_03_TDATA,
	                        S_AXIS_02_TDATA,
	                        S_AXIS_01_TDATA,
	                        S_AXIS_00_TDATA};

	assign data_out = data_internal[N_LINKS*DATA_WIDTH - 1 : 0];

	assign S_AXIS_00_TREADY = 1'b1;
	assign S_AXIS_01_TREADY = 1'b1;
	assign S_AXIS_02_TREADY = 1'b1;
	assign S_AXIS_03_TREADY = 1'b1;
	assign S_AXIS_04_TREADY = 1'b1;
	assign S_AXIS_05_TREADY = 1'b1;
	assign S_AXIS_06_TREADY = 1'b1;
	assign S_AXIS_07_TREADY = 1'b1;
	assign S_AXIS_08_TREADY = 1'b1;
	assign S_AXIS_09_TREADY = 1'b1;
	assign S_AXIS_10_TREADY = 1'b1;
	assign S_AXIS_11_TREADY = 1'b1;
	assign S_AXIS_12_TREADY = 1'b1;
	assign S_AXIS_13_TREADY = 1'b1;
	assign S_AXIS_14_TREADY = 1'b1;
	assign S_AXIS_15_TREADY = 1'b1;
endmodule
