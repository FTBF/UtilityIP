# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set N_INPUTS [ipgui::add_param $IPINST -name "N_INPUTS" -parent ${Page_0}]
  set_property tooltip {Number of trigger inputs} ${N_INPUTS}
  set N_OUTPUTS [ipgui::add_param $IPINST -name "N_OUTPUTS" -parent ${Page_0}]
  set_property tooltip {Number of trigger outputs} ${N_OUTPUTS}
  set N_EXTERNAL [ipgui::add_param $IPINST -name "N_EXTERNAL" -parent ${Page_0}]
  set_property tooltip {Number of trigger outputs that are external pins} ${N_EXTERNAL}
  set UNIFIED_STREAMS [ipgui::add_param $IPINST -name "UNIFIED_STREAMS" -parent ${Page_0}]
  set_property tooltip {Present the deserialized trigger outputs as a single wide AXIS stream, or split into one stream per link} ${UNIFIED_STREAMS}


}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.N_EXTERNAL { PARAM_VALUE.N_EXTERNAL } {
	# Procedure called to update N_EXTERNAL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_EXTERNAL { PARAM_VALUE.N_EXTERNAL } {
	# Procedure called to validate N_EXTERNAL
	return true
}

proc update_PARAM_VALUE.N_INPUTS { PARAM_VALUE.N_INPUTS } {
	# Procedure called to update N_INPUTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_INPUTS { PARAM_VALUE.N_INPUTS } {
	# Procedure called to validate N_INPUTS
	return true
}

proc update_PARAM_VALUE.N_OUTPUTS { PARAM_VALUE.N_OUTPUTS } {
	# Procedure called to update N_OUTPUTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_OUTPUTS { PARAM_VALUE.N_OUTPUTS } {
	# Procedure called to validate N_OUTPUTS
	return true
}

proc update_PARAM_VALUE.UNIFIED_STREAMS { PARAM_VALUE.UNIFIED_STREAMS } {
	# Procedure called to update UNIFIED_STREAMS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UNIFIED_STREAMS { PARAM_VALUE.UNIFIED_STREAMS } {
	# Procedure called to validate UNIFIED_STREAMS
	return true
}


proc update_MODELPARAM_VALUE.N_INPUTS { MODELPARAM_VALUE.N_INPUTS PARAM_VALUE.N_INPUTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_INPUTS}] ${MODELPARAM_VALUE.N_INPUTS}
}

proc update_MODELPARAM_VALUE.N_OUTPUTS { MODELPARAM_VALUE.N_OUTPUTS PARAM_VALUE.N_OUTPUTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_OUTPUTS}] ${MODELPARAM_VALUE.N_OUTPUTS}
}

proc update_MODELPARAM_VALUE.N_EXTERNAL { MODELPARAM_VALUE.N_EXTERNAL PARAM_VALUE.N_EXTERNAL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_EXTERNAL}] ${MODELPARAM_VALUE.N_EXTERNAL}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.UNIFIED_STREAMS { MODELPARAM_VALUE.UNIFIED_STREAMS PARAM_VALUE.UNIFIED_STREAMS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UNIFIED_STREAMS}] ${MODELPARAM_VALUE.UNIFIED_STREAMS}
}

