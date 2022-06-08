# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\Documents\KU-COSE321-00\csd_lab_assignment9_system\_ide\scripts\systemdebugger_csd_lab_assignment9_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\Documents\KU-COSE321-00\csd_lab_assignment9_system\_ide\scripts\systemdebugger_csd_lab_assignment9_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Zed 210248AC8E49" && level==0 && jtag_device_ctx=="jsn-Zed-210248AC8E49-23727093-0"}
fpga -file C:/Documents/KU-COSE321-00/csd_lab_assignment9/_ide/bitstream/SoC_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw C:/Documents/KU-COSE321-00/csd_platform/export/csd_platform/hw/SoC_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source C:/Documents/KU-COSE321-00/csd_lab_assignment9/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow C:/Documents/KU-COSE321-00/csd_lab_assignment9/Debug/csd_lab_assignment9.elf
configparams force-mem-access 0
bpadd -addr &main
