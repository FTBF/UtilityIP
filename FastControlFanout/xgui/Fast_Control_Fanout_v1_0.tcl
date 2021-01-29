# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NFANOUT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NRESYNC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INVERT" -parent ${Page_0}


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

proc update_PARAM_VALUE.NRESYNC { PARAM_VALUE.NRESYNC } {
	# Procedure called to update NRESYNC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NRESYNC { PARAM_VALUE.NRESYNC } {
	# Procedure called to validate NRESYNC
	return true
}


proc update_MODELPARAM_VALUE.NFANOUT { MODELPARAM_VALUE.NFANOUT PARAM_VALUE.NFANOUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NFANOUT}] ${MODELPARAM_VALUE.NFANOUT}
}

proc update_MODELPARAM_VALUE.NRESYNC { MODELPARAM_VALUE.NRESYNC PARAM_VALUE.NRESYNC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NRESYNC}] ${MODELPARAM_VALUE.NRESYNC}
}

proc update_MODELPARAM_VALUE.INVERT { MODELPARAM_VALUE.INVERT PARAM_VALUE.INVERT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INVERT}] ${MODELPARAM_VALUE.INVERT}
}

