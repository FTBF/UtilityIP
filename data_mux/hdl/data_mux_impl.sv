`timescale 1ns / 1ps

module data_mux_impl# (
    parameter integer DATA_WIDTH = 32,
    parameter integer N_INPUTS = 16,
    parameter OUTPUT_REVERSE_BITS = 1
    )
    (
    //Clock
    input wire clk,
    
    //Input AXIS busses
    input  wire [DATA_WIDTH-1:0] tdata_in  [N_INPUTS],
    input  wire                  tvalid_in [N_INPUTS],
    output wire                  tready_in [N_INPUTS],
    
    //Output AXIS bus
    output reg [DATA_WIDTH-1:0] tdata_out,
    output reg                  tvalid_out,
    input  wire                 tready_out,
    
    //configuration parameters 
    input wire [15:0]           n_idle_words,
    input wire [3:0]            output_select,
    input wire [DATA_WIDTH-1:0] idle_word,
    input wire [DATA_WIDTH-1:0] idle_word_BX0,
    
    //fast control parameter
    input wire fc_orbitSync,
    input wire fc_linkReset
    );
    
    //We want all links advancing always, so we pass all input streams tready
    generate
        genvar i;
        for(i = 0; i < N_INPUTS; i += 1) assign tready_in[i] = tready_out;
    endgenerate
    
    reg [DATA_WIDTH-1:0] tdata_select;
    reg                  tvalid_select;
    
    reg                  fc_linkReset_dly;
    reg                  fc_orbitSync_dly;
    reg [15:0]           idleCountdown;
    wire                 sendIdle = |idleCountdown;
    
    //check if idle pattern should be sent
    always_ff @(posedge clk) begin
        if (tready_out) begin
            fc_linkReset_dly <= fc_linkReset;
            fc_orbitSync_dly <= fc_orbitSync;
        end
        
        if(!fc_linkReset_dly && fc_linkReset) idleCountdown <= n_idle_words;
        else if(sendIdle && tready_out)       idleCountdown <= idleCountdown - 1;
    end
    
    //multiplexer
    always_comb begin
        tdata_select <= 0;
        tvalid_select <= 0;
        
        if(sendIdle) begin
            if (!fc_orbitSync_dly && fc_orbitSync) begin
                tdata_select <= idle_word_BX0;
            end else begin
                tdata_select <= idle_word;
            end
            tvalid_select <= 1;
        end else begin
            for(int i = 0; i < N_INPUTS; i += 1) begin
                if(output_select == i) begin
                    tdata_select <= tdata_in[i];
                    tvalid_select <= tvalid_in[i];
                end
            end
        end
    end
    
    //output data reverser
    always_ff @(posedge clk) begin
        if (tready_out) begin
            tvalid_out <= tvalid_select;
            
            if(OUTPUT_REVERSE_BITS == 1) begin
                for(int i = 0; i < DATA_WIDTH; i += 1) begin
                    tdata_out[i] <= tdata_select[DATA_WIDTH - 1 - i];
                end
            end else begin
                tdata_out <= tdata_select;
            end
        end else begin
            tdata_out <= tdata_out;
            tvalid_out <= tvalid_out;
        end
    end
    
endmodule
