proc init { cellpath otherInfo } {
	return []
}

 
proc post_configure_ip {cellpath otherInfo } {
	# Any updates to interface properties based on user configuration
}
 
proc propagate {cellpath otherInfo } {
    set cell_handle [get_bd_cells $cellpath]
    set intf_handle [get_bd_intf_pins $cellpath/axi]
}
