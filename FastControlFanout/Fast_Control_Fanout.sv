`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2021 10:58:47 AM
// Design Name: 
// Module Name: Fast_Control_Fanout
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


module Fast_Control_Fanout #(
        parameter integer NFANOUT = 1,
        parameter integer NRESYNC = 1,
        parameter [NFANOUT-1:0] INVERT = 0
    )
    (
        input wire fast_clock_in,
        input wire fast_command_in,
        
        output wire fast_command_out,
        
        output wire [NFANOUT-1:0] fast_clock_out_P,
        output wire [NFANOUT-1:0] fast_clock_out_N,
        output wire [NFANOUT-1:0] fast_command_out_P,
        output wire [NFANOUT-1:0] fast_command_out_N,
        
        input arstn
    );
    
    logic [(NRESYNC?(NRESYNC-1):0) : 0] resync_command;
    
    // logic to resync the fast command to the "new" clock 
    generate
    if(NRESYNC != 0)
    begin
        always_ff @(posedge fast_clock_in)
        begin
            resync_command[0] <= fast_command_in;
            for(int i = 1; i < NRESYNC; i += 1)
            begin
                resync_command[i] <= resync_command[i-2];
            end
        end
    end
    else
    begin
        assign resync_command = fast_command_in;
    end
    endgenerate
    
    assign fast_command_out = resync_command[(NRESYNC?(NRESYNC-1):0)];
    
    generate
        genvar i;
        for(i = 0; i < (NFANOUT?NFANOUT:1); i += 1)  
        begin
        
           logic clock;
           logic command;
           
           ODDRE1 #(
              .IS_C_INVERTED(1'b0),      // Optional inversion for C
              .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
              .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
              .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                         // ULTRASCALE_PLUS_ES2)
              .SRVAL(1'b0)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
           )
           ODDRE1_clock (
              .Q(clock),   // 1-bit output: Data output to IOB
              .C(fast_clock_in),   // 1-bit input: High-speed clock input
              .D1(0), // 1-bit input: Parallel data input 1
              .D2(1), // 1-bit input: Parallel data input 2
              .SR(!arstn)  // 1-bit input: Active High Async Reset
           );

           OBUFDS OBUFDS_clockt (
              .O(fast_clock_out_P[i]),   // 1-bit output: Diff_p output (connect directly to top-level port)
              .OB(fast_clock_out_N[i]), // 1-bit output: Diff_n output (connect directly to top-level port)
              .I(clock)    // 1-bit input: Buffer input
           );
           
           ODDRE1 #(
              .IS_C_INVERTED(1'b0),      // Optional inversion for C
              .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
              .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
              .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                         // ULTRASCALE_PLUS_ES2)
              .SRVAL(1'b0)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
           )
           ODDRE1_inst (
              .Q(command),   // 1-bit output: Data output to IOB
              .C(fast_clock_in),   // 1-bit input: High-speed clock input
              .D1((INVERT[i])?(!fast_command_out):(fast_command_out)), // 1-bit input: Parallel data input 1
              .D2((INVERT[i])?(!fast_command_out):(fast_command_out)), // 1-bit input: Parallel data input 2
              .SR(!arstn)  // 1-bit input: Active High Async Reset
           );

           OBUFDS OBUFDS_inst (
              .O(fast_command_out_P[i]),   // 1-bit output: Diff_p output (connect directly to top-level port)
              .OB(fast_command_out_N[i]), // 1-bit output: Diff_n output (connect directly to top-level port)
              .I(command)    // 1-bit input: Buffer input
           );
           
        end
    endgenerate
    
endmodule
