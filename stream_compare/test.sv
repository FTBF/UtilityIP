`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2020 01:55:03 PM
// Design Name: 
// Module Name: test
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


module test(

    );
    
    localparam C_S_AXI_ADDR_WIDTH = 32;
    localparam C_S_AXI_DATA_WIDTH = 32;
    localparam N_REG = 4;
    
	logic clk = 0;
	logic aresetn;

	logic [31:0] S_AXIS_0_TDATA;
	logic S_AXIS_0_TVALID;
	logic S_AXIS_0_TREADY;

	logic [31:0] S_AXIS_1_TDATA;
	logic S_AXIS_1_TVALID;
	logic S_AXIS_1_TREADY;

    //configuration parameter interface 
    logic                                  IPIF_Bus2IP_resetn;
    logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr;   //unused
    logic                                  IPIF_Bus2IP_RNW;    //unused
    logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE;     //unused
    logic [0 : 0]                          IPIF_Bus2IP_CS;     //unused
    logic [N_REG-1 : 0]                    IPIF_Bus2IP_RdCE; 
    logic [N_REG-1 : 0]                    IPIF_Bus2IP_WrCE;
    logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data;
    logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data;
    logic                                  IPIF_IP2Bus_WrAck;
    logic                                  IPIF_IP2Bus_RdAck;
    logic                                  IPIF_IP2Bus_Error;	
    
    always #10 clk <= !clk;
    
    stream_compare #(C_S_AXI_ADDR_WIDTH, C_S_AXI_DATA_WIDTH, N_REG) str_cmp (.*);
    
    initial
    begin
        aresetn = 1;
        IPIF_Bus2IP_resetn = 1;
        IPIF_Bus2IP_Addr = 0;
        IPIF_Bus2IP_RNW = 0;
        IPIF_Bus2IP_RdCE = 0;
        IPIF_Bus2IP_WrCE = 0;
        IPIF_Bus2IP_Data = 0;
        
        S_AXIS_0_TDATA = 32'h12345678;
        S_AXIS_0_TVALID = 1;
        
        S_AXIS_1_TDATA = 32'h12345679;
        S_AXIS_1_TVALID = 1;
        
        #100 aresetn = 0;
        IPIF_Bus2IP_resetn = 0;
        #20  aresetn = 1;
        IPIF_Bus2IP_resetn = 1;
        
        #100 IPIF_Bus2IP_Data = 1;
        #40 IPIF_Bus2IP_WrCE = 4'b1;
        #80 IPIF_Bus2IP_WrCE = 4'b0;
        
        #100 IPIF_Bus2IP_Data = 2;
        #40 IPIF_Bus2IP_WrCE = 4'b1;
        #80 IPIF_Bus2IP_WrCE = 4'b0;
    end
    
endmodule
