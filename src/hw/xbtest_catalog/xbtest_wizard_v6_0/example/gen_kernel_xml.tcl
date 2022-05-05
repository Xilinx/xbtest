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

proc gen_kernel_xml { config } {

    foreach {cu_cfg} [dict get $config cu_config] {

        set kernel_name             [dict get $cu_cfg kernel_name]
        set krnl_mode               [dict get $cu_cfg krnl_mode]
        log_message $config {GEN_KERNEL_XML-2} [list $kernel_name]; # Start

        set kernel_vendor           [dict get $config ip_vendor]
        set kernel_library          [dict get $config ip_library]
        set kernel_version_major    [dict get $config ip_version_major]
        set kernel_version_minor    [dict get $config ip_version_minor]
        set vlnv                    ${kernel_vendor}:${kernel_library}:${kernel_name}:${kernel_version_major}.${kernel_version_minor}

        set use_aie 0
        if {$krnl_mode == 0} {
            set use_aie [dict get $cu_cfg use_aie]
        }

        # Find axi ports
        set connection_indexes [list]
        foreach key [dict keys $cu_cfg sp_m*_axi] {
            regexp {sp_m0*([0-9]+)_axi} $key -> connection_idx
            lappend connection_indexes $connection_idx
        }
        set num_connections [llength $connection_indexes]

        set ports           {}
        set args            {}
        set id              0
        set offset          16
        set has_interrupt   true

        # Add memory mapped ports
        for {set i 0} {$i < $num_connections} {incr i} {
            set connection_idx  [lindex $connection_indexes $i]
            set port            [format {m%02d_axi} $connection_idx]
            lappend ports [subst {      <port name="$port" mode="master" range="0xFFFFFFFFFFFFFFFF" dataWidth="512" portType="addressable" base="0x0"/>}]
        }
        # Add stream ports for power CU
        if {$use_aie} {
            lappend ports {      <port name="m_axis_aie0" mode="write_only" dataWidth="128" portType="stream"/>}
            lappend ports {      <port name="s_axis_aie0" mode="read_only" dataWidth="128" portType="stream"/>}
        }
        # Add scalar arguments
        for {set i 0} {$i < 4} {incr i} {
            set name                [format {scalar%02d} $i]
            set offset              [format {0x%03x} $offset]

            lappend args [subst {      <arg id="$id" name="$name" type="uint" addressQualifier="0" port="s_axi_control" size="0x4" offset="$offset" hostSize="0x4" hostOffset="0x0"/>}]
            set offset [expr {$offset + 8}]
            incr id
        }
        # Add global memory arguments
        for {set i 0} {$i < $num_connections} {incr i} {
            set connection_idx      [lindex $connection_indexes $i]
            set name                [format {axi%02d_ptr0}  $connection_idx]
            set port                [format {m%02d_axi}     $connection_idx]
            set offset              [format {0x%03x}        $offset]

            lappend args [subst {      <arg id="$id" name="$name" type="int*" addressQualifier="1" port="$port" size="0x8" offset="$offset" hostSize="0x8" hostOffset="0x0"/>}]
            set offset [expr {$offset + 8}]
            incr id
        }
        if {$use_aie} {
            lappend args [subst {      <arg id="$id" name="arg_m_axis_aie0" type="stream" addressQualifier="4" port="m_axis_aie0" size="0x0" offset="0x0" hostSize="0x8" hostOffset="0x0" memSize="0x20" origName="arg_m_axis_aie0" origUse="variable"/>}]; incr id
            lappend args [subst {      <arg id="$id" name="arg_s_axis_aie0" type="stream" addressQualifier="4" port="s_axis_aie0" size="0x0" offset="0x0" hostSize="0x8" hostOffset="0x0" memSize="0x20" origName="arg_s_axis_aie0" origUse="variable"/>}]; incr id
        }

        # Output xml
        set KERNEL_XML [subst {<?xml version="1.0" encoding="UTF-8"?>
<root versionMajor="1" versionMinor="6">
  <kernel name="$kernel_name" language="ip_c" vlnv="$vlnv" attributes="" preferredWorkGroupSizeMultiple="0" workGroupSize="1" interrupt="$has_interrupt">
    <ports>
      <port name="s_axi_control" mode="slave" range="0x1000" dataWidth="32" portType="addressable" base="0x0"/>
[join $ports "\n"]
    </ports>
    <args>
[join $args "\n"]
    </args>
  </kernel>
</root>
}]

        write_file [dict get $cu_cfg kernel_xml] $KERNEL_XML
        log_message $config {GEN_KERNEL_XML-1} [list [dict get $cu_cfg kernel_xml]]; # End of generation
    }
}
