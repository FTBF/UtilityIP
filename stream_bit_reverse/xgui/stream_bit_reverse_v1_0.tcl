# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set DATA_WIDTH [ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width in bits of each sub-stream contained within the input stream} ${DATA_WIDTH}
  set N_STREAMS [ipgui::add_param $IPINST -name "N_STREAMS" -parent ${Page_0}]
  set_property tooltip {Number of sub-streams contained within the input stream} ${N_STREAMS}


}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.N_STREAMS { PARAM_VALUE.N_STREAMS } {
	# Procedure called to update N_STREAMS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_STREAMS { PARAM_VALUE.N_STREAMS } {
	# Procedure called to validate N_STREAMS
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.N_STREAMS { MODELPARAM_VALUE.N_STREAMS PARAM_VALUE.N_STREAMS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_STREAMS}] ${MODELPARAM_VALUE.N_STREAMS}
}

