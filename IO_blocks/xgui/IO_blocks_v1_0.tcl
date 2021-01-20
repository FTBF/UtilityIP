# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NLINKS" -parent ${Page_0}


}

proc update_PARAM_VALUE.NLINKS { PARAM_VALUE.NLINKS } {
	# Procedure called to update NLINKS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NLINKS { PARAM_VALUE.NLINKS } {
	# Procedure called to validate NLINKS
	return true
}

proc update_PARAM_VALUE.WORD_PER_LINK { PARAM_VALUE.WORD_PER_LINK } {
	# Procedure called to update WORD_PER_LINK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WORD_PER_LINK { PARAM_VALUE.WORD_PER_LINK } {
	# Procedure called to validate WORD_PER_LINK
	return true
}


proc update_MODELPARAM_VALUE.NLINKS { MODELPARAM_VALUE.NLINKS PARAM_VALUE.NLINKS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NLINKS}] ${MODELPARAM_VALUE.NLINKS}
}

proc update_MODELPARAM_VALUE.WORD_PER_LINK { MODELPARAM_VALUE.WORD_PER_LINK PARAM_VALUE.WORD_PER_LINK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WORD_PER_LINK}] ${MODELPARAM_VALUE.WORD_PER_LINK}
}

