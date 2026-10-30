# ONE-TIME setup in the Vivado Tcl Console: creates the VIO block (lets you type n from Tcl)
#   source C:/Projects/demo/vio_setup.tcl
set ipdef [lindex [lsort [get_ipdefs -filter {NAME == vio}]] end]
puts "Using IP: $ipdef"
create_ip -name vio -vendor xilinx.com -library ip -module_name vio_0
set_property -dict [list CONFIG.C_NUM_PROBE_IN {0} CONFIG.C_NUM_PROBE_OUT {1} CONFIG.C_PROBE_OUT0_WIDTH {5}] [get_ips vio_0]
generate_target all [get_ips vio_0]
puts "vio_0 created."
