
proc init { cellpath otherInfo } {  
	set cell_handle [get_bd_cells $cellpath]                                                                 
}


proc pre_propagate {cellpath otherInfo } {                                                           
	set cell_handle [get_bd_cells $cellpath]                                                                 
}


proc propagate {cellpath otherInfo } {
    set cell_handle [get_bd_cells $cellpath]
    set busipif [get_bd_intf_pins -of [get_bd_cells $cell_handle] -filter {VLNV==NONE:user:IPIF_AXISL__rtl:1.0}]

    set labels [list ]
    set names [list ]
    set intfs [list ]
    foreach {pin} $busipif {
        set nets [get_bd_intf_nets -of $pin]
        set modules [get_bd_cells -of $nets]
        set target_pins [get_bd_intf_pins -of $nets]
        foreach ip $modules {
            if {[string match $cell_handle $ip]} { continue }
            lappend labels "$ip"
            lappend names [lindex [split [get_property VLNV $ip] ":"] 2]
            break
        }
        foreach tpin $target_pins {
            if {[string match $tpin $pin]} { continue }
            lappend intfs [lindex [split "$tpin" "/"] end]
            break
        }
    }
    set_property CONFIG.TARGET_LABELS $labels $cell_handle
    set_property CONFIG.TARGET_NAMES $names $cell_handle
    set_property CONFIG.TARGET_INTFS $intfs $cell_handle
}

