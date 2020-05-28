# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set page0 [ipgui::add_page $IPINST -name "page0"]
  set polynomial_index [ipgui::add_param $IPINST -name "polynomial_index" -parent ${page0}]
  set_property tooltip {Select the LFSR polynomial from a preset list of 100 maximal-length polynomials.  Different polynomials will produce different pseudorandom sequences.} ${polynomial_index}
  set Usage [ipgui::add_param $IPINST -name "Usage" -parent ${page0} -layout horizontal]
  set_property tooltip {Select whether this block will be used to generate a pseudorandom sequence or to check words received from a pseudorandom sequence.} ${Usage}


}

proc update_PARAM_VALUE.polynomial_index { PARAM_VALUE.polynomial_index } {
	# Procedure called to update polynomial_index when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.polynomial_index { PARAM_VALUE.polynomial_index } {
	# Procedure called to validate polynomial_index
	return true
}

proc update_PARAM_VALUE.Usage { PARAM_VALUE.Usage } {
	# Procedure called to update Usage when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Usage { PARAM_VALUE.Usage } {
	# Procedure called to validate Usage
	return true
}


proc update_MODELPARAM_VALUE.polynomial_index { MODELPARAM_VALUE.polynomial_index PARAM_VALUE.polynomial_index } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.polynomial_index}] ${MODELPARAM_VALUE.polynomial_index}
}

proc update_MODELPARAM_VALUE.Usage { MODELPARAM_VALUE.Usage PARAM_VALUE.Usage } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Usage}] ${MODELPARAM_VALUE.Usage}
}

