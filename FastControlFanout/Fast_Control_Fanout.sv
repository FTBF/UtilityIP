`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2021 10:58:47 AM
// Design Name: 
// Module Name: Fast_Control_Fanout
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


module Fast_Control_Fanout #(
        parameter integer NFANOUT = 1,
        parameter integer NRESYNC = 1,
        parameter integer RESYNCCLEANUP = 1,
        parameter integer DEBUG = 1,
        parameter [NFANOUT-1:0] INVERT = 0,
        parameter C_S_AXI_DATA_WIDTH = 32,
        parameter C_S_AXI_ADDR_WIDTH = 13,
        parameter N_REG = 4
    )
    (
        input wire fast_clock_in,
        input wire fast_clock_in_orig,
        input wire fast_command_in,
        
        output wire fast_command_out,
        
        output wire [NFANOUT-1:0] fast_clock_out_P,
        output wire [NFANOUT-1:0] fast_clock_out_N,
        output wire [NFANOUT-1:0] fast_command_out_P,
        output wire [NFANOUT-1:0] fast_command_out_N,
        
        //configuration parameter interface 
        input  wire                                  IPIF_Bus2IP_resetn,
        input  wire [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr,
        input  wire                                  IPIF_Bus2IP_RNW,
        input  wire [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE,     //unused
        input  wire [0 : 0]                          IPIF_Bus2IP_CS,     //unused
        input  wire [N_REG-1 : 0]                    IPIF_Bus2IP_RdCE, 
        input  wire [N_REG-1 : 0]                    IPIF_Bus2IP_WrCE,
        input  wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data,
        output wire [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data,
        output wire                                  IPIF_IP2Bus_WrAck,
        output wire                                  IPIF_IP2Bus_RdAck,
        output wire                                  IPIF_IP2Bus_Error,
        
        input wire IPIF_clk,
        
        output wire debug_trig,

        
        input wire arstn
    );
    
    assign IPIF_IP2Bus_Error = 1'b0;
    
    logic resync_command;
    
    // logic to resync the fast command to the "new" clock 
    generate
    if(NRESYNC >= 2)
    begin
        xpm_cdc_single #(
           .DEST_SYNC_FF(NRESYNC),   // DECIMAL; range: 2-10
           .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
           .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
           .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
        )
        xpm_cdc_single_inst (
           .dest_out(resync_command), // 1-bit output: src_in synchronized to the destination clock domain. This output is
           .dest_clk(fast_clock_in), // 1-bit input: Clock signal for the destination clock domain.
           .src_clk(fast_clock_in_orig),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
           .src_in(fast_command_in)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
        );
    end
    else if(NRESYNC == 1)
    begin
        always_ff @(posedge fast_clock_in)
        begin
            resync_command <= fast_command_in;
        end
    end
    else
    begin
        assign resync_command = fast_command_in;
    end
    endgenerate

    generate
    if(RESYNCCLEANUP == 1)
    begin
        logic [8:0] cleanup_in_SR;
        logic [8:0] cleanup_out_SR;
        logic [5:0] lock_count = 0;
        logic [2:0] lock_val;
        logic [2:0] bit_ctr = 0;
        
        always_ff @(posedge fast_clock_in) cleanup_in_SR <= {cleanup_in_SR[7:0], resync_command};
        
        logic header_match;
        assign header_match = cleanup_in_SR[8:6] == 3'b110 && cleanup_in_SR[1];
        always_ff @(posedge fast_clock_in)
        begin
            bit_ctr <= bit_ctr + 1;
            lock_val <= lock_val;
            lock_count <= lock_count;
            
            if(lock_count == '0)
            begin
                if(header_match == 1'b1)
                begin
                    lock_val <= bit_ctr;
                    lock_count <= lock_count + 1;
                end
            end
            else
            begin
                if(lock_count != '1 && bit_ctr == lock_val && header_match == 1'b1)      lock_count <= lock_count + 1; 
                else if               (bit_ctr == lock_val && header_match == 1'b0)      lock_count <= lock_count - 1; 
                else if               (bit_ctr != lock_val && header_match == 1'b1)      lock_count <= lock_count - 1;
            end
            
            if(bit_ctr == lock_val)
            begin
                if(!header_match || cleanup_in_SR[5:3] == 3'b110 || cleanup_in_SR[4:2] == 3'b110)
                begin
                    cleanup_out_SR <= {cleanup_out_SR[7], 8'b11000001};
                end
                else
                begin
                    cleanup_out_SR <= {cleanup_out_SR[7], cleanup_in_SR[8:1]};
                end
            end
            else
            begin
                cleanup_out_SR <= {cleanup_out_SR[7:0], 1'b0};
            end
        end
        
        assign fast_command_out = cleanup_out_SR[8];
    end
    else
    begin
        assign fast_command_out = resync_command;
    end
    endgenerate
    
    generate
    if(DEBUG == 1)
    begin
    
        typedef struct packed
        {
            logic [31:0] padding4;
            logic [21:0] padding3;
            logic [9:0]  delay;
            logic [25:0] padding2;
            logic [2:0]  offset_clean;
            logic [2:0]  offset_raw;
            logic [30:0] padding1;
            logic        reset;
        } param_t;
        
        param_t params_in;
        param_t params_out;
        
        assign params_in.offset_raw = params_out.offset_raw;
        assign params_in.offset_clean = params_out.offset_clean;
        assign params_in.delay = params_out.delay;
        
        logic IPIF_IP2Bus_RdAck_pdc;
        logic IPIF_IP2Bus_RdAck_bram;
        
        always_ff @(posedge IPIF_clk) IPIF_IP2Bus_RdAck_bram <= |IPIF_Bus2IP_RdCE;
        
        assign IPIF_IP2Bus_RdAck = (IPIF_Bus2IP_Addr[12] == 1'b1)?IPIF_IP2Bus_RdAck_pdc:IPIF_IP2Bus_RdAck_bram;
        
        logic [31:0] IPIF_IP2Bus_Data_pdc;
        logic [31:0] IPIF_IP2Bus_Data_bram;
        
        assign IPIF_IP2Bus_Data = (IPIF_Bus2IP_Addr[12] == 1'b1)?IPIF_IP2Bus_Data_bram:IPIF_IP2Bus_Data_pdc;
        
        IPIF_parameterDecode#(
            .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
            .N_REG(N_REG),
            .W_PULSE_REG(4'b1),
            .PARAM_T(param_t),
            .DEFAULTS({32'h0, 32'd100, 32'b0, 32'b0})
        ) parameterDecoder (
            .clk(IPIF_clk),
            
            .IPIF_bus2ip_data(IPIF_Bus2IP_Data),  
            .IPIF_bus2ip_rdce(IPIF_Bus2IP_RdCE),
            .IPIF_bus2ip_resetn(IPIF_Bus2IP_resetn),
            .IPIF_bus2ip_wrce(IPIF_Bus2IP_WrCE),
            .IPIF_ip2bus_data(IPIF_IP2Bus_Data_pdc),
            .IPIF_ip2bus_rdack(IPIF_IP2Bus_RdAck_pdc),
            .IPIF_ip2bus_wrack(IPIF_IP2Bus_WrAck),
            
            .parameters_out(params_out),
            .parameters_in(params_in)
        );

        
        logic [16:0] debug_in;
        
        logic [8:0] debug_sr_raw;
        logic [8:0] debug_sr_clean;
        
        always_ff @(posedge fast_clock_in)
        begin
            debug_sr_raw <= {debug_sr_raw[7:0], fast_command_in};
            debug_sr_clean <= {debug_sr_clean[7:0], fast_command_out};
        end
        
        logic [2:0] eight_count;
        
        always_ff @(posedge fast_clock_in or negedge arstn)
        begin
            if(!arstn)
            begin
                debug_in <= '0;
                eight_count <= '0;
            end
            else
            begin
                eight_count <= eight_count + 1;
                
                debug_in <= debug_in;                
                if(eight_count == params_out.offset_raw)
                begin
                    debug_in[16:8] <= {debug_sr_raw[8:6] != 3'b110, debug_sr_raw[8:1]};
                end
                if(eight_count == params_out.offset_clean)
                begin
                    debug_in[7:0] <= debug_sr_clean[8:1];
                end
            end
        end
        
        enum {FILLING, WAITING, READING} debug_state;
        
        logic write_enable;
        logic [9:0] write_addr;
        logic [9:0] wait_ctr;
        logic resetn;
        assign resetn = arstn && !params_out.reset;
        
        assign params_in.padding1 = debug_state;
        
        logic triggered;
        assign debug_trig = triggered;
        
        
        always_ff @(posedge fast_clock_in or negedge resetn)
        begin
            triggered <= triggered;
        
            if(!resetn)
            begin
                debug_state <= FILLING;
                write_enable <= 0;
                write_addr <= '0;
                wait_ctr <= '0;
                triggered <= 0;
            end
            else
            begin
                if(write_enable && eight_count == '0) write_addr <= write_addr + 1;
                else                                  write_addr <= write_addr;
            
                case(debug_state)
                    FILLING:
                    begin
                        write_enable <= 1;
                        if(debug_in[16])
                        begin
                            debug_state <= WAITING;
                            triggered <= 1'b1;
                        end
                    end
                    WAITING:
                    begin
                        if(eight_count == '0) triggered <= 1'b0;
                        if(eight_count == '0) wait_ctr <= wait_ctr + 1;
                        write_enable <= 1;
                        if(wait_ctr == params_out.delay) debug_state <= READING;
                    end
                    READING:
                    begin
                        write_enable <= 0;
                    end
                endcase
            end
        end
    
        xpm_memory_tdpram #(
           .ADDR_WIDTH_A(10),               // DECIMAL
           .ADDR_WIDTH_B(10),               // DECIMAL
           .BYTE_WRITE_WIDTH_A(18),        // DECIMAL
           .BYTE_WRITE_WIDTH_B(18),        // DECIMAL
           .CASCADE_HEIGHT(0),             // DECIMAL
           .CLOCKING_MODE("independent_clock"), // String
           .MEMORY_PRIMITIVE("auto"),      // String
           .MEMORY_SIZE(1024*18),             // DECIMAL
           .READ_DATA_WIDTH_A(18),         // DECIMAL
           .READ_DATA_WIDTH_B(18),         // DECIMAL
           .READ_LATENCY_A(1),             // DECIMAL
           .READ_LATENCY_B(1),             // DECIMAL
           .RST_MODE_A("SYNC"),            // String
           .RST_MODE_B("SYNC"),            // String
           .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
           .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
           .USE_MEM_INIT(1),               // DECIMAL
           .WAKEUP_TIME("disable_sleep"),  // String
           .WRITE_DATA_WIDTH_A(18),        // DECIMAL
           .WRITE_DATA_WIDTH_B(18),        // DECIMAL
           .WRITE_MODE_A("no_change"),     // String
           .WRITE_MODE_B("no_change")      // String
        )
        xpm_memory_tdpram_inst (
           .douta(),                   // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
           .doutb(IPIF_IP2Bus_Data_bram),                   // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
           .addra(write_addr),                   // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
           .addrb(IPIF_Bus2IP_Addr[11:2]),                   // ADDR_WIDTH_B-bit input: Address for port B write and read operations.
           .clka(fast_clock_in),                     // 1-bit input: Clock signal for port A. Also clocks port B when
           .clkb(IPIF_clk),                     // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
           .dina({triggered, debug_in}),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
           .dinb(),                     // WRITE_DATA_WIDTH_B-bit input: Data input for port B write operations.
           .ena(1'b1),                       // 1-bit input: Memory enable signal for port A. Must be high on clock
           .enb(1'b1),                       // 1-bit input: Memory enable signal for port B. Must be high on clock
           .regcea(1'b1),                 // 1-bit input: Clock Enable for the last register stage on the output
           .regceb(1'b1),                 // 1-bit input: Clock Enable for the last register stage on the output
           .rsta(!resetn),                     // 1-bit input: Reset signal for the final port A output register stage.
           .rstb(!resetn),                     // 1-bit input: Reset signal for the final port B output register stage.
           .sleep(1'b0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
           .wea(write_enable && eight_count == '0),                       // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
           .web(1'b0)                        // WRITE_DATA_WIDTH_B/BYTE_WRITE_WIDTH_B-bit input: Write enable vector
        );
    end
    else
    begin
        assign debug_trig = 0;
    end
    endgenerate
    
    generate
        genvar i;
        for(i = 0; i < (NFANOUT?NFANOUT:1); i += 1)  
        begin
        
           logic clock;
           logic command;
           
           ODDRE1 #(
              .IS_C_INVERTED(1'b0),      // Optional inversion for C
              .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
              .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
              .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                         // ULTRASCALE_PLUS_ES2)
              .SRVAL(1'b0)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
           )
           ODDRE1_clock (
              .Q(clock),   // 1-bit output: Data output to IOB
              .C(fast_clock_in),   // 1-bit input: High-speed clock input
              .D1(0), // 1-bit input: Parallel data input 1
              .D2(1), // 1-bit input: Parallel data input 2
              .SR(!arstn)  // 1-bit input: Active High Async Reset
           );

           OBUFDS OBUFDS_clockt (
              .O(fast_clock_out_P[i]),   // 1-bit output: Diff_p output (connect directly to top-level port)
              .OB(fast_clock_out_N[i]), // 1-bit output: Diff_n output (connect directly to top-level port)
              .I(clock)    // 1-bit input: Buffer input
           );
           
           ODDRE1 #(
              .IS_C_INVERTED(1'b0),      // Optional inversion for C
              .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
              .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
              .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                         // ULTRASCALE_PLUS_ES2)
              .SRVAL(1'b0)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
           )
           ODDRE1_inst (
              .Q(command),   // 1-bit output: Data output to IOB
              .C(fast_clock_in),   // 1-bit input: High-speed clock input
              .D1((INVERT[i])?(!fast_command_out):(fast_command_out)), // 1-bit input: Parallel data input 1
              .D2((INVERT[i])?(!fast_command_out):(fast_command_out)), // 1-bit input: Parallel data input 2
              .SR(!arstn)  // 1-bit input: Active High Async Reset
           );

           OBUFDS OBUFDS_inst (
              .O(fast_command_out_P[i]),   // 1-bit output: Diff_p output (connect directly to top-level port)
              .OB(fast_command_out_N[i]), // 1-bit output: Diff_n output (connect directly to top-level port)
              .I(command)    // 1-bit input: Buffer input
           );
           
        end
    endgenerate
    
endmodule
