# Copyright (C) 2022 Xilinx, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

####################################################################################################################
# This is a generated file. Use and modify at your own risk.
####################################################################################################################

proc add_hdl_parameter { config_ref kernel_name param_name param_value } {
    upvar 1 $config_ref config; # Dictionary passed as ref.

    set_property value $param_value [ipx::add_user_parameter  $param_name [ipx::current_core]]
    set_property value $param_value [ipx::get_user_parameters $param_name -of_objects [ipx::current_core]]
    set_property value $param_value [ipx::get_hdl_parameters  $param_name -of_objects [ipx::current_core]]
    log_message $config {PACKAGE_KERNEL-4} [list $param_name $kernel_name $param_value]
}
proc add_parameter_quiet { config_ref kernel_name param_name param_value } {
    upvar 1 $config_ref config; # Dictionary passed as ref.

    set_property value $param_value [ipx::add_user_parameter  $param_name [ipx::current_core]]
    set_property value $param_value [ipx::get_user_parameters $param_name -of_objects [ipx::current_core]]
}
proc add_parameter { config_ref kernel_name param_name param_value } {
    upvar 1 $config_ref config; # Dictionary passed as ref.

    add_parameter_quiet config $kernel_name $param_name $param_value
    log_message $config {PACKAGE_KERNEL-4} [list $param_name $kernel_name $param_value]
}
proc set_bus_parameter { config_ref kernel_name bus_if_name param_name param_value } {
    upvar 1 $config_ref config; # Dictionary passed as ref.

    set_property value $param_value [ipx::get_bus_parameters $param_name -of_objects [ipx::get_bus_interfaces $bus_if_name -of_objects [ipx::current_core]]]
    log_message $config {PACKAGE_KERNEL-4} [list $bus_if_name->$param_name $kernel_name $param_value]
}

proc add_bus_interface { config_ref kernel_name bus_if_name interface_mode abstraction_type_vlnv bus_type_vlnv } {
    upvar 1 $config_ref config; # Dictionary passed as ref.

    log_message $config {PACKAGE_KERNEL-6} [list $bus_type_vlnv $kernel_name $bus_if_name]
    set bus_if [ipx::add_bus_interface $bus_if_name [ipx::current_core]]
    set_property interface_mode         $interface_mode         $bus_if
    set_property abstraction_type_vlnv  $abstraction_type_vlnv  $bus_if
    set_property bus_type_vlnv          $bus_type_vlnv          $bus_if
}
proc set_port_map { bus_if_name port_map_name physical_name } {
    set port_map [ipx::add_port_map $port_map_name [ipx::get_bus_interfaces $bus_if_name -of_objects [ipx::current_core]]]
    set_property physical_name $physical_name $port_map
}


