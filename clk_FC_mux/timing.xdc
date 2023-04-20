# Setting up these exclusive clock groups requires that this XDC file be processed "LATE"
# Check the component.xml for how to mark an XDC file as "LATE" processing order
set_clock_groups -name muxed_clocks -physically_exclusive \
    -group [get_clocks -include_generated_clocks -of_objects [get_pins BUFCTRL_inst/I0]] \
    -group [get_clocks -include_generated_clocks -of_objects [get_pins BUFCTRL_inst/I1]]

set_false_path -to [get_pins BUFGCTRL_inst/S0]
set_false_path -to [get_pins BUFGCTRL_inst/S0]
