
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/IO_blocks_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NLINKS" -parent ${Page_0}
  set DRIVE_ENABLED [ipgui::add_param $IPINST -name "DRIVE_ENABLED" -parent ${Page_0}]
  set_property tooltip {Enable capability to drive voltage to IO pins} ${DRIVE_ENABLED}
  set INPUT_STREAMS_ENABLE [ipgui::add_param $IPINST -name "INPUT_STREAMS_ENABLE" -parent ${Page_0}]
  set_property tooltip {Enable AXI-stream inputs} ${INPUT_STREAMS_ENABLE}
  set OUTPUT_STREAMS_ENABLE [ipgui::add_param $IPINST -name "OUTPUT_STREAMS_ENABLE" -parent ${Page_0}]
  set_property tooltip {Enable AXI-stream outputs} ${OUTPUT_STREAMS_ENABLE}
  set INVERT [ipgui::add_param $IPINST -name "INVERT" -parent ${Page_0}]
  set_property tooltip {Channels with inverted differential pairs (bit vector; 1: inverted, 0: not inverted)} ${INVERT}


}

proc update_PARAM_VALUE.DRIVE_ENABLED { PARAM_VALUE.DRIVE_ENABLED PARAM_VALUE.INPUT_STREAMS_ENABLE } {
	# Procedure called to update DRIVE_ENABLED when any of the dependent parameters in the arguments change
	
	set DRIVE_ENABLED ${PARAM_VALUE.DRIVE_ENABLED}
	set INPUT_STREAMS_ENABLE ${PARAM_VALUE.INPUT_STREAMS_ENABLE}
	set values(INPUT_STREAMS_ENABLE) [get_property value $INPUT_STREAMS_ENABLE]
	if { [gen_USERPARAMETER_DRIVE_ENABLED_ENABLEMENT $values(INPUT_STREAMS_ENABLE)] } {
		set_property enabled true $DRIVE_ENABLED
	} else {
		set_property enabled false $DRIVE_ENABLED
		set_property value [gen_USERPARAMETER_DRIVE_ENABLED_VALUE $values(INPUT_STREAMS_ENABLE)] $DRIVE_ENABLED
	}
}

proc validate_PARAM_VALUE.DRIVE_ENABLED { PARAM_VALUE.DRIVE_ENABLED } {
	# Procedure called to validate DRIVE_ENABLED
	return true
}

proc update_PARAM_VALUE.INPUT_STREAMS_ENABLE { PARAM_VALUE.INPUT_STREAMS_ENABLE } {
	# Procedure called to update INPUT_STREAMS_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_STREAMS_ENABLE { PARAM_VALUE.INPUT_STREAMS_ENABLE } {
	# Procedure called to validate INPUT_STREAMS_ENABLE
	return true
}

proc update_PARAM_VALUE.NLINKS { PARAM_VALUE.NLINKS } {
	# Procedure called to update NLINKS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NLINKS { PARAM_VALUE.NLINKS } {
	# Procedure called to validate NLINKS
	return true
}

proc update_PARAM_VALUE.OUTPUT_STREAMS_ENABLE { PARAM_VALUE.OUTPUT_STREAMS_ENABLE } {
	# Procedure called to update OUTPUT_STREAMS_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUTPUT_STREAMS_ENABLE { PARAM_VALUE.OUTPUT_STREAMS_ENABLE } {
	# Procedure called to validate OUTPUT_STREAMS_ENABLE
	return true
}

proc update_PARAM_VALUE.INVERT { PARAM_VALUE.INVERT } {
	# Procedure called to update INVERT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INVERT { PARAM_VALUE.INVERT } {
	# Procedure called to validate INVERT
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

proc update_MODELPARAM_VALUE.DRIVE_ENABLED { MODELPARAM_VALUE.DRIVE_ENABLED PARAM_VALUE.DRIVE_ENABLED } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DRIVE_ENABLED}] ${MODELPARAM_VALUE.DRIVE_ENABLED}
}

proc update_MODELPARAM_VALUE.OUTPUT_STREAMS_ENABLE { MODELPARAM_VALUE.OUTPUT_STREAMS_ENABLE PARAM_VALUE.OUTPUT_STREAMS_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUTPUT_STREAMS_ENABLE}] ${MODELPARAM_VALUE.OUTPUT_STREAMS_ENABLE}
}

proc update_MODELPARAM_VALUE.INVERT { MODELPARAM_VALUE.INVERT PARAM_VALUE.INVERT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INVERT}] ${MODELPARAM_VALUE.INVERT}
}

