
//============================================================================
// University of Minnesota
//============================================================================
// Contact: frahm@physics.umn.edu
//============================================================================
// clkRateTool2 - Modified version of Jeremy's clock rate tool
// This version uses an async reset to track clocks that go to 0 Hz.
//============================================================================

module clkRateTool
  (input reset_in,
   input clk100,
   input clktest,
   output reg [31:0] value);
   
   reg [23:0] refCtr;
   reg [23:0] rateCtr;
   
   reg async_reset;
   reg counting1a, counting1b;

   //=======================================================================
   // 100 MHz clock domain
   //=======================================================================
   
   always @(posedge clk100 or posedge reset_in) begin
      if (reset_in)
      begin
         refCtr <= 0;
         counting1a <= 0;
         async_reset <= 1;
         value<=32'hffffffff;
      end
      else
      begin
         if (refCtr == 24'h800000) refCtr <= 0; // 
         else refCtr <= refCtr+24'h1;

         if (refCtr < 24'd1000000) counting1a <= 1; 
         else counting1a <= 0;
         
         if (refCtr == 24'h100000) value <= rateCtr;                // 1,048,576
		 else if (reset_in) value<=32'hffffffff;
         else value <= value;
         
         if ((refCtr & 24'hFFFF00) == 24'h110000) async_reset <= 1; // 1,114,112
         else async_reset <= reset_in;
      end
   end
   
   //=======================================================================
   // test clock domain
   //=======================================================================
	
   // on for 0.01 s; off for 0.08 s
   always @(posedge clktest) begin
      counting1b <= counting1a; 
   end
   always @(posedge clktest or posedge async_reset) begin
      if (async_reset == 1) rateCtr <= 0;
      else if ((counting1b) == 1) rateCtr <= rateCtr+24'h1;
      else rateCtr <= rateCtr;
   end
   
endmodule
