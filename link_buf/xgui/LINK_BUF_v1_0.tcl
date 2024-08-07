# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set INVERT [ipgui::add_param $IPINST -name "INVERT" -parent ${Page_0}]
  set_property tooltip {Invert data} ${INVERT}
  set NLINK [ipgui::add_param $IPINST -name "NLINK" -parent ${Page_0}]
  set_property tooltip {number of links} ${NLINK}


}

proc update_PARAM_VALUE.INVERT { PARAM_VALUE.INVERT } {
	# Procedure called to update INVERT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INVERT { PARAM_VALUE.INVERT } {
	# Procedure called to validate INVERT
	return true
}

proc update_PARAM_VALUE.NLINK { PARAM_VALUE.NLINK } {
	# Procedure called to update NLINK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NLINK { PARAM_VALUE.NLINK } {
	# Procedure called to validate NLINK
	return true
}


proc update_MODELPARAM_VALUE.NLINK { MODELPARAM_VALUE.NLINK PARAM_VALUE.NLINK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NLINK}] ${MODELPARAM_VALUE.NLINK}
}

proc update_MODELPARAM_VALUE.INVERT { MODELPARAM_VALUE.INVERT PARAM_VALUE.INVERT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INVERT}] ${MODELPARAM_VALUE.INVERT}
}

