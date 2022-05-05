#########################################################################################
# Post system linker TCL hook
#########################################################################################

###################################### Update here ######################################
proc postsys_link_body {} {
  #### Continuous clocks connectivity

  # connect_continuous_clocks ss_ucs 0; # No UCS present, continuous clock is not supported
  # connect_continuous_clocks ss_ucs 2; # UCS subsystem version v2
  connect_continuous_clocks ss_ucs 3; # UCS subsystem version v3

}







##################################### DO NOT EDIT #######################################
proc connect_continuous_clocks { ucs_name ucs_version} {
  # Set names depending on UCS version
  if {$ucs_version == 0} {
    connect_bd_net  [get_bd_pins krnl_*/ap_clk]     [get_bd_pins krnl_*/ap_clk_cont]
    connect_bd_net  [get_bd_pins krnl_*/ap_clk_2]   [get_bd_pins krnl_*/ap_clk_2_cont]
    return
  } elseif {$ucs_version == 2} {
    set clk_prop_name_0   ENABLE_KERNEL_CONT_CLOCK
    set clk_prop_val_0    true
    set clk_port_0        clk_kernel_cont
    set clk_prop_name_1   ENABLE_KERNEL2_CONT_CLOCK
    set clk_prop_val_1    true
    set clk_port_1        clk_kernel2_cont
  } elseif {$ucs_version == 3} {
    set clk_prop_name_0   ENABLE_CONT_KERNEL_CLOCK_00
    set clk_prop_val_0    true
    set clk_port_0        aclk_kernel_00_cont
    set clk_prop_name_1   ENABLE_CONT_KERNEL_CLOCK_01
    set clk_prop_val_1    true
    set clk_port_1        aclk_kernel_01_cont
  } else {
    common::send_msg_id {XBTEST_POSTSYS_LINK-1} {ERROR} "Failed to connect continuous clocks. UCS version ($ucs_version) not defined in connect_continuous_clocks in your postsys_link.tcl"
  }
  # Check the UCS cell exists
  if {[get_bd_cells $ucs_name] == {}} {
    common::send_msg_id {XBTEST_POSTSYS_LINK-2} {ERROR} "Failed to connect continuous clocks. UCS cell ($ucs_name) not found. Check cell name in BD"
  }
  # Enable UCS kernel continuous clocks outputs
  foreach {prop val} [dict create $clk_prop_name_0 $clk_prop_val_0 $clk_prop_name_1 $clk_prop_val_0] {
    # Check property exists
    if {![regexp -nocase -- ".*CONFIG.${prop}.*" [list_property [get_bd_cells $ucs_name]]]} {
      common::send_msg_id {XBTEST_POSTSYS_LINK-3} {ERROR} "Failed to connect continuous clocks. UCS cell property (CONFIG.$prop) does not exists. Check UCS susbsystem ($ucs_name) version"
    }
    set_property CONFIG.$prop $val [get_bd_cells $ucs_name]
  }
  # Connect UCS continuous clocks outputs to clock inputs of all xbtest compute units continuous
  foreach {src dst} [dict create $clk_port_0 ap_clk_cont $clk_port_1 ap_clk_2_cont] {
    if {[get_bd_pins $ucs_name/$src] == {}} {
      common::send_msg_id {XBTEST_POSTSYS_LINK-4} {ERROR} "Failed to connect continuous clocks. UCS cell pin ($ucs_name/$src) not found. Check cell pin name in BD"
    }
    connect_bd_net [get_bd_pins $ucs_name/$src] [get_bd_pins krnl_*/$dst]
  }
}
# Execute body
postsys_link_body
