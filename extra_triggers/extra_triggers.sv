module extra_triggers (
		input logic clk,
		input logic in_linkreset_econd,
		input logic in_linkreset_econt,
		input logic in_linkreset_rocd,
		input logic in_linkreset_roct,
		input logic in_bunchcountreset,
		input logic in_orbitcountreset,
		input logic in_l1a,
		input logic in_calibrationreq_ext,
		input logic in_calibrationreq_int,
		input logic in_nonzerosuppress,
		input logic in_eventbufferreset,
		input logic in_eventcountreset,
		input logic in_chipsync,
		input logic in_dump,
		input logic extra_trigger,
		output logic out_linkreset_econd,
		output logic out_linkreset_econt,
		output logic out_linkreset_rocd,
		output logic out_linkreset_roct,
		output logic out_bunchcountreset,
		output logic out_orbitcountreset,
		output logic out_l1a,
		output logic out_calibrationreq_ext,
		output logic out_calibrationreq_int,
		output logic out_nonzerosuppress,
		output logic out_eventbufferreset,
		output logic out_eventcountreset,
		output logic out_chipsync,
		output logic out_dump
	);

	assign out_l1a = in_l1a | extra_trigger;

	assign out_linkreset_econd = in_linkreset_econd;
	assign out_linkreset_econt = in_linkreset_econt;
	assign out_linkreset_rocd = in_linkreset_rocd;
	assign out_linkreset_roct = in_linkreset_roct;
	assign out_bunchcountreset = in_bunchcountreset;
	assign out_orbitcountreset = in_orbitcountreset;
	assign out_calibrationreq_ext = in_calibrationreq_ext;
	assign out_calibrationreq_int = in_calibrationreq_int;
	assign out_nonzerosuppress = in_nonzerosuppress;
	assign out_eventbufferreset = in_eventbufferreset;
	assign out_eventcountreset = in_eventcountreset;
	assign out_chipsync = in_chipsync;
	assign out_dump = in_dump;
endmodule
