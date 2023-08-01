# Nominally, we want this to be a 12 MHz clock, which has a period of 83.333 ns.
# But, we want the econ tester firmware to be operable up to higher frequencies, so we'll tell the timing analysis tool that the frequency is 12.9 MHz, with a period of 77.519ns
create_clock -period 77.519 -name clk12 [get_nets {*DDS_clk*}]

# It seems that our double-PLL is overtaxing the clock placer, so this may help
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets {*clk320}]
