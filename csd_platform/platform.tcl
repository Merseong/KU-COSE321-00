# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Documents\KU-COSE321-00\csd_platform\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Documents\KU-COSE321-00\csd_platform\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {csd_platform}\
-hw {C:\Documents\KU-COSE321-00\SoC_wrapper.xsa}\
-proc {ps7_cortexa9_0} -os {standalone} -out {C:/Documents/KU-COSE321-00}

platform write
platform generate -domains 
platform active {csd_platform}
platform generate
platform clean
platform generate
platform generate -domains zynq_fsbl 
platform generate
platform generate
platform clean
platform generate
