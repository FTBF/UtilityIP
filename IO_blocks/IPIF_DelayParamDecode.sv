`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2020 09:57:20 PM
// Design Name: 
// Module Name: IPIF_DelayParamDecode
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


module IPIF_DelayParamDecode #(
        parameter integer NLINKS = 12,
        parameter integer WORD_PER_LINK = 4
    )
    (
        //input clocks
        //this is assumed to be the same 160 clocking the AXI and IPIF blocks
        input wire clk160,
    
        //ipif configuration interface ports 
        input wire [31:0] IPIF_bus2ip_data,  
        input wire [(NLINKS+1)*WORD_PER_LINK - 1:0] IPIF_bus2ip_rdce,
        input wire IPIF_bus2ip_resetn,
        input wire [(NLINKS+1)*WORD_PER_LINK - 1:0] IPIF_bus2ip_wrce,
        output reg [31:0] IPIF_ip2bus_data,
        output reg IPIF_ip2bus_rdack,
        output reg IPIF_ip2bus_wrack,
        
        //parmeter and control signals 
        input wire delay_ready [NLINKS],
        input wire [15:0] bit_align_errors [NLINKS],
        input wire [8:0] delay_out [NLINKS],
        input wire [8:0] delay_out_N [NLINKS],
        
        output reg delay_set [NLINKS],
        output reg delay_mode [NLINKS],
        output reg [8:0] delay_in [NLINKS],
        output reg [8:0] delay_error_offset [NLINKS],
        output reg reset_counters [NLINKS],
        output reg rstb_links [NLINKS],

		output reg bypass_IOBUF [NLINKS],
        
        output reg global_reset_counters,
        output reg global_rstb_links
    );
    
    reg [31:0] read_reg;
    
    // send write acknowladge 
    always @(posedge clk160 or negedge IPIF_bus2ip_resetn) 
        if(!IPIF_bus2ip_resetn) IPIF_ip2bus_wrack <= 0;
        else                    IPIF_ip2bus_wrack <= |IPIF_bus2ip_wrce;
    
    // decode global parameters
    always @(posedge clk160 or negedge IPIF_bus2ip_resetn)
    begin
        if(!IPIF_bus2ip_resetn)
        begin
            global_reset_counters <= 0;
            global_rstb_links <= 1;
            
        end
        else
        begin
            if(IPIF_bus2ip_wrce == (1 << 0))  //parameter 0
            begin
                {global_reset_counters, global_rstb_links} <= IPIF_bus2ip_data[1:0];
            end
        end
    end
    
    generate
        genvar j;
        for(j = 0; j < NLINKS; j = j + 1)
        begin
            always @(posedge clk160 or negedge IPIF_bus2ip_resetn)
                begin
                    if(!IPIF_bus2ip_resetn)
                    begin
                        delay_set[j] <= 0;
                        delay_mode[j] <= 0;
                        delay_in[j] <= 0;
                        delay_error_offset[j] <= 0;
                        reset_counters[j] <= 0;
                        rstb_links[j] <= 1;
						bypass_IOBUF[j] <= 0;
                    end
                    else
                    begin
                        if(IPIF_bus2ip_wrce == (1 << (WORD_PER_LINK*(j+1) + 0)))  //parameter 0
                        begin
                            {bypass_IOBUF[j], delay_set[j], delay_mode[j], reset_counters[j], rstb_links[j]} <= IPIF_bus2ip_data[4:0];
                        end
                        
                        if(IPIF_bus2ip_wrce == (1 << (WORD_PER_LINK*(j+1) + 1)))  //parameter 1
                        begin
                            {delay_error_offset[j], delay_in[j]} <= IPIF_bus2ip_data[17:0];
                        end
                    end
                end
            end
            
            always @(posedge clk160 or negedge IPIF_bus2ip_resetn)
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
                //global parameter readback
                if(IPIF_bus2ip_rdce == (1 << 0)) read_reg = {30'b0, global_reset_counters, global_rstb_links};
                
                //individual channel readback 
                for(int j = 0; j < NLINKS; j = j + 1)
                begin
                    if(IPIF_bus2ip_rdce == (1 << (WORD_PER_LINK*(j+1) + 0))) read_reg = {27'b0, bypass_IOBUF[j], delay_set[j], delay_mode[j], reset_counters[j], rstb_links[j]};
                    if(IPIF_bus2ip_rdce == (1 << (WORD_PER_LINK*(j+1) + 1))) read_reg = {14'b0, delay_error_offset[j], delay_in[j]};
                    if(IPIF_bus2ip_rdce == (1 << (WORD_PER_LINK*(j+1) + 2))) read_reg = {16'b0, bit_align_errors[j]};
                    if(IPIF_bus2ip_rdce == (1 << (WORD_PER_LINK*(j+1) + 3))) read_reg = {13'b0, delay_out_N[j], delay_out[j], delay_ready[j]};
                end
            end
        endgenerate

endmodule
