# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set INCLUDE_AXI_SYNC [ipgui::add_param $IPINST -name "INCLUDE_AXI_SYNC" -parent ${Page_0}]
  set_property tooltip {Only needed if clock and IPIF_clock are unrelated} ${INCLUDE_AXI_SYNC}


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

proc update_PARAM_VALUE.INCLUDE_AXI_SYNC { PARAM_VALUE.INCLUDE_AXI_SYNC } {
	# Procedure called to update INCLUDE_AXI_SYNC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INCLUDE_AXI_SYNC { PARAM_VALUE.INCLUDE_AXI_SYNC } {
	# Procedure called to validate INCLUDE_AXI_SYNC
	return true
}

proc update_PARAM_VALUE.N_REG { PARAM_VALUE.N_REG } {
	# Procedure called to update N_REG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_REG { PARAM_VALUE.N_REG } {
	# Procedure called to validate N_REG
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.INCLUDE_AXI_SYNC { MODELPARAM_VALUE.INCLUDE_AXI_SYNC PARAM_VALUE.INCLUDE_AXI_SYNC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INCLUDE_AXI_SYNC}] ${MODELPARAM_VALUE.INCLUDE_AXI_SYNC}
}

proc update_MODELPARAM_VALUE.N_REG { MODELPARAM_VALUE.N_REG PARAM_VALUE.N_REG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_REG}] ${MODELPARAM_VALUE.N_REG}
}

