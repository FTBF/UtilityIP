`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2020 11:14:46 AM
// Design Name: 
// Module Name: data_sync_ctrl
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


module data_sync_ctrl(
        input wire clk,
        
        input wire fc_orbitSync,
        
        input reg [1:0]   sync_mode,
        input reg [15:0]  repeat_length,
        
        output reg sync_pulse
    );
    
    reg [15:0] orbit_counter;
    reg [1:0] byte_counter;
    
    always_ff @(posedge clk)
    begin
        if(fc_orbitSync) {orbit_counter, byte_counter} <= 0;
        else             {orbit_counter, byte_counter} <= {orbit_counter, byte_counter} + 1;
    end
    
    always_ff @(posedge clk)
    begin
        case(sync_mode)
            2'd1:   //normal orbit sync with prescale
            begin
                sync_pulse <= fc_orbitSync;
            end
            2'd2:   //free running for N words  
            begin
                sync_pulse <= (orbit_counter == repeat_length)
            end
            default:
            begin
                sync_pulse <= 0;
            end
        endcase
    end
    
endmodule
