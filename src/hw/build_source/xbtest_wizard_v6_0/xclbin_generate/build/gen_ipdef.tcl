package require yaml

if {$argc == 1} {
    set config_yml_name [lindex $argv 0]
} else {
    common::send_msg_id {GEN_IPDEF-1} {ERROR} "Wrong argument. Expected 1 argument: IP config yaml"
}

if {![file exist $config_yml_name]} {
    common::send_msg_id {GEN_IPDEF-5} {ERROR} "IP config yaml does not exist: $config_yml_name"
}

set source_dir [file dirname $config_yml_name]
common::send_msg_id {GEN_IPDEF-2} {INFO} "Reading $config_yml_name"
set fp [open $config_yml_name r]
set config_yml [read $fp]
close $fp

set config [yaml::yaml2dict $config_yml]

set core_full_name  [dict get $config build full_name]
common::send_msg_id {GEN_IPDEF-3} {INFO} "Generating IPDEF for $core_full_name"

set output_dir          [pwd]
set gen_ipdef_prj_name  gen_ipdef_${core_full_name}_prj
set gen_ipdef_prj_dir   [file join $output_dir tmp $gen_ipdef_prj_name]
set edit_ip_prj_name    $core_full_name
set edit_ip_prj_dir     [file join $output_dir xbtest_catalog $edit_ip_prj_name]
set edit_ip_prj_xml     [file join $edit_ip_prj_dir component.xml]
set edit_ip_prj_src     [file join $edit_ip_prj_dir src]

create_project $gen_ipdef_prj_name $gen_ipdef_prj_dir
ipx::edit_ip_in_project -upgrade false -name $edit_ip_prj_name -directory $edit_ip_prj_dir $edit_ip_prj_xml

proc set_obj_property { prop val obj obj_desc } {
    set obj_prop [list_property $obj]
    if {[lsearch -nocase $obj_prop $prop] != -1} {
        common::send_msg_id {GEN_IPDEF-4} {INFO} "Set property $prop with value ($val) for $obj_desc"
        set_property $prop $val $obj
    }
}

# Set core property
set_obj_property core_revision 0 [ipx::current_core] "IP core"; # default
if {[dict exists $config component]} {
    foreach {property value} [dict get $config component] {
        set_obj_property $property $value [ipx::current_core] "IP core"
    }
}

proc copy_file_parents { src_dir src dst } {
    set src_file [file join $src_dir $src]
    if {![file exist $src_file]} {
        common::send_msg_id {GEN_IPDEF-5} {ERROR} "IP source file does not exist: $src_file"
    }
    set src_split [file split $src]
    set src_parents [lrange $src_split 0 end-1]
    set dst_tmp $dst
    foreach {parent} $src_parents {
        set dst_tmp [file join $dst_tmp $parent]
        file mkdir $dst_tmp
    }
    set dst_tmp [file join $dst_tmp [lindex $src_split end]]
    file copy -force $src_file $dst_tmp
    return $dst_tmp
}

proc open_file_parents { src opt } {
    set src_split [file split $src]
    set src_parents [lrange $src_split 0 end-1]
    set dst_tmp ""
    foreach {parent} $src_parents {
        set dst_tmp [file join $dst_tmp $parent]
        file mkdir $dst_tmp
    }
    set dst_tmp [file join $dst_tmp [lindex $src_split end]]
    set fp [open $dst_tmp $opt]
    return $fp
}

proc add_file_in_group { source_dir file_name edit_ip_prj_dir fg fg_name } {
    common::send_msg_id {GEN_IPDEF-6} {INFO} "Registering file $file_name to file group $fg_name"
    set file_cp [copy_file_parents $source_dir $file_name $edit_ip_prj_dir]
    return [ipx::add_file $file_cp $fg]
}

# Set file groups
if {[dict exists $config file_groups]} {
    set file_groups [dict get $config file_groups]
    foreach fg_name [lsort -dictionary [dict keys $file_groups]] {
        common::send_msg_id {GEN_IPDEF-7} {INFO} "Creating file group $fg_name"
        set fg_def [dict get $file_groups $fg_name]

        set fg [ipx::add_file_group -type $fg_name {} [ipx::current_core]]
        foreach {property value} $fg_def {
            set_obj_property $property $value $fg "file group $fg_name"
        }
        foreach {el} [dict get $fg_def files] {
            if {[llength $el] == 1} {
                set fi [add_file_in_group $source_dir $el $edit_ip_prj_dir $fg $fg_name]
            } else {
                foreach {file_name file_property} $el {
                    set fi [add_file_in_group $source_dir $file_name $edit_ip_prj_dir $fg $fg_name]
                    foreach {property value} $file_property {
                        set_obj_property $property $value $fi "file $file_name of file group $fg"
                    }
                }
            }
        }
    }
    ipx::merge_project_changes files [ipx::current_core]
}

