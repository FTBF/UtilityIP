# pin numbers available in the git repo
# IN0_P on of the DIO5 (in for the DIO correspond to OUT of the ZCU)
set_property -dict {PACKAGE_PIN U9 IOSTANDARD LVDS } [ get_ports syncTrigOut0_P_0 ]
# IN0_N on of the DIO5
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVDS } [ get_ports syncTrigOut0_N_0 ]
# IN1_P on of the DIO5 (in for the DIO correspond to OUT of the ZCU)
set_property -dict {PACKAGE_PIN T7 IOSTANDARD LVDS } [ get_ports syncTrigOut_P_0 ]
# IN1_N on of the DIO5
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVDS } [ get_ports syncTrigOut_N_0 ]
# OUT2_P on of the DIO5 (out of the DIO correspond to in to the ZCU)
set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVDS } [ get_ports asyncTrigIn_P_0 ]
# OUT2_N 
set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVDS } [ get_ports asyncTrigIn_N_0 ]
# OUT3_P
set_property -dict {PACKAGE_PIN Y2 IOSTANDARD LVDS } [ get_ports busyIn_P_0 ]
# OUT3_N
set_property -dict {PACKAGE_PIN Y1 IOSTANDARD LVDS } [ get_ports busyIn_N_0 ]
# OE0 on of the DIO5
set_property -dict {PACKAGE_PIN V6 IOSTANDARD LVCMOS18 } [ get_ports OutDisable0_0 ]
# OE1 on of the DIO5
set_property -dict {PACKAGE_PIN K12 IOSTANDARD LVCMOS18 } [ get_ports OutDisable1_0 ]
# OE2 on of the DIO5
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS18 } [ get_ports OutDisable2_0 ]
# OE3 on of the DIO5
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS18 } [ get_ports OutDisable3_0 ]
# TERM_EN0 
set_property -dict {PACKAGE_PIN U6 IOSTANDARD LVCMOS18 } [ get_ports TermEnable0_0 ]
# TERM_EN1 
set_property -dict {PACKAGE_PIN AC1 IOSTANDARD LVCMOS18 } [ get_ports TermEnable1_0 ]
# TERM_EN2 
set_property -dict {PACKAGE_PIN AC3 IOSTANDARD LVCMOS18 } [ get_ports TermEnable2_0 ]
# TERM_EN3 
set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVCMOS18 } [ get_ports TermEnable3_0 ]
# LED_TOP 
set_property -dict {PACKAGE_PIN AB4 IOSTANDARD LVCMOS18 } [ get_ports ledTop_0 ]
# LED_BOT
set_property -dict {PACKAGE_PIN AC4 IOSTANDARD LVCMOS18 } [ get_ports ledBot_0 ]
# SW14
set_property -dict {PACKAGE_PIN AF15 IOSTANDARD LVCMOS33 } [ get_ports startRun_0 ]
# SW17
set_property -dict {PACKAGE_PIN AE14 IOSTANDARD LVCMOS33 } [ get_ports stopRun_0 ]
