`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2020 01:18:55 PM
// Design Name: 
// Module Name: IO_blocks
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


module IO_blocks#(
    parameter integer NLINKS = 12,
    parameter integer WORD_PER_LINK = 4,
	parameter integer DRIVE_ENABLED = 1
    )
    (
    input logic in_clk160,
    input logic in_clk640,

	input logic out_clk160,

	input logic [7:0] in_tdata_00,
	input logic [7:0] in_tdata_01,
	input logic [7:0] in_tdata_02,
	input logic [7:0] in_tdata_03,
	input logic [7:0] in_tdata_04,
	input logic [7:0] in_tdata_05,
	input logic [7:0] in_tdata_06,
	input logic [7:0] in_tdata_07,
	input logic [7:0] in_tdata_08,
	input logic [7:0] in_tdata_09,
	input logic [7:0] in_tdata_10,
	input logic [7:0] in_tdata_11,
	input logic [7:0] in_tdata_12,
	input logic [7:0] in_tdata_13,
	input logic [7:0] in_tdata_14,
	input logic [7:0] in_tdata_15,

	input logic in_tvalid_00,
	input logic in_tvalid_01,
	input logic in_tvalid_02,
	input logic in_tvalid_03,
	input logic in_tvalid_04,
	input logic in_tvalid_05,
	input logic in_tvalid_06,
	input logic in_tvalid_07,
	input logic in_tvalid_08,
	input logic in_tvalid_09,
	input logic in_tvalid_10,
	input logic in_tvalid_11,
	input logic in_tvalid_12,
	input logic in_tvalid_13,
	input logic in_tvalid_14,
	input logic in_tvalid_15,

	output logic [7:0] out_tdata_00,
	output logic [7:0] out_tdata_01,
	output logic [7:0] out_tdata_02,
	output logic [7:0] out_tdata_03,
	output logic [7:0] out_tdata_04,
	output logic [7:0] out_tdata_05,
	output logic [7:0] out_tdata_06,
	output logic [7:0] out_tdata_07,
	output logic [7:0] out_tdata_08,
	output logic [7:0] out_tdata_09,
	output logic [7:0] out_tdata_10,
	output logic [7:0] out_tdata_11,
	output logic [7:0] out_tdata_12,
	output logic [7:0] out_tdata_13,
	output logic [7:0] out_tdata_14,
	output logic [7:0] out_tdata_15,

	output logic out_tvalid_00,
	output logic out_tvalid_01,
	output logic out_tvalid_02,
	output logic out_tvalid_03,
	output logic out_tvalid_04,
	output logic out_tvalid_05,
	output logic out_tvalid_06,
	output logic out_tvalid_07,
	output logic out_tvalid_08,
	output logic out_tvalid_09,
	output logic out_tvalid_10,
	output logic out_tvalid_11,
	output logic out_tvalid_12,
	output logic out_tvalid_13,
	output logic out_tvalid_14,
	output logic out_tvalid_15,

    inout logic [NLINKS-1:0]  D_IN_OUT_P,
    inout logic [NLINKS-1:0]  D_IN_OUT_N,
    
    //ipif configuration interface ports 
    input logic [31:0] IPIF_bus2ip_addr,  //unused
    input logic [3:0] IPIF_bus2ip_be,  //unused
    input logic [NLINKS:0] IPIF_bus2ip_cs,  //unused
    input logic [31:0] IPIF_bus2ip_data,  
    input logic [(NLINKS+1)*WORD_PER_LINK-1:0] IPIF_bus2ip_rdce,
    input logic IPIF_bus2ip_resetn,
    input logic IPIF_bus2ip_rnw,  //unused
    input logic [(NLINKS+1)*WORD_PER_LINK-1:0] IPIF_bus2ip_wrce,
    output logic [31:0] IPIF_ip2bus_data,
    output logic IPIF_ip2bus_error,  //unused
    output logic IPIF_ip2bus_rdack,
    output logic IPIF_ip2bus_wrack
    );
    
    //ground unused error port 
    assign IPIF_ip2bus_error = 0;
    
    logic delay_ready [NLINKS];
    logic waiting_for_transitions [NLINKS];
    logic [15:0] bit_align_errors [NLINKS];
    logic [8:0] delay_out [NLINKS];
    logic [8:0] delay_out_N [NLINKS];
    
    logic delay_set [NLINKS];
    logic delay_mode [NLINKS];
    logic [8:0] delay_in [NLINKS];
    logic [8:0] delay_error_offset [NLINKS];
    logic reset_counters [NLINKS];
    logic rstb_links [NLINKS];
	logic bypass_IOBUF [NLINKS];
	logic tristate_IOBUF [NLINKS];
    
    logic global_reset_counters;
    logic global_rstb_links;
    
    //IPIF parmaters are decoded here 
    IPIF_DelayParamDecode #(
        .NLINKS(NLINKS),
        .WORD_PER_LINK(WORD_PER_LINK)
    ) parameterDecode
    (
        .clk160(in_clk160),
    
        //ipif configuration interface ports 
        .IPIF_bus2ip_data(IPIF_bus2ip_data),  
        .IPIF_bus2ip_rdce(IPIF_bus2ip_rdce),
        .IPIF_bus2ip_resetn(IPIF_bus2ip_resetn),
        .IPIF_bus2ip_wrce(IPIF_bus2ip_wrce),
        .IPIF_ip2bus_data(IPIF_ip2bus_data),
        .IPIF_ip2bus_rdack(IPIF_ip2bus_rdack),
        .IPIF_ip2bus_wrack(IPIF_ip2bus_wrack),
        
        //parmeter and control signals 
        .delay_ready(delay_ready),
        .waiting_for_transitions(waiting_for_transitions),
        .bit_align_errors(bit_align_errors),
        .delay_out(delay_out),
        .delay_out_N(delay_out_N),
        
        .delay_set(delay_set),
        .delay_mode(delay_mode),
        .delay_in(delay_in),
        .delay_error_offset(delay_error_offset),
        .reset_counters(reset_counters),
        .rstb_links(rstb_links),

		.bypass_IOBUF(bypass_IOBUF),
		.tristate_IOBUF(tristate_IOBUF),
        
        .global_reset_counters(global_reset_counters),
        .global_rstb_links(global_rstb_links)
    );

	logic [7:0] in_tdata [15:0];
	logic in_tvalid [15:0];
	logic [7:0] out_tdata [15:0];
	logic [7:0] ISERDES_out [15:0];
	logic [7:0] bypass_in_data [15:0];
	logic [7:0] bypass_out_data [15:0];
	logic out_tvalid [15:0];

    assign in_tdata = {in_tdata_15, in_tdata_14, in_tdata_13, in_tdata_12,
		               in_tdata_11, in_tdata_10, in_tdata_09, in_tdata_08,
		               in_tdata_07, in_tdata_06, in_tdata_05, in_tdata_04,
		               in_tdata_03, in_tdata_02, in_tdata_01, in_tdata_00};

    assign in_tvalid = {in_tvalid_15, in_tvalid_14, in_tvalid_13, in_tvalid_12,
		                in_tvalid_11, in_tvalid_10, in_tvalid_09, in_tvalid_08,
		                in_tvalid_07, in_tvalid_06, in_tvalid_05, in_tvalid_04,
		                in_tvalid_03, in_tvalid_02, in_tvalid_01, in_tvalid_00};

	assign out_tdata_00 = out_tdata[0];
	assign out_tdata_01 = out_tdata[1];
	assign out_tdata_02 = out_tdata[2];
	assign out_tdata_03 = out_tdata[3];
	assign out_tdata_04 = out_tdata[4];
	assign out_tdata_05 = out_tdata[5];
	assign out_tdata_06 = out_tdata[6];
	assign out_tdata_07 = out_tdata[7];
	assign out_tdata_08 = out_tdata[8];
	assign out_tdata_09 = out_tdata[9];
	assign out_tdata_10 = out_tdata[10];
	assign out_tdata_11 = out_tdata[11];
	assign out_tdata_12 = out_tdata[12];
	assign out_tdata_13 = out_tdata[13];
	assign out_tdata_14 = out_tdata[14];
	assign out_tdata_15 = out_tdata[15];

	assign out_tvalid_00 = 1'b1;
	assign out_tvalid_01 = 1'b1;
	assign out_tvalid_02 = 1'b1;
	assign out_tvalid_03 = 1'b1;
	assign out_tvalid_04 = 1'b1;
	assign out_tvalid_05 = 1'b1;
	assign out_tvalid_06 = 1'b1;
	assign out_tvalid_07 = 1'b1;
	assign out_tvalid_08 = 1'b1;
	assign out_tvalid_09 = 1'b1;
	assign out_tvalid_10 = 1'b1;
	assign out_tvalid_11 = 1'b1;
	assign out_tvalid_12 = 1'b1;
	assign out_tvalid_13 = 1'b1;
	assign out_tvalid_14 = 1'b1;
	assign out_tvalid_15 = 1'b1;

    generate
    genvar i;
        for(i = 0; i < NLINKS; i = i + 1)
        begin : ioblocks
            
            logic IOBUFDS_to_ISERDES_P, IOBUFDS_to_ISERDES_N;
            logic DATA_OSERDES_to_IOBUFDS, TRISTATE_OSERDES_to_IOBUFDS;

			OSERDESE3 #(
				.DATA_WIDTH(8),
				.IS_RST_INVERTED(1),
				.SIM_DEVICE("ULTRASCALE_PLUS")
			) oserdes_inst (
				.CLK(in_clk640),
				.CLKDIV(in_clk160),
				.D(in_tdata[i]),
				.T(~in_tvalid[i] || tristate_IOBUF[i]), // T = 1 means tristate, T = 0 means drive data to output
				.OQ(DATA_OSERDES_to_IOBUFDS),
				.T_OUT(TRISTATE_OSERDES_to_IOBUFDS)
			);
   
			if (DRIVE_ENABLED == 1) begin
				IOBUFDS_DIFF_OUT diff_buf(.IO(D_IN_OUT_P[i]), .IOB(D_IN_OUT_N[i]), 
										  .I(DATA_OSERDES_to_IOBUFDS), 
										  .O(IOBUFDS_to_ISERDES_P), .OB(IOBUFDS_to_ISERDES_N),
										  .TM(TRISTATE_OSERDES_to_IOBUFDS),
										  .TS(TRISTATE_OSERDES_to_IOBUFDS));
			end else begin
				IBUFDS_DIFF_OUT diff_buf(.I(D_IN_OUT_P[i]), .IB(D_IN_OUT_N[i]),
					                     .O(IOBUFDS_to_ISERDES_P), .OB(IOBUFDS_to_ISERDES_N));
			end
        
            input_blocks sigmon(
                .clk640(in_clk640),
                .clk160(in_clk160),
				.fifo_rd_clk(out_clk160),
                
                .serial_data_P(IOBUFDS_to_ISERDES_P),
                .serial_data_N(IOBUFDS_to_ISERDES_N),

                .D_OUT_P(ISERDES_out[i]),
                .D_OUT_N(),  //intentionally unconnected
                
                .delay_set(delay_set[i]),
                .delay_mode(delay_mode[i]),
                .bit_align_errors(bit_align_errors[i]),
                .delay_in(delay_in[i]),
                .delay_out(delay_out[i]),
                .delay_out_N(delay_out_N[i]),
                .delay_error_offset(delay_error_offset[i]),
                .delay_ready(delay_ready[i]),
                .waiting_for_transitions(waiting_for_transitions[i]),
                
                .reset_counters(global_reset_counters || reset_counters[i]),

                .rstb(global_rstb_links && rstb_links[i])
            );

			assign out_tdata[i] = (bypass_IOBUF[i] ? bypass_out_data[i] : ISERDES_out[i]);
        end
    endgenerate        

	// Should probably replace this next part with an instance of
	// xpm_fifo_async...
	
	// Clock crossing for the bypass mode
	// We do not use an actual xpm_cdc module for this because it should not
	// be necessary.  The input and output 160 MHz clocks should have some
	// relationship, and Vivado should be able to use that relationship to
	// make timing work on this path.

	// Register the data in the input clk160 domain (this register stage
	// roughly mimics OSERDES, which registers the input data)
	always @(posedge in_clk160) begin
		for (int i = 0; i < NLINKS; i = i + 1) begin
			bypass_in_data[i] <= in_tdata[i];
		end
	end

	// Register the data in the output clk160 domain (this register stage
	// roughly mimics ISERDES, which registers the output data)
	always @(posedge out_clk160) begin
		for (int i = 0; i < NLINKS; i = i + 1) begin
			bypass_out_data[i] <= bypass_in_data[i];
		end
	end
endmodule
