
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/IO_blocks_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NLINKS" -parent ${Page_0}

  set DIFF_IO [ipgui::add_param $IPINST -name "DIFF_IO" -parent ${Page_0}]
  set_property tooltip {Differential input/output vs. single-ended} ${DIFF_IO}
  set UNIFIED_STREAMS [ipgui::add_param $IPINST -name "UNIFIED_STREAMS" -parent ${Page_0}]
  set_property tooltip {Present the input and output data as a single wide AXIS stream, or split into one stream per link} ${UNIFIED_STREAMS}
  set OUTPUT_STREAMS_ENABLE [ipgui::add_param $IPINST -name "OUTPUT_STREAMS_ENABLE" -parent ${Page_0}]
  set_property tooltip {Enable AXI-stream outputs} ${OUTPUT_STREAMS_ENABLE}
  set INPUT_STREAMS_ENABLE [ipgui::add_param $IPINST -name "INPUT_STREAMS_ENABLE" -parent ${Page_0}]
  set_property tooltip {Enable AXI-stream inputs} ${INPUT_STREAMS_ENABLE}
  set DRIVE_ENABLED [ipgui::add_param $IPINST -name "DRIVE_ENABLED" -parent ${Page_0}]
  set_property tooltip {Enable capability to drive voltage to IO pins} ${DRIVE_ENABLED}
  set INVERT [ipgui::add_param $IPINST -name "INVERT" -parent ${Page_0}]
  set_property tooltip {Channels with inverted differential pairs (bit vector: for each bit, 1: inverted, 0: not inverted)} ${INVERT}
  set INCLUDE_SYNCHRONIZER [ipgui::add_param $IPINST -name "INCLUDE_SYNCHRONIZER" -parent ${Page_0}]
  set_property tooltip {Include IPIF synchronizer (only necessary if IPIF clock is unrelated to other clocks)} ${INCLUDE_SYNCHRONIZER}
}

proc update_PARAM_VALUE.DRIVE_ENABLED { PARAM_VALUE.DRIVE_ENABLED PARAM_VALUE.INPUT_STREAMS_ENABLE } {
	# Procedure called to update DRIVE_ENABLED when any of the dependent parameters in the arguments change
	
	set DRIVE_ENABLED ${PARAM_VALUE.DRIVE_ENABLED}
	set INPUT_STREAMS_ENABLE ${PARAM_VALUE.INPUT_STREAMS_ENABLE}
	set values(INPUT_STREAMS_ENABLE) [get_property value $INPUT_STREAMS_ENABLE]
	if { [gen_USERPARAMETER_DRIVE_ENABLED_ENABLEMENT $values(INPUT_STREAMS_ENABLE)] } {
		set_property enabled true $DRIVE_ENABLED
	} else {
		set_property enabled false $DRIVE_ENABLED
		set_property value [gen_USERPARAMETER_DRIVE_ENABLED_VALUE $values(INPUT_STREAMS_ENABLE)] $DRIVE_ENABLED
	}
}

