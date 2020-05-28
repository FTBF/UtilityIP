`timescale 1ns / 1ps

module OSERDES_ip(
		input wire CLK,
		input wire CLKDIV,

		input wire [7:0] tdata,
		input wire tvalid,
		output wire tready,

		output wire OQ,
		output wire T_OUT,
		
		input wire RST
    );

	assign tready = 1'b1;
	
	wire T;

	SRL16E #(.INIT(16'hFFFF), .IS_CLK_INVERTED(1'b0)) T_delay (
		.Q(T),
		.CE(1'b1),
		.CLK(CLK),
		.D(!tvalid),
		.A0(1'b1),
		.A1(1'b1),
		.A2(1'b0),
		.A3(1'b0));
        
	OSERDESE3 #(
	   .DATA_WIDTH(8),                 // Parallel Data Width (4-8)
	   .INIT(1'b0),                    // Initialization value of the OSERDES flip-flops
	   .IS_CLKDIV_INVERTED(1'b0),      // Optional inversion for CLKDIV
	   .IS_CLK_INVERTED(1'b0),         // Optional inversion for CLK
	   .IS_RST_INVERTED(1'b1),         // Optional inversion for RST
	   .SIM_DEVICE("ULTRASCALE_PLUS")  // Set the device version (ULTRASCALE, ULTRASCALE_PLUS,
	)
	OSERDESE3_inst (
	   .OQ(OQ),         // 1-bit output: Serial Output Data
	   .T_OUT(T_OUT),   // 1-bit output: 3-state control output to IOB
	   .CLK(CLK),       // 1-bit input: High-speed clock
	   .CLKDIV(CLKDIV), // 1-bit input: Divided Clock
	   .D(tdata),           // 8-bit input: Parallel Data Input
	   .RST(RST),       // 1-bit input: Asynchronous Reset
	   .T(T)            // 1-bit input: Tristate input from fabric
	);
endmodule
