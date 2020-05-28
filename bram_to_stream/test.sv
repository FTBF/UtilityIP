timeunit 1 ns;
timeprecision 1 ps;


module testbench();

	import axi_vip_pkg::*;
	import design_1_axi_vip_0_1_pkg::*;
	import axi4stream_vip_pkg::*;
	import design_1_axi4stream_vip_0_0_pkg::*;

	localparam p = 10;

	xil_axi_resp_t     resp;
	
	design_1_axi_vip_0_1_mst_t agent;

	axi4stream_ready_gen ready_gen;

	design_1_axi4stream_vip_0_0_slv_t slv_agent;

	design_1_wrapper DUT (
		//.M00_AXIS_0_tdata(tdata),
		//.M00_AXIS_0_tready(tready),
		//.M00_AXIS_0_tvalid(tvalid)
	);

	initial begin

		agent = new("My VIP Agent", DUT.design_1_i.axi_vip_0.inst.IF);
		agent.set_agent_tag("Master");
		agent.start_master();

		slv_agent = new("slave vip agent", DUT.design_1_i.axi4stream_vip_0.inst.IF);
		slv_agent.start_slave();
		ready_gen = slv_agent.driver.create_ready("ready_gen");
		ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_EVENTS);
		ready_gen.set_low_time(30);
		ready_gen.set_event_count(256);
		slv_agent.driver.send_tready(ready_gen);

		#200;


		#p;
		#p;
		#p;
		#p;

		agent.AXI4LITE_WRITE_BURST(32'hc0000000, 0, 32'haccccccc, resp);
		#p;
		agent.AXI4LITE_WRITE_BURST(32'hc0000004, 0, 32'h04030201, resp);
		#p;
		agent.AXI4LITE_WRITE_BURST(32'hc0000008, 0, 32'h14131211, resp);
		#p;
		agent.AXI4LITE_WRITE_BURST(32'hc000000c, 0, 32'h24232221, resp);
		#100;
		agent.AXI4LITE_WRITE_BURST(32'h44A00040, 0, 32'h00000000, resp);
		#100;
		agent.AXI4LITE_WRITE_BURST(32'h44A00000, 0, 32'h00000002, resp);
		#230;

		agent.AXI4LITE_WRITE_BURST(32'h44A00040, 0, 32'h00000001, resp);
		#100;
		agent.AXI4LITE_WRITE_BURST(32'h44A00000, 0, 32'h00000002, resp);
		#200;
		



	end


endmodule

