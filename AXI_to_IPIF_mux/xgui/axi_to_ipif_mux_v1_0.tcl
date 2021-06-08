# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_DPHASE_TIMEOUT [ipgui::add_param $IPINST -name "C_DPHASE_TIMEOUT" -parent ${Page_0}]
  set_property tooltip {Transaction timeout in clock ticks} ${C_DPHASE_TIMEOUT}
  set N_CHIP [ipgui::add_param $IPINST -name "N_CHIP" -parent ${Page_0}]
  set_property tooltip {Number of target chip selects} ${N_CHIP}
  set N_REG [ipgui::add_param $IPINST -name "N_REG" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Number of registers per chip} ${N_REG}
  set BROADCAST_REG [ipgui::add_param $IPINST -name "BROADCAST_REG" -parent ${Page_0}]
  set_property tooltip {Sets registers to broadcast mode (one bit per register)} ${BROADCAST_REG}
  set MUX_BY_CHIP [ipgui::add_param $IPINST -name "MUX_BY_CHIP" -parent ${Page_0}]
  set_property tooltip {Muc IPIF interface into sepearte interfaces per chip} ${MUX_BY_CHIP}


}

proc update_PARAM_VALUE.BROADCAST_REG { PARAM_VALUE.BROADCAST_REG } {
	# Procedure called to update BROADCAST_REG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BROADCAST_REG { PARAM_VALUE.BROADCAST_REG } {
	# Procedure called to validate BROADCAST_REG
	return true
}

proc update_PARAM_VALUE.C_DPHASE_TIMEOUT { PARAM_VALUE.C_DPHASE_TIMEOUT } {
	# Procedure called to update C_DPHASE_TIMEOUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DPHASE_TIMEOUT { PARAM_VALUE.C_DPHASE_TIMEOUT } {
	# Procedure called to validate C_DPHASE_TIMEOUT
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

proc update_PARAM_VALUE.C_S_AXI_MIN_SIZE { PARAM_VALUE.C_S_AXI_MIN_SIZE } {
	# Procedure called to update C_S_AXI_MIN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_MIN_SIZE { PARAM_VALUE.C_S_AXI_MIN_SIZE } {
	# Procedure called to validate C_S_AXI_MIN_SIZE
	return true
}

proc update_PARAM_VALUE.C_USE_WSTRB { PARAM_VALUE.C_USE_WSTRB } {
	# Procedure called to update C_USE_WSTRB when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_USE_WSTRB { PARAM_VALUE.C_USE_WSTRB } {
	# Procedure called to validate C_USE_WSTRB
	return true
}

proc update_PARAM_VALUE.MUX_BY_CHIP { PARAM_VALUE.MUX_BY_CHIP } {
	# Procedure called to update MUX_BY_CHIP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MUX_BY_CHIP { PARAM_VALUE.MUX_BY_CHIP } {
	# Procedure called to validate MUX_BY_CHIP
	return true
}

proc update_PARAM_VALUE.N_CHIP { PARAM_VALUE.N_CHIP } {
	# Procedure called to update N_CHIP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_CHIP { PARAM_VALUE.N_CHIP } {
	# Procedure called to validate N_CHIP
	return true
}

proc update_PARAM_VALUE.N_REG { PARAM_VALUE.N_REG } {
	# Procedure called to update N_REG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_REG { PARAM_VALUE.N_REG } {
	# Procedure called to validate N_REG
	return true
}

proc update_PARAM_VALUE.TARGET_LABELS { PARAM_VALUE.TARGET_LABELS } {
	# Procedure called to update TARGET_LABELS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TARGET_LABELS { PARAM_VALUE.TARGET_LABELS } {
	# Procedure called to validate TARGET_LABELS
	return true
}

proc update_PARAM_VALUE.TARGET_NAMES { PARAM_VALUE.TARGET_NAMES } {
	# Procedure called to update TARGET_NAMES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TARGET_NAMES { PARAM_VALUE.TARGET_NAMES } {
	# Procedure called to validate TARGET_NAMES
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

proc update_MODELPARAM_VALUE.C_S_AXI_MIN_SIZE { MODELPARAM_VALUE.C_S_AXI_MIN_SIZE PARAM_VALUE.C_S_AXI_MIN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_MIN_SIZE}] ${MODELPARAM_VALUE.C_S_AXI_MIN_SIZE}
}

proc update_MODELPARAM_VALUE.C_USE_WSTRB { MODELPARAM_VALUE.C_USE_WSTRB PARAM_VALUE.C_USE_WSTRB } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_USE_WSTRB}] ${MODELPARAM_VALUE.C_USE_WSTRB}
}

proc update_MODELPARAM_VALUE.C_DPHASE_TIMEOUT { MODELPARAM_VALUE.C_DPHASE_TIMEOUT PARAM_VALUE.C_DPHASE_TIMEOUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DPHASE_TIMEOUT}] ${MODELPARAM_VALUE.C_DPHASE_TIMEOUT}
}

proc update_MODELPARAM_VALUE.N_CHIP { MODELPARAM_VALUE.N_CHIP PARAM_VALUE.N_CHIP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_CHIP}] ${MODELPARAM_VALUE.N_CHIP}
}

proc update_MODELPARAM_VALUE.N_REG { MODELPARAM_VALUE.N_REG PARAM_VALUE.N_REG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_REG}] ${MODELPARAM_VALUE.N_REG}
}

proc update_MODELPARAM_VALUE.MUX_BY_CHIP { MODELPARAM_VALUE.MUX_BY_CHIP PARAM_VALUE.MUX_BY_CHIP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MUX_BY_CHIP}] ${MODELPARAM_VALUE.MUX_BY_CHIP}
}

proc update_MODELPARAM_VALUE.BROADCAST_REG { MODELPARAM_VALUE.BROADCAST_REG PARAM_VALUE.BROADCAST_REG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BROADCAST_REG}] ${MODELPARAM_VALUE.BROADCAST_REG}
}