# Get core_top_level
set core_top_level  {}
if {[dict exists $config build import_from_hdl core_top_level]} {
    set core_top_level [dict get $config build import_from_hdl core_top_level]
    set core_top_level [file join $source_dir $core_top_level]
}
# Get core_top_entity
set core_top_entity {}
if {[dict exists $config build import_from_hdl core_top_entity]} {
    set core_top_entity [dict get $config build import_from_hdl core_top_entity]
}

# Import model parameters from HDL
set import_hdlparams 0
if {[dict exists $config build import_from_hdl hdlparams]} {
    set import_hdlparams [dict get $config build import_from_hdl hdlparams]
}
if {($core_top_entity == {}) && ($import_hdlparams)} {
    set import_hdlparams 0
    common::send_msg_id {GEN_IPDEF-20} {WARNING} "Cannot import  model parameters from HDL as core_top_entity is not set"
}
if {($core_top_level == {}) && ($import_hdlparams)} {
    set import_hdlparams 0
    common::send_msg_id {GEN_IPDEF-20} {WARNING} "Cannot import  model parameters from HDL as core_top_level is not set"
}
if {$import_hdlparams} {
    common::send_msg_id {GEN_IPDEF-8} {INFO} "Importing model parameters from HDL top level module ($core_top_entity) in $core_top_level"
    ipx::add_model_parameters_from_hdl [ipx::current_core] -top_level_hdl_file $core_top_level -top_module_name $core_top_entity
}

# Import ports from HDL
set import_ports 0
if {[dict exists $config build import_from_hdl ports]} {
    set import_ports [dict get $config build import_from_hdl ports]
}
if {($core_top_level == {}) && ($import_ports)} {
    set import_ports 0
    common::send_msg_id {GEN_IPDEF-20} {WARNING} "Cannot import ports from HDL as core_top_level is not set"
}
if {($core_top_entity == {}) && ($import_ports)} {
    set import_ports 0
    common::send_msg_id {GEN_IPDEF-20} {WARNING} "Cannot import ports from HDL as core_top_entity is not set"
}
if {$import_ports} {
    common::send_msg_id {GEN_IPDEF-9} {INFO} "Importing ports from HDL top level module ($core_top_entity) in $core_top_level"
    ipx::add_ports_from_hdl [ipx::current_core] -top_level_hdl_file $core_top_level -top_module_name $core_top_entity
}

# Set user parameters
if {[dict exists $config user_parameters]} {
    set order 1

    # Add default component name
    set user_param_name Component_Name
    foreach {user_parameters_el} [dict get $config user_parameters] {
        set component_name_key [lsearch -nocase -inline [dict keys $user_parameters_el] $user_param_name]
    }
    if {$component_name_key == {}} {
        common::send_msg_id {GEN_IPDEF-10} {INFO} "Adding user parameter $user_param_name"
        set user_param [ipx::add_user_parameter $user_param_name [ipx::current_core]]
        set param [ipgui::add_param -name $user_param_name -component [ipx::current_core]]
        set_obj_property value_resolve_type user            $user_param "user parameter $user_param_name"
        set_obj_property value              $core_full_name $user_param "user parameter $user_param_name"
        set_obj_property order              $order          $user_param "user parameter $user_param_name"
        incr order
    }
    # Add user parameters
    foreach {user_parameters_el} [dict get $config user_parameters] {
        foreach {user_param_name user_param_prop} $user_parameters_el {
            common::send_msg_id {GEN_IPDEF-10} {INFO} "Adding user parameter $user_param_name"
            set user_param [ipx::add_user_parameter $user_param_name [ipx::current_core]]
            set param [ipgui::add_param -name $user_param_name -component [ipx::current_core]]
            ipgui::remove_param -component [ipx::current_core] $param
            # Add default value_resolve_type property
            set_obj_property value_resolve_type user $user_param "user parameter $user_param_name"
            # Add default order property
            if {[lsearch -nocase [dict keys $user_param_prop] order] == -1} {
                set_obj_property order $order $user_param "user parameter $user_param_name"
                incr order
            }
            # Handle value property for boolean parameters
            set value_format_key [lsearch -nocase -inline [dict keys $user_param_prop] value_format]
            if {$value_format_key != {}} {
                set value_format [dict get $user_param_prop $value_format_key]
                if {[string tolower $value_format] == "bool"} {
                    set value_key [lsearch -nocase -inline [dict keys $user_param_prop] value]
                    if {$value_key != {}} {
                        set value [dict get $user_param_prop $value_key]
                        dict set user_param_prop $value_key [expr {$value ? "true" : "false"}]
                    }
                }
            }
            # Handle other properties
            foreach {property value} $user_param_prop {
                set_obj_property $property $value $user_param "user parameter $user_param_name"
            }
            # Handle hdl parameter
            set hdl_param [ipx::get_hdl_parameters $user_param_name -of_objects [ipx::current_core]]
            if {$hdl_param != {}} {
                set value_key   [lsearch -nocase -inline [dict keys $user_param_prop] value]
                set value       [dict get $user_param_prop $value_key]

                set_obj_property value $value $hdl_param "hdl parameter $user_param_name"
            }
        }
    }
}

