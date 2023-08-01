module I2C_interconnect #(
	parameter integer C_S_AXI_DATA_WIDTH = 32,
	parameter integer C_S_AXI_ADDR_WIDTH = 11,
	parameter ENABLE_AXI = 0
)(
	input  logic I2C_0_SCL_o,
	input  logic I2C_0_SCL_t,
	output logic I2C_0_SCL_i,
	input  logic I2C_0_SDA_o,
	input  logic I2C_0_SDA_t,
	output logic I2C_0_SDA_i,
	input  logic I2C_1_SCL_o,
	input  logic I2C_1_SCL_t,
	output logic I2C_1_SCL_i,
	input  logic I2C_1_SDA_o,
	input  logic I2C_1_SDA_t,
	output logic I2C_1_SDA_i,
	input  logic I2C_2_SCL_o,
	input  logic I2C_2_SCL_t,
	output logic I2C_2_SCL_i,
	input  logic I2C_2_SDA_o,
	input  logic I2C_2_SDA_t,
	output logic I2C_2_SDA_i,
	input  logic I2C_3_SCL_o,
	input  logic I2C_3_SCL_t,
	output logic I2C_3_SCL_i,
	input  logic I2C_3_SDA_o,
	input  logic I2C_3_SDA_t,
	output logic I2C_3_SDA_i,
	
	//master ports 
	output logic I2C_4_SCL_o,
	output logic I2C_4_SCL_t,
	input  logic I2C_4_SCL_i,
	output logic I2C_4_SDA_o,
	output logic I2C_4_SDA_t,
	input  logic I2C_4_SDA_i,
	output logic I2C_5_SCL_o,
	output logic I2C_5_SCL_t,
	input  logic I2C_5_SCL_i,
	output logic I2C_5_SDA_o,
	output logic I2C_5_SDA_t,
	input  logic I2C_5_SDA_i,
	output logic I2C_6_SCL_o,
	output logic I2C_6_SCL_t,
	input  logic I2C_6_SCL_i,
	output logic I2C_6_SDA_o,
	output logic I2C_6_SDA_t,
	input  logic I2C_6_SDA_i,
	output logic I2C_7_SCL_o,
	output logic I2C_7_SCL_t,
	input  logic I2C_7_SCL_i,
	output logic I2C_7_SDA_o,
	output logic I2C_7_SDA_t,
	input  logic I2C_7_SDA_i,

	// AXI interface ports
	input  logic                                S_AXI_ACLK,
	input  logic                                S_AXI_ARESETN,
	input  logic [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
	input  logic [2 : 0]                        S_AXI_AWPROT,
	input  logic                                S_AXI_AWVALID,
	output logic                                S_AXI_AWREADY,
	input  logic [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
	input  logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
	input  logic                                S_AXI_WVALID,
	output logic                                S_AXI_WREADY,
	output logic [1 : 0]                        S_AXI_BRESP,
	output logic                                S_AXI_BVALID,
	input  logic                                S_AXI_BREADY,
	input  logic [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
	input  logic [2 : 0]                        S_AXI_ARPROT,
	input  logic                                S_AXI_ARVALID,
	output logic                                S_AXI_ARREADY,
	output logic [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA,
	output logic [1 : 0]                        S_AXI_RRESP,
	output logic                                S_AXI_RVALID,
	input  logic                                S_AXI_RREADY
);

localparam N_REG = 8;

logic                                  IPIF_Bus2IP_resetn;
logic [(C_S_AXI_ADDR_WIDTH-1) : 0]     IPIF_Bus2IP_Addr;
logic                                  IPIF_Bus2IP_RNW;
logic [((C_S_AXI_DATA_WIDTH/8)-1) : 0] IPIF_Bus2IP_BE;
logic [0 : 0]                          IPIF_Bus2IP_CS;
logic [N_REG-1 : 0]                    IPIF_Bus2IP_RdCE;
logic [N_REG-1 : 0]                    IPIF_Bus2IP_WrCE;
logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_Bus2IP_Data;
logic [(C_S_AXI_DATA_WIDTH-1) : 0]     IPIF_IP2Bus_Data;
logic                                  IPIF_IP2Bus_WrAck;
logic                                  IPIF_IP2Bus_RdAck;
logic                                  IPIF_IP2Bus_Error;

// ground unused error bit
assign IPIF_IP2Bus_Error = 0;

axi_to_ipif_mux #(
	.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
	.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
	.N_CHIP(1),
	.N_REG(N_REG),
	.MUX_BY_CHIP(0)
) axi_ipif (
	.S_AXI_ACLK(S_AXI_ACLK),
	.S_AXI_ARESETN(S_AXI_ARESETN),
	.S_AXI_AWADDR(S_AXI_AWADDR),
	.S_AXI_AWVALID(S_AXI_AWVALID),
	.S_AXI_AWREADY(S_AXI_AWREADY),
	.S_AXI_WDATA(S_AXI_WDATA),
	.S_AXI_WSTRB(S_AXI_WSTRB),
	.S_AXI_WVALID(S_AXI_WVALID),
	.S_AXI_WREADY(S_AXI_WREADY),
	.S_AXI_BRESP(S_AXI_BRESP),
	.S_AXI_BVALID(S_AXI_BVALID),
	.S_AXI_BREADY(S_AXI_BREADY),
	.S_AXI_ARADDR(S_AXI_ARADDR),
	.S_AXI_ARVALID(S_AXI_ARVALID),
	.S_AXI_ARREADY(S_AXI_ARREADY),
	.S_AXI_RDATA(S_AXI_RDATA),
	.S_AXI_RRESP(S_AXI_RRESP),
	.S_AXI_RVALID(S_AXI_RVALID),
	.S_AXI_RREADY(S_AXI_RREADY),
	.IPIF_Bus2IP_resetn(IPIF_Bus2IP_resetn),
	.IPIF_Bus2IP_Addr(IPIF_Bus2IP_Addr),
	.IPIF_Bus2IP_RNW(IPIF_Bus2IP_RNW),
	.IPIF_Bus2IP_BE(IPIF_Bus2IP_BE),
	.IPIF_Bus2IP_CS(IPIF_Bus2IP_CS),
	.IPIF_Bus2IP_RdCE(IPIF_Bus2IP_RdCE),
	.IPIF_Bus2IP_WrCE(IPIF_Bus2IP_WrCE),
	.IPIF_Bus2IP_Data(IPIF_Bus2IP_Data),
	.IPIF_IP2Bus_Data(IPIF_IP2Bus_Data),
	.IPIF_IP2Bus_WrAck(IPIF_IP2Bus_WrAck),
	.IPIF_IP2Bus_RdAck(IPIF_IP2Bus_RdAck),
	.IPIF_IP2Bus_Error(IPIF_IP2Bus_Error)
);

typedef struct packed {
	logic [32-1-1:0] padding;
	logic enable;
} single_link_t;

typedef struct packed {
	single_link_t [8-1:0] links;
} param_t;

param_t params_from_IP;
param_t params_to_IP;

localparam single_link_t single_link_defaults = '{default: '0, enable:1'b1};
localparam param_t defaults = '{default:'0, links:{8{single_link_defaults}}};

IPIF_parameterDecode #(
	.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
	.N_REG(N_REG),
	.PARAM_T(param_t),
	.DEFAULTS(defaults)
) parameterDecode (
	.clk(S_AXI_ACLK),

	.IPIF_bus2ip_data(IPIF_Bus2IP_Data),
	.IPIF_bus2ip_rdce(IPIF_Bus2IP_RdCE),
	.IPIF_bus2ip_resetn(IPIF_Bus2IP_resetn),
	.IPIF_bus2ip_wrce(IPIF_Bus2IP_WrCE),
	.IPIF_ip2bus_data(IPIF_IP2Bus_Data),
	.IPIF_ip2bus_rdack(IPIF_IP2Bus_RdAck),
	.IPIF_ip2bus_wrack(IPIF_IP2Bus_WrAck),

	.parameters_in(params_from_IP),
	.parameters_out(params_to_IP)
);

logic [8-1:0] enable;
always_comb begin
	params_from_IP = params_to_IP;
	for (int i = 0; i < 8; i++) begin
		params_from_IP.links[i].padding = '0;
		if (ENABLE_AXI == 1) begin
			enable[i] = params_to_IP.links[i].enable;
		end else begin
			enable[i] = 1'b1;
		end
	end
end

// For a disabled channel, set the output to 1 and the tristate to 1, and
// treat the input as though it were 1 (and its tristate also 1).

logic SCL_i, SDA_i, SCL_t, SCA_t;

assign SCL_i = ((~enable[0] | I2C_0_SCL_t | I2C_0_SCL_o) &
                (~enable[1] | I2C_1_SCL_t | I2C_1_SCL_o) &
                (~enable[2] | I2C_2_SCL_t | I2C_2_SCL_o) &
                (~enable[3] | I2C_3_SCL_t | I2C_3_SCL_o) &
                (~enable[4] | I2C_4_SCL_i) &
                (~enable[5] | I2C_5_SCL_i) &
                (~enable[6] | I2C_6_SCL_i) &
                (~enable[7] | I2C_7_SCL_i));

assign SDA_i = ((~enable[0] | I2C_0_SDA_t | I2C_0_SDA_o) &
                (~enable[1] | I2C_1_SDA_t | I2C_1_SDA_o) &
                (~enable[2] | I2C_2_SDA_t | I2C_2_SDA_o) &
                (~enable[3] | I2C_3_SDA_t | I2C_3_SDA_o) &
                (~enable[4] | I2C_4_SDA_i) &
                (~enable[5] | I2C_5_SDA_i) &
                (~enable[6] | I2C_6_SDA_i) &
                (~enable[7] | I2C_7_SDA_i));

assign SCL_t = ((~enable[0] | I2C_0_SCL_t) & 
                (~enable[1] | I2C_1_SCL_t) &
                (~enable[2] | I2C_2_SCL_t) &
                (~enable[3] | I2C_3_SCL_t));

assign SDA_t = ((~enable[0] | I2C_0_SDA_t) &
                (~enable[1] | I2C_1_SDA_t) &
                (~enable[2] | I2C_2_SDA_t) &
                (~enable[3] | I2C_3_SDA_t));

assign I2C_0_SCL_i = (~enable[0] | SCL_i);
assign I2C_1_SCL_i = (~enable[1] | SCL_i);
assign I2C_2_SCL_i = (~enable[2] | SCL_i);
assign I2C_3_SCL_i = (~enable[3] | SCL_i);

assign I2C_0_SDA_i = (~enable[0] | SDA_i);
assign I2C_1_SDA_i = (~enable[1] | SDA_i);
assign I2C_2_SDA_i = (~enable[2] | SDA_i);
assign I2C_3_SDA_i = (~enable[3] | SDA_i);

assign I2C_4_SCL_t = (~enable[4] | SCL_t);
assign I2C_5_SCL_t = (~enable[5] | SCL_t);
assign I2C_6_SCL_t = (~enable[6] | SCL_t);
assign I2C_7_SCL_t = (~enable[7] | SCL_t);

assign I2C_4_SDA_t = (~enable[4] | SDA_t);
assign I2C_5_SDA_t = (~enable[5] | SDA_t);
assign I2C_6_SDA_t = (~enable[6] | SDA_t);
assign I2C_7_SDA_t = (~enable[7] | SDA_t);

assign I2C_4_SCL_o = (~enable[4] | SCL_i);
assign I2C_5_SCL_o = (~enable[5] | SCL_i);
assign I2C_6_SCL_o = (~enable[6] | SCL_i);
assign I2C_7_SCL_o = (~enable[7] | SCL_i);

assign I2C_4_SDA_o = (~enable[4] | SDA_i);
assign I2C_5_SDA_o = (~enable[5] | SDA_i);
assign I2C_6_SDA_o = (~enable[6] | SDA_i);
assign I2C_7_SDA_o = (~enable[7] | SDA_i);

endmodule
