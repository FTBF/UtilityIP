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
    parameter INCLUDE_SYNCHRONIZER = 0,
    parameter integer DATA_WIDTH = 32,
    parameter integer N_INPUTS = 2,
    parameter OUTPUT_REVERSE_BITS = 1,
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 32,
    parameter integer N_REG = 8
    ) 
    (
    //Clock
    input logic IPIF_clk,
    input logic clk,
    input logic aresetn,
    
    //Input AXIS busses
    input  logic [DATA_WIDTH-1:0] axis_0_tdata_in,
    input  logic                  axis_0_tvalid_in,
    output logic                  axis_0_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_1_tdata_in,
    input  logic                  axis_1_tvalid_in,
    output logic                  axis_1_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_2_tdata_in,
    input  logic                  axis_2_tvalid_in,
    output logic                  axis_2_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_3_tdata_in,
    input  logic                  axis_3_tvalid_in,
    output logic                  axis_3_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_4_tdata_in,
    input  logic                  axis_4_tvalid_in,
    output logic                  axis_4_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_5_tdata_in,
    input  logic                  axis_5_tvalid_in,
    output logic                  axis_5_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_6_tdata_in,
    input  logic                  axis_6_tvalid_in,
    output logic                  axis_6_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_7_tdata_in,
    input  logic                  axis_7_tvalid_in,
    output logic                  axis_7_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_8_tdata_in,
    input  logic                  axis_8_tvalid_in,
    output logic                  axis_8_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_9_tdata_in,
    input  logic                  axis_9_tvalid_in,
    output logic                  axis_9_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_10_tdata_in,
    input  logic                  axis_10_tvalid_in,
    output logic                  axis_10_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_11_tdata_in,
    input  logic                  axis_11_tvalid_in,
    output logic                  axis_11_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_12_tdata_in,
    input  logic                  axis_12_tvalid_in,
    output logic                  axis_12_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_13_tdata_in,
    input  logic                  axis_13_tvalid_in,
    output logic                  axis_13_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_14_tdata_in,
    input  logic                  axis_14_tvalid_in,
    output logic                  axis_14_tready_in,
    
    input  logic [DATA_WIDTH-1:0] axis_15_tdata_in,
    input  logic                  axis_15_tvalid_in,
    output logic                  axis_15_tready_in,
    
    //Output AXIS bus
    output logic [DATA_WIDTH-1:0] axis_out_tdata,
    output logic                  axis_out_tvalid,
    input  logic                  axis_out_tready,
    
    //configuration parameter interface 
    input  logic                                  IPIF_Bus2IP_resetn,
    input  logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr,   //unused
    input  logic                                  IPIF_Bus2IP_RNW,    //unused
    input  logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE,     //unused
    input  logic [0 : 0]                          IPIF_Bus2IP_CS,     //unused
    input  logic [N_REG-1 : 0]                    IPIF_Bus2IP_RdCE, 
    input  logic [N_REG-1 : 0]                    IPIF_Bus2IP_WrCE,
    input  logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data,
    output logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data,
    output logic                                  IPIF_IP2Bus_WrAck,
    output logic                                  IPIF_IP2Bus_RdAck,
    output logic                                  IPIF_IP2Bus_Error,
    
    //fast control parameter
    input logic fc_orbitSync,
    input logic fc_linkReset_ROCd,
    input logic fc_linkReset_ROCt
    );
    
    //decode configuration parameters from IPIF bus 
    assign IPIF_IP2Bus_Error = 0;
    
    typedef struct packed
    {
        // Register 7
        logic [DATA_WIDTH-1:0] padding7;
        // Register 6
        logic [DATA_WIDTH-1:0] header_BX0;
        // Register 5
        logic [DATA_WIDTH-1:0] header;
        // Register 4
        logic [DATA_WIDTH-1:0] header_mask;
        // Register 3
        logic [DATA_WIDTH-1:0] idle_word_BX0;
        // Register 2
        logic [DATA_WIDTH-1:0] idle_word;
        // Register 1
        logic [15:0]           padding1;
        logic [15:0]           n_idle_words;
        // Register 0
        logic [27:0]           padding0;
        logic [3:0]            output_select;
    } param_t;
    
    param_t params_from_IP;
    param_t params_from_bus;
    param_t params_to_IP;
    param_t params_to_bus;
    
    always_comb begin
        params_from_IP = params_to_IP;
        params_from_IP.padding0 = '0;
        params_from_IP.padding1 = '0;
        params_from_IP.padding7 = '0;
    end
    
    IPIF_parameterDecode#(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
        .USE_ONEHOT_READ(0),
        .N_REG(N_REG),
        .PARAM_T(param_t),
        .DEFAULTS({32'b0, 32'h90000000, 32'ha0000000, 32'h00000000, 32'h9ccccccc, 32'haccccccc, 16'b0, 16'd256, 32'b0})
    ) parameterDecoder (
        .clk(IPIF_clk),
        
        .IPIF_bus2ip_addr(IPIF_Bus2IP_Addr),
        .IPIF_bus2ip_data(IPIF_Bus2IP_Data),  
        .IPIF_bus2ip_rdce(IPIF_Bus2IP_RdCE),
        .IPIF_bus2ip_resetn(IPIF_Bus2IP_resetn),
        .IPIF_bus2ip_wrce(IPIF_Bus2IP_WrCE),
        .IPIF_ip2bus_data(IPIF_IP2Bus_Data),
        .IPIF_ip2bus_rdack(IPIF_IP2Bus_RdAck),
        .IPIF_ip2bus_wrack(IPIF_IP2Bus_WrAck),
        
        .parameters_out(params_from_bus),
        .parameters_in(params_to_bus)
    );

    IPIF_clock_converter #(
        .INCLUDE_SYNCHRONIZER(INCLUDE_SYNCHRONIZER),
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .N_REG(N_REG),
        .PARAM_T(param_t)
    ) IPIF_clock_conv (
        .IP_clk(clk),
        .bus_clk(IPIF_clk),
        .params_from_IP(params_from_IP),
        .params_from_bus(params_from_bus),
        .params_to_IP(params_to_IP),
        .params_to_bus(params_to_bus));
    
    //map ports (necessary for IP packaging) to a more user friends data structure 
    logic [DATA_WIDTH-1:0] tdata_in_all  [16];
    logic                  tvalid_in_all [16];
    logic                  tready_in_all [16];
    assign tvalid_in_all = {axis_0_tvalid_in, axis_1_tvalid_in, axis_2_tvalid_in, axis_3_tvalid_in, axis_4_tvalid_in, axis_5_tvalid_in, axis_6_tvalid_in, axis_7_tvalid_in, axis_8_tvalid_in, axis_9_tvalid_in, axis_10_tvalid_in, axis_11_tvalid_in, axis_12_tvalid_in, axis_13_tvalid_in, axis_14_tvalid_in, axis_15_tvalid_in};
    assign tdata_in_all  = {axis_0_tdata_in,  axis_1_tdata_in,  axis_2_tdata_in,  axis_3_tdata_in,  axis_4_tdata_in,  axis_5_tdata_in,  axis_6_tdata_in,  axis_7_tdata_in,  axis_8_tdata_in,  axis_9_tdata_in,  axis_10_tdata_in,  axis_11_tdata_in,  axis_12_tdata_in,  axis_13_tdata_in,  axis_14_tdata_in,  axis_15_tdata_in};
    
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
    
    logic [DATA_WIDTH-1:0] tdata_in  [N_INPUTS];
    logic                  tvalid_in [N_INPUTS];
    logic                  tready_in [N_INPUTS];
    
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
        .aresetn(aresetn),
        
        //Input AXIS busses
        .tdata_in(tdata_in),
        .tvalid_in(tvalid_in),
        .tready_in(tready_in),
        
        //Output AXIS bus
        .tdata_out(axis_out_tdata),
        .tvalid_out(axis_out_tvalid),
        .tready_out(axis_out_tready),
        
        //configuration parameters 
        .n_idle_words(params_to_IP.n_idle_words),
        .output_select(params_to_IP.output_select),
        .idle_word(params_to_IP.idle_word),
        .idle_word_BX0(params_to_IP.idle_word_BX0),
        .header_mask(params_to_IP.header_mask),
        .header(params_to_IP.header),
        .header_BX0(params_to_IP.header_BX0),
        
        //fast control parameter
        .fc_orbitSync(fc_orbitSync),
        .fc_linkReset(fc_linkReset_ROCd || fc_linkReset_ROCt)
    );
    
    
    
endmodule
