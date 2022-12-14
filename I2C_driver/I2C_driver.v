`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2019 11:09:00 AM
// Design Name: 
// Module Name: I2C_driver
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


module iic_buffer#(
    parameter SCL_OPEN_COLLECTOR = 1

    )(
    output iic_scl_i, // IIC Serial Clock Input from 3-state buffer (required)
    input iic_scl_o, // IIC Serial Clock Output to 3-state buffer (required)
    input iic_scl_t, // IIC Serial Clock Output Enable to 3-state buffer (required)
    output iic_sda_i, // IIC Serial Data Input from 3-state buffer (required)
    input iic_sda_o, // IIC Serial Data Output to 3-state buffer (required)
    input iic_sda_t, // IIC Serial Data Output Enable to 3-state buffer (required)

	inout SCL,
	inout SDA
	
	
    );
    
    IOBUF sda_buf(.I(1'b0), .O(iic_sda_i), .T(iic_sda_o | iic_sda_t), .IO(SDA));
    
   wire       SCLtmp;
   assign SCLtmp =  iic_scl_o| iic_scl_t;
    generate
        if(SCL_OPEN_COLLECTOR)
        begin
            IOBUF scl_buf(.I(1'b0), .O(iic_scl_i), .T(SCLtmp), .IO(SCL));
        end
        else
        begin
            IOBUF scl_buf(.I(SCLtmp), .O(iic_scl_i), .T(1'b0), .IO(SCL));
        end
    endgenerate 
   
endmodule
