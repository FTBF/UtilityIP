`timescale 1ns / 1ps

module ExtTrigTop #(
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer C_S_AXI_ADDR_WIDTH = 32,
		parameter integer N_REG = 4,
		parameter INCLUDE_AXI_SYNC = 1
	)(
		input  logic clk40,
		input  logic clk160,
		input  logic clk640,

		input  logic                                  IPIF_clk,
		input  logic                                  IPIF_Bus2IP_resetn,
		input  logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr, //unused
		input  logic                                  IPIF_Bus2IP_RNW, //unused
		input  logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE, //unused
		input  logic [0 : 0]                          IPIF_Bus2IP_CS, //unused
		input  logic [N_REG-1 : 0]                    IPIF_Bus2IP_RdCE,
		input  logic [N_REG-1 : 0]                    IPIF_Bus2IP_WrCE,
		input  logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data,
		output logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data,
		output logic                                  IPIF_IP2Bus_WrAck,
		output logic                                  IPIF_IP2Bus_RdAck,
		output logic                                  IPIF_IP2Bus_Error,

		input  logic asyncTrigIn_P,
		input  logic asyncTrigIn_N,
		input  logic busyIn_P,
		input  logic busyIn_N,
		input  logic startRun,
		input  logic stopRun,
		output logic syncTrigOut,
		output logic syncTrigOut0_P,
		output logic syncTrigOut0_N,
		output logic syncTrigOut_P,
		output logic syncTrigOut_N,
		output logic OutDisable0,
		output logic OutDisable1,
		output logic OutDisable2,
		output logic OutDisable3,
		output logic TermEnable0,
		output logic TermEnable1,
		output logic TermEnable2,
		output logic TermEnable3,
		output logic ledTop,
		output logic ledBot,
		output logic [7:0] trig_phase
	);

	logic [31:0] trig_in_count;


	typedef struct packed {
		// Register 3
		logic [32-5-1:0] padding3;
		logic [5-1:0] trigDelay;
		// Register 2
		logic [32-1:0] padding2;
		// Register 1
		logic [32-1:0] trig_in_count;
		// Register 0
		logic [32-3-1:0] padding0;
		logic            stopRun;
		logic            startRun;
		logic            reset;
	} param_t;

	param_t params_from_IP;
	param_t params_from_bus;
	param_t params_to_IP;
	param_t params_to_bus;

	always_comb begin
		params_from_IP = params_to_IP;
		params_from_IP.padding3 = '0;
		params_from_IP.padding2 = '0;
		params_from_IP.padding0 = '0;
		params_from_IP.trig_in_count = trig_in_count;
	end

	localparam param_t defaults = '{default:'0};
	localparam param_t self_reset = '{default:'0, reset:1'b1, startRun:1'b1, stopRun:1'b1};

	IPIF_parameterDecode #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(param_t),
		.DEFAULTS(defaults),
		.SELF_RESET(self_reset)
	) parameterDecoder (
		.clk(IPIF_clk),

		.IPIF_bus2ip_data(IPIF_Bus2IP_Data),
		.IPIF_bus2ip_rdce(IPIF_Bus2IP_RdCE),
		.IPIF_bus2ip_resetn(IPIF_Bus2IP_resetn),
		.IPIF_bus2ip_wrce(IPIF_Bus2IP_WrCE),
		.IPIF_ip2bus_data(IPIF_IP2Bus_Data),
		.IPIF_ip2bus_rdack(IPIF_IP2Bus_RdAck),
		.IPIF_ip2bus_wrack(IPIF_IP2Bus_WrAck),

		.parameters_out(params_from_bus),
		.parameters_in(params_to_bus)
	);

	IPIF_clock_converter #(
		.INCLUDE_SYNCHRONIZER(INCLUDE_AXI_SYNC),
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(param_t)
	) IPIF_clock_conv (
		.IP_clk(clock),
		.bus_clk(IPIF_clk),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus)
	);

	logic asyncTrigIn;
	IBUFDS IBUFDS_asyncTrigIn (
		.O(asyncTrigIn),   // 1-bit output: Buffer output
		.I(asyncTrigIn_P),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
		.IB(asyncTrigIn_N)  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
	);

	logic asyncTrigIn0;
//	IDDRE1 #(
//		.DDR_CLK_EDGE("OPPOSITE_EDGE"), // IDDRE1 mode (OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED)
//		.IS_CB_INVERTED(1'b1),          // Optional inversion for CB
//		.IS_C_INVERTED(1'b0)            // Optional inversion for C
//	) IDDRE1_asyncTrigIn (
//		.Q1(asyncTrigIn0), // 1-bit output: Registered parallel output 1
//		.Q2(),             // 1-bit output: Registered parallel output 2
//		.C(clk40),         // 1-bit input: High-speed clock
//		.CB(clk40),        // 1-bit input: Inversion of High-speed clock C
//		.D(asyncTrigIn),   // 1-bit input: Serial Data Input
//		.R(0)              // 1-bit input: Active-High Async Reset
//	);

	logic busyIn;
	IBUFDS IBUFDS_busyIn (
		.O(busyIn),   // 1-bit output: Buffer output
		.I(busyIn_P), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
		.IB(busyIn_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
	);

	logic busyIn0;
	IDDRE1 #(
		.DDR_CLK_EDGE("OPPOSITE_EDGE"), // IDDRE1 mode (OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED)
		.IS_CB_INVERTED(1'b1),          // Optional inversion for CB
		.IS_C_INVERTED(1'b0)            // Optional inversion for C
	) IDDRE1_busyIn (
		.Q1(busyIn0), // 1-bit output: Registered parallel output 1
		.Q2(),        // 1-bit output: Registered parallel output 2
		.C(clk40),    // 1-bit input: High-speed clock
		.CB(clk40),   // 1-bit input: Inversion of High-speed clock C
		.D(busyIn),   // 1-bit input: Serial Data Input
		.R(0)         // 1-bit input: Active-High Async Reset
	);

    logic [7:0] deserialized_word;
//  ISERDESE3  : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (ISERDESE3_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // ISERDESE3: Input SERial/DESerializer
   //            Kintex UltraScale+
   // Xilinx HDL Language Template, version 2021.2

   ISERDESE3 #(
      .DATA_WIDTH(8),                  // Parallel data width (4,8)
      .FIFO_ENABLE("FALSE"),          // Enables the use of the FIFO
      .FIFO_SYNC_MODE("FALSE"),       // Always set to FALSE. TRUE is reserved for later use.
      .IS_CLK_B_INVERTED(1'b1),       // Optional inversion for CLK_B
      .IS_CLK_INVERTED(1'b0),         // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0),         // Optional inversion for RST
      .SIM_DEVICE("ULTRASCALE_PLUS")  // Set the device version for simulation functionality (ULTRASCALE,
                                      // ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
   )
   ISERDESE3_inst (
      .FIFO_EMPTY(FIFO_EMPTY),           // 1-bit output: FIFO empty flag
      .INTERNAL_DIVCLK(INTERNAL_DIVCLK), // 1-bit output: Internally divided down clock used when FIFO is
                                         // disabled (do not connect)
      .Q(deserialized_word),                    // 8-bit registered output
      .CLK(clk640),                         // 1-bit input: High-speed clock
      .CLKDIV(clk160),                   // 1-bit input: Divided Clock
      .CLK_B(clk640),                     // 1-bit input: Inversion of High-speed clock CLK
      .D(asyncTrigIn),                   // 1-bit input: Serial Data Input
      .FIFO_RD_CLK(clk160),            // 1-bit input: FIFO read clock
      .FIFO_RD_EN(1'b0),           // 1-bit input: Enables reading the FIFO when asserted
      .RST(1'b0)                          // 1-bit input: Asynchronous Reset
   );

   // End of ISERDESE3_inst instantiation


//	typedef logic [7:0] word;
//	parameter delay = 256;
//	var word fifo[delay];
//	for(genvar i=0;i<delay-1;i++)
//	   always @(posedge clk160)
//	       fifo[i+1] <= fifo[i];
	       
    always @(posedge clk160) begin
        trig_phase <= deserialized_word; 
//        fifo[0] <= deserialized_word;
//        trig_phase <= fifo[delay-1];
    end


	logic asyncTrigIn1, syncTrig0;
	logic [31:0] clockCounter;
	logic accept, dead, running;

	always_comb begin
	   asyncTrigIn0 = deserialized_word[0];
		accept = asyncTrigIn0 && !asyncTrigIn1 && !busyIn0 && !dead && running;
	end

	always_ff  @(posedge clk40) begin
		asyncTrigIn1 <= asyncTrigIn0;
		if(asyncTrigIn0 && !asyncTrigIn1)
			ledTop <= !ledTop;

		//Running FSM
		if((startRun || params_to_IP.startRun) && !running) begin
			running <= 1;
			trig_in_count <= 0;
		end else begin
			if(trig_in_count == 32'h40000 || (stopRun || params_to_IP.stopRun))
				running <= 0;
		end

		//Trigger FSM
		if(accept) begin
			syncTrig0 <= 1;
			ledBot <= !ledBot;
			clockCounter = 0;
			dead <=1;
			trig_in_count <= trig_in_count + 1;
		end else begin
			syncTrig0 <= 0;
			clockCounter <= clockCounter + 1;
			if(clockCounter == 32'h400)
				dead <= 0;
		end
	end

	SRLC32E #(
		.INIT(32'h00000000),    // Initial contents of shift register
		.IS_CLK_INVERTED(1'b0)  // Optional inversion for CLK
	) SRLC32E_syncTrigOut (
		.Q(syncTrigOut),            // 1-bit output: SRL Data
		.Q31(),                     // 1-bit output: SRL Cascade Data
		.A(params_to_IP.trigDelay), // 5-bit input: Selects SRL depth
		.CE(1),                     // 1-bit input: clk40 enable
		.CLK(clk40),                // 1-bit input: Clock
		.D(accept)                  // 1-bit input: SRL Data
	);

	logic syncTrig0DDR;
	ODDRE1 #(
		.IS_C_INVERTED(1'b0),
		.SIM_DEVICE("ULTRASCALE_PLUS"),
		.SRVAL(1'b0)
	) ODDRE1_syncTrig0 (
		.Q(syncTrig0DDR), // 1-bit output: Data output to IOB
		.C(clk40),        // 1-bit input: High-speed clock input
		.D1(syncTrig0),   // 1-bit input: Parallel data input 1
		.D2(syncTrig0),   // 1-bit input: Parallel data input 2
		.SR(0)            // 1-bit input: Active-High Async Reset
	);

	OBUFDS OBUFDS_syncTrig0 (
		.O(syncTrigOut0_P),  // 1-bit output: Diff_p output (connect directly to top-level port)
		.OB(syncTrigOut0_N), // 1-bit output: Diff_n output (connect directly to top-level port)
		.I(syncTrig0DDR)     // 1-bit input: Buffer input
	);

	logic syncTrigOutDDR;
	ODDRE1 #(
		.IS_C_INVERTED(1'b0),
		.SIM_DEVICE("ULTRASCALE_PLUS"),
		.SRVAL(1'b0)
	) ODDRE1_syncTrigOut (
		.Q(syncTrigOutDDR), // 1-bit output: Data output to IOB
		.C(clk40),          // 1-bit input: High-speed clock input
		.D1(syncTrigOut),   // 1-bit input: Parallel data input 1
		.D2(syncTrigOut),   // 1-bit input: Parallel data input 2
		.SR(0)              // 1-bit input: Active-High Async Reset
	);

	OBUFDS OBUFDS_syncTrigOut (
		.O(syncTrigOut_P),  // 1-bit output: Diff_p output (connect directly to top-level port)
		.OB(syncTrigOut_N), // 1-bit output: Diff_n output (connect directly to top-level port)
		.I(syncTrigOutDDR)  // 1-bit input: Buffer input
	);

	always_comb begin
		OutDisable0 <= 0;
		OutDisable1 <= 0;
		OutDisable2 <= 1;
		OutDisable3 <= 1;
		TermEnable0 <= 0;
		TermEnable1 <= 0;
		TermEnable2 <= 1;
		TermEnable3 <= 1;
	end					
	
endmodule
