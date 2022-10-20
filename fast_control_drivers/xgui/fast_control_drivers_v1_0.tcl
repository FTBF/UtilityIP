# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set INVERT_FCMD [ipgui::add_param $IPINST -name "INVERT_FCMD" -parent ${Page_0}]
  set_property tooltip {Invert fast command data} ${INVERT_FCMD}


}

proc update_PARAM_VALUE.INVERT_FCMD { PARAM_VALUE.INVERT_FCMD } {
	# Procedure called to update INVERT_FCMD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INVERT_FCMD { PARAM_VALUE.INVERT_FCMD } {
	# Procedure called to validate INVERT_FCMD
	return true
}


proc update_MODELPARAM_VALUE.INVERT_FCMD { MODELPARAM_VALUE.INVERT_FCMD PARAM_VALUE.INVERT_FCMD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INVERT_FCMD}] ${MODELPARAM_VALUE.INVERT_FCMD}
}

