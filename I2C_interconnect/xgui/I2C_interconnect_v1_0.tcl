# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set NUM_INTERFACES [ipgui::add_param $IPINST -name "NUM_INTERFACES" -parent ${Page_0}]
  set_property tooltip {Number of I2c interfaces} ${NUM_INTERFACES}
  ipgui::add_param $IPINST -name "NUM_MASTER_INTERFACES" -parent ${Page_0}
  set ENABLE_AXI [ipgui::add_param $IPINST -name "ENABLE_AXI" -parent ${Page_0}]
  set_property tooltip {Use an AXI interface to enable and disable individual I2C interfaces at runtime} ${ENABLE_AXI}


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

proc update_PARAM_VALUE.ENABLE_AXI { PARAM_VALUE.ENABLE_AXI } {
	# Procedure called to update ENABLE_AXI when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_AXI { PARAM_VALUE.ENABLE_AXI } {
	# Procedure called to validate ENABLE_AXI
	return true
}

proc update_PARAM_VALUE.NUM_INTERFACES { PARAM_VALUE.NUM_INTERFACES } {
	# Procedure called to update NUM_INTERFACES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_INTERFACES { PARAM_VALUE.NUM_INTERFACES } {
	# Procedure called to validate NUM_INTERFACES
	return true
}

proc update_PARAM_VALUE.NUM_MASTER_INTERFACES { PARAM_VALUE.NUM_MASTER_INTERFACES } {
	# Procedure called to update NUM_MASTER_INTERFACES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_MASTER_INTERFACES { PARAM_VALUE.NUM_MASTER_INTERFACES } {
	# Procedure called to validate NUM_MASTER_INTERFACES
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

