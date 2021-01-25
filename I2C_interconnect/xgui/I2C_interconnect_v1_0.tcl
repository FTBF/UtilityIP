# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set NUM_INTERFACES [ipgui::add_param $IPINST -name "NUM_INTERFACES" -parent ${Page_0}]
  set_property tooltip {Number of I2c interfaces} ${NUM_INTERFACES}
  ipgui::add_param $IPINST -name "NUM_MASTER_INTERFACES" -parent ${Page_0}


}

proc update_PARAM_VALUE.NUM_INTERFACES { PARAM_VALUE.NUM_INTERFACES } {
	# Procedure called to update NUM_INTERFACES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_INTERFACES { PARAM_VALUE.NUM_INTERFACES } {
	# Procedure called to validate NUM_INTERFACES
	return true
}

proc update_PARAM_VALUE.NUM_MASTER_INTERFACES { PARAM_VALUE.NUM_MASTER_INTERFACES } {
	# Procedure called to update NUM_MASTER_INTERFACES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_MASTER_INTERFACES { PARAM_VALUE.NUM_MASTER_INTERFACES } {
	# Procedure called to validate NUM_MASTER_INTERFACES
	return true
}


