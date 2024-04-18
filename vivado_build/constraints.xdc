set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports { resetn }];
set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { tx_o }];
set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { rx_i }];
