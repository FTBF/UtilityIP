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
	output logic I2C_3_SDA_i,
	
	//master ports 
	output logic I2C_4_SCL_o,
	output logic I2C_4_SCL_t,
	input  logic I2C_4_SCL_i,
	output logic I2C_4_SDA_o,
	output logic I2C_4_SDA_t,
	input  logic I2C_4_SDA_i,
	output logic I2C_5_SCL_o,
	output logic I2C_5_SCL_t,
	input  logic I2C_5_SCL_i,
	output logic I2C_5_SDA_o,
	output logic I2C_5_SDA_t,
	input  logic I2C_5_SDA_i,
	output logic I2C_6_SCL_o,
	output logic I2C_6_SCL_t,
	input  logic I2C_6_SCL_i,
	output logic I2C_6_SDA_o,
	output logic I2C_6_SDA_t,
	input  logic I2C_6_SDA_i,
	output logic I2C_7_SCL_o,
	output logic I2C_7_SCL_t,
	input  logic I2C_7_SCL_i,
	output logic I2C_7_SDA_o,
	output logic I2C_7_SDA_t,
	input  logic I2C_7_SDA_i
);

logic SCL_i, SDA_i, SCL_t, SCA_t;

assign SCL_i = ((I2C_0_SCL_t | I2C_0_SCL_o) &
                (I2C_1_SCL_t | I2C_1_SCL_o) &
                (I2C_2_SCL_t | I2C_2_SCL_o) &
                (I2C_3_SCL_t | I2C_3_SCL_o) &
                (I2C_4_SCL_i) &
                (I2C_5_SCL_i) &
                (I2C_6_SCL_i) &
                (I2C_7_SCL_i));

assign SDA_i = ((I2C_0_SDA_t | I2C_0_SDA_o) &
                (I2C_1_SDA_t | I2C_1_SDA_o) &
                (I2C_2_SDA_t | I2C_2_SDA_o) &
                (I2C_3_SDA_t | I2C_3_SDA_o) &
                 I2C_4_SDA_i &
                 I2C_5_SDA_i &
                 I2C_6_SDA_i &
                 I2C_7_SDA_i);

assign SCL_t = I2C_0_SCL_t & I2C_1_SCL_t & I2C_2_SCL_t & I2C_3_SCL_t;
assign SDA_t = I2C_0_SDA_t & I2C_1_SDA_t & I2C_2_SDA_t & I2C_3_SDA_t;

assign I2C_0_SCL_i = SCL_i;
assign I2C_1_SCL_i = SCL_i;
assign I2C_2_SCL_i = SCL_i;
assign I2C_3_SCL_i = SCL_i;

assign I2C_0_SDA_i = SDA_i;
assign I2C_1_SDA_i = SDA_i;
assign I2C_2_SDA_i = SDA_i;
assign I2C_3_SDA_i = SDA_i;

assign I2C_4_SCL_t = SCL_t;
assign I2C_5_SCL_t = SCL_t;
assign I2C_6_SCL_t = SCL_t;
assign I2C_7_SCL_t = SCL_t;

assign I2C_4_SDA_t = SDA_t;
assign I2C_5_SDA_t = SDA_t;
assign I2C_6_SDA_t = SDA_t;
assign I2C_7_SDA_t = SDA_t;

assign I2C_4_SCL_o = SCL_i;
assign I2C_5_SCL_o = SCL_i;
assign I2C_6_SCL_o = SCL_i;
assign I2C_7_SCL_o = SCL_i;

assign I2C_4_SDA_o = SDA_i;
assign I2C_5_SDA_o = SDA_i;
assign I2C_6_SDA_o = SDA_i;
assign I2C_7_SDA_o = SDA_i;

endmodule
