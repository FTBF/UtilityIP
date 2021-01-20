`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2020 10:44:52 AM
// Design Name: 
// Module Name: input_blocks
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


module input_blocks(
        input wire          clk640,
        input wire          clk160,
		input wire          fifo_rd_clk,
        
        input wire serial_data_P,
        input wire serial_data_N,

        output wire [7 : 0] D_OUT_P,
        output wire [7 : 0] D_OUT_N,
        
        output wire [15:0]   bit_align_errors,
        
        input wire          delay_set,
        input wire          delay_mode,
        input wire [8:0]    delay_in,
        output wire [8:0]   delay_out,
        output wire [8:0]   delay_out_N,
        input wire [8:0]    delay_error_offset,
        output wire         delay_ready,

        input wire          reset_counters,
        input wire          rstb
    );
    
   wire [8 : 0]    rx_cntvaluein_0;
   wire            rx_load_0;
   reg             rx_en_vtc_0;
   wire [8 : 0]    rx_cntvaluein_1;
   wire            rx_load_1;
   reg             rx_en_vtc_1;
   wire            rx_clk;
   wire            fifo_rd_clk_0;
   wire            fifo_rd_clk_1;
   wire            fifo_rd_en_0;
   wire            fifo_rd_en_1;
   wire            fifo_empty_0;
   wire            fifo_empty_1;
   wire            rst_seq_done;
   
   assign fifo_rd_clk_0 = fifo_rd_clk;
   assign fifo_rd_clk_1 = fifo_rd_clk;
   
   assign fifo_rd_en_0 = !fifo_empty_0;
   assign fifo_rd_en_1 = !fifo_empty_1;
   
   wire [5:0] eye_width;
   wire [8:0] delay_out_N_local;
   
   assign delay_out_N = (delay_mode)?({eye_width, 3'b0}):(delay_out_N_local);
   
   delay_ctrl dly_ctrl(
        .clk160(clk160),
        
        .D_OUT_P(D_OUT_P),
        .D_OUT_N(D_OUT_N),

        .delay_mode(delay_mode),
        .delay_set(delay_set),
        .delay_in(delay_in),
        .delay_error_offset(delay_error_offset),
        
        .bit_align_errors(bit_align_errors),
        .delay_out_P(delay_out),
        .delay_out_N(delay_out_N_local),
        
        .eye_width(eye_width),
        
        .fifo_ready(fifo_rd_en_0 && fifo_rd_en_1),
        
        .delay_set_P(rx_cntvaluein_0),
        .delay_set_N(rx_cntvaluein_1),
        .delay_wr_P(rx_load_0),
        .delay_wr_N(rx_load_1),
        
        .delay_ready(delay_ready),
        
        .reset_counters(reset_counters),
        .rstb(rstb)
    );

   
   wire link_data_delay_P;
   wire link_data_delay_N;
   
   IDELAYE3 #(
      .CASCADE("NONE"),
      .DELAY_FORMAT("COUNT"),
      .DELAY_SRC("IDATAIN"),
      .DELAY_TYPE("VAR_LOAD"),
      .DELAY_VALUE(0),
      .IS_CLK_INVERTED(0),
      .IS_RST_INVERTED(1),
      .UPDATE_MODE("ASYNC"),
      .SIM_DEVICE("ULTRASCALE_PLUS")
      )
      idelay_P    
    (
     .CASC_OUT(),
     .CNTVALUEOUT(delay_out),
     .DATAOUT(link_data_delay_P),
     .CASC_IN(0),
     .CASC_RETURN(0),
     .CE(0),
     .CLK(clk160),
     .CNTVALUEIN(rx_cntvaluein_0),
     .DATAIN(0),
     .EN_VTC(0),
     .IDATAIN(serial_data_P),
     .INC(0),
     .LOAD(rx_load_0),
     .RST(rstb)
     );
     
   
    ISERDESE3  #(
      .DATA_WIDTH(8),
      .FIFO_ENABLE("TRUE"),
      .FIFO_SYNC_MODE("FALSE"),
      .IS_CLK_B_INVERTED(1),
      .IS_CLK_INVERTED(0),
      .IS_RST_INVERTED(1),
      .SIM_DEVICE("ULTRASCALE_PLUS")
      )
      iserdes_P
    (
     .INTERNAL_DIVCLK(),
     .Q(D_OUT_P),
     .CLK(clk640),
     .CLK_B(clk640),
     .CLKDIV(clk160),
     .D(link_data_delay_P),
     .FIFO_RD_CLK(fifo_rd_clk_0),
     .FIFO_EMPTY(fifo_empty_0),
     .FIFO_RD_EN(fifo_rd_en_0),
     .RST(rstb)
     );

    IDELAYE3 #(
      .CASCADE("NONE"),
      .DELAY_FORMAT("COUNT"),
      .DELAY_SRC("IDATAIN"),
      .DELAY_TYPE("VAR_LOAD"),
      .DELAY_VALUE(0),
      .IS_CLK_INVERTED(0),
      .IS_RST_INVERTED(1),
      .UPDATE_MODE("ASYNC"),
      .SIM_DEVICE("ULTRASCALE_PLUS")
      )
      idelay_N  
    (
     .CASC_OUT(),
     .CNTVALUEOUT(delay_out_N_local),
     .DATAOUT(link_data_delay_N),
     .CASC_IN(0),
     .CASC_RETURN(0),
     .CE(0),
     .CLK(clk160),
     .CNTVALUEIN(rx_cntvaluein_1),
     .DATAIN(0),
     .EN_VTC(0),
     .IDATAIN(serial_data_N),
     .INC(0),
     .LOAD(rx_load_1),
     .RST(rstb)
     );
        
    ISERDESE3  #(
      .DATA_WIDTH(8),
      .FIFO_ENABLE("TRUE"),
      .FIFO_SYNC_MODE("FALSE"),
      .IS_CLK_B_INVERTED(1),
      .IS_CLK_INVERTED(0),
      .IS_RST_INVERTED(1),
      .SIM_DEVICE("ULTRASCALE_PLUS")
      )
      iserdes_N
    (
     .INTERNAL_DIVCLK(),
     .Q(D_OUT_N),
     .CLK(clk640),
     .CLK_B(clk640),
     .CLKDIV(clk160),
     .D(link_data_delay_N),
     .FIFO_RD_CLK(fifo_rd_clk_1),
     .FIFO_EMPTY(fifo_empty_1),
     .FIFO_RD_EN(fifo_rd_en_1),
     .RST(rstb)
     );
   

endmodule
