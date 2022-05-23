# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NFANOUT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INVERT" -parent ${Page_0}
  set INCLUDE_SYNCHRONIZER [ipgui::add_param $IPINST -name "INCLUDE_SYNCHRONIZER" -parent ${Page_0}]
  set_property tooltip {Include IPIF synchronizer (only necessary if IPIF clock is unrelated to other clocks)} ${INCLUDE_SYNCHRONIZER}


}

proc update_PARAM_VALUE.INCLUDE_SYNCHRONIZER { PARAM_VALUE.INCLUDE_SYNCHRONIZER } {
	# Procedure called to update INCLUDE_SYNCHRONIZER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INCLUDE_SYNCHRONIZER { PARAM_VALUE.INCLUDE_SYNCHRONIZER } {
	# Procedure called to validate INCLUDE_SYNCHRONIZER
	return true
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

proc update_PARAM_VALUE.INVERT { PARAM_VALUE.INVERT } {
	# Procedure called to update INVERT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INVERT { PARAM_VALUE.INVERT } {
	# Procedure called to validate INVERT
	return true
}

proc update_PARAM_VALUE.NFANOUT { PARAM_VALUE.NFANOUT } {
	# Procedure called to update NFANOUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NFANOUT { PARAM_VALUE.NFANOUT } {
	# Procedure called to validate NFANOUT
	return true
}

proc update_PARAM_VALUE.N_REG { PARAM_VALUE.N_REG } {
	# Procedure called to update N_REG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_REG { PARAM_VALUE.N_REG } {
	# Procedure called to validate N_REG
	return true
}

proc update_MODELPARAM_VALUE.INCLUDE_SYNCHRONIZER { MODELPARAM_VALUE.INCLUDE_SYNCHRONIZER PARAM_VALUE.INCLUDE_SYNCHRONIZER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INCLUDE_SYNCHRONIZER}] ${MODELPARAM_VALUE.INCLUDE_SYNCHRONIZER}
}

proc update_MODELPARAM_VALUE.NFANOUT { MODELPARAM_VALUE.NFANOUT PARAM_VALUE.NFANOUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NFANOUT}] ${MODELPARAM_VALUE.NFANOUT}
}

proc update_MODELPARAM_VALUE.INVERT { MODELPARAM_VALUE.INVERT PARAM_VALUE.INVERT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INVERT}] ${MODELPARAM_VALUE.INVERT}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.N_REG { MODELPARAM_VALUE.N_REG PARAM_VALUE.N_REG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_REG}] ${MODELPARAM_VALUE.N_REG}
}

