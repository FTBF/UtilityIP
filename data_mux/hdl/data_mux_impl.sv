`timescale 1ns / 1ps

module data_mux_impl# (
    parameter integer DATA_WIDTH = 32,
    parameter integer N_INPUTS = 16,
    parameter OUTPUT_REVERSE_BITS = 1
    )
    (
    //Clock
    input logic clk,
    
    //Input AXIS busses
    input  logic [DATA_WIDTH-1:0] tdata_in  [N_INPUTS],
    input  logic                  tvalid_in [N_INPUTS],
    output logic                  tready_in [N_INPUTS],
    
    //Output AXIS bus
    output logic [DATA_WIDTH-1:0] tdata_out,
    output logic                  tvalid_out,
    input  logic                  tready_out,
    
    //configuration parameters 
    input logic [15:0]           n_idle_words,
    input logic [3:0]            output_select,
    input logic [DATA_WIDTH-1:0] idle_word,
    input logic [DATA_WIDTH-1:0] idle_word_BX0,
    input logic [DATA_WIDTH-1:0] header_mask,
    input logic [DATA_WIDTH-1:0] header,
    input logic [DATA_WIDTH-1:0] header_BX0,
    
    //fast control parameter
    input logic fc_orbitSync,
    input logic fc_linkReset
    );

	logic r_tvalid = 1'b0;
	logic [DATA_WIDTH-1:0] r_tdata = '0;
    
    logic [DATA_WIDTH-1:0] tdata_select;
    logic                  tvalid_select;

    logic                  fc_linkReset_dly;
    logic                  fc_orbitSync_dly;
    logic [15:0]           idleCountdown;
    logic                  sendIdle = |idleCountdown;
    
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
					if (!fc_orbitSync_dly && fc_orbitSync) begin
						tdata_select <= (tdata_in[i] & ~header_mask) | (header_BX0 & header_mask);
					end else begin
						tdata_select <= (tdata_in[i] & ~header_mask) | (header & header_mask);
					end
                    tvalid_select <= tvalid_in[i];
                end
            end
        end
    end

	// Skid buffer to handle the output
	always_ff @(posedge clk) begin
		if (tvalid_select && !r_tvalid && !tready_out) begin
			r_tvalid <= 1'b1;
		end else if (tready_out) begin
			r_tvalid <= 1'b0;
		end

		if (!r_tvalid) begin
			r_tdata <= tdata_select;
		end
	end

	logic [DATA_WIDTH-1:0] temp_tdata;
	always_comb begin
		tvalid_out = (tvalid_select || r_tvalid);

		for(int j = 0; j < N_INPUTS; j += 1) begin
			tready_in[j] = !r_tvalid;
		end

		temp_tdata = (r_tvalid ? r_tdata : tdata_select);
		if (OUTPUT_REVERSE_BITS == 1) begin
			//output data reverser
			for (int i = 0; i < DATA_WIDTH; i += 1) begin
				tdata_out[i] = temp_tdata[DATA_WIDTH - 1 - i];
			end
		end else begin
			tdata_out = temp_tdata;
		end
	end
endmodule
