# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  set NUM_INTERFACES [ipgui::add_param $IPINST -name "NUM_INTERFACES"]
  set_property tooltip {Number of I2c interfaces} ${NUM_INTERFACES}

}

proc update_PARAM_VALUE.NUM_INTERFACES { PARAM_VALUE.NUM_INTERFACES } {
	# Procedure called to update NUM_INTERFACES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_INTERFACES { PARAM_VALUE.NUM_INTERFACES } {
	# Procedure called to validate NUM_INTERFACES
	return true
}