# Set bus interfaces
if {[dict exists $config bus_interfaces]} {
    foreach {bus_interfaces_el} [dict get $config bus_interfaces] {
        foreach {bus_if_name bus_if_def} $bus_interfaces_el {
            common::send_msg_id {GEN_IPDEF-11} {INFO} "Creating bus interface $bus_if_name"
            set bus_if [ipx::add_bus_interface $bus_if_name [ipx::current_core]]
            foreach {property value} $bus_if_def {
                set_obj_property $property $value $bus_if "bus interface $bus_if_name"
            }
            foreach {bus_parameters_el} [dict get $bus_if_def bus_parameters] {
                foreach {bus_param_name bus_param_prop} $bus_parameters_el {
                    common::send_msg_id {GEN_IPDEF-12} {INFO} "Adding bus parameter $bus_param_name to bus interface $bus_if_name"
                    set bus_param [ipx::add_bus_parameter $bus_param_name $bus_if]
                    foreach {property value} $bus_param_prop {
                        set_obj_property $property $value $bus_param "bus parameter $bus_param_name of bus interface $bus_if_name"
                    }
                }
            }
            set port_maps [dict get $bus_if_def port_maps]
            foreach port_name [lsort -dictionary [dict keys $port_maps]] {
                set physical_name [dict get $port_maps $port_name]
                common::send_msg_id {GEN_IPDEF-13} {INFO} "Configuring port map $port_name to physical $physical_name for bus interface $bus_if_name"
                set port_map [ipx::add_port_map $port_name $bus_if]
                set_obj_property physical_name $physical_name $port_map "port map $port_name of bus interface $bus_if_name"
            }
        }
    }
}

# Set address spaces
if {[dict exists $config address_spaces]} {
    foreach {address_spaces_el} [dict get $config address_spaces] {
        foreach {addr_space_name addr_space_def} $address_spaces_el {
            common::send_msg_id {GEN_IPDEF-14} {INFO} "Creating address space $addr_space_name"
            set addr_space [ipx::add_address_space $addr_space_name [ipx::current_core]]
            foreach {property value} $addr_space_def {
                set_obj_property $property $value $addr_space "address space $addr_space_name"
            }
        }
    }
}

# Set memory maps
if {[dict exists $config memory_maps]} {
    foreach {memory_maps_el} [dict get $config memory_maps] {
        foreach {mem_map_name mem_map_def} $memory_maps_el {
            common::send_msg_id {GEN_IPDEF-15} {INFO} "Creating memory map $mem_map_name"
            set mem_map [ipx::add_memory_map $mem_map_name [ipx::current_core]]
            foreach {property value} $mem_map_def {
                set_obj_property $property $value $mem_map "memory map $mem_map_name"
            }

            foreach {address_blocks_el} [dict get $mem_map_def address_blocks] {
                foreach {addr_block_name addr_block_prop} $address_blocks_el {
                    common::send_msg_id {GEN_IPDEF-16} {INFO} "Adding address block $addr_block_name to memory map $mem_map_name"
                    set addr_block [ipx::add_address_block $addr_block_name $mem_map]
                    foreach {property value} $addr_block_prop {
                        set_obj_property $property $value $addr_block "address block $addr_block_name of memory map $mem_map_name"
                    }
                    foreach {registers_el} [dict get $addr_block_prop registers] {
                        foreach {reg_name reg_prop} $registers_el {
                            common::send_msg_id {GEN_IPDEF-17} {INFO} "Adding register $reg_name to address block $addr_block_name"
                            set reg [ipx::add_register $reg_name $addr_block]
                            foreach {property value} $reg_prop {
                                set_obj_property $property $value $reg "register $reg_name of address block $addr_block_name"
                            }
                        }
                    }
                }
            }
        }
    }
}

common::send_msg_id {GEN_IPDEF-18} {INFO} "Save IP and clean project"
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete
close_project -delete
common::send_msg_id {GEN_IPDEF-19} {INFO} "Done!"