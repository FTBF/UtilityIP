
proc init { cellpath otherInfo } {  

	set cell_handle [get_bd_cells $cellpath]                                                                 
	set all_busif [get_bd_intf_pins $cellpath/*]		                                                     
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]
	set full_sbusif_list [list  S00_AXI ]
			                                                                                                 
	foreach busif $all_busif {                                                                               
		if { [string equal -nocase [get_property MODE $busif] "slave"] == 1 } {                            
			set busif_param_list [list]                                                                      
			set busif_name [get_property NAME $busif]					                                     
			if { [lsearch -exact -nocase $full_sbusif_list $busif_name ] == -1 } {					         
			    continue                                                                                     
			}                                                                                                
			foreach tparam $axi_standard_param_list {                                                        
				lappend busif_param_list "C_${busif_name}_${tparam}"                                       
			}                                                                                                
			bd::mark_propagate_only $cell_handle $busif_param_list			                                 
		}		                                                                                             
	}                                                                                                        
}


proc pre_propagate {cellpath otherInfo } {                                                           

	set cell_handle [get_bd_cells $cellpath]                                                                 
	set all_busif [get_bd_intf_pins $cellpath/*]		                                                     
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]
	                                                                                                         
	foreach busif $all_busif {	                                                                             
		if { [string equal -nocase [get_property CONFIG.PROTOCOL $busif] "AXI4"] != 1 } {                  
			continue                                                                                         
		}                                                                                                    
		if { [string equal -nocase [get_property MODE $busif] "master"] != 1 } {                           
			continue                                                                                         
		}			                                                                                         
		                                                                                                     
		set busif_name [get_property NAME $busif]			                                                 
		foreach tparam $axi_standard_param_list {		                                                     
			set busif_param_name "C_${busif_name}_${tparam}"			                                     
			                                                                                                 
			set val_on_cell_intf_pin [get_property CONFIG.${tparam} $busif]                                  
			set val_on_cell [get_property CONFIG.${busif_param_name} $cell_handle]                           
			                                                                                                 
			if { [string equal -nocase $val_on_cell_intf_pin $val_on_cell] != 1 } {                          
				if { $val_on_cell != "" } {                                                                  
					set_property CONFIG.${tparam} $val_on_cell $busif                                        
				}                                                                                            
			}			                                                                                     
		}		                                                                                             
	}                                                                                                        
}


proc propagate {cellpath otherInfo } {
        set cell_handle [get_bd_cells $cellpath]
	set all_busif [get_bd_intf_pins $cellpath/*]
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]

        set ip_name $cell_handle
        set intf_net_name IP
        set label ""
        set name ""
        set pin [get_bd_intf_pins $ip_name/$intf_net_name]
        set modules [get_bd_cells -of [get_bd_intf_nets -of $pin]]
        foreach {ip} $modules {
            if {[string match $ip_name $ip]} { continue }
            set label $ip
            set name [lindex [split [get_property VLNV $ip] ":"] 2]
            break
        }
        set_property CONFIG.TARGET_LABEL $label $cell_handle
        set_property CONFIG.TARGET_NAME $name $cell_handle
        
	foreach busif $all_busif {
		if { [string equal -nocase [get_property CONFIG.PROTOCOL $busif] "AXI4"] != 1 } {
			continue
		}
		if { [string equal -nocase [get_property MODE $busif] "slave"] != 1 } {
			continue
		}

		set busif_name [get_property NAME $busif]
		foreach tparam $axi_standard_param_list {
			set busif_param_name "C_${busif_name}_${tparam}"

			set val_on_cell_intf_pin [get_property CONFIG.${tparam} $busif]
			set val_on_cell [get_property CONFIG.${busif_param_name} $cell_handle]

			if { [string equal -nocase $val_on_cell_intf_pin $val_on_cell] != 1 } {
				#override property of bd_interface_net to bd_cell -- only for slaves.  May check for supported values..
				if { $val_on_cell_intf_pin != "" } {
					set_property CONFIG.${busif_param_name} $val_on_cell_intf_pin $cell_handle
				}
			}
		}
	}
}

