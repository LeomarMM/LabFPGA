set_time_format -unit ns -decimal_places 3
create_clock -name {i_CLK} -period 10.000 [get_ports { i_CLK }]
create_generated_clock -name {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK} -source [get_ports {i_CLK}] -master_clock {i_CLK} [get_registers {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}] 
derive_clock_uncertainty