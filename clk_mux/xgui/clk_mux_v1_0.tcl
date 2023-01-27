# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set USE_AXI [ipgui::add_param $IPINST -name "USE_AXI" -parent ${Page_0}]
  set_property tooltip {Provide an AXI interface for configuration and status readout} ${USE_AXI}
  ipgui::add_param $IPINST -name "INPUTFREQ" -parent ${Page_0} -widget comboBox
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

proc update_PARAM_VALUE.INPUTFREQ { PARAM_VALUE.INPUTFREQ } {
	# Procedure called to update INPUTFREQ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUTFREQ { PARAM_VALUE.INPUTFREQ } {
	# Procedure called to validate INPUTFREQ
	return true
}

proc update_PARAM_VALUE.USE_AXI { PARAM_VALUE.USE_AXI } {
	# Procedure called to update USE_AXI when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_AXI { PARAM_VALUE.USE_AXI } {
	# Procedure called to validate USE_AXI
	return true
}


proc update_MODELPARAM_VALUE.INPUTFREQ { MODELPARAM_VALUE.INPUTFREQ PARAM_VALUE.INPUTFREQ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUTFREQ}] ${MODELPARAM_VALUE.INPUTFREQ}
}

proc update_MODELPARAM_VALUE.USE_AXI { MODELPARAM_VALUE.USE_AXI PARAM_VALUE.USE_AXI } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_AXI}] ${MODELPARAM_VALUE.USE_AXI}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

