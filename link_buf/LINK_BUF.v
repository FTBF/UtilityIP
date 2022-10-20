`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2020 04:24:30 PM
// Design Name: 
// Module Name: LINK_BUF
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


module LINK_BUF #(
        parameter NLINK = 1,
        parameter [NLINK-1:0] INVERT = 0
    )(
        input wire [NLINK-1:0] d_in_p,
        input wire [NLINK-1:0] d_in_n,
        output wire [NLINK-1:0] d_out_p,
        output wire [NLINK-1:0] d_out_n
    );
    
    generate
        genvar i;
        for(i = 0; i < NLINK; i = i + 1)
        begin : buffer
            if(INVERT[i] == 0) IBUFDS_DIFF_OUT diff_buff(.I(d_in_p[i]), .IB(d_in_n[i]), .O(d_out_p[i]), .OB(d_out_n[i]));
            else               IBUFDS_DIFF_OUT diff_buff(.I(d_in_p[i]), .IB(d_in_n[i]), .O(d_out_n[i]), .OB(d_out_p[i]));
        end
    endgenerate
    
endmodule