proc package_one_kernel { config_ref packaged_kernel_dir cu_cfg } {
    upvar 1 $config_ref config; # Dictionary passed as ref.

    set kernel_name [dict get $cu_cfg kernel_name]
    log_message $config {PACKAGE_KERNEL-3} [list $kernel_name]

    set path_to_tmp_project [file join [dict get $config run_dir] tmp_kernel_pack]

    create_project -force kernel_pack $path_to_tmp_project

    set ip_rep_dir  [file join $packaged_kernel_dir ip_rep]
    set ip_name_v   [dict get $config ip_name_v]
    set ip_catalog  [dict get $config ip_catalog]

    file delete -force -- $ip_rep_dir; file mkdir $ip_rep_dir
    file copy -force [file join $ip_catalog $ip_name_v] $ip_rep_dir

    set_property ip_repo_paths $ip_rep_dir [current_project]
    update_ip_catalog

    set component_xml   [file join $ip_rep_dir $ip_name_v component.xml]
    set packaged_dir    [file join $packaged_kernel_dir $kernel_name]
    set packaged_zip    [file join $packaged_kernel_dir ${kernel_name}.zip]
    ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $packaged_dir $component_xml

    # Set messages by default to be sure they will be loaded.
    add_parameter_quiet config $kernel_name MESSAGES_DICT [dict get $config MESSAGES_DICT]
    add_hdl_parameter   config $kernel_name C_CLOCK0_FREQ [dict get $config wizard_actual_config cu_configuration clock 0 freq]
    add_hdl_parameter   config $kernel_name C_CLOCK1_FREQ [dict get $config wizard_actual_config cu_configuration clock 1 freq]

    set krnl_mode [dict get $cu_cfg krnl_mode]

    add_hdl_parameter config $kernel_name C_KRNL_MODE       $krnl_mode
    add_hdl_parameter config $kernel_name C_KRNL_SLR        [dict get $cu_cfg slr_idx]
    add_parameter     config $kernel_name C_STOP_POST_OPT   [dict get $config STOP_POST_OPT]

    # Customize parameters
    if {$krnl_mode == 0} {
        set throttle_mode [dict get $cu_cfg throttle_mode]
        if {$throttle_mode == {EXTERNAL_MACRO}} {
            set c_throttle_mode 2
        } elseif {$throttle_mode == {EXTERNAL_CLK}} {
            set c_throttle_mode 3
        } elseif {$throttle_mode == {INTERNAL_MACRO}} {
            set c_throttle_mode 0
        } else {
            set c_throttle_mode 1; # default mode INTERNAL_CLK
        }
        add_hdl_parameter   config $kernel_name C_THROTTLE_MODE     $c_throttle_mode
        add_hdl_parameter   config $kernel_name C_USE_AIE           [dict get $cu_cfg use_aie]
        add_parameter_quiet config $kernel_name C_DYNAMIC_GEOMETRY  [dict get $config C_DYNAMIC_GEOMETRY]
        add_parameter_quiet config $kernel_name C_INVALID           [dict get $config C_INVALID]
        add_parameter_quiet config $kernel_name C_UTILIZATION       [dict get $config C_UTILIZATION]

    } elseif {$krnl_mode == 1} {
        set num_port [dict get $cu_cfg num_port]

        add_hdl_parameter config $kernel_name C_NUM_USED_M_AXI  $num_port
        add_hdl_parameter config $kernel_name C_MEM_KRNL_INST   [dict get $cu_cfg inst]

        set type [dict get $cu_cfg type]
        if {$type == {single_channel}} {
            set c_mem_type 1
        } else {
            set c_mem_type 2
        }
        add_hdl_parameter config $kernel_name C_MEM_TYPE $c_mem_type

        set axi_data_size   [dict get $cu_cfg axi_data_size]
        set axi_id_threads  [dict get $cu_cfg axi_id_threads]
        set axi_outstanding [dict get $cu_cfg axi_outstanding]
        if {$axi_id_threads == 1} {
            set c_use_axi_id 0
            set c_axi_thread_id_width 1
        } else {
            set c_use_axi_id 1
            set c_axi_thread_id_width [expr int( log($axi_id_threads) / log(2) )]
        }
        add_hdl_parameter config $kernel_name C_USE_AXI_ID $c_use_axi_id

        for {set ii 1} {$ii <= $num_port} {incr ii} {
            add_hdl_parameter config $kernel_name C_M[format "%02d" $ii]_AXI_DATA_WIDTH         $axi_data_size
            add_hdl_parameter config $kernel_name C_M[format "%02d" $ii]_AXI_THREAD_ID_WIDTH    $c_axi_thread_id_width

            set_bus_parameter config $kernel_name m[format "%02d" $ii]_axi NUM_WRITE_THREADS        $axi_id_threads
            set_bus_parameter config $kernel_name m[format "%02d" $ii]_axi NUM_READ_THREADS         $axi_id_threads
            set_bus_parameter config $kernel_name m[format "%02d" $ii]_axi NUM_WRITE_OUTSTANDING    $axi_outstanding
            set_bus_parameter config $kernel_name m[format "%02d" $ii]_axi NUM_READ_OUTSTANDING     $axi_outstanding
        }

    } elseif {(($krnl_mode == 3) || ($krnl_mode == 4) || ($krnl_mode == 6))} {

        set gt_idx  [dict get $cu_cfg gt_idx]
        set gt_type [dict get $cu_cfg type]
        add_hdl_parameter config $kernel_name C_GT_INDEX $gt_idx

        add_parameter config $kernel_name GT_${gt_idx}_GROUP_SELECT [dict get $cu_cfg group_select]
        add_parameter config $kernel_name GT_TYPE                   $gt_type

        # Group the GT Core's clock and serial ports into interfaces for connecting to shell ports
        # Do not do this in coreinfo, because this interface will not be used in [connectivity] .ini for other kernel
        # if this interface is not used v++ returns:
        # ERROR: [VPL 41-758] The following clock pins are not connected to a valid clock source: /krnl_powertest_slr0_1/gt_refclk ...
        # Do this here only for GT kernel
        # Ref clock
        add_bus_interface config $kernel_name gt_refclk slave xilinx.com:interface:diff_clock_rtl:1.0 xilinx.com:interface:diff_clock:1.0
        set_port_map gt_refclk CLK_P QSFP_CK_P
        set_port_map gt_refclk CLK_N QSFP_CK_N
        # Serial port
        add_bus_interface config $kernel_name gt_serial_port master xilinx.com:interface:gt_rtl:1.0 xilinx.com:interface:gt:1.0
        set_port_map gt_serial_port GRX_P QSFP_RX_P
        set_port_map gt_serial_port GRX_N QSFP_RX_N
        set_port_map gt_serial_port GTX_P QSFP_TX_P
        set_port_map gt_serial_port GTX_N QSFP_TX_N
    }

    if {$krnl_mode == 4} {
        # default value: 1 GTY with 4 lanes, 10/25GbE
        set C_GT_TYPE             0
        set C_GT_NUM_GT           1
        set C_GT_NUM_LANE         4
        set C_GT_RATE             0
        set C_GT_MAC_ENABLE_RSFEC 0

        set ip_sel       [dict get $cu_cfg ip_sel]
        set enable_rsfec [dict get $cu_cfg enable_rsfec]

        #set_property value $gt_mac_ip_sel [ipx::get_user_parameters GT_MAC_IP_SEL -of_objects [ipx::current_core]]
        # convert string into integer
        # Only two values possible for gt_mac_ip_sel (see validate_gt_mac_ip_sel)
        if {$ip_sel == {xbtest_sub_xxv_gt}} {
            set C_GT_MAC_IP_SEL 1
            # versal: 1 GTY with 4 lanes, fix 25GbE
            set C_GT_TYPE       0
            set C_GT_NUM_GT     1
            set C_GT_NUM_LANE   4
            set C_GT_RATE       2
        } elseif {$ip_sel == {xxv}} {
            set C_GT_MAC_IP_SEL 0
        }

        # GTM settings
        if {$gt_type == {GTM}} {
            #  GTM: 2 GTs with 2 lanes each, 25GbE
            set C_GT_TYPE      1
            set C_GT_NUM_GT    2
            set C_GT_NUM_LANE  2
            set C_GT_RATE      2

            add_bus_interface config $kernel_name gt_refclk_1 slave xilinx.com:interface:diff_clock_rtl:1.0 xilinx.com:interface:diff_clock:1.0
            set_port_map gt_refclk_1 CLK_P QSFP_CK_P_1
            set_port_map gt_refclk_1 CLK_N QSFP_CK_N_1
        }

        if {$enable_rsfec} {
            set C_GT_MAC_ENABLE_RSFEC 1
        } else {
            set C_GT_MAC_ENABLE_RSFEC 0
        }

        add_parameter     config $kernel_name GT_MAC_IP_SEL         $ip_sel
        add_parameter     config $kernel_name ENABLE_RSFEC          $enable_rsfec

        add_hdl_parameter config $kernel_name C_GT_MAC_IP_SEL       $C_GT_MAC_IP_SEL
        add_hdl_parameter config $kernel_name C_GT_TYPE             $C_GT_TYPE
        add_hdl_parameter config $kernel_name C_GT_NUM_GT           $C_GT_NUM_GT
        add_hdl_parameter config $kernel_name C_GT_NUM_LANE         $C_GT_NUM_LANE
        add_hdl_parameter config $kernel_name C_GT_RATE             $C_GT_RATE
        add_hdl_parameter config $kernel_name C_GT_MAC_ENABLE_RSFEC $C_GT_MAC_ENABLE_RSFEC
    }

    if {$krnl_mode == 5} {
        set dna_read [dict get $cu_cfg dna_read]
        if {$dna_read} {
            set C_DNA_READ 1
        } else {
            set C_DNA_READ 0
        }

        add_hdl_parameter   config $kernel_name C_DNA_READ     $C_DNA_READ
    }


    ####################################################################################################################
    # set new vlnv
    ####################################################################################################################
    set build_date [dict get $config build_date]

    set_property name           $kernel_name                                                                [ipx::current_core]
    set_property description    "xbtest RTL kernel automatically generated from $ip_name_v on $build_date"  [ipx::current_core]

    # Overwrite value from wizard example design
    set_property supports_ooc singular [ipx::current_core]

    ipx::create_xgui_files  [ipx::current_core]
    ipx::update_checksums   [ipx::current_core]
    ipx::check_integrity    [ipx::current_core]

    ipx::archive_core $packaged_zip [ipx::current_core]

    ####################################################################################################################
    # Remove project
    ####################################################################################################################

    # delete $packaged_kernel_dir project
    close_project -delete
    # delete $path_to_tmp_project/kernel_pack project
    close_project -delete

    file delete -force $packaged_dir
    file mkdir $packaged_dir
    exec unzip $packaged_zip -d $packaged_dir
    file delete -force $packaged_zip
    file delete -force $path_to_tmp_project
}

proc package_kernel { config_ref } {
    upvar 1 $config_ref config; # Dictionary passed as ref.

    log_message $config {PACKAGE_KERNEL-1}

    set packaged_kernel_dir [dict get $config packaged_kernel_dir]

    foreach {cu_cfg} [dict get $config cu_config] {
        set kernel_name [dict get $cu_cfg kernel_name]
        set kernel_xml  [dict get $cu_cfg kernel_xml]
        set kernel_xo   [dict get $cu_cfg kernel_xo]

        package_one_kernel config $packaged_kernel_dir $cu_cfg

        if {[file exists $kernel_xo]} {
            file delete -force $kernel_xo
        }
        package_xo -xo_path $kernel_xo -kernel_name $kernel_name -ip_directory [file join $packaged_kernel_dir $kernel_name] -kernel_xml [dict get $cu_cfg kernel_xml]
    }

    log_message $config {PACKAGE_KERNEL-2}
}
