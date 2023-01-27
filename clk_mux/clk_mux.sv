`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2021 04:50:25 PM
// Design Name: 
// Module Name: clk_mux
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


module clk_mux #(
        parameter INPUTFREQ = 40,
        parameter USE_AXI = 0,
        parameter integer C_S_AXI_DATA_WIDTH = 32,
        parameter integer C_S_AXI_ADDR_WIDTH = 11
    ) (
        input wire clk_ext,
        input wire clk_int,

        input wire clk_int_select,

        output wire clk320_out,
        output wire clk40_out,
        output wire locked,
        output wire clk_ext_active,

        input wire aresetn,

        input  logic                                S_AXI_ACLK,
        input  logic                                S_AXI_ARESETN,
        input  logic [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
        input  logic [2 : 0]                        S_AXI_AWPROT,
        input  logic                                S_AXI_AWVALID,
        output logic                                S_AXI_AWREADY,
        input  logic [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
        input  logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
        input  logic                                S_AXI_WVALID,
        output logic                                S_AXI_WREADY,
        output logic [1 : 0]                        S_AXI_BRESP,
        output logic                                S_AXI_BVALID,
        input  logic                                S_AXI_BREADY,
        input  logic [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
        input  logic [2 : 0]                        S_AXI_ARPROT,
        input  logic                                S_AXI_ARVALID,
        output logic                                S_AXI_ARREADY,
        output logic [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA,
        output logic [1 : 0]                        S_AXI_RRESP,
        output logic                                S_AXI_RVALID,
        input  logic                                S_AXI_RREADY
    );

    // First, all of the AXI / IPIF stuff

    localparam N_REG = 2;

    logic                                  IPIF_Bus2IP_resetn;
    logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr;
    logic                                  IPIF_Bus2IP_RNW;
    logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE;
    logic [0 : 0]                          IPIF_Bus2IP_CS;
    logic [N_REG-1 : 0]                    IPIF_Bus2IP_RdCE;
    logic [N_REG-1 : 0]                    IPIF_Bus2IP_WrCE;
    logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data;
    logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data;
    logic                                  IPIF_IP2Bus_WrAck;
    logic                                  IPIF_IP2Bus_RdAck;
    logic                                  IPIF_IP2Bus_Error;

    // ground unused error bit
    assign IPIF_IP2Bus_Error = 0;

    axi_to_ipif_mux #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
        .N_CHIP(1),
        .N_REG(N_REG),
        .MUX_BY_CHIP(0)
    ) axi_ipif (
        .S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARESETN(S_AXI_ARESETN),
        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA),
        .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WVALID(S_AXI_WVALID),
        .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY),
        .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_RREADY(S_AXI_RREADY),
        .IPIF_Bus2IP_resetn(IPIF_Bus2IP_resetn),
        .IPIF_Bus2IP_Addr(IPIF_Bus2IP_Addr),
        .IPIF_Bus2IP_RNW(IPIF_Bus2IP_RNW),
        .IPIF_Bus2IP_BE(IPIF_Bus2IP_BE),
        .IPIF_Bus2IP_CS(IPIF_Bus2IP_CS),
        .IPIF_Bus2IP_RdCE(IPIF_Bus2IP_RdCE),
        .IPIF_Bus2IP_WrCE(IPIF_Bus2IP_WrCE),
        .IPIF_Bus2IP_Data(IPIF_Bus2IP_Data),
        .IPIF_IP2Bus_Data(IPIF_IP2Bus_Data),
        .IPIF_IP2Bus_WrAck(IPIF_IP2Bus_WrAck),
        .IPIF_IP2Bus_RdAck(IPIF_IP2Bus_RdAck),
        .IPIF_IP2Bus_Error(IPIF_IP2Bus_Error)
    );

    typedef struct packed {
        // Register 3
        logic [32-1:0] padding3;
        // Register 2
        logic [32-1-1:0] padding2;
        logic locked;
        // Register 1
        logic [32-1-1:0] padding1;
        logic clk_ext_active;
        // Register 0
        logic [32-1-1:0] padding0;
        logic clk_int_select;
    } param_t;

    param_t params_from_IP;
    param_t params_to_IP;

    //IPIF parameters are decoded here
    IPIF_parameterDecode #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .N_REG(N_REG),
        .PARAM_T(param_t)
    ) parameterDecode (
        .clk(S_AXI_ACLK),

        .IPIF_bus2ip_data(IPIF_Bus2IP_Data),
        .IPIF_bus2ip_rdce(IPIF_Bus2IP_RdCE),
        .IPIF_bus2ip_resetn(IPIF_Bus2IP_resetn),
        .IPIF_bus2ip_wrce(IPIF_Bus2IP_WrCE),
        .IPIF_ip2bus_data(IPIF_IP2Bus_Data),
        .IPIF_ip2bus_rdack(IPIF_IP2Bus_RdAck),
        .IPIF_ip2bus_wrack(IPIF_IP2Bus_WrAck),

        .parameters_in(params_from_IP),
        .parameters_out(params_to_IP)
    );

    always_comb begin
        params_from_IP = params_to_IP;
        params_from_IP.padding0 = '0;
        params_from_IP.padding1 = '0;
        params_from_IP.padding2 = '0;
        params_from_IP.padding3 = '0;
        params_from_IP.clk_ext_active = clk_ext_active;
        params_from_IP.locked = locked;
    end

    // Clock mux logic begins here

    // clk_ext immediately goes to an MMCM to produce a 100 MHz clock
    // This MMCM also produces the clk_ext_active output signal
    // The feedback path of this MMCM goes through a BUFG
    // The output is clk100_ext
    //
    // Next, both clk_int and clk100_ext go through a BUFG before going to the
    // multiplexer
    // In order to switch to the external clock, the external clock must be
    // active.  If the external clock ever becomes inactive, the mux will fall
    // back on the internal clock.
    //
    // Lastly, the mux output goes through another MMCM to produce the 40 and
    // 320 MHz output clocks.  This MMCM produces the locked output signal.

    localparam CLK_MULT    = (INPUTFREQ == 40)?(30):(3.750);
    localparam CLK_DIV_100 = (INPUTFREQ == 40)?(12):(12);
    localparam CLK_PERIOD  = (INPUTFREQ == 40)?(25.0):(3.125);

    logic clockInStopped;
    logic locked_ext;
    assign clk_ext_active = !clockInStopped && locked_ext;

    logic clk100_ext;
    logic clkFB_ext_I, clkFB_ext_O;
    BUFG BUFG_FB_ext_inst ( .O(clkFB_ext_O), .I(clkFB_ext_I) );

    MMCME4_ADV #(
        .BANDWIDTH("OPTIMIZED"),        // Jitter programming
        .CLKFBOUT_MULT_F(CLK_MULT),     // Multiply value for all CLKOUT
        .CLKIN1_PERIOD(CLK_PERIOD),     // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        .CLKOUT0_DIVIDE_F(CLK_DIV_100), // Divide amount for CLKOUT0
        .CLKOUT0_PHASE(0.0),            // Phase offset for CLKOUT0
        .COMPENSATION("AUTO"),          // Clock input compensation
        .DIVCLK_DIVIDE(1),              // Master division value
        .IS_RST_INVERTED(1'b1)          // Optional inversion for RST
    ) MMCME4_ADV_EXT (
        .CLKINSTOPPED(clockInStopped),  // 1-bit output: Input clock stopped
        .CLKFBOUT(clkFB_ext_I),         // 1-bit output: Feedback clock
        .CLKFBIN(clkFB_ext_O),          // 1-bit input: Feedback clock
        .CLKOUT0(clk100_ext),           // 1-bit output: CLKOUT0
        .LOCKED(locked_ext),            // 1-bit output: LOCK
        .CLKIN1(clk_ext),               // 1-bit input: Primary clock
        .RST(aresetn)                   // 1-bit input: Reset
    );

    logic clk100_ext_buf, clk100_int_buf;
    BUFG BUFG_100_ext_inst ( .O(clk100_ext_buf), .I(clk100_ext) );
    BUFG BUFG_100_int_inst ( .O(clk100_int_buf), .I(clk_int) );

    logic S0, S1;
    always @(posedge clk100_ext_buf) begin
        if (USE_AXI == 1) begin
            S0 <= clk_ext_active && !params_to_IP.clk_int_select;
        end else begin
            S0 <= clk_ext_active && !clk_int_select;
        end
    end

    always @(posedge clk100_int_buf) begin
        if (USE_AXI == 1) begin
            S1 <= !clk_ext_active || params_to_IP.clk_int_select;
        end else begin
            S1 <= !clk_ext_active || clk_int_select;
        end
    end

    logic clk100_mux;
    BUFGCTRL #(
        .INIT_OUT(0),               // Initial value of BUFGCTRL output, 0-1
        .PRESELECT_I0("FALSE"),     // BUFGCTRL output uses I0 input, FALSE, TRUE
        .PRESELECT_I1("FALSE")     // BUFGCTRL output uses I1 input, FALSE, TRUE
    ) BUFGCTRL_100_inst (
        .O(clk100_mux),            // 1-bit output: Clock output
        .CE0(1'b1),                // 1-bit input: Clock enable input for I0
        .CE1(1'b1),                // 1-bit input: Clock enable input for I1
        .I0(clk100_ext_buf),       // 1-bit input: Primary clock
        .I1(clk100_int_buf),       // 1-bit input: Secondary clock
        .IGNORE0(~clk_ext_active), // 1-bit input: Clock ignore input for I0
        .IGNORE1(1'b0),            // 1-bit input: Clock ignore input for I1
        .S0(S0),                   // 1-bit input: Clock select for I0
        .S1(S1)                    // 1-bit input: Clock select for I1
    );   

    logic clkFB_100_I, clkFB_100_O;
    BUFG BUFG_FB_int_inst ( .O(clkFB_100_O), .I(clkFB_100_I) );

    MMCME4_ADV #(
        .BANDWIDTH("OPTIMIZED"),        // Jitter programming
        .CLKFBOUT_MULT_F(12),           // Multiply value for all CLKOUT
        .CLKIN1_PERIOD(10.0),           // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        .CLKOUT0_DIVIDE_F(3.75),        // Divide amount for CLKOUT0
        .CLKOUT0_PHASE(0.0),            // Phase offset for CLKOUT0
        .CLKOUT1_DIVIDE(30),            // Divide amount for CLKOUT (1-128)
        .CLKOUT1_PHASE(0.0),            // Phase offset for CLKOUT outputs (-360.000-360.000).
        .COMPENSATION("AUTO"),          // Clock input compensation
        .DIVCLK_DIVIDE(1),              // Master division value
        .IS_RST_INVERTED(1'b1)          // Optional inversion for RST
    ) MMCME4_ADV_100 (
        .CLKINSTOPPED(), // 1-bit output: Input clock stopped
        .CLKFBOUT(clkFB_100_I),         // 1-bit output: Feedback clock
        .CLKFBIN(clkFB_100_O),          // 1-bit input: Feedback clock
        .CLKOUT0(clk320_out),           // 1-bit output: CLKOUT0
        .CLKOUT1(clk40_out),            // 1-bit output: CLKOUT1
        .LOCKED(locked),                // 1-bit output: LOCK
        .CLKIN1(clk100_mux),            // 1-bit input: Primary clock
        .RST(aresetn)                      // 1-bit input: Reset
    );

endmodule
