# Setting up these exclusive clock groups requires that this XDC file be processed "LATE"
# Check the component.xml for how to mark an XDC file as "LATE" processing order
set_clock_groups -name muxed_clocks -physically_exclusive \
    -group [get_clocks -include_generated_clocks -of_objects [get_pins mmcme4_adv_inst/CLKIN1]] \
    -group [get_clocks -include_generated_clocks -of_objects [get_pins mmcme4_adv_inst/CLKIN2]]

set_property CLOCK_DELAY_GROUP clk_mux_group [get_nets -of [get_pins -filter {REF_PIN_NAME =~ O} -of [get_cells -hier *clk40_buf]]]
set_property CLOCK_DELAY_GROUP clk_mux_group [get_nets -of [get_pins -filter {REF_PIN_NAME =~ O} -of [get_cells -hier *clk320_buf]]]
