`timescale 1ns / 1ps
module repeating_handshake #(
		parameter INCLUDE_SYNCHRONIZER = 1,
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer N_REG = 2,
		parameter type PARAM_T = logic[N_REG*C_S_AXI_DATA_WIDTH-1:0]
	)(
		input  logic   src_clk,
		input  logic   dest_clk,
		input  PARAM_T src_data,
		output PARAM_T dest_data
	);


	generate
		genvar i;
		if (INCLUDE_SYNCHRONIZER) begin
			localparam WIDTH = N_REG * C_S_AXI_DATA_WIDTH;
			localparam HANDSHAKE_WIDTH = 1024;
			localparam N_HANDSHAKES = ((WIDTH - 1) / HANDSHAKE_WIDTH) + 1;
			localparam FULL_WIDTH = N_HANDSHAKES * HANDSHAKE_WIDTH;

			typedef union packed {
				PARAM_T param_struct;
				logic [N_REG*C_S_AXI_DATA_WIDTH-1:0] flat_vector;
			} param_union_t;

			param_union_t src_data_union;
			param_union_t dest_data_union;
			logic [FULL_WIDTH-1:0] src_flat;
			logic [FULL_WIDTH-1:0] dest_flat;

			assign src_data_union.param_struct = src_data;
			assign src_flat[WIDTH-1:0] = src_data_union.flat_vector;
			assign dest_data_union.flat_vector = dest_flat[WIDTH-1:0];
			assign dest_data = dest_data_union.param_struct;

			for (i = 0; i < N_HANDSHAKES; i += 1) begin
				logic send, recv;
				assign send = ~recv;
				xpm_cdc_handshake #(
					.DEST_SYNC_FF(2),
					.SRC_SYNC_FF(2),
					.INIT_SYNC_FF(1),
					.DEST_EXT_HSK(0),
					.WIDTH(HANDSHAKE_WIDTH),
					.SIM_ASSERT_CHK(1)
				) handshake (
					.src_clk(src_clk),
					.src_in(src_flat[i*HANDSHAKE_WIDTH +: HANDSHAKE_WIDTH]),
					.src_send(send),
					.src_rcv(recv),
					.dest_clk(dest_clk),
					.dest_out(dest_flat[i*HANDSHAKE_WIDTH +: HANDSHAKE_WIDTH]));
			end

		end else begin
			always @(posedge dest_clk)
				dest_data <= src_data;
		end
	endgenerate
endmodule

module IPIF_clock_converter #(
		parameter INCLUDE_SYNCHRONIZER = 1,
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer N_REG = 2,
		parameter type PARAM_T = logic[N_REG*C_S_AXI_DATA_WIDTH-1:0]
	)(
		input  logic   IP_clk,
		input  logic   bus_clk,
		input  logic   bus_clk_aresetn,
		input  logic [N_REG-1:0] RdCE_from_bus,
		output PARAM_T RdCE_to_IP,
		input  logic [N_REG-1:0] WrCE_from_bus,
		output PARAM_T WrCE_to_IP,
		input  PARAM_T params_from_IP,
		input  PARAM_T params_from_bus,
		output PARAM_T params_to_IP,
		output PARAM_T params_to_bus
	);

	// First deal with all the RdCE/WrCE stuff
	typedef union packed {
		PARAM_T param_struct;
		logic [N_REG-1:0][C_S_AXI_DATA_WIDTH-1:0] param_array;
	} param_union_t;
	param_union_t RdCE_union, WrCE_union;

	logic [N_REG-1:0] RdCE_bus_internal = '0, WrCE_bus_internal = '0;
	logic [N_REG-1:0] RdCE_to_bus, WrCE_to_bus;
	logic [N_REG-1:0] RdCE_to_IP_raw, WrCE_to_IP_raw;
	logic [N_REG-1:0] RdCE_to_IP_raw_edge_detect, WrCE_to_IP_raw_edge_detect;

	always_ff @(posedge bus_clk) begin
		for (int i = 0; i < N_REG; i++) begin
			if (bus_clk_aresetn == 1'b1) begin
				RdCE_bus_internal <= '0;
				WrCE_bus_internal <= '0;
			end else begin
				if (RdCE_from_bus[i] == 1'b1) begin
					RdCE_bus_internal[i] <= 1'b1;
				end else if (RdCE_to_bus[i] == 1'b1) begin
					RdCE_bus_internal[i] <= 1'b0;
				end
				if (WrCE_from_bus[i] == 1'b1) begin
					WrCE_bus_internal[i] <= 1'b1;
				end else if (WrCE_to_bus[i] == 1'b1) begin
					WrCE_bus_internal[i] <= 1'b0;
				end
			end
		end
	end

	repeating_handshake #(
		.INCLUDE_SYNCHRONIZER(INCLUDE_SYNCHRONIZER),
		.C_S_AXI_DATA_WIDTH(1),
		.N_REG(2*N_REG)
	) RW_bus2ip (
		.src_clk(bus_clk),
		.dest_clk(IP_clk),
		.src_data({RdCE_bus_internal, WrCE_bus_internal}),
		.dest_data({RdCE_to_IP_raw, WrCE_to_IP_raw}));
	repeating_handshake #(
		.INCLUDE_SYNCHRONIZER(INCLUDE_SYNCHRONIZER),
		.C_S_AXI_DATA_WIDTH(1),
		.N_REG(2*N_REG)
	) RW_ip2bus (
		.src_clk(IP_clk),
		.dest_clk(bus_clk),
		.src_data({RdCE_to_IP_raw, WrCE_to_IP_raw}),
		.dest_data({RdCE_to_bus, WrCE_to_bus}));

	// We only want a single IP_clk cycle pulse, so use edge-detection logic
	always_ff @(posedge IP_clk) begin
		RdCE_to_IP_raw_edge_detect <= RdCE_to_IP_raw;
		WrCE_to_IP_raw_edge_detect <= WrCE_to_IP_raw;
	end

	// Copy the single-cycle pulse into the param_t struct so we can more
	// easily access the correct RdCE/WrCE signal in user code
	always_comb begin
		for (int i = 0; i < N_REG; i++) begin
			RdCE_union.param_array[i] = {C_S_AXI_DATA_WIDTH{RdCE_to_IP_raw[i] & ~RdCE_to_IP_raw_edge_detect[i]}};
			WrCE_union.param_array[i] = {C_S_AXI_DATA_WIDTH{WrCE_to_IP_raw[i] & ~WrCE_to_IP_raw_edge_detect[i]}};
		end
		RdCE_to_IP = RdCE_union.param_struct;
		WrCE_to_IP = WrCE_union.param_struct;
	end
	// Now we're done with all the RdCE/WrCE stuff.  Here's the actual data.

	repeating_handshake #(
		.INCLUDE_SYNCHRONIZER(INCLUDE_SYNCHRONIZER),
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(PARAM_T)
	) ip2bus (
		.src_clk(IP_clk),
		.dest_clk(bus_clk),
		.src_data(params_from_IP),
		.dest_data(params_to_bus));

	repeating_handshake #(
		.INCLUDE_SYNCHRONIZER(INCLUDE_SYNCHRONIZER),
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(PARAM_T)
	) bus2ip (
		.src_clk(bus_clk),
		.dest_clk(IP_clk),
		.src_data(params_from_bus),
		.dest_data(params_to_IP));
endmodule
