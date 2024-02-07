# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "WIDTH" -parent ${Page_0}
  set AXI_STREAM [ipgui::add_param $IPINST -name "AXI_STREAM" -parent ${Page_0}]
  set_property tooltip {Include AXI stream interfaces} ${AXI_STREAM}
  set INCLUDE_AXI_SYNC [ipgui::add_param $IPINST -name "INCLUDE_AXI_SYNC" -parent ${Page_0}]
  set_property tooltip {Include clock domain crossing for the AXI interface} ${INCLUDE_AXI_SYNC}


}

proc update_PARAM_VALUE.AXI_STREAM { PARAM_VALUE.AXI_STREAM } {
	# Procedure called to update AXI_STREAM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_STREAM { PARAM_VALUE.AXI_STREAM } {
	# Procedure called to validate AXI_STREAM
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

proc update_PARAM_VALUE.INCLUDE_AXI_SYNC { PARAM_VALUE.INCLUDE_AXI_SYNC } {
	# Procedure called to update INCLUDE_AXI_SYNC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INCLUDE_AXI_SYNC { PARAM_VALUE.INCLUDE_AXI_SYNC } {
	# Procedure called to validate INCLUDE_AXI_SYNC
	return true
}

proc update_PARAM_VALUE.WIDTH { PARAM_VALUE.WIDTH } {
	# Procedure called to update WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH { PARAM_VALUE.WIDTH } {
	# Procedure called to validate WIDTH
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

proc update_MODELPARAM_VALUE.WIDTH { MODELPARAM_VALUE.WIDTH PARAM_VALUE.WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH}] ${MODELPARAM_VALUE.WIDTH}
}

proc update_MODELPARAM_VALUE.AXI_STREAM { MODELPARAM_VALUE.AXI_STREAM PARAM_VALUE.AXI_STREAM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_STREAM}] ${MODELPARAM_VALUE.AXI_STREAM}
}

