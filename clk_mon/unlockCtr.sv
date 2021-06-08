`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2021 05:28:31 PM
// Design Name: 
// Module Name: unlockCtr
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


module unlockCtr(
    input logic clk_ref,
    input logic locked,
    output logic [31:0] unlocks,
    input logic reset
    );
    
    //first make unlock signal synchronous 
    logic locked_async, locked_sync, locked_sync_dly;
    xpm_cdc_async_rst #(.DEST_SYNC_FF(2)) lockSync (.dest_arst(locked_async), .dest_clk(clk_ref), .src_arst(locked));
    //then count negative edge transitions 
    always_ff @(posedge clk_ref or negedge reset)
    begin
        if(!reset)
        begin
            unlocks <= 0;
            locked_sync <= 0;
            locked_sync_dly <= 0;
        end
        else
        begin
            locked_sync <= locked_async;
            locked_sync_dly <= locked_sync;
        
            //if(IPIF_Bus2IP_WrCE[1] && IPIF_Bus2IP_CS[i]) params_in.unlocks <= 0;  // reset if any write happens 
            //else 
            if(locked_sync_dly && !locked_sync && (unlocks != '1)) unlocks <= unlocks + 1; 
        end
    end
endmodule
