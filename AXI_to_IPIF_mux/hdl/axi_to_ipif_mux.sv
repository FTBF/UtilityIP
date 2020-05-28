`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2020 09:26:32 AM
// Design Name: 
// Module Name: axi_to_ipif_Data_mux
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

module axi_to_ipif_mux #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 32,
    parameter [31:0] C_S_AXI_MIN_SIZE = 32'h1ff,
    parameter integer C_USE_WSTRB = 0,
    parameter integer C_DPHASE_TIMEOUT = 8,
    parameter integer N_CHIP = 16,
    parameter integer N_REG = 4,
    parameter [N_REG-1:0] BROADCAST_REG = '0,
    parameter MUX_BY_CHIP = 1, 
    parameter C_FAMILY = "vertex6"
    )(
      //System signals
      input wire S_AXI_ACLK,
      input wire S_AXI_ARESETN,
      input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
      input wire S_AXI_AWVALID,
      output wire S_AXI_AWREADY,
      input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
      input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
      input wire S_AXI_WVALID,
      output wire S_AXI_WREADY,
      output wire [1:0] S_AXI_BRESP,
      output wire S_AXI_BVALID,
      input wire S_AXI_BREADY,
      input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
      input wire S_AXI_ARVALID,
      output wire S_AXI_ARREADY,
      output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
      output wire [1:0] S_AXI_RRESP,
      output wire S_AXI_RVALID,
      input wire S_AXI_RREADY,

      //Controls to the IP/IPIF modules
      
      //Bus for direct connection of AXIL to IPIF block 
      output wire                                  IPIF_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr,
      output wire                                  IPIF_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE,
      output wire [N_CHIP-1 : 0]                   IPIF_Bus2IP_CS,
      output wire [N_CHIP*N_REG-1 : 0]             IPIF_Bus2IP_RdCE, 
      output wire [N_CHIP*N_REG-1 : 0]             IPIF_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_IP2Bus_Data,
      input wire                                   IPIF_IP2Bus_WrAck,
      input wire                                   IPIF_IP2Bus_RdAck,
      input wire                                   IPIF_IP2Bus_Error,
      
      //Connections using IPIF interconnect mux 
      output wire                                  IPIF_C00_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C00_Bus2IP_Addr,
      output wire                                  IPIF_C00_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C00_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C00_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C00_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C00_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C00_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C00_IP2Bus_Data,
      input wire                                   IPIF_C00_IP2Bus_WrAck,
      input wire                                   IPIF_C00_IP2Bus_RdAck,
      input wire                                   IPIF_C00_IP2Bus_Error,
      
      output wire                                  IPIF_C01_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C01_Bus2IP_Addr,
      output wire                                  IPIF_C01_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C01_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C01_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C01_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C01_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C01_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C01_IP2Bus_Data,
      input wire                                   IPIF_C01_IP2Bus_WrAck,
      input wire                                   IPIF_C01_IP2Bus_RdAck,
      input wire                                   IPIF_C01_IP2Bus_Error,
      
      output wire                                  IPIF_C02_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C02_Bus2IP_Addr,
      output wire                                  IPIF_C02_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C02_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C02_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C02_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C02_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C02_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C02_IP2Bus_Data,
      input wire                                   IPIF_C02_IP2Bus_WrAck,
      input wire                                   IPIF_C02_IP2Bus_RdAck,
      input wire                                   IPIF_C02_IP2Bus_Error,
      
      output wire                                  IPIF_C03_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C03_Bus2IP_Addr,
      output wire                                  IPIF_C03_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C03_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C03_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C03_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C03_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C03_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C03_IP2Bus_Data,
      input wire                                   IPIF_C03_IP2Bus_WrAck,
      input wire                                   IPIF_C03_IP2Bus_RdAck,
      input wire                                   IPIF_C03_IP2Bus_Error,
      
      output wire                                  IPIF_C04_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C04_Bus2IP_Addr,
      output wire                                  IPIF_C04_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C04_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C04_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C04_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C04_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C04_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C04_IP2Bus_Data,
      input wire                                   IPIF_C04_IP2Bus_WrAck,
      input wire                                   IPIF_C04_IP2Bus_RdAck,
      input wire                                   IPIF_C04_IP2Bus_Error,
      
      output wire                                  IPIF_C05_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C05_Bus2IP_Addr,
      output wire                                  IPIF_C05_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C05_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C05_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C05_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C05_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C05_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C05_IP2Bus_Data,
      input wire                                   IPIF_C05_IP2Bus_WrAck,
      input wire                                   IPIF_C05_IP2Bus_RdAck,
      input wire                                   IPIF_C05_IP2Bus_Error,
      
      output wire                                  IPIF_C06_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C06_Bus2IP_Addr,
      output wire                                  IPIF_C06_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C06_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C06_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C06_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C06_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C06_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C06_IP2Bus_Data,
      input wire                                   IPIF_C06_IP2Bus_WrAck,
      input wire                                   IPIF_C06_IP2Bus_RdAck,
      input wire                                   IPIF_C06_IP2Bus_Error,
      
      output wire                                  IPIF_C07_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C07_Bus2IP_Addr,
      output wire                                  IPIF_C07_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C07_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C07_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C07_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C07_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C07_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C07_IP2Bus_Data,
      input wire                                   IPIF_C07_IP2Bus_WrAck,
      input wire                                   IPIF_C07_IP2Bus_RdAck,
      input wire                                   IPIF_C07_IP2Bus_Error,
      
      output wire                                  IPIF_C08_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C08_Bus2IP_Addr,
      output wire                                  IPIF_C08_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C08_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C08_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C08_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C08_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C08_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C08_IP2Bus_Data,
      input wire                                   IPIF_C08_IP2Bus_WrAck,
      input wire                                   IPIF_C08_IP2Bus_RdAck,
      input wire                                   IPIF_C08_IP2Bus_Error,
      
      output wire                                  IPIF_C09_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C09_Bus2IP_Addr,
      output wire                                  IPIF_C09_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C09_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C09_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C09_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C09_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C09_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C09_IP2Bus_Data,
      input wire                                   IPIF_C09_IP2Bus_WrAck,
      input wire                                   IPIF_C09_IP2Bus_RdAck,
      input wire                                   IPIF_C09_IP2Bus_Error,
      
      output wire                                  IPIF_C10_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C10_Bus2IP_Addr,
      output wire                                  IPIF_C10_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C10_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C10_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C10_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C10_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C10_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C10_IP2Bus_Data,
      input wire                                   IPIF_C10_IP2Bus_WrAck,
      input wire                                   IPIF_C10_IP2Bus_RdAck,
      input wire                                   IPIF_C10_IP2Bus_Error,
      
      output wire                                  IPIF_C11_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C11_Bus2IP_Addr,
      output wire                                  IPIF_C11_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C11_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C11_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C11_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C11_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C11_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C11_IP2Bus_Data,
      input wire                                   IPIF_C11_IP2Bus_WrAck,
      input wire                                   IPIF_C11_IP2Bus_RdAck,
      input wire                                   IPIF_C11_IP2Bus_Error,
      
      output wire                                  IPIF_C12_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C12_Bus2IP_Addr,
      output wire                                  IPIF_C12_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C12_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C12_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C12_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C12_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C12_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C12_IP2Bus_Data,
      input wire                                   IPIF_C12_IP2Bus_WrAck,
      input wire                                   IPIF_C12_IP2Bus_RdAck,
      input wire                                   IPIF_C12_IP2Bus_Error,
      
      output wire                                  IPIF_C13_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C13_Bus2IP_Addr,
      output wire                                  IPIF_C13_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C13_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C13_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C13_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C13_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C13_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C13_IP2Bus_Data,
      input wire                                   IPIF_C13_IP2Bus_WrAck,
      input wire                                   IPIF_C13_IP2Bus_RdAck,
      input wire                                   IPIF_C13_IP2Bus_Error,
      
      output wire                                  IPIF_C14_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C14_Bus2IP_Addr,
      output wire                                  IPIF_C14_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C14_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C14_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C14_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C14_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C14_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C14_IP2Bus_Data,
      input wire                                   IPIF_C14_IP2Bus_WrAck,
      input wire                                   IPIF_C14_IP2Bus_RdAck,
      input wire                                   IPIF_C14_IP2Bus_Error,
      
      output wire                                  IPIF_C15_Bus2IP_resetn,
      output wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_C15_Bus2IP_Addr,
      output wire                                  IPIF_C15_Bus2IP_RNW,
      output wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_C15_Bus2IP_BE,
      output wire [0 : 0]                          IPIF_C15_Bus2IP_CS,
      output wire [N_REG-1 : 0]                    IPIF_C15_Bus2IP_RdCE, 
      output wire [N_REG-1 : 0]                    IPIF_C15_Bus2IP_WrCE,
      output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_C15_Bus2IP_Data,
      input wire [(C_S_AXI_DATA_WIDTH-1) : 0]      IPIF_C15_IP2Bus_Data,
      input wire                                   IPIF_C15_IP2Bus_WrAck,
      input wire                                   IPIF_C15_IP2Bus_RdAck,
      input wire                                   IPIF_C15_IP2Bus_Error
      
    );
    
    wire                                  Bus2IP_Clk;
    wire                                  Bus2IP_Resetn;
    wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     Bus2IP_Addr;
    wire                                  Bus2IP_RNW;
    wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] Bus2IP_BE;
    wire [N_CHIP-1 : 0]                   Bus2IP_CS;
    wire [N_CHIP*N_REG-1 : 0]             Bus2IP_RdCE; 
    wire [N_CHIP*N_REG-1 : 0]             Bus2IP_WrCE;
    wire [(C_S_AXI_DATA_WIDTH-1) : 0]     Bus2IP_Data;
    wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IP2Bus_Data;
    wire                                  IP2Bus_WrAck;
    wire                                  IP2Bus_RdAck;
    wire                                  IP2Bus_Error;
    
    //construct unpacked array parameters expected by the vhdl IPIF block
    typedef bit [63:0] C_ARD_ADDR_RANGE_ARRAY_type [N_CHIP*2];
    function C_ARD_ADDR_RANGE_ARRAY_type set_ARD_ADDR_RANGE_ARRAY( input integer N_chip, input integer N_reg );
       C_ARD_ADDR_RANGE_ARRAY_type C_ARD_ADDR_RANGE_ARRAY_tmp;
        for(int i = 0; i < N_chip; i += 1)
        begin
            C_ARD_ADDR_RANGE_ARRAY_tmp[i*2] = N_reg*4*i;
            C_ARD_ADDR_RANGE_ARRAY_tmp[i*2 + 1] = N_reg*4*(i+1) - 1;
        end
        return( C_ARD_ADDR_RANGE_ARRAY_tmp );
    endfunction
    
    typedef bit [63:0] C_ARD_NUM_CE_ARRAY_type [N_CHIP];
    function C_ARD_NUM_CE_ARRAY_type set_ARD_NUM_CE_ARRAY( input integer N_chip, input integer N_reg );
       C_ARD_NUM_CE_ARRAY_type C_ARD_NUM_CE_ARRAY_tmp;
        for(int i = 0; i < N_chip; i += 1)
        begin
            C_ARD_NUM_CE_ARRAY_tmp[i] = N_reg;
        end
        return( C_ARD_NUM_CE_ARRAY_tmp );
    endfunction 
    
    localparam C_ARD_NUM_CE_ARRAY_type     C_ARD_NUM_CE_ARRAY     = set_ARD_NUM_CE_ARRAY(N_CHIP, N_REG);
    localparam C_ARD_ADDR_RANGE_ARRAY_type C_ARD_ADDR_RANGE_ARRAY = set_ARD_ADDR_RANGE_ARRAY(N_CHIP, N_REG);
    
    //AXI lite to IPIF block 
    axi_lite_ipif #(
      .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
      .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
      .C_S_AXI_MIN_SIZE(C_S_AXI_MIN_SIZE),
      .C_USE_WSTRB(C_USE_WSTRB),
      .C_DPHASE_TIMEOUT(C_DPHASE_TIMEOUT),
      .C_ARD_ADDR_RANGE_ARRAY(C_ARD_ADDR_RANGE_ARRAY),
      .C_ARD_NUM_CE_ARRAY(C_ARD_NUM_CE_ARRAY),
      .C_FAMILY(C_FAMILY)
    ) ipif (
      //System signals
      S_AXI_ACLK,
      S_AXI_ARESETN,
      S_AXI_AWADDR,
      S_AXI_AWVALID,
      S_AXI_AWREADY,
      S_AXI_WDATA,
      S_AXI_WSTRB,
      S_AXI_WVALID,
      S_AXI_WREADY,
      S_AXI_BRESP,
      S_AXI_BVALID,
      S_AXI_BREADY,
      S_AXI_ARADDR,
      S_AXI_ARVALID,
      S_AXI_ARREADY,
      S_AXI_RDATA,
      S_AXI_RRESP,
      S_AXI_RVALID,
      S_AXI_RREADY,
      //Controls to the IP/IPIF modules
      Bus2IP_Clk,
      Bus2IP_Resetn,
      Bus2IP_Addr,
      Bus2IP_RNW,
      Bus2IP_BE,
      Bus2IP_CS,  
      Bus2IP_RdCE,
      Bus2IP_WrCE,
      Bus2IP_Data,
      IP2Bus_Data,
      IP2Bus_WrAck,
      IP2Bus_RdAck,
      IP2Bus_Error
    );
    
    //Select if IPIF interconnect will be used
    generate
        genvar i;
        if(MUX_BY_CHIP == 1)
        begin
            //Interface definitions for IPIF multiplexer
            IPIF_bus #(
                .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
                .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
                .N_CHIP(N_CHIP),
                .N_REG(N_REG)
            ) input_bus (
                .Bus2IP_Clk(Bus2IP_Clk),
                .Bus2IP_Resetn(Bus2IP_Resetn)
            );
            
            IPIF_bus #(
                .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
                .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
                .N_CHIP(1),
                .N_REG(N_REG)
            ) output_bus [N_CHIP] (
                .Bus2IP_Clk(Bus2IP_Clk),
                .Bus2IP_Resetn(Bus2IP_Resetn)
            );
            
            IPIF_interconnect #(
                .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
                .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
                .N_CHIP(N_CHIP),
                .N_REG(N_REG),
                .BROADCAST_REG(BROADCAST_REG)
            ) ipifMux (
                .input_bus(input_bus),
                .output_bus(output_bus)
            );
            
            //Here we map the system verilog interfaces to the sad old verilog ports ... this gets ugly ... 
            
            assign input_bus.Bus2IP_Addr   = Bus2IP_Addr;  
            assign input_bus.Bus2IP_RNW    = Bus2IP_RNW ;   
            assign input_bus.Bus2IP_BE     = Bus2IP_BE  ;    
            assign input_bus.Bus2IP_CS     = Bus2IP_CS  ;    
            assign input_bus.Bus2IP_RdCE   = Bus2IP_RdCE;   
            assign input_bus.Bus2IP_WrCE   = Bus2IP_WrCE;  
            assign input_bus.Bus2IP_Data   = Bus2IP_Data;  
            assign IP2Bus_Data   = input_bus.IP2Bus_Data ;  
            assign IP2Bus_WrAck  = input_bus.IP2Bus_WrAck; 
            assign IP2Bus_RdAck  = input_bus.IP2Bus_RdAck; 
            assign IP2Bus_Error  = input_bus.IP2Bus_Error;
            
            assign IPIF_C00_Bus2IP_resetn = output_bus[0].Bus2IP_Resetn;
            assign IPIF_C00_Bus2IP_Addr   = output_bus[0].Bus2IP_Addr;
            assign IPIF_C00_Bus2IP_RNW    = output_bus[0].Bus2IP_RNW;
            assign IPIF_C00_Bus2IP_BE     = output_bus[0].Bus2IP_BE;
            assign IPIF_C00_Bus2IP_CS     = output_bus[0].Bus2IP_CS;
            assign IPIF_C00_Bus2IP_RdCE   = output_bus[0].Bus2IP_RdCE;
            assign IPIF_C00_Bus2IP_WrCE   = output_bus[0].Bus2IP_WrCE;
            assign IPIF_C00_Bus2IP_Data   = output_bus[0].Bus2IP_Data;
            assign output_bus[0].IP2Bus_Data   = IPIF_C00_IP2Bus_Data ;
            assign output_bus[0].IP2Bus_WrAck  = IPIF_C00_IP2Bus_WrAck;
            assign output_bus[0].IP2Bus_RdAck  = IPIF_C00_IP2Bus_RdAck;
            assign output_bus[0].IP2Bus_Error  = IPIF_C00_IP2Bus_Error;
            
            if(N_CHIP >= 2)
            begin
                assign IPIF_C01_Bus2IP_resetn = output_bus[1].Bus2IP_Resetn;
                assign IPIF_C01_Bus2IP_Addr   = output_bus[1].Bus2IP_Addr;
                assign IPIF_C01_Bus2IP_RNW    = output_bus[1].Bus2IP_RNW;
                assign IPIF_C01_Bus2IP_BE     = output_bus[1].Bus2IP_BE;
                assign IPIF_C01_Bus2IP_CS     = output_bus[1].Bus2IP_CS;
                assign IPIF_C01_Bus2IP_RdCE   = output_bus[1].Bus2IP_RdCE;
                assign IPIF_C01_Bus2IP_WrCE   = output_bus[1].Bus2IP_WrCE;
                assign IPIF_C01_Bus2IP_Data   = output_bus[1].Bus2IP_Data;
                assign output_bus[1].IP2Bus_Data   = IPIF_C01_IP2Bus_Data ;
                assign output_bus[1].IP2Bus_WrAck  = IPIF_C01_IP2Bus_WrAck;
                assign output_bus[1].IP2Bus_RdAck  = IPIF_C01_IP2Bus_RdAck;
                assign output_bus[1].IP2Bus_Error  = IPIF_C01_IP2Bus_Error;
            end
            
            if(N_CHIP >= 3)
            begin
                assign IPIF_C02_Bus2IP_resetn = output_bus[2].Bus2IP_Resetn;
                assign IPIF_C02_Bus2IP_Addr   = output_bus[2].Bus2IP_Addr;
                assign IPIF_C02_Bus2IP_RNW    = output_bus[2].Bus2IP_RNW;
                assign IPIF_C02_Bus2IP_BE     = output_bus[2].Bus2IP_BE;
                assign IPIF_C02_Bus2IP_CS     = output_bus[2].Bus2IP_CS;
                assign IPIF_C02_Bus2IP_RdCE   = output_bus[2].Bus2IP_RdCE;
                assign IPIF_C02_Bus2IP_WrCE   = output_bus[2].Bus2IP_WrCE;
                assign IPIF_C02_Bus2IP_Data   = output_bus[2].Bus2IP_Data;
                assign output_bus[2].IP2Bus_Data   = IPIF_C02_IP2Bus_Data ;
                assign output_bus[2].IP2Bus_WrAck  = IPIF_C02_IP2Bus_WrAck;
                assign output_bus[2].IP2Bus_RdAck  = IPIF_C02_IP2Bus_RdAck;
                assign output_bus[2].IP2Bus_Error  = IPIF_C02_IP2Bus_Error;
            end
            
            if(N_CHIP >= 4)
            begin  
                assign IPIF_C03_Bus2IP_resetn = output_bus[3].Bus2IP_Resetn;
                assign IPIF_C03_Bus2IP_Addr   = output_bus[3].Bus2IP_Addr;
                assign IPIF_C03_Bus2IP_RNW    = output_bus[3].Bus2IP_RNW;
                assign IPIF_C03_Bus2IP_BE     = output_bus[3].Bus2IP_BE;
                assign IPIF_C03_Bus2IP_CS     = output_bus[3].Bus2IP_CS;
                assign IPIF_C03_Bus2IP_RdCE   = output_bus[3].Bus2IP_RdCE;
                assign IPIF_C03_Bus2IP_WrCE   = output_bus[3].Bus2IP_WrCE;
                assign IPIF_C03_Bus2IP_Data   = output_bus[3].Bus2IP_Data;
                assign output_bus[3].IP2Bus_Data   = IPIF_C03_IP2Bus_Data ;
                assign output_bus[3].IP2Bus_WrAck  = IPIF_C03_IP2Bus_WrAck;
                assign output_bus[3].IP2Bus_RdAck  = IPIF_C03_IP2Bus_RdAck;
                assign output_bus[3].IP2Bus_Error  = IPIF_C03_IP2Bus_Error;
            end
            
            if(N_CHIP >= 5)
            begin  
                assign IPIF_C04_Bus2IP_resetn = output_bus[4].Bus2IP_Resetn;
                assign IPIF_C04_Bus2IP_Addr   = output_bus[4].Bus2IP_Addr;
                assign IPIF_C04_Bus2IP_RNW    = output_bus[4].Bus2IP_RNW;
                assign IPIF_C04_Bus2IP_BE     = output_bus[4].Bus2IP_BE;
                assign IPIF_C04_Bus2IP_CS     = output_bus[4].Bus2IP_CS;
                assign IPIF_C04_Bus2IP_RdCE   = output_bus[4].Bus2IP_RdCE;
                assign IPIF_C04_Bus2IP_WrCE   = output_bus[4].Bus2IP_WrCE;
                assign IPIF_C04_Bus2IP_Data   = output_bus[4].Bus2IP_Data;
                assign output_bus[4].IP2Bus_Data   = IPIF_C04_IP2Bus_Data ;
                assign output_bus[4].IP2Bus_WrAck  = IPIF_C04_IP2Bus_WrAck;
                assign output_bus[4].IP2Bus_RdAck  = IPIF_C04_IP2Bus_RdAck;
                assign output_bus[4].IP2Bus_Error  = IPIF_C04_IP2Bus_Error;
            end
            
            if(N_CHIP >= 6)
            begin
                assign IPIF_C05_Bus2IP_resetn = output_bus[5].Bus2IP_Resetn;
                assign IPIF_C05_Bus2IP_Addr   = output_bus[5].Bus2IP_Addr;
                assign IPIF_C05_Bus2IP_RNW    = output_bus[5].Bus2IP_RNW;
                assign IPIF_C05_Bus2IP_BE     = output_bus[5].Bus2IP_BE;
                assign IPIF_C05_Bus2IP_CS     = output_bus[5].Bus2IP_CS;
                assign IPIF_C05_Bus2IP_RdCE   = output_bus[5].Bus2IP_RdCE;
                assign IPIF_C05_Bus2IP_WrCE   = output_bus[5].Bus2IP_WrCE;
                assign IPIF_C05_Bus2IP_Data   = output_bus[5].Bus2IP_Data;
                assign output_bus[5].IP2Bus_Data   = IPIF_C05_IP2Bus_Data ;
                assign output_bus[5].IP2Bus_WrAck  = IPIF_C05_IP2Bus_WrAck;
                assign output_bus[5].IP2Bus_RdAck  = IPIF_C05_IP2Bus_RdAck;
                assign output_bus[5].IP2Bus_Error  = IPIF_C05_IP2Bus_Error;
            end
            
            if(N_CHIP >= 7)
            begin
                assign IPIF_C06_Bus2IP_resetn = output_bus[6].Bus2IP_Resetn;
                assign IPIF_C06_Bus2IP_Addr   = output_bus[6].Bus2IP_Addr;
                assign IPIF_C06_Bus2IP_RNW    = output_bus[6].Bus2IP_RNW;
                assign IPIF_C06_Bus2IP_BE     = output_bus[6].Bus2IP_BE;
                assign IPIF_C06_Bus2IP_CS     = output_bus[6].Bus2IP_CS;
                assign IPIF_C06_Bus2IP_RdCE   = output_bus[6].Bus2IP_RdCE;
                assign IPIF_C06_Bus2IP_WrCE   = output_bus[6].Bus2IP_WrCE;
                assign IPIF_C06_Bus2IP_Data   = output_bus[6].Bus2IP_Data;
                assign output_bus[6].IP2Bus_Data   = IPIF_C06_IP2Bus_Data ;
                assign output_bus[6].IP2Bus_WrAck  = IPIF_C06_IP2Bus_WrAck;
                assign output_bus[6].IP2Bus_RdAck  = IPIF_C06_IP2Bus_RdAck;
                assign output_bus[6].IP2Bus_Error  = IPIF_C06_IP2Bus_Error;
            end
            
            if(N_CHIP >= 8)
            begin 
                assign IPIF_C07_Bus2IP_resetn = output_bus[7].Bus2IP_Resetn;
                assign IPIF_C07_Bus2IP_Addr   = output_bus[7].Bus2IP_Addr;
                assign IPIF_C07_Bus2IP_RNW    = output_bus[7].Bus2IP_RNW;
                assign IPIF_C07_Bus2IP_BE     = output_bus[7].Bus2IP_BE;
                assign IPIF_C07_Bus2IP_CS     = output_bus[7].Bus2IP_CS;
                assign IPIF_C07_Bus2IP_RdCE   = output_bus[7].Bus2IP_RdCE;
                assign IPIF_C07_Bus2IP_WrCE   = output_bus[7].Bus2IP_WrCE;
                assign IPIF_C07_Bus2IP_Data   = output_bus[7].Bus2IP_Data;
                assign output_bus[7].IP2Bus_Data   = IPIF_C07_IP2Bus_Data ;
                assign output_bus[7].IP2Bus_WrAck  = IPIF_C07_IP2Bus_WrAck;
                assign output_bus[7].IP2Bus_RdAck  = IPIF_C07_IP2Bus_RdAck;
                assign output_bus[7].IP2Bus_Error  = IPIF_C07_IP2Bus_Error;
            end
            
            if(N_CHIP >= 9)
            begin 
                assign IPIF_C08_Bus2IP_resetn = output_bus[8].Bus2IP_Resetn;
                assign IPIF_C08_Bus2IP_Addr   = output_bus[8].Bus2IP_Addr;
                assign IPIF_C08_Bus2IP_RNW    = output_bus[8].Bus2IP_RNW;
                assign IPIF_C08_Bus2IP_BE     = output_bus[8].Bus2IP_BE;
                assign IPIF_C08_Bus2IP_CS     = output_bus[8].Bus2IP_CS;
                assign IPIF_C08_Bus2IP_RdCE   = output_bus[8].Bus2IP_RdCE;
                assign IPIF_C08_Bus2IP_WrCE   = output_bus[8].Bus2IP_WrCE;
                assign IPIF_C08_Bus2IP_Data   = output_bus[8].Bus2IP_Data;
                assign output_bus[8].IP2Bus_Data   = IPIF_C08_IP2Bus_Data ;
                assign output_bus[8].IP2Bus_WrAck  = IPIF_C08_IP2Bus_WrAck;
                assign output_bus[8].IP2Bus_RdAck  = IPIF_C08_IP2Bus_RdAck;
                assign output_bus[8].IP2Bus_Error  = IPIF_C08_IP2Bus_Error;
            end
            
            if(N_CHIP >= 10)
            begin  
                assign IPIF_C09_Bus2IP_resetn = output_bus[9].Bus2IP_Resetn;
                assign IPIF_C09_Bus2IP_Addr   = output_bus[9].Bus2IP_Addr;
                assign IPIF_C09_Bus2IP_RNW    = output_bus[9].Bus2IP_RNW;
                assign IPIF_C09_Bus2IP_BE     = output_bus[9].Bus2IP_BE;
                assign IPIF_C09_Bus2IP_CS     = output_bus[9].Bus2IP_CS;
                assign IPIF_C09_Bus2IP_RdCE   = output_bus[9].Bus2IP_RdCE;
                assign IPIF_C09_Bus2IP_WrCE   = output_bus[9].Bus2IP_WrCE;
                assign IPIF_C09_Bus2IP_Data   = output_bus[9].Bus2IP_Data;
                assign output_bus[9].IP2Bus_Data   = IPIF_C09_IP2Bus_Data ;
                assign output_bus[9].IP2Bus_WrAck  = IPIF_C09_IP2Bus_WrAck;
                assign output_bus[9].IP2Bus_RdAck  = IPIF_C09_IP2Bus_RdAck;
                assign output_bus[9].IP2Bus_Error  = IPIF_C09_IP2Bus_Error;
            end
            
            if(N_CHIP >= 11)
            begin  
                assign IPIF_C10_Bus2IP_resetn = output_bus[10].Bus2IP_Resetn;
                assign IPIF_C10_Bus2IP_Addr   = output_bus[10].Bus2IP_Addr;
                assign IPIF_C10_Bus2IP_RNW    = output_bus[10].Bus2IP_RNW;
                assign IPIF_C10_Bus2IP_BE     = output_bus[10].Bus2IP_BE;
                assign IPIF_C10_Bus2IP_CS     = output_bus[10].Bus2IP_CS;
                assign IPIF_C10_Bus2IP_RdCE   = output_bus[10].Bus2IP_RdCE;
                assign IPIF_C10_Bus2IP_WrCE   = output_bus[10].Bus2IP_WrCE;
                assign IPIF_C10_Bus2IP_Data   = output_bus[10].Bus2IP_Data;
                assign output_bus[10].IP2Bus_Data   = IPIF_C10_IP2Bus_Data ;
                assign output_bus[10].IP2Bus_WrAck  = IPIF_C10_IP2Bus_WrAck;
                assign output_bus[10].IP2Bus_RdAck  = IPIF_C10_IP2Bus_RdAck;
                assign output_bus[10].IP2Bus_Error  = IPIF_C10_IP2Bus_Error;
            end
            
            if(N_CHIP >= 12)
            begin 
                assign IPIF_C11_Bus2IP_resetn = output_bus[11].Bus2IP_Resetn;
                assign IPIF_C11_Bus2IP_Addr   = output_bus[11].Bus2IP_Addr;
                assign IPIF_C11_Bus2IP_RNW    = output_bus[11].Bus2IP_RNW;
                assign IPIF_C11_Bus2IP_BE     = output_bus[11].Bus2IP_BE;
                assign IPIF_C11_Bus2IP_CS     = output_bus[11].Bus2IP_CS;
                assign IPIF_C11_Bus2IP_RdCE   = output_bus[11].Bus2IP_RdCE;
                assign IPIF_C11_Bus2IP_WrCE   = output_bus[11].Bus2IP_WrCE;
                assign IPIF_C11_Bus2IP_Data   = output_bus[11].Bus2IP_Data;
                assign output_bus[11].IP2Bus_Data   = IPIF_C11_IP2Bus_Data ;
                assign output_bus[11].IP2Bus_WrAck  = IPIF_C11_IP2Bus_WrAck;
                assign output_bus[11].IP2Bus_RdAck  = IPIF_C11_IP2Bus_RdAck;
                assign output_bus[11].IP2Bus_Error  = IPIF_C11_IP2Bus_Error;
            end
            
            if(N_CHIP >= 13)
            begin 
                assign IPIF_C12_Bus2IP_resetn = output_bus[12].Bus2IP_Resetn;
                assign IPIF_C12_Bus2IP_Addr   = output_bus[12].Bus2IP_Addr;
                assign IPIF_C12_Bus2IP_RNW    = output_bus[12].Bus2IP_RNW;
                assign IPIF_C12_Bus2IP_BE     = output_bus[12].Bus2IP_BE;
                assign IPIF_C12_Bus2IP_CS     = output_bus[12].Bus2IP_CS;
                assign IPIF_C12_Bus2IP_RdCE   = output_bus[12].Bus2IP_RdCE;
                assign IPIF_C12_Bus2IP_WrCE   = output_bus[12].Bus2IP_WrCE;
                assign IPIF_C12_Bus2IP_Data   = output_bus[12].Bus2IP_Data;
                assign output_bus[12].IP2Bus_Data   = IPIF_C12_IP2Bus_Data ;
                assign output_bus[12].IP2Bus_WrAck  = IPIF_C12_IP2Bus_WrAck;
                assign output_bus[12].IP2Bus_RdAck  = IPIF_C12_IP2Bus_RdAck;
                assign output_bus[12].IP2Bus_Error  = IPIF_C12_IP2Bus_Error;
            end
            
            if(N_CHIP >= 14)
            begin 
                assign IPIF_C13_Bus2IP_resetn = output_bus[13].Bus2IP_Resetn;
                assign IPIF_C13_Bus2IP_Addr   = output_bus[13].Bus2IP_Addr;
                assign IPIF_C13_Bus2IP_RNW    = output_bus[13].Bus2IP_RNW;
                assign IPIF_C13_Bus2IP_BE     = output_bus[13].Bus2IP_BE;
                assign IPIF_C13_Bus2IP_CS     = output_bus[13].Bus2IP_CS;
                assign IPIF_C13_Bus2IP_RdCE   = output_bus[13].Bus2IP_RdCE;
                assign IPIF_C13_Bus2IP_WrCE   = output_bus[13].Bus2IP_WrCE;
                assign IPIF_C13_Bus2IP_Data   = output_bus[13].Bus2IP_Data;
                assign output_bus[13].IP2Bus_Data   = IPIF_C13_IP2Bus_Data ;
                assign output_bus[13].IP2Bus_WrAck  = IPIF_C13_IP2Bus_WrAck;
                assign output_bus[13].IP2Bus_RdAck  = IPIF_C13_IP2Bus_RdAck;
                assign output_bus[13].IP2Bus_Error  = IPIF_C13_IP2Bus_Error;
            end
            
            if(N_CHIP >= 15)
            begin 
                assign IPIF_C14_Bus2IP_resetn = output_bus[14].Bus2IP_Resetn;
                assign IPIF_C14_Bus2IP_Addr   = output_bus[14].Bus2IP_Addr;
                assign IPIF_C14_Bus2IP_RNW    = output_bus[14].Bus2IP_RNW;
                assign IPIF_C14_Bus2IP_BE     = output_bus[14].Bus2IP_BE;
                assign IPIF_C14_Bus2IP_CS     = output_bus[14].Bus2IP_CS;
                assign IPIF_C14_Bus2IP_RdCE   = output_bus[14].Bus2IP_RdCE;
                assign IPIF_C14_Bus2IP_WrCE   = output_bus[14].Bus2IP_WrCE;
                assign IPIF_C14_Bus2IP_Data   = output_bus[14].Bus2IP_Data;
                assign output_bus[14].IP2Bus_Data   = IPIF_C14_IP2Bus_Data ;
                assign output_bus[14].IP2Bus_WrAck  = IPIF_C14_IP2Bus_WrAck;
                assign output_bus[14].IP2Bus_RdAck  = IPIF_C14_IP2Bus_RdAck;
                assign output_bus[14].IP2Bus_Error  = IPIF_C14_IP2Bus_Error;
            end
            
            if(N_CHIP >= 16)
            begin  
                assign IPIF_C15_Bus2IP_resetn = output_bus[15].Bus2IP_Resetn;
                assign IPIF_C15_Bus2IP_Addr   = output_bus[15].Bus2IP_Addr;
                assign IPIF_C15_Bus2IP_RNW    = output_bus[15].Bus2IP_RNW;
                assign IPIF_C15_Bus2IP_BE     = output_bus[15].Bus2IP_BE;
                assign IPIF_C15_Bus2IP_CS     = output_bus[15].Bus2IP_CS;
                assign IPIF_C15_Bus2IP_RdCE   = output_bus[15].Bus2IP_RdCE;
                assign IPIF_C15_Bus2IP_WrCE   = output_bus[15].Bus2IP_WrCE;
                assign IPIF_C15_Bus2IP_Data   = output_bus[15].Bus2IP_Data;
                assign output_bus[15].IP2Bus_Data   = IPIF_C15_IP2Bus_Data ;
                assign output_bus[15].IP2Bus_WrAck  = IPIF_C15_IP2Bus_WrAck;
                assign output_bus[15].IP2Bus_RdAck  = IPIF_C15_IP2Bus_RdAck;
                assign output_bus[15].IP2Bus_Error  = IPIF_C15_IP2Bus_Error;
            end
        end
        else
        begin 
            assign IPIF_Bus2IP_resetn = Bus2IP_Resetn;
            assign IPIF_Bus2IP_Addr   = Bus2IP_Addr;  
            assign IPIF_Bus2IP_RNW    = Bus2IP_RNW;   
            assign IPIF_Bus2IP_BE     = Bus2IP_BE;
            //Fix the endianness of CS and Rd/WrCE
            for(i = 0; i < N_CHIP; i += 1) 
                assign IPIF_Bus2IP_CS[i]     = Bus2IP_CS[N_CHIP - 1 - i];
            for(i = 0; i < N_CHIP*N_REG; i += 1)
            begin
                assign IPIF_Bus2IP_WrCE[i]   = Bus2IP_WrCE[N_CHIP*N_REG - 1 - i];
                assign IPIF_Bus2IP_RdCE[i]   = Bus2IP_RdCE[N_CHIP*N_REG - 1 - i];   
            end  
            assign IPIF_Bus2IP_Data   = Bus2IP_Data;  
            assign IP2Bus_Data   = IPIF_IP2Bus_Data ;

            assign IP2Bus_WrAck  = IPIF_IP2Bus_WrAck; 
            assign IP2Bus_RdAck  = IPIF_IP2Bus_RdAck; 
            assign IP2Bus_Error  = IPIF_IP2Bus_Error; 
        end
    endgenerate
    

    
endmodule
