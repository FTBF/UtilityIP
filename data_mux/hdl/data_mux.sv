`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2020 04:30:47 PM
// Design Name: 
// Module Name: stream_mux
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


module data_mux#(
    parameter integer DATA_WIDTH = 32,
    parameter integer N_INPUTS = 2,
    parameter OUTPUT_REVERSE_BITS = 1,
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 32,
    parameter integer N_REG = 4
    ) 
    (
    //Clock
    input wire clk,
    
    //Input AXIS busses
    input  wire [DATA_WIDTH-1:0] axis_0_tdata_in,
    input  wire                  axis_0_tvalid_in,
    output wire                  axis_0_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_1_tdata_in,
    input  wire                  axis_1_tvalid_in,
    output wire                  axis_1_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_2_tdata_in,
    input  wire                  axis_2_tvalid_in,
    output wire                  axis_2_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_3_tdata_in,
    input  wire                  axis_3_tvalid_in,
    output wire                  axis_3_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_4_tdata_in,
    input  wire                  axis_4_tvalid_in,
    output wire                  axis_4_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_5_tdata_in,
    input  wire                  axis_5_tvalid_in,
    output wire                  axis_5_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_6_tdata_in,
    input  wire                  axis_6_tvalid_in,
    output wire                  axis_6_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_7_tdata_in,
    input  wire                  axis_7_tvalid_in,
    output wire                  axis_7_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_8_tdata_in,
    input  wire                  axis_8_tvalid_in,
    output wire                  axis_8_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_9_tdata_in,
    input  wire                  axis_9_tvalid_in,
    output wire                  axis_9_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_10_tdata_in,
    input  wire                  axis_10_tvalid_in,
    output wire                  axis_10_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_11_tdata_in,
    input  wire                  axis_11_tvalid_in,
    output wire                  axis_11_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_12_tdata_in,
    input  wire                  axis_12_tvalid_in,
    output wire                  axis_12_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_13_tdata_in,
    input  wire                  axis_13_tvalid_in,
    output wire                  axis_13_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_14_tdata_in,
    input  wire                  axis_14_tvalid_in,
    output wire                  axis_14_tready_in,
    
    input  wire [DATA_WIDTH-1:0] axis_15_tdata_in,
    input  wire                  axis_15_tvalid_in,
    output wire                  axis_15_tready_in,
    
    //Output AXIS bus
    output wire [DATA_WIDTH-1:0] axis_out_tdata,
    output wire                  axis_out_tvalid,
    input  wire                  axis_out_tready,
    
    //configuration parameter interface 
    input  wire                                  IPIF_Bus2IP_resetn,
    input  wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr,   //unused
    input  wire                                  IPIF_Bus2IP_RNW,    //unused
    input  wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE,     //unused
    input  wire [0 : 0]                          IPIF_Bus2IP_CS,     //unused
    input  wire [N_REG-1 : 0]                    IPIF_Bus2IP_RdCE, 
    input  wire [N_REG-1 : 0]                    IPIF_Bus2IP_WrCE,
    input  wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data,
    output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data,
    output wire                                  IPIF_IP2Bus_WrAck,
    output wire                                  IPIF_IP2Bus_RdAck,
    output wire                                  IPIF_IP2Bus_Error,
    
    //fast control parameter
    input wire fc_linkReset
    );
    
    //decode configuration parameters from IPIF bus 
    wire [15:0]           n_idle_words;
    wire [3:0]            output_select;
    wire [DATA_WIDTH-1:0] idle_word;
    
    assign IPIF_IP2Bus_Error = 0;
    
    typedef struct packed
    {
        logic [31:0]           padding3;
        logic [DATA_WIDTH-1:0] idle_word;
        logic [15:0]           padding2;
        logic [15:0]           n_idle_words;
        logic [27:0]           padding1;
        logic [3:0]            output_select;
    } param_t;
    
    param_t params_in;
    param_t params_out;
    
    assign params_in.output_select = params_out.output_select;
    assign params_in.n_idle_words = params_out.n_idle_words;
    assign params_in.idle_word = params_out.idle_word;
    
    IPIF_parameterDecode#(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .N_REG(N_REG),
        .PARAM_T(param_t),
        .DEFAULTS({32'b0, 32'haccccccc, 16'b0, 16'd256, 23'b0})
    ) parameterDecoder (
        .clk(clk),
        
        .IPIF_bus2ip_data(IPIF_Bus2IP_Data),  
        .IPIF_bus2ip_rdce(IPIF_Bus2IP_RdCE),
        .IPIF_bus2ip_resetn(IPIF_Bus2IP_resetn),
        .IPIF_bus2ip_wrce(IPIF_Bus2IP_WrCE),
        .IPIF_ip2bus_data(IPIF_IP2Bus_Data),
        .IPIF_ip2bus_rdack(IPIF_IP2Bus_RdAck),
        .IPIF_ip2bus_wrack(IPIF_IP2Bus_WrAck),
        
        .parameters_out(params_out),
        .parameters_in(params_in)
    );
    
    //map ports (necessary for IP packaging) to a more user friends data structure 
    wire [DATA_WIDTH-1:0] tdata_in_all  [16] = {axis_0_tdata_in,  axis_1_tdata_in,  axis_2_tdata_in,  axis_3_tdata_in,  axis_4_tdata_in,  axis_5_tdata_in,  axis_6_tdata_in,  axis_7_tdata_in,  axis_8_tdata_in,  axis_9_tdata_in,  axis_10_tdata_in,  axis_11_tdata_in,  axis_12_tdata_in,  axis_13_tdata_in,  axis_14_tdata_in,  axis_15_tdata_in};
    wire                  tvalid_in_all [16] = {axis_0_tvalid_in, axis_1_tvalid_in, axis_2_tvalid_in, axis_3_tvalid_in, axis_4_tvalid_in, axis_5_tvalid_in, axis_6_tvalid_in, axis_7_tvalid_in, axis_8_tvalid_in, axis_9_tvalid_in, axis_10_tvalid_in, axis_11_tvalid_in, axis_12_tvalid_in, axis_13_tvalid_in, axis_14_tvalid_in, axis_15_tvalid_in};
    wire                  tready_in_all [16];
    
    assign axis_0_tready_in = tready_in_all[0];
    assign axis_1_tready_in = tready_in_all[1];
    assign axis_2_tready_in = tready_in_all[2];
    assign axis_3_tready_in = tready_in_all[3];
    assign axis_4_tready_in = tready_in_all[4];
    assign axis_5_tready_in = tready_in_all[5];
    assign axis_6_tready_in = tready_in_all[6];
    assign axis_7_tready_in = tready_in_all[7];
    assign axis_8_tready_in = tready_in_all[8];
    assign axis_9_tready_in = tready_in_all[9];
    assign axis_10_tready_in = tready_in_all[10];
    assign axis_11_tready_in = tready_in_all[11];
    assign axis_12_tready_in = tready_in_all[12];
    assign axis_13_tready_in = tready_in_all[13];
    assign axis_14_tready_in = tready_in_all[14];
    assign axis_15_tready_in = tready_in_all[15];
    
    wire [DATA_WIDTH-1:0] tdata_in  [N_INPUTS];
    wire                  tvalid_in [N_INPUTS];
    wire                  tready_in [N_INPUTS];
    
    generate
        genvar i;
        for(i = 0; i < N_INPUTS; i += 1)
        begin
            assign tdata_in[i]  = tdata_in_all[i];
            assign tvalid_in[i] = tvalid_in_all[i];
            assign tready_in_all[i] = tready_in[i];
        end
    endgenerate

    data_mux_impl# (
        .DATA_WIDTH(DATA_WIDTH),
        .N_INPUTS(N_INPUTS),
        .OUTPUT_REVERSE_BITS(OUTPUT_REVERSE_BITS)
    ) data_mux_inst
    (
        //Clock
        .clk(clk),
        
        //Input AXIS busses
        .tdata_in(tdata_in),
        .tvalid_in(tvalid_in),
        .tready_in(tready_in),
        
        //Output AXIS bus
        .tdata_out(axis_out_tdata),
        .tvalid_out(axis_out_tvalid),
        .tready_out(axis_out_tready),
        
        //configuration parameters 
        .n_idle_words(params_out.n_idle_words),
        .output_select(params_out.output_select),
        .idle_word(params_out.idle_word),
        
        //fast control parameter
        .fc_linkReset(fc_linkReset)
    );
    
    
    
endmodule
