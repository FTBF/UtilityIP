module I2C_interconnect (
	input  logic I2C_0_SCL_o,
	input  logic I2C_0_SCL_t,
	output logic I2C_0_SCL_i,
	input  logic I2C_0_SDA_o,
	input  logic I2C_0_SDA_t,
	output logic I2C_0_SDA_i,
	input  logic I2C_1_SCL_o,
	input  logic I2C_1_SCL_t,
	output logic I2C_1_SCL_i,
	input  logic I2C_1_SDA_o,
	input  logic I2C_1_SDA_t,
	output logic I2C_1_SDA_i,
	input  logic I2C_2_SCL_o,
	input  logic I2C_2_SCL_t,
	output logic I2C_2_SCL_i,
	input  logic I2C_2_SDA_o,
	input  logic I2C_2_SDA_t,
	output logic I2C_2_SDA_i,
	input  logic I2C_3_SCL_o,
	input  logic I2C_3_SCL_t,
	output logic I2C_3_SCL_i,
	input  logic I2C_3_SDA_o,
	input  logic I2C_3_SDA_t,
	output logic I2C_3_SDA_i
);

logic SCL_i, SDA_i;

assign SCL_i = ((I2C_0_SCL_t | I2C_0_SCL_o) &
                (I2C_1_SCL_t | I2C_1_SCL_o) &
                (I2C_2_SCL_t | I2C_2_SCL_o) &
                (I2C_3_SCL_t | I2C_3_SCL_o));

assign SDA_i = ((I2C_0_SDA_t | I2C_0_SDA_o) &
                (I2C_1_SDA_t | I2C_1_SDA_o) &
                (I2C_2_SDA_t | I2C_2_SDA_o) &
                (I2C_3_SDA_t | I2C_3_SDA_o));

assign I2C_0_SCL_i = SCL_i;
assign I2C_1_SCL_i = SCL_i;
assign I2C_2_SCL_i = SCL_i;
assign I2C_3_SCL_i = SCL_i;

assign I2C_0_SDA_i = SDA_i;
assign I2C_1_SDA_i = SDA_i;
assign I2C_2_SDA_i = SDA_i;
assign I2C_3_SDA_i = SDA_i;

endmodule