proc validate_PARAM_VALUE.DRIVE_ENABLED { PARAM_VALUE.DRIVE_ENABLED } {
	# Procedure called to validate DRIVE_ENABLED
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.DIFF_IO { PARAM_VALUE.DIFF_IO } {
	# Procedure called to update DIFF_IO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DIFF_IO { PARAM_VALUE.DIFF_IO } {
	# Procedure called to validate DIFF_IO
	return true
}

proc update_PARAM_VALUE.INCLUDE_SYNCHRONIZER { PARAM_VALUE.INCLUDE_SYNCHRONIZER } {
	# Procedure called to update INCLUDE_SYNCHRONIZER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INCLUDE_SYNCHRONIZER { PARAM_VALUE.INCLUDE_SYNCHRONIZER } {
	# Procedure called to validate INCLUDE_SYNCHRONIZER
	return true
}

proc update_PARAM_VALUE.INPUT_STREAMS_ENABLE { PARAM_VALUE.INPUT_STREAMS_ENABLE } {
	# Procedure called to update INPUT_STREAMS_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_STREAMS_ENABLE { PARAM_VALUE.INPUT_STREAMS_ENABLE } {
	# Procedure called to validate INPUT_STREAMS_ENABLE
	return true
}

proc update_PARAM_VALUE.INVERT { PARAM_VALUE.INVERT } {
	# Procedure called to update INVERT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INVERT { PARAM_VALUE.INVERT } {
	# Procedure called to validate INVERT
	return true
}

proc update_PARAM_VALUE.NLINKS { PARAM_VALUE.NLINKS } {
	# Procedure called to update NLINKS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NLINKS { PARAM_VALUE.NLINKS } {
	# Procedure called to validate NLINKS
	return true
}

proc update_PARAM_VALUE.OUTPUT_STREAMS_ENABLE { PARAM_VALUE.OUTPUT_STREAMS_ENABLE } {
	# Procedure called to update OUTPUT_STREAMS_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUTPUT_STREAMS_ENABLE { PARAM_VALUE.OUTPUT_STREAMS_ENABLE } {
	# Procedure called to validate OUTPUT_STREAMS_ENABLE
	return true
}

proc update_PARAM_VALUE.UNIFIED_STREAMS { PARAM_VALUE.UNIFIED_STREAMS } {
	# Procedure called to update UNIFIED_STREAMS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UNIFIED_STREAMS { PARAM_VALUE.UNIFIED_STREAMS } {
	# Procedure called to validate UNIFIED_STREAMS
	return true
}

proc update_PARAM_VALUE.WORD_PER_LINK { PARAM_VALUE.WORD_PER_LINK } {
	# Procedure called to update WORD_PER_LINK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WORD_PER_LINK { PARAM_VALUE.WORD_PER_LINK } {
	# Procedure called to validate WORD_PER_LINK
	return true
}


proc update_MODELPARAM_VALUE.INCLUDE_SYNCHRONIZER { MODELPARAM_VALUE.INCLUDE_SYNCHRONIZER PARAM_VALUE.INCLUDE_SYNCHRONIZER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INCLUDE_SYNCHRONIZER}] ${MODELPARAM_VALUE.INCLUDE_SYNCHRONIZER}
}

proc update_MODELPARAM_VALUE.NLINKS { MODELPARAM_VALUE.NLINKS PARAM_VALUE.NLINKS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NLINKS}] ${MODELPARAM_VALUE.NLINKS}
}

proc update_MODELPARAM_VALUE.WORD_PER_LINK { MODELPARAM_VALUE.WORD_PER_LINK PARAM_VALUE.WORD_PER_LINK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WORD_PER_LINK}] ${MODELPARAM_VALUE.WORD_PER_LINK}
}

proc update_MODELPARAM_VALUE.DRIVE_ENABLED { MODELPARAM_VALUE.DRIVE_ENABLED PARAM_VALUE.DRIVE_ENABLED } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DRIVE_ENABLED}] ${MODELPARAM_VALUE.DRIVE_ENABLED}
}

proc update_MODELPARAM_VALUE.OUTPUT_STREAMS_ENABLE { MODELPARAM_VALUE.OUTPUT_STREAMS_ENABLE PARAM_VALUE.OUTPUT_STREAMS_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUTPUT_STREAMS_ENABLE}] ${MODELPARAM_VALUE.OUTPUT_STREAMS_ENABLE}
}

proc update_MODELPARAM_VALUE.INVERT { MODELPARAM_VALUE.INVERT PARAM_VALUE.INVERT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INVERT}] ${MODELPARAM_VALUE.INVERT}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.DIFF_IO { MODELPARAM_VALUE.DIFF_IO PARAM_VALUE.DIFF_IO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DIFF_IO}] ${MODELPARAM_VALUE.DIFF_IO}
}

