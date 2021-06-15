
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/LFSR_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set page0 [ipgui::add_page $IPINST -name "page0"]
  set PRBS_type [ipgui::add_param $IPINST -name "PRBS_type" -parent ${page0} -widget comboBox]
  set_property tooltip {PRBS type: PRBS15, PRBS7, or a 32-bit PRBS (selectable polynomial)} ${PRBS_type}
  set polynomial_index [ipgui::add_param $IPINST -name "polynomial_index" -parent ${page0}]
  set_property tooltip {Select the LFSR polynomial from a preset list of 100 maximal-length polynomials.  Different polynomials will produce different pseudorandom sequences.} ${polynomial_index}
  ipgui::add_param $IPINST -name "iterations" -parent ${page0}
  set Usage [ipgui::add_param $IPINST -name "Usage" -parent ${page0} -layout horizontal]
  set_property tooltip {Select whether this block will be used to generate a pseudorandom sequence or to check words received from a pseudorandom sequence.} ${Usage}

}

proc update_PARAM_VALUE.polynomial_index { PARAM_VALUE.polynomial_index PARAM_VALUE.PRBS_type } {
	# Procedure called to update polynomial_index when any of the dependent parameters in the arguments change
	set polynomial_index ${PARAM_VALUE.polynomial_index}
	set PRBS_type ${PARAM_VALUE.PRBS_type}
	set values(PRBS_type) [get_property value $PRBS_type]
	if { [gen_USERPARAMETER_polynomial_index_ENABLEMENT $values(PRBS_type)] } {
		set_property enabled true $polynomial_index
	} else {
		set_property enabled false $polynomial_index
	}
}

proc validate_PARAM_VALUE.polynomial_index { PARAM_VALUE.polynomial_index } {
	# Procedure called to validate polynomial_index
	return true
}

proc update_PARAM_VALUE.PRBS_type { PARAM_VALUE.PRBS_type } {
	# Procedure called to update PRBS_type when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PRBS_type { PARAM_VALUE.PRBS_type } {
	# Procedure called to validate PRBS_type
	return true
}

proc update_PARAM_VALUE.iterations { PARAM_VALUE.iterations } {
	# Procedure called to update iterations when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.iterations { PARAM_VALUE.iterations } {
	# Procedure called to validate iterations
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

proc update_MODELPARAM_VALUE.PRBS_type { MODELPARAM_VALUE.PRBS_type PARAM_VALUE.PRBS_type } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PRBS_type}] ${MODELPARAM_VALUE.PRBS_type}
}

proc update_MODELPARAM_VALUE.iterations { MODELPARAM_VALUE.iterations PARAM_VALUE.iterations } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.iterations}] ${MODELPARAM_VALUE.iterations}
}

proc update_MODELPARAM_VALUE.Usage { MODELPARAM_VALUE.Usage PARAM_VALUE.Usage } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Usage}] ${MODELPARAM_VALUE.Usage}
}

