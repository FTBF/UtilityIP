module stream_split (
	input logic clk40,
	input logic [383:0] data_in,
	input logic [11:0] valid_in,
	output logic [31:0] M00_AXIS_TDATA,
	output logic        M00_AXIS_TVALID,
	output logic [31:0] M01_AXIS_TDATA,
	output logic        M01_AXIS_TVALID,
	output logic [31:0] M02_AXIS_TDATA,
	output logic        M02_AXIS_TVALID,
	output logic [31:0] M03_AXIS_TDATA,
	output logic        M03_AXIS_TVALID,
	output logic [31:0] M04_AXIS_TDATA,
	output logic        M04_AXIS_TVALID,
	output logic [31:0] M05_AXIS_TDATA,
	output logic        M05_AXIS_TVALID,
	output logic [31:0] M06_AXIS_TDATA,
	output logic        M06_AXIS_TVALID,
	output logic [31:0] M07_AXIS_TDATA,
	output logic        M07_AXIS_TVALID,
	output logic [31:0] M08_AXIS_TDATA,
	output logic        M08_AXIS_TVALID,
	output logic [31:0] M09_AXIS_TDATA,
	output logic        M09_AXIS_TVALID,
	output logic [31:0] M10_AXIS_TDATA,
	output logic        M10_AXIS_TVALID,
	output logic [31:0] M11_AXIS_TDATA,
	output logic        M11_AXIS_TVALID);

	assign M00_AXIS_TDATA = data_in[ 0*32 +: 32];
	assign M01_AXIS_TDATA = data_in[ 1*32 +: 32];
	assign M02_AXIS_TDATA = data_in[ 2*32 +: 32];
	assign M03_AXIS_TDATA = data_in[ 3*32 +: 32];
	assign M04_AXIS_TDATA = data_in[ 4*32 +: 32];
	assign M05_AXIS_TDATA = data_in[ 5*32 +: 32];
	assign M06_AXIS_TDATA = data_in[ 6*32 +: 32];
	assign M07_AXIS_TDATA = data_in[ 7*32 +: 32];
	assign M08_AXIS_TDATA = data_in[ 8*32 +: 32];
	assign M09_AXIS_TDATA = data_in[ 9*32 +: 32];
	assign M10_AXIS_TDATA = data_in[10*32 +: 32];
	assign M11_AXIS_TDATA = data_in[11*32 +: 32];

	assign M00_AXIS_TVALID = valid_in[ 0];
	assign M01_AXIS_TVALID = valid_in[ 1];
	assign M02_AXIS_TVALID = valid_in[ 2];
	assign M03_AXIS_TVALID = valid_in[ 3];
	assign M04_AXIS_TVALID = valid_in[ 4];
	assign M05_AXIS_TVALID = valid_in[ 5];
	assign M06_AXIS_TVALID = valid_in[ 6];
	assign M07_AXIS_TVALID = valid_in[ 7];
	assign M08_AXIS_TVALID = valid_in[ 8];
	assign M09_AXIS_TVALID = valid_in[ 9];
	assign M10_AXIS_TVALID = valid_in[10];
	assign M11_AXIS_TVALID = valid_in[11];

endmodule
