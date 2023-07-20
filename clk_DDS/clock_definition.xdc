# Nominally, we want this to be a 20 MHz clock, which has a period of 50 ns.
# But, we want the econ tester firmware to be operable up to higher frequencies, so we'll tell the timing analysis tool that the frequency is 21.5 MHz, with a period of 46.511ns
create_clock -period 46.511 -name clk20 [get_nets {*clk_DDS*}]
