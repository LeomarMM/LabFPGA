## Generated SDC file "LabFPGA.out.sdc"

## Copyright (C) 2022  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 21.1.1 Build 850 06/23/2022 SJ Lite Edition"

## DATE    "Fri Aug 26 13:15:21 2022"

##
## DEVICE  "5CSEMA5F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {i_CLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports {i_CLK}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK} -source [get_ports {i_CLK}] -master_clock {i_CLK} [get_registers {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}] -rise_to [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}]  0.380  
set_clock_uncertainty -rise_from [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}] -fall_to [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}]  0.380  
set_clock_uncertainty -rise_from [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}] -rise_to [get_clocks {i_CLK}]  0.350  
set_clock_uncertainty -rise_from [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}] -fall_to [get_clocks {i_CLK}]  0.350  
set_clock_uncertainty -fall_from [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}] -rise_to [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}]  0.380  
set_clock_uncertainty -fall_from [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}] -fall_to [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}]  0.380  
set_clock_uncertainty -fall_from [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}] -rise_to [get_clocks {i_CLK}]  0.350  
set_clock_uncertainty -fall_from [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}] -fall_to [get_clocks {i_CLK}]  0.350  
set_clock_uncertainty -rise_from [get_clocks {i_CLK}] -rise_to [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}]  0.350  
set_clock_uncertainty -rise_from [get_clocks {i_CLK}] -fall_to [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}]  0.350  
set_clock_uncertainty -rise_from [get_clocks {i_CLK}] -rise_to [get_clocks {i_CLK}] -setup 0.310  
set_clock_uncertainty -rise_from [get_clocks {i_CLK}] -rise_to [get_clocks {i_CLK}] -hold 0.270  
set_clock_uncertainty -rise_from [get_clocks {i_CLK}] -fall_to [get_clocks {i_CLK}] -setup 0.310  
set_clock_uncertainty -rise_from [get_clocks {i_CLK}] -fall_to [get_clocks {i_CLK}] -hold 0.270  
set_clock_uncertainty -fall_from [get_clocks {i_CLK}] -rise_to [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}]  0.350  
set_clock_uncertainty -fall_from [get_clocks {i_CLK}] -fall_to [get_clocks {MONITOR_RX:U1|UART_RX:U2|COUNTER_CLK:CC1|r_CLK}]  0.350  
set_clock_uncertainty -fall_from [get_clocks {i_CLK}] -rise_to [get_clocks {i_CLK}] -setup 0.310  
set_clock_uncertainty -fall_from [get_clocks {i_CLK}] -rise_to [get_clocks {i_CLK}] -hold 0.270  
set_clock_uncertainty -fall_from [get_clocks {i_CLK}] -fall_to [get_clocks {i_CLK}] -setup 0.310  
set_clock_uncertainty -fall_from [get_clocks {i_CLK}] -fall_to [get_clocks {i_CLK}] -hold 0.270  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

