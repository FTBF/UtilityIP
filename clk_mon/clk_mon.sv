`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2021 02:30:19 PM
// Design Name: 
// Module Name: clk_mon
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


module clk_mon #(
    parameter NCLK = 1,
    
    parameter C_S_AXI_ADDR_WIDTH = 32,
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter N_REG = 4
    )(
    input wire clk_ref,
    
    input wire [NCLK-1:0] clk_test,
    
    input wire [NCLK-1:0] locked,
    
    //configuration parameter interface 
    input  wire                                  IPIF_Bus2IP_resetn,
    input  wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr,   //unused
    input  wire                                  IPIF_Bus2IP_RNW,    //unused
    input  wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE,     //unused
    input  wire [NCLK-1 : 0]                     IPIF_Bus2IP_CS,     //unused
    input  wire [NCLK*N_REG-1 : 0]               IPIF_Bus2IP_RdCE, 
    input  wire [NCLK*N_REG-1 : 0]               IPIF_Bus2IP_WrCE,
    input  wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data,
    output reg  [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data,
    output wire                                  IPIF_IP2Bus_WrAck,
    output wire                                  IPIF_IP2Bus_RdAck,
    output wire                                  IPIF_IP2Bus_Error,

    input wire aresetn
    );
    
    logic [NCLK-1:0] ip2bus_rdack;
    assign IPIF_IP2Bus_RdAck = |ip2bus_rdack;
    
    logic [NCLK-1:0] ip2bus_wrack;
    assign IPIF_IP2Bus_WrAck = |ip2bus_wrack;
    
    logic [31:0] data [NCLK-1:0];
    always_comb
    begin
        IPIF_IP2Bus_Data = '0;
        
        for(int j = 0; j < NCLK; j += 1)
        begin
            if(IPIF_Bus2IP_CS == ({{(NCLK-1){1'b0}}, 1'b1} << j) ) IPIF_IP2Bus_Data = data[j];
        end
    end
    
    //decode configuration parameters from IPIF bus 
    assign IPIF_IP2Bus_Error = 0;
    
    typedef struct packed {
		// Register 3
		logic [32-1:0] padding3;
		// Register 2
		logic [32-1-1:0] padding2;
		logic locked;
		// Register 1
        logic [31:0]  unlocks;
		// Register 0
		logic [32-24-1:0] padding0;
        logic [24-1:0]  rate;
    } param_t;
        
    generate
    for(genvar i = 0; i < NCLK; i += 1)
    begin : clks
        
        param_t params_in;

		assign params_in.padding0 = '0;
		assign params_in.padding2 = '0;
		assign params_in.padding3 = '0;
		assign params_in.locked = locked[i];
    
        IPIF_parameterDecode#(
            .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
            .N_REG(N_REG),
            .PARAM_T(),
            .DEFAULTS({C_S_AXI_DATA_WIDTH*N_REG*{1'b0}})
        ) param_decoder (
            .clk(clk_ref),
            
            .IPIF_bus2ip_data(IPIF_Bus2IP_Data),  
            .IPIF_bus2ip_rdce(IPIF_Bus2IP_RdCE[i*N_REG +: N_REG]),
            .IPIF_bus2ip_resetn(IPIF_Bus2IP_resetn),
            .IPIF_bus2ip_wrce(IPIF_Bus2IP_WrCE[i*N_REG +: N_REG]),
            .IPIF_ip2bus_data(data[i]),
            .IPIF_ip2bus_rdack(ip2bus_rdack[i]),
            .IPIF_ip2bus_wrack(ip2bus_wrack[i]),
            
            .parameters_out(),
            .parameters_in(params_in)
        );
    
        //calculate clock rate 
        clkRateTool #(
			.CLK_REF_RATE_HZ(100000000),
			.MEASURE_PERIOD_s(1),
			.MEASURE_TIME_s(0.001)
		) crt (
			.reset_in(!aresetn),
			.clk_ref(clk_ref),
			.clk_test(clk_test[i]),
			.value(params_in.rate)
		);
        
        //count unlocks 
        unlockCtr ulm (
			.clk_ref(clk_ref),
			.locked(locked[i]),
			.unlocks(params_in.unlocks),
			.reset(aresetn && !(IPIF_Bus2IP_WrCE[2*i+1] && IPIF_Bus2IP_CS[i]))
		);
    end
    endgenerate
    
endmodule
