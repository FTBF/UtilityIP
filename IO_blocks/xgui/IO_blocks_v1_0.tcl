# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NLINKS" -parent ${Page_0}

  set DRIVE_ENABLED [ipgui::add_param $IPINST -name "DRIVE_ENABLED" -parent ${Page_0}]
  set_property tooltip {Enable capability to drive voltage to IO pins} ${DRIVE_ENABLED}
  set INPUT_STREAMS_ENABLE [ipgui::add_param $IPINST -name "INPUT_STREAMS_ENABLE" -parent ${Page_0}]
  set_property tooltip {Enable AXI-stream inputs} ${INPUT_STREAMS_ENABLE}
  set OUTPUT_STREAMS_ENABLE [ipgui::add_param $IPINST -name "OUTPUT_STREAMS_ENABLE" -parent ${Page_0}]
  set_property tooltip {Enable AXI-stream outputs} ${OUTPUT_STREAMS_ENABLE}

}

proc update_PARAM_VALUE.DRIVE_ENABLED { PARAM_VALUE.DRIVE_ENABLED } {
	# Procedure called to update DRIVE_ENABLED when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DRIVE_ENABLED { PARAM_VALUE.DRIVE_ENABLED } {
	# Procedure called to validate DRIVE_ENABLED
	return true
}

proc update_PARAM_VALUE.INPUT_STREAMS_ENABLE { PARAM_VALUE.INPUT_STREAMS_ENABLE } {
	# Procedure called to update INPUT_STREAMS_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_STREAMS_ENABLE { PARAM_VALUE.INPUT_STREAMS_ENABLE } {
	# Procedure called to validate INPUT_STREAMS_ENABLE
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

proc update_PARAM_VALUE.WORD_PER_LINK { PARAM_VALUE.WORD_PER_LINK } {
	# Procedure called to update WORD_PER_LINK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WORD_PER_LINK { PARAM_VALUE.WORD_PER_LINK } {
	# Procedure called to validate WORD_PER_LINK
	return true
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

