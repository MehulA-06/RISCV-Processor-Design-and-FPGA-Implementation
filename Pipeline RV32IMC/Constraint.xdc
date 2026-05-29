
set_property -dict { PACKAGE_PIN AD12  IOSTANDARD LVDS } [get_ports { sys_clk_p }]
set_property -dict { PACKAGE_PIN AD11  IOSTANDARD LVDS } [get_ports { sys_clk_n }]

create_clock -period 5.000 -name sys_clk_200 -waveform {0.000 2.500} [get_ports sys_clk_p]

create_generated_clock \
    -name clk_25 \
    -source [get_ports sys_clk_p] \
    -multiply_by 1 \
    -divide_by 8 \
    [get_pins {clk_bufg/O}]

set_property -dict { PACKAGE_PIN E18  IOSTANDARD LVCMOS12 } [get_ports { rst }]

set_false_path -from [get_ports rst]

set_property -dict { PACKAGE_PIN T28  IOSTANDARD LVCMOS33 } [get_ports { led_out[0] }]
set_property -dict { PACKAGE_PIN V19  IOSTANDARD LVCMOS33 } [get_ports { led_out[1] }]
set_property -dict { PACKAGE_PIN U30  IOSTANDARD LVCMOS33 } [get_ports { led_out[2] }]
set_property -dict { PACKAGE_PIN U29  IOSTANDARD LVCMOS33 } [get_ports { led_out[3] }]
set_property -dict { PACKAGE_PIN V20  IOSTANDARD LVCMOS33 } [get_ports { led_out[4] }]
set_property -dict { PACKAGE_PIN V26  IOSTANDARD LVCMOS33 } [get_ports { led_out[5] }]
set_property -dict { PACKAGE_PIN W24  IOSTANDARD LVCMOS33 } [get_ports { led_out[6] }]
set_property -dict { PACKAGE_PIN W23  IOSTANDARD LVCMOS33 } [get_ports { led_out[7] }]

set_false_path -to [get_ports {led_out[*]}]

set_property CFGBVS         VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3         [current_design]

set_switching_activity -default_toggle_rate 12.5 -default_static_probability 0.5 [current_design]

set_switching_activity -toggle_rate  0.5  -static_probability 0.5 [get_ports {rst}]
set_switching_activity -toggle_rate  0.0  -static_probability 0.5 [get_ports {sys_clk_p}]
set_switching_activity -toggle_rate  0.0  -static_probability 0.5 [get_ports {sys_clk_n}]

set_switching_activity -toggle_rate  5.0  -static_probability 0.5 [get_ports {led_out[*]}]

set_operating_conditions -grade commercial -process typical

