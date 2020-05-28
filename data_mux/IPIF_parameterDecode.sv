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


module IPIF_parameterDecode#(
    parameter integer DATA_WIDTH = 32,
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer N_REG = 4
    )(
    input clk,
    
    input wire [C_S_AXI_DATA_WIDTH-1 : 0]  IPIF_bus2ip_data,  
    input wire [N_REG-1 : 0]               IPIF_bus2ip_rdce,
    input wire                             IPIF_bus2ip_resetn,
    input wire [N_REG-1 : 0]               IPIF_bus2ip_wrce,
    output reg [C_S_AXI_DATA_WIDTH-1 : 0]  IPIF_ip2bus_data,
    output reg                             IPIF_ip2bus_rdack,
    output reg                             IPIF_ip2bus_wrack,
    
    output reg [15:0]           n_idle_words,
    output reg [3:0]            output_select,
    output reg [DATA_WIDTH-1:0] idle_word
    );
    
    reg [31:0] read_reg;
    
    // send write acknowladge 
    always @(posedge clk or negedge IPIF_bus2ip_resetn) 
        if(!IPIF_bus2ip_resetn) IPIF_ip2bus_wrack <= 0;
        else                    IPIF_ip2bus_wrack <= |IPIF_bus2ip_wrce;

    
    always @(posedge clk or negedge IPIF_bus2ip_resetn)
    begin
        if(!IPIF_bus2ip_resetn)
        begin
            n_idle_words <= 256;
            output_select <= 0;
            idle_word <= 32'haccccccc;
        end
        else
        begin
            if(IPIF_bus2ip_wrce == (1 << 0))  //parameter 0
            begin
                output_select <= IPIF_bus2ip_data[3:0];
            end
            
            if(IPIF_bus2ip_wrce == (1 << 1))  //parameter 1
            begin
                n_idle_words <= IPIF_bus2ip_data[15:0];
            end
            
            if(IPIF_bus2ip_wrce == (1 << 2))  //parameter 2
            begin
                idle_word <= IPIF_bus2ip_data;
            end
            
        end
    end
            
    always @(posedge clk or negedge IPIF_bus2ip_resetn)
    begin
        if(!IPIF_bus2ip_resetn)
        begin
            IPIF_ip2bus_data <= 0;
            IPIF_ip2bus_rdack <= 0;
        end
        else
        begin
            IPIF_ip2bus_data <= read_reg;
            
            IPIF_ip2bus_rdack <= |IPIF_bus2ip_rdce;
        end
    end
    
    always_comb
    begin
        read_reg = '0;
        
        //channel readback 
        if(IPIF_bus2ip_rdce == (1 << 0)) read_reg = {28'b0, output_select};
        if(IPIF_bus2ip_rdce == (1 << 1)) read_reg = {16'b0, n_idle_words};
        if(IPIF_bus2ip_rdce == (1 << 2)) read_reg = idle_word;
    end

endmodule
