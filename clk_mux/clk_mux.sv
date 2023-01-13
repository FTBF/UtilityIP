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
        parameter INPUTFREQ = 40
    )
    (
        input wire clk_ext,
        input wire clk_int,
        
        input wire clk_int_select,
        
        output wire clk320_out,
        output wire clk40_out,
        output wire locked,
        output wire clk_ext_active,
        
        input wire nrst
    );
    
    logic clk100_ext;
	logic clk100_mux;
    logic locked_ext;
    
    logic clkFB_100_I, clkFB_100_O;
    BUFG BUFG_FB_int_inst ( .O(clkFB_100_O), .I(clkFB_100_I) );
    
    localparam CLK_MULT    = (INPUTFREQ == 40)?(30):(3.750);
	localparam CLK_DIV_100 = (INPUTFREQ == 40)?(12):(12);
    localparam CLK_PERIOD  = (INPUTFREQ == 40)?(25.0):(3.125);
    
    logic clkFB_ext_I, clkFB_ext_O;
    BUFG BUFG_FB_ext_inst ( .O(clkFB_ext_O), .I(clkFB_ext_I) );
    
    logic clockInStopped;
    assign clk_ext_active = !clockInStopped && locked_ext;
    
    MMCME4_ADV #(
       .BANDWIDTH("OPTIMIZED"),        // Jitter programming
       .CLKFBOUT_MULT_F(CLK_MULT),     // Multiply value for all CLKOUT
       .CLKIN1_PERIOD(CLK_PERIOD),     // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       .CLKOUT0_DIVIDE_F(CLK_DIV_100), // Divide amount for CLKOUT0
       .CLKOUT0_PHASE(0.0),            // Phase offset for CLKOUT0
       .COMPENSATION("AUTO"),          // Clock input compensation
       .DIVCLK_DIVIDE(1),              // Master division value
       .IS_RST_INVERTED(1'b1)          // Optional inversion for RST
    )
    MMCME4_ADV_EXT (
       .CLKINSTOPPED(clockInStopped), // 1-bit output: Input clock stopped
       .CLKFBOUT(clkFB_ext_I),         // 1-bit output: Feedback clock
       .CLKFBIN(clkFB_ext_O),           // 1-bit input: Feedback clock
       .CLKOUT0(clk100_ext),           // 1-bit output: CLKOUT0
       .LOCKED(locked_ext),             // 1-bit output: LOCK
       .CLKIN1(clk_ext),             // 1-bit input: Primary clock
       .RST(nrst)                    // 1-bit input: Reset
    );
	
	logic S0, S1;
    logic clk100_ext_buf, clk100_int_buf;
	always @(posedge clk100_ext_buf)
		S0 <= clk_ext_active && !clk_int_select;
	
	always @(posedge clk100_int_buf)
		S1 <= !clk_ext_active || clk_int_select;

    BUFG BUFG_100_ext_inst ( .O(clk100_ext_buf), .I(clk100_ext) );
    BUFG BUFG_100_int_inst ( .O(clk100_int_buf), .I(clk_int) );
    BUFGCTRL #(
        .INIT_OUT(0),               // Initial value of BUFGCTRL output, 0-1
        .PRESELECT_I0("FALSE"),     // BUFGCTRL output uses I0 input, FALSE, TRUE
        .PRESELECT_I1("FALSE")     // BUFGCTRL output uses I1 input, FALSE, TRUE
     )
     BUFGCTRL_100_inst (
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
    )
    MMCME4_ADV_100 (
       .CLKINSTOPPED(), // 1-bit output: Input clock stopped
       .CLKFBOUT(clkFB_100_I),         // 1-bit output: Feedback clock
       .CLKFBIN(clkFB_100_O),          // 1-bit input: Feedback clock
       .CLKOUT0(clk320_out),           // 1-bit output: CLKOUT0
       .CLKOUT1(clk40_out),            // 1-bit output: CLKOUT1
       .LOCKED(locked),                // 1-bit output: LOCK
       .CLKIN1(clk100_mux),            // 1-bit input: Primary clock
       .RST(nrst)                      // 1-bit input: Reset
    );
    
endmodule
