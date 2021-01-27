`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2020 02:46:01 PM
// Design Name: 
// Module Name: delay_ctrl
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


module delay_ctrl(
        input wire clk160,
        
        input wire [7:0] D_OUT_P,
        input wire [7:0] D_OUT_N,

        input wire delay_mode,
        input wire delay_set,
        input wire [8:0] delay_in,
        input wire [8:0] delay_error_offset,
        
        output reg [15:0] bit_align_errors,
        input wire [8:0]  delay_out_P,
        input wire [8:0]  delay_out_N,
        
        output wire [5:0] eye_width,
        
        input wire fifo_ready,
        
        output wire [8:0] delay_set_P,
        output wire [8:0] delay_set_N,
        output wire       delay_wr_P,
        output wire       delay_wr_N,
        
        output wire       delay_ready,
        
        input wire reset_counters,
        input wire rstb
    );
    
   reg [3:0]       dly_cnt = 0;
   
   //reserved for later use with IDELAYCTRL
   assign rst_seq_done = 1'b1;
   
   //detect word errors
    reg autoReset;
    reg [4:0] autoErrCnt;
    reg [4:0] autoTransitionCnt;
    wire totalCounterResetb_manual;
    assign totalCounterResetb_manual = rst_seq_done && rstb && !reset_counters;
    wire totalCounterResetb_auto;
    assign totalCounterResetb_auto = rst_seq_done && !autoReset;
    
    wire bae;
    assign bae = |(~(D_OUT_P ^ D_OUT_N));
    
    reg last_bit;
    always @(posedge clk160)
        last_bit <= D_OUT_P[0];

    wire any_transition;
    assign any_transition = |({last_bit, D_OUT_P[8-1:1]} ^ D_OUT_P);
    
    reg countEnable;
    
    always @(posedge clk160 or negedge totalCounterResetb_manual)
    begin
        if(!totalCounterResetb_manual)
        begin
            bit_align_errors <= 0;
        end
        else
        begin
            if(countEnable && fifo_ready && (!(&bit_align_errors)) && bae) bit_align_errors <= bit_align_errors + 1;
        end
    end
    
    always @(posedge clk160)
    begin
        if(!totalCounterResetb_auto)
        begin
            autoErrCnt <= 0;
			autoTransitionCnt <= 0;
        end
        else
        begin
            if(bae) autoErrCnt <= autoErrCnt + 1;
			if(any_transition) autoTransitionCnt <= autoTransitionCnt + 1;
        end
    end
    
    reg [8:0] delay_target_P = 0;
    reg [8:0] delay_target_N = 0;
    wire delay_ready_P;
    wire delay_ready_N;
    
    wire delay_ready_manual;
    assign delay_ready_manual = delay_ready_P && delay_ready_N;
    
    reg delay_ready_automatic;
    
    assign delay_ready = (delay_mode)?(delay_ready_automatic):(delay_ready_manual);
    
    reg [2:0] delay_set_SR = 3'b0;
   
    always @(posedge clk160) delay_set_SR <= {delay_set_SR[1:0], delay_set};
    
    IDELAY_set_ctrl idelSetCtrl_P(
        .clk160(clk160),
        
        .delay_target(delay_target_P),
        .delay_out(delay_out_P),
        
        .delay_set_value(delay_set_P),
        .delay_wr(delay_wr_P),
        .delay_ready(delay_ready_P),
        
        .rstb(rstb)

    );
    
    IDELAY_set_ctrl #(1) idelSetCtrl_N(
        .clk160(clk160),
        
        .delay_target(delay_target_N),
        .delay_out(delay_out_N),
        
        .delay_set_value(delay_set_N),
        .delay_wr(delay_wr_N),
        .delay_ready(delay_ready_N),
        
        .rstb(rstb)

    );
     
   //auto bit alignment control state machine
   localparam STATE_BITALIGN_IDLE             = 4'h0;
   localparam STATE_BITALIGN_AUTOINIT         = 4'h1;
   localparam STATE_BITALIGN_INITRESET        = 4'h2;
   localparam STATE_BITALIGN_INITWAIT         = 4'h3;
   localparam STATE_BITALIGN_PHASE1_RESET     = 4'h4;
   localparam STATE_BITALIGN_PHASE1_RESET2    = 4'h5;
   localparam STATE_BITALIGN_PHASE1_WAITCNT   = 4'h6;
   localparam STATE_BITALIGN_PHASE1_CHECK     = 4'h7;
   localparam STATE_BITALIGN_PHASE1_WAITADJ   = 4'h8;
   localparam STATE_BITALIGN_PHASE2_WAITADJ   = 4'h9;
   localparam STATE_BITALIGN_PHASE2_RESET     = 4'ha;
   localparam STATE_BITALIGN_PHASE2_RESET2    = 4'hb;
   localparam STATE_BITALIGN_PHASE2_WAITCNT   = 4'hc;
   localparam STATE_BITALIGN_PHASE2_CHECK     = 4'hd;
   localparam STATE_BITALIGN_PHASE2_ADJ       = 4'he;
   localparam STATE_BITALIGN_PHASE2_END       = 4'hf;
   
   reg [3:0] state_bitalign = STATE_BITALIGN_IDLE;
   reg [5:0] step_cnt;
   reg [4:0] wait_cnt;
   
   reg [5:0] step_max;
   reg [5:0] max_loc;
   reg [1:0] phase2_stage;
   reg [1:0] eye_mon;
   
  assign eye_width = step_max;
      
   always @(posedge clk160 or negedge rstb)
   begin
      if(!rstb)
      begin
         step_cnt <= 0;
         step_max <= 0;
         max_loc <= 0;
         delay_target_P <= 0;
         delay_target_N <= 0;
         autoReset <= 0;
         phase2_stage <= 0;
         eye_mon <= 0;
         delay_ready_automatic <= 0;
         countEnable <= 1;
         state_bitalign <= STATE_BITALIGN_IDLE;
      end
      else
      begin
         case(state_bitalign)
            STATE_BITALIGN_IDLE: //0
            begin
                countEnable <= 1;
                if(delay_mode)
                begin  //Auto mode
                    state_bitalign <= STATE_BITALIGN_AUTOINIT;
                end
                else
                begin  //manual mode
                    if(delay_set_SR == 3'b001)
                    begin
                        delay_target_P <= delay_in;
                        delay_target_N <= delay_in + delay_error_offset;
                    end
                end
            end
            
            STATE_BITALIGN_AUTOINIT: //1
            begin
                delay_target_P <= 9'h1f0;
                delay_target_N <= 9'h1f8;
                step_cnt <= 0;
                step_max <= 0;
                max_loc <= 0;
                phase2_stage <= 0;
                eye_mon <= 0;
                delay_ready_automatic <= 0;
                countEnable <= 0;
                state_bitalign <= STATE_BITALIGN_INITRESET;
            end
            
            STATE_BITALIGN_INITRESET: //2
            begin
                state_bitalign <= STATE_BITALIGN_INITWAIT;
            end
            
            STATE_BITALIGN_INITWAIT: //3
            begin
                if(delay_ready_manual) state_bitalign <= STATE_BITALIGN_PHASE1_RESET;
            end
            
            STATE_BITALIGN_PHASE1_RESET: //4
            begin
                if(delay_mode)
                begin
                    autoReset <= 1;
                    state_bitalign <= STATE_BITALIGN_PHASE1_RESET2;
                end
                else
                begin
                    state_bitalign <= STATE_BITALIGN_IDLE;
                end
            end
            
            STATE_BITALIGN_PHASE1_RESET2: //5
            begin
                autoReset <= 0;
                wait_cnt <= 16;
                state_bitalign <= STATE_BITALIGN_PHASE1_WAITCNT;
            end
            
            STATE_BITALIGN_PHASE1_WAITCNT: //6
            begin
                if (autoTransitionCnt)
                    wait_cnt <= wait_cnt - 1;
                if(!wait_cnt)
                begin
                    state_bitalign <= STATE_BITALIGN_PHASE1_CHECK;
                    
                    if(autoErrCnt) step_cnt <= 0;
                    else                 step_cnt <= step_cnt + 1;
                end
            end
            
            STATE_BITALIGN_PHASE1_CHECK: //7
            begin
                if(delay_target_P[8:3] != 6'b0)
                begin
                    state_bitalign <= STATE_BITALIGN_PHASE1_WAITADJ;
                    delay_target_P <= delay_target_P - 8;
                    delay_target_N <= delay_target_N - 8;
                    
                    if(step_cnt >= step_max)
                    begin
                        step_max <= step_cnt;
                        max_loc <= delay_target_P[8:3];
                    end
                end
                else
                begin
                    state_bitalign <= STATE_BITALIGN_PHASE2_WAITADJ;
                    delay_target_P <= {max_loc + step_max[5:1], step_max[0], 2'b0};
                    delay_target_N <= {max_loc, 3'b0};
                    step_max <= step_max;
                end
                
            end
            
            STATE_BITALIGN_PHASE1_WAITADJ: //8
            begin
                if(delay_ready_manual) state_bitalign <= STATE_BITALIGN_PHASE1_RESET;
            end
            
            
            STATE_BITALIGN_PHASE2_WAITADJ: //9
            begin
                if(delay_mode)
                begin
                    if(delay_ready_manual) state_bitalign <= STATE_BITALIGN_PHASE2_RESET;
                end
                else           state_bitalign <= STATE_BITALIGN_PHASE2_END;
                delay_ready_automatic <= 1;
            end
            
            STATE_BITALIGN_PHASE2_RESET: //a
            begin
                if(delay_mode)
                begin
                    autoReset <= 1;
                    state_bitalign <= STATE_BITALIGN_PHASE2_RESET2;
                end
                else
                begin
                    state_bitalign <= STATE_BITALIGN_IDLE;
                end
            end
            
            STATE_BITALIGN_PHASE2_RESET2: //b
            begin
                autoReset <= 0;
                wait_cnt <= 16;
                state_bitalign <= STATE_BITALIGN_PHASE2_WAITCNT;
            end
            
            STATE_BITALIGN_PHASE2_WAITCNT: //c
            begin
                if (autoTransitionCnt)
                    wait_cnt <= wait_cnt - 1;
                if(!wait_cnt) state_bitalign <= STATE_BITALIGN_PHASE2_CHECK;
            end
            
            STATE_BITALIGN_PHASE2_CHECK: //d
            begin
                state_bitalign <= STATE_BITALIGN_PHASE2_ADJ;
                phase2_stage <= phase2_stage + 1;
                case(phase2_stage)
                    2'h0:
                    begin
                        eye_mon[1] <= (|autoErrCnt) || (delay_target_N == 9'h1ff);
                        delay_target_N <= delay_target_P - {step_max, 2'b0};
                    end
                    2'h1:
                    begin
                        eye_mon[0] <= (|autoErrCnt) || (delay_target_N == 9'b0);
                        delay_target_N <= delay_target_P;
                    end
                    2'h2:
                    begin
                        countEnable <= 1;
                    end
                    2'h3:
                    begin
                        countEnable <= 0;
                        delay_target_N <= delay_target_P + {step_max, 2'b0};
                    end
                endcase
            end
            
            STATE_BITALIGN_PHASE2_ADJ: //e
            begin
                state_bitalign <= STATE_BITALIGN_PHASE2_WAITADJ;
                if(phase2_stage == 2'h1)
                begin
                    case(eye_mon)
                        2'b01:
                        begin
                            delay_target_P <= delay_target_P + 1;
                        end
                        2'b10:
                        begin
                            delay_target_P <= delay_target_P - 1;
                        end
                        2'b11:
                        begin
                            if(step_max > 1) step_max <= step_max - 1;
                        end
                    endcase
                end
            end
            
            STATE_BITALIGN_PHASE2_END: //f
            begin
                delay_target_N <= delay_target_P;
                state_bitalign <= STATE_BITALIGN_IDLE;
            end
            
            default: state_bitalign <= STATE_BITALIGN_IDLE;
         endcase
      end
   end
endmodule
