set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports resetn]
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports tx_o]
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports rx_i]

