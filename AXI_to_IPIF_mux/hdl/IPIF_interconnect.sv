`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2020 11:58:13 AM
// Design Name: 
// Module Name: IPIF_interconnect
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

//interface to simplify writing IPIF interconnect 
interface IPIF_bus #(
    parameter integer C_S_AXI_ADDR_WIDTH = 32,
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer N_CHIP = 1,
    parameter integer N_REG = 1
)(
    input wire Bus2IP_Clk,
    input wire Bus2IP_Resetn
);

    logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     Bus2IP_Addr;
    logic                                  Bus2IP_RNW;
    logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] Bus2IP_BE;
    logic [N_CHIP-1 : 0]                   Bus2IP_CS;
    logic [N_CHIP*N_REG-1 : 0]             Bus2IP_RdCE; 
    logic [N_CHIP*N_REG-1 : 0]             Bus2IP_WrCE;
    logic [(C_S_AXI_DATA_WIDTH-1) : 0]     Bus2IP_Data;
    logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IP2Bus_Data;
    logic                                  IP2Bus_WrAck;
    logic                                  IP2Bus_RdAck;
    logic                                  IP2Bus_Error;
    
    modport master (
        output Bus2IP_Addr,
        output Bus2IP_RNW,
        output Bus2IP_BE,
        output Bus2IP_CS,
        output Bus2IP_RdCE, 
        output Bus2IP_WrCE,
        output Bus2IP_Data,
        input  IP2Bus_Data,
        input  IP2Bus_WrAck,
        input  IP2Bus_RdAck,
        input  IP2Bus_Error
    ); 
    
    modport slave (
        input  Bus2IP_Addr,
        input  Bus2IP_RNW,
        input  Bus2IP_BE,
        input  Bus2IP_CS,
        input  Bus2IP_RdCE, 
        input  Bus2IP_WrCE,
        input  Bus2IP_Data,
        output IP2Bus_Data,
        output IP2Bus_WrAck,
        output IP2Bus_RdAck,
        output IP2Bus_Error
    ); 
endinterface

    
module IPIF_interconnect #(
    parameter integer C_S_AXI_ADDR_WIDTH = 32,
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer N_CHIP = 1,
    parameter integer N_REG = 1,
    parameter [N_REG-1:0] BROADCAST_REG = '0
)(
    IPIF_bus.slave input_bus,
    
    IPIF_bus.master output_bus [N_CHIP]
);

//utility function
function integer clog2s;
  input integer value;
   begin
      clog2s = ((value==1)?1:$clog2(value));
   end
endfunction // value


//Annoying hack to make multiplexer
logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IP2Bus_Data  [N_CHIP];
logic                                  IP2Bus_WrAck [N_CHIP];
logic                                  IP2Bus_RdAck [N_CHIP];
logic                                  IP2Bus_Error [N_CHIP];

generate
    genvar iChip;
    genvar iBit;
    for(iChip = 0; iChip < N_CHIP; iChip += 1)
    begin : ipifInterface
    
        //Annoying hack to make multiplexer
        assign IP2Bus_Data[iChip]  = output_bus[iChip].IP2Bus_Data;
        assign IP2Bus_WrAck[iChip] = output_bus[iChip].IP2Bus_WrAck;
        assign IP2Bus_RdAck[iChip] = output_bus[iChip].IP2Bus_RdAck;
        assign IP2Bus_Error[iChip] = output_bus[iChip].IP2Bus_Error;
        
        assign output_bus[iChip].Bus2IP_Addr = {(31 - (clog2s(N_REG)+2))*{1'b0}, input_bus.Bus2IP_Addr[0 +: clog2s(N_REG)+2]};
        assign output_bus[iChip].Bus2IP_RNW  = input_bus.Bus2IP_RNW;
        assign output_bus[iChip].Bus2IP_BE   = input_bus.Bus2IP_BE;
        //CS and CE are big endian for some reason, flip them here 
        if(BROADCAST_REG != '0)
        begin
            assign output_bus[iChip].Bus2IP_CS   = (!input_bus.Bus2IP_RNW && (BROADCAST_REG & output_bus[0].Bus2IP_RdCE))?(1'b1):(input_bus.Bus2IP_CS[N_CHIP - 1 - iChip]);
            for(iBit = 0; iBit < N_REG; iBit += 1)
            begin
                assign output_bus[iChip].Bus2IP_RdCE[iBit] = input_bus.Bus2IP_RdCE[N_CHIP*N_REG - 1 - N_REG*iChip - iBit]; 
                if(BROADCAST_REG[iBit] == 0) assign output_bus[iChip].Bus2IP_WrCE[iBit] = input_bus.Bus2IP_WrCE[N_CHIP*N_REG - 1 - N_REG*iChip - iBit];
                else                         assign output_bus[iChip].Bus2IP_WrCE[iBit] = input_bus.Bus2IP_WrCE[N_CHIP*N_REG - 1 - iBit];
            end
        end
        else
        begin
            assign output_bus[iChip].Bus2IP_CS   = input_bus.Bus2IP_CS[N_CHIP - 1 - iChip];
            for(iBit = 0; iBit < N_REG; iBit += 1)
            begin
                assign output_bus[iChip].Bus2IP_RdCE[iBit] = input_bus.Bus2IP_RdCE[N_CHIP*N_REG - 1 - N_REG*iChip - iBit]; 
                assign output_bus[iChip].Bus2IP_WrCE[iBit] = input_bus.Bus2IP_WrCE[N_CHIP*N_REG - 1 - N_REG*iChip - iBit];
            end
        end
        assign output_bus[iChip].Bus2IP_Data = input_bus.Bus2IP_Data;
    end
    
    //multiplex return signals 
    always_comb
    begin
        input_bus.IP2Bus_Data <= '0;
        input_bus.IP2Bus_WrAck <= 0;
        input_bus.IP2Bus_RdAck <= 0;
        input_bus.IP2Bus_Error <= 0;
        
        for(int iChip = 0; iChip < N_CHIP; iChip += 1)
        begin
            if(input_bus.Bus2IP_CS == (1 << (N_CHIP - 1 - iChip)))
            begin
                input_bus.IP2Bus_Data  <= IP2Bus_Data [iChip];
                input_bus.IP2Bus_WrAck <= IP2Bus_WrAck[iChip];
                input_bus.IP2Bus_RdAck <= IP2Bus_RdAck[iChip];
                input_bus.IP2Bus_Error <= IP2Bus_Error[iChip];
            end
        end
    end
endgenerate



endmodule
