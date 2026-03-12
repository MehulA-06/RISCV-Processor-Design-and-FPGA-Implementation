# 32 MHz CLOCK
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 31.250 -name sys_clk -waveform {0 5} [get_ports clk]

# RESET BUTTON (BTNC)

set_property PACKAGE_PIN T18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# USER LEDs

set_property PACKAGE_PIN T22 [get_ports {led_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[0]}]

set_property PACKAGE_PIN T21 [get_ports {led_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[1]}]

set_property PACKAGE_PIN U22 [get_ports {led_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[2]}]

set_property PACKAGE_PIN U21 [get_ports {led_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[3]}]

set_property PACKAGE_PIN V22 [get_ports {led_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[4]}]

set_property PACKAGE_PIN W22 [get_ports {led_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[5]}]

set_property PACKAGE_PIN U19 [get_ports {led_out[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[6]}]

set_property PACKAGE_PIN U14 [get_ports {led_out[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[7]}]
