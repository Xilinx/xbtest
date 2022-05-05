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

# Script that generates pre-canned tests

proc gen_pre_canned_file_path { config test } {
    return [file join [dict get $config pre_canned_dir] ${test}.json]
}

proc append_top_comment { TEST_JSON_REF TAB next } {
    upvar 1 $TEST_JSON_REF TEST_JSON
    set TAB_1 "  "
    lappend TEST_JSON "$TAB[string2json {comment}]: \["
    lappend TEST_JSON "$TAB$TAB_1[string2json {This is an example of test JSON file}],"
    lappend TEST_JSON "$TAB$TAB_1[string2json {You can use this example as template for your own tests}],"
    lappend TEST_JSON "$TAB$TAB_1[string2json {Please refer to the User Guide for how to define or add/remove testcases}],"
    lappend TEST_JSON "$TAB$TAB_1[string2json {Comments can be added or removed anywhere in test JSON file}]"
    lappend TEST_JSON "$TAB\]$next"
}

proc append_comment_1 { TEST_JSON_REF TAB next } {
    upvar 1 $TEST_JSON_REF TEST_JSON
    lappend TEST_JSON "$TAB[string2json {comment}]: [string2json {Use comment to detail your test if necessary (you can also remove this comment)}]$next"
}

############################################################################################################

proc gen_pre_canned_verify { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config

    set TAB_1 "  "

    set test    verify
    set file    [gen_pre_canned_file_path $config $test]

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {}
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned_power { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"

    set test    power
    set file    [gen_pre_canned_file_path $config $test]

    # Check is test applicable
    set is_power_cu false
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 0} {
            set is_power_cu true
        }
    }
    if {!$is_power_cu} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no power CU found"]; # n/a
        return
    }

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set duration 100
    set toggle_rates {5 10 15 20}

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    lappend TEST_JSON       "$TAB_2[string2json {power}]: \{"
    append_comment_1 TEST_JSON $TAB_3 {,}
    lappend TEST_JSON           "$TAB_3[string2json {global_config}]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {test_sequence}]: \["
    set ii      0
    set ii_max [expr [llength $toggle_rates] - 1]
    foreach toggle_rate $toggle_rates {
    lappend TEST_JSON                   "$TAB_5\{"
    lappend TEST_JSON                       "$TAB_6[string2json {duration}]: $duration,"
    lappend TEST_JSON                       "$TAB_6[string2json {toggle_rate}]: $toggle_rate"
        if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON                   "$TAB_5\}$next"
        incr ii
    }
    lappend TEST_JSON               "$TAB_4\]"
    lappend TEST_JSON           "$TAB_3\}"
    lappend TEST_JSON       "$TAB_2\}"
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned_memory { config_ref target } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"
    set TAB_7 "$TAB_6$TAB_1"

    set test memory
    if {$target == {host}} {
        set test ${test}_host
    }
    set file [gen_pre_canned_file_path $config $test]

    # Check is test applicable
    set memory_names {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 1} {
            set memory_name [dict get $cu_cfg memory_name]
            if {[dict get $cu_cfg target] == $target} {
                if {$memory_name ni $memory_names} {
                    lappend memory_names $memory_name
                }
            }
        }
    }

    if {$memory_names == {}} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no $target memory CU found"]; # n/a
        return
    }

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set duration 20
    set modes {alternate_wr_rd only_wr only_rd simultaneous_wr_rd}

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    lappend TEST_JSON       "$TAB_2[string2json {memory}]: \{"
    set ii      0
    set ii_max [expr [llength $memory_names] - 1]
    foreach memory_name $memory_names {
    lappend TEST_JSON           "$TAB_3[string2json $memory_name]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    append_comment_1 TEST_JSON $TAB_5 {,}
    lappend TEST_JSON                   "$TAB_5[string2json {test_sequence}]: \["
    set jj      0
    set jj_max [expr [llength $modes] - 1]
    foreach mode $modes {
    lappend TEST_JSON                       "$TAB_6\{"
    lappend TEST_JSON                           "$TAB_7[string2json {duration}]: $duration,"
    lappend TEST_JSON                           "$TAB_7[string2json {mode}]: [string2json $mode]"
        if {$jj < $jj_max} { set next "," } else { set next "" }
    lappend TEST_JSON                       "$TAB_6\}$next"
        incr jj
    }
    lappend TEST_JSON                   "$TAB_5\]"
    lappend TEST_JSON               "$TAB_4\}"
        if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON           "$TAB_3\}$next"
        incr ii
    }
    lappend TEST_JSON       "$TAB_2\}"
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned_dma { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"

    set test    dma
    set file    [gen_pre_canned_file_path $config $test]

    if {[dict get $config wizard_actual_config platform is_nodma]} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "targeting NoDMA platform"]; # n/a
        return
    }

    set target  board

    # Check is test applicable
    set memory_names {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 1} {
            set memory_name [dict get $cu_cfg memory_name]
            if {[dict get $cu_cfg target] == $target} {
                if {$memory_name ni $memory_names} {
                    lappend memory_names $memory_name
                }
            }
        }
    }

    if {$memory_names == {}} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no $target memory CU found"]; # n/a
        return
    }

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set duration 10

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    lappend TEST_JSON       "$TAB_2[string2json {dma}]: \{"
    lappend TEST_JSON           "$TAB_3[string2json {global_config}]: \{"
    append_comment_1 TEST_JSON $TAB_4 {,}
    lappend TEST_JSON               "$TAB_4[string2json {test_sequence}]: \["
    set ii      0
    set ii_max [expr [llength $memory_names] - 1]
    foreach memory_name $memory_names {
        if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON                   "$TAB_5\{"
    lappend TEST_JSON                       "$TAB_6[string2json {duration}]: $duration,"
    lappend TEST_JSON                       "$TAB_6[string2json {target}]: [string2json $memory_name]"
    lappend TEST_JSON                   "$TAB_5\}$next"
        incr ii
    }
    lappend TEST_JSON               "$TAB_4\]"
    lappend TEST_JSON           "$TAB_3\}"
    lappend TEST_JSON       "$TAB_2\}"
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned_p2p_card { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"

    set test    p2p_card
    set file    [gen_pre_canned_file_path $config $test]

    if {![dict get $config wizard_actual_config platform p2p_support]} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "platform does not support P2P"]; # n/a
        return
    }
    if {[dict get $config wizard_actual_config platform is_nodma]} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "targeting NoDMA platform"]; # n/a
        return
    }

    set target  board

    # Check is test applicable
    set memory_names {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 1} {
            set memory_name [dict get $cu_cfg memory_name]
            if {[dict get $cu_cfg target] == $target} {
                if {$memory_name ni $memory_names} {
                    lappend memory_names $memory_name
                }
            }
        }
    }

    if {$memory_names == {}} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no $target memory CU found"]; # n/a
        return
    }

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set duration 10

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    lappend TEST_JSON       "$TAB_2[string2json {p2p_card}]: \{"
    lappend TEST_JSON           "$TAB_3[string2json {global_config}]: \{"
    append_comment_1 TEST_JSON $TAB_4 {,}
    lappend TEST_JSON               "$TAB_4[string2json {test_sequence}]: \["
    set ii      0
    set ii_max [expr [llength $memory_names] - 1]
    foreach memory_name $memory_names {
        if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON                   "$TAB_5\{"
    lappend TEST_JSON                       "$TAB_6[string2json {duration}]: $duration,"
    lappend TEST_JSON                       "$TAB_6[string2json {source}]: [string2json $memory_name]"
    lappend TEST_JSON                   "$TAB_5\}$next"
        incr ii
    }
    lappend TEST_JSON               "$TAB_4\]"
    lappend TEST_JSON           "$TAB_3\}"
    lappend TEST_JSON       "$TAB_2\}"
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned_p2p_nvme { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"

    set test    p2p_nvme
    set file    [gen_pre_canned_file_path $config $test]

    if {![dict get $config wizard_actual_config platform p2p_support]} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "platform does not support P2P"]; # n/a
        return
    }

    set target  board

    # Check is test applicable
    set memory_names {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 1} {
            set memory_name [dict get $cu_cfg memory_name]
            if {[dict get $cu_cfg target] == $target} {
                if {$memory_name ni $memory_names} {
                    lappend memory_names $memory_name
                }
            }
        }
    }

    if {$memory_names == {}} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no $target memory CU found"]; # n/a
        return
    }

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set duration 10

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    lappend TEST_JSON       "$TAB_2[string2json {p2p_nvme}]: \{"
    lappend TEST_JSON           "$TAB_3[string2json {global_config}]: \{"
    append_comment_1 TEST_JSON $TAB_4 {,}
    lappend TEST_JSON               "$TAB_4[string2json {test_sequence}]: \["
    set ii      0
    set ii_max [expr [llength $memory_names] - 1]
    foreach memory_name $memory_names {
        if {$ii < $ii_max} { set next "," } else { set next "" }

            if {![dict get $config wizard_actual_config platform is_nodma]} {
    lappend TEST_JSON                   "$TAB_5\{"
    lappend TEST_JSON                       "$TAB_6[string2json {duration}]: $duration,"
    lappend TEST_JSON                       "$TAB_6[string2json {source}]: [string2json $memory_name]"
    lappend TEST_JSON                   "$TAB_5\},"
            }
    lappend TEST_JSON                   "$TAB_5\{"
    lappend TEST_JSON                       "$TAB_6[string2json {duration}]: $duration,"
    lappend TEST_JSON                       "$TAB_6[string2json {target}]: [string2json $memory_name]"
    lappend TEST_JSON                   "$TAB_5\}$next"
        incr ii
    }
    lappend TEST_JSON               "$TAB_4\]"
    lappend TEST_JSON           "$TAB_3\}"
    lappend TEST_JSON       "$TAB_2\}"
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned_gt_mac { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"
    set TAB_7 "$TAB_6$TAB_1"

    set test    gt_mac
    set file    [gen_pre_canned_file_path $config $test]

    # Check is test applicable
    set gt_macs {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 4} {
            set gt_idx [dict get $cu_cfg gt_idx]
            if {$gt_idx ni $gt_macs} {
                lappend gt_macs $gt_idx
            }
        }
    }
    if {$gt_macs == {}} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no GT_MAC CU found"]; # n/a
        return
    }

    set mac_addresses_available [dict_get_quiet $config {wizard_actual_config platform mac_addresses_available}]
    if {$mac_addresses_available != {default}} {
        if {$mac_addresses_available == 0} {
            log_message $config {GEN_PRE_CANNED-3} [list $test "no MAC address available"]; # n/a
            return
        } elseif {$mac_addresses_available < [llength $gt_macs]} {
            set num_gt $mac_addresses_available
            set gt_macs [lrange $gt_macs 0 [expr $num_gt - 1]]; # Needs at least 1 MAC address per GT, reduce number of GT used
        } elseif {$mac_addresses_available >= [expr [llength $gt_macs] * 4]} {
            set mac_addresses_available {default}; # Enough mac addresses for all lanes of all GTs, do not change the default behaviour
        }
    }
    set lanes_config {}; # default lane config
    if {$mac_addresses_available != {default}} {
        set addr_idx 0
        for {set lane_idx 0} {$lane_idx < 4} {incr lane_idx} {
            foreach gt_idx $gt_macs {
                set cfg {}
                if {$addr_idx < $mac_addresses_available} {
                    dict set cfg source_addr    board_mac_addr_$addr_idx; # Manually assign the board MAC address evenly between GTs
                } else {
                    set cfg {disable_lane true}; # disable lanes that cannot be assigned with mac address
                }
                dict set lanes_config $gt_idx $lane_idx $cfg
                incr addr_idx
            }
        }
    }

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start
    set durations_modes {1 conf_25gbe_c74_fec 1 clear_status 10 run 1 check_status 1 conf_10gbe_c74_fec 1 clear_status 10 run 1 check_status}

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    lappend TEST_JSON       "$TAB_2[string2json {gt_mac}]: \{"
    append_comment_1 TEST_JSON $TAB_3 {,}
    set ii      0
    set ii_max [expr [llength $gt_macs] - 1]
    foreach gt_idx $gt_macs {
    lappend TEST_JSON           "$TAB_3[string2json $gt_idx]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    lappend TEST_JSON                   "$TAB_5[string2json {match_tx_rx}]: true,"
    lappend TEST_JSON                   "$TAB_5[string2json {test_sequence}]: \["
        set jj      0
        set jj_max [expr [llength $durations_modes] / 2 - 1]
    foreach {duration mode} $durations_modes {
    lappend TEST_JSON                       "$TAB_6\{"
    lappend TEST_JSON                           "$TAB_7[string2json {duration}]: $duration,"
    lappend TEST_JSON                           "$TAB_7[string2json {mode}]: [string2json $mode]"
            if {$jj < $jj_max} { set next "," } else { set next "" }
    lappend TEST_JSON                       "$TAB_6\}$next"
            incr jj
        }
    lappend TEST_JSON                   "$TAB_5\]"
        if {$lanes_config != {}} { set next "," } else { set next "" }
    lappend TEST_JSON               "$TAB_4\}$next"
        if {$lanes_config != {}} {
    lappend TEST_JSON               "$TAB_4[string2json {lane_config}]: \{"
            set lane_config [dict get $lanes_config $gt_idx]
            set kk      0
            set kk_max [expr [llength [dict keys $lane_config]] - 1]
            foreach {lane_idx cfg} $lane_config {
    lappend TEST_JSON                   "$TAB_5[string2json $lane_idx]: \{"
                set ll      0
                set ll_max [expr [llength [dict keys $cfg]] - 1]
                foreach {key val} $cfg {
                    if {$ll < $ll_max} { set next "," } else { set next "" }
                    if {$key == {source_addr}} { set json_val [string2json $val] } else { set json_val $val }
    lappend TEST_JSON                       "$TAB_6[string2json $key]: $json_val$next"
                    incr ll
                }
                if {$kk < $kk_max} { set next "," } else { set next "" }
    lappend TEST_JSON                   "$TAB_5\}$next"
                incr kk
            }
    lappend TEST_JSON               "$TAB_4\}"
        }
        if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON           "$TAB_3\}$next"
        incr ii
    }
    lappend TEST_JSON       "$TAB_2\}"
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned_switch { config_ref rate } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config

    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"
    set TAB_7 "$TAB_6$TAB_1"

    if {($rate != {10gbe}) && ($rate != {25gbe})} {
        return
    }

    set test    switch_$rate
    set file    [gen_pre_canned_file_path $config $test]

    # Check is test applicable
    set gt_macs {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 4} {
            set gt_idx [dict get $cu_cfg gt_idx]
            if {$gt_idx ni $gt_macs} {
                lappend gt_macs $gt_idx
            }
        }
    }
    if {$gt_macs == {}} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no GT_MAC CU found"]; # n/a
        return
    }

    set mac_addresses_available [dict_get_quiet $config {wizard_actual_config platform mac_addresses_available}]
    if {$mac_addresses_available != {default}} {
        if {$mac_addresses_available == 0} {
            log_message $config {GEN_PRE_CANNED-3} [list $test "no MAC address available"]; # n/a
            return
        } elseif {$mac_addresses_available < [expr [llength $gt_macs] * 4]} {
            set num_pairs               [expr $mac_addresses_available / 2]
            set mac_addresses_available [expr $num_pairs * 2]
            if {$num_pairs == 0} {
                log_message $config {GEN_PRE_CANNED-3} [list $test "not enough MAC address available"]; # n/a
                return
            } elseif {$num_pairs < [llength $gt_macs]} {
                set gt_macs [lrange $gt_macs 0 [expr $num_pairs - 1]]; # Need at least 2 MAC address per GT, reduce number of GT used
            }
        } elseif {$mac_addresses_available >= [expr [llength $gt_macs] * 4]} {
            set mac_addresses_available {default}; # Enough mac addresses for all lanes of all GTs, do not change the default behaviour
        }
    }

    set lanes_config {}
    # default lane config
    foreach gt_idx $gt_macs {
        dict set lanes_config $gt_idx 0 {tx_mapping 1}
        dict set lanes_config $gt_idx 1 {tx_mapping 0}
        dict set lanes_config $gt_idx 2 {tx_mapping 3}
        dict set lanes_config $gt_idx 3 {tx_mapping 2}
    }
    if {$mac_addresses_available != {default}} {
        set addr_idx 0
        foreach gt_idx $gt_macs {
            for {set lane_idx 0} {$lane_idx < 2} {incr lane_idx} {
                set cfg [dict get $lanes_config $gt_idx $lane_idx]
                if {$addr_idx < $mac_addresses_available} {
                    dict set cfg source_addr board_mac_addr_$addr_idx; # Manually assign the board MAC address evenly between GTs
                } else {
                    set cfg {disable_lane true}; # disable lanes that cannot be assigned with mac address
                }
                dict set lanes_config $gt_idx $lane_idx $cfg
                incr addr_idx
            }
        }
        foreach gt_idx $gt_macs {
            for {set lane_idx 2} {$lane_idx < 4} {incr lane_idx} {
                set cfg [dict get $lanes_config $gt_idx $lane_idx]
                if {$addr_idx < $mac_addresses_available} {
                    dict set cfg source_addr board_mac_addr_$addr_idx; # Manually assign the board MAC address evenly between GTs
                } else {
                    set cfg {disable_lane true}; # disable lanes that cannot be assigned with mac address
                }
                dict set lanes_config $gt_idx $lane_idx $cfg
                incr addr_idx
            }
        }
    }

    if {$rate == {10gbe}} {
        set durations_modes {1 conf_10gbe_no_fec 1 clear_status 60 run 1 check_status}
    } elseif {$rate == {25gbe}} {
        set durations_modes {1 conf_25gbe_c74_fec 1 clear_status 60 run 1 check_status}
    }

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    lappend TEST_JSON       "$TAB_2[string2json {gt_mac}]: \{"
    append_comment_1 TEST_JSON $TAB_3 {,}
    set ii      0
    set ii_max [expr [llength $gt_macs] - 1]
    foreach gt_idx $gt_macs {
    lappend TEST_JSON           "$TAB_3[string2json $gt_idx]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    lappend TEST_JSON                   "$TAB_5[string2json {match_tx_rx}]: true,"
    lappend TEST_JSON                   "$TAB_5[string2json {test_sequence}]: \["
        set jj      0
        set jj_max [expr [llength $durations_modes] / 2 - 1]
        foreach {duration mode} $durations_modes {
    lappend TEST_JSON                       "$TAB_6\{"
    lappend TEST_JSON                           "$TAB_7[string2json {duration}]: $duration,"
    lappend TEST_JSON                           "$TAB_7[string2json {mode}]: [string2json $mode]"
            if {$jj < $jj_max} { set next "," } else { set next "" }
    lappend TEST_JSON                       "$TAB_6\}$next"
            incr jj
        }
    lappend TEST_JSON                   "$TAB_5\]"
        if {$lanes_config != {}} { set next "," } else { set next "" }
    lappend TEST_JSON               "$TAB_4\}$next"
        if {$lanes_config != {}} {
    lappend TEST_JSON               "$TAB_4[string2json {lane_config}]: \{"
            set lane_config [dict get $lanes_config $gt_idx]
            set kk      0
            set kk_max [expr [llength [dict keys $lane_config]] - 1]
            foreach {lane_idx cfg} $lane_config {
    lappend TEST_JSON                   "$TAB_5[string2json $lane_idx]: \{"
                set ll      0
                set ll_max [expr [llength [dict keys $cfg]] - 1]
                foreach {key val} $cfg {
                    if {$ll < $ll_max} { set next "," } else { set next "" }
                    if {$key == {source_addr}} { set json_val [string2json $val] } else { set json_val $val }
    lappend TEST_JSON                       "$TAB_6[string2json $key]: $json_val$next"
                    incr ll
                }
                if {$kk < $kk_max} { set next "," } else { set next "" }
    lappend TEST_JSON                   "$TAB_5\}$next"
                incr kk
            }
    lappend TEST_JSON               "$TAB_4\}"
        }
        if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON           "$TAB_3\}$next"
        incr ii
    }
    lappend TEST_JSON       "$TAB_2\}"
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned_gt_mac_port_to_port { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"
    set TAB_7 "$TAB_6$TAB_1"

    set test    gt_mac_port_to_port
    set file    [gen_pre_canned_file_path $config $test]

    # Check is test applicable
    set gt_macs {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 4} {
            set gt_idx [dict get $cu_cfg gt_idx]
            if {$gt_idx ni $gt_macs} {
                lappend gt_macs $gt_idx
            }
        }
    }
    if {[llength $gt_macs] < 2} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "number of GT_MAC CUs found is less than 2"]; # n/a
        return
    }

    # Only use 2 GT if more than 2 GT
    set gt_macs [lrange $gt_macs 0 1]
    set gt_mac_port_map {}
    dict set gt_mac_port_map [lindex $gt_macs 0] [lindex $gt_macs 1]

    set mac_addresses_available [dict_get_quiet $config {wizard_actual_config platform mac_addresses_available}]
    if {$mac_addresses_available != {default}} {
        if {$mac_addresses_available == 0} {
            log_message $config {GEN_PRE_CANNED-3} [list $test "no MAC address available"]; # n/a
            return
        } elseif {$mac_addresses_available < [expr [llength $gt_macs] * 4]} {
            set num_pairs               [expr $mac_addresses_available / 2]
            set mac_addresses_available [expr $num_pairs * 2]
            if {$num_pairs == 0} {
                log_message $config {GEN_PRE_CANNED-3} [list $test "not enough MAC address available"]; # n/a
                return
            }
        } elseif {$mac_addresses_available >= [expr [llength $gt_macs] * 4]} {
            set mac_addresses_available {default}; # Enough mac addresses for all lanes of all GTs, do not change the default behaviour
        }
    }

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set lanes_config {}
    if {$mac_addresses_available != {default}} {
        set addr_idx 0
        for {set lane_idx 0} {$lane_idx < 4} {incr lane_idx} {
            foreach gt_idx $gt_macs {
                set cfg {}
                if {$addr_idx < $mac_addresses_available} {
                    dict set cfg source_addr board_mac_addr_$addr_idx; # Manually assign the board MAC address evenly between GTs
                } else {
                    set cfg {disable_lane true}; # disable lanes that cannot be assigned with mac address
                }
                dict set lanes_config $gt_idx $lane_idx $cfg
                incr addr_idx
            }
        }
    }

    set durations_modes {1 conf_25gbe_c74_fec 1 clear_status 60 run 1 check_status}

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    lappend TEST_JSON       "$TAB_2[string2json {gt_mac}]: \{"
    append_comment_1 TEST_JSON $TAB_3 {,}
    set ii      0
    set ii_max [expr [llength [dict keys $gt_mac_port_map]] - 1]
    foreach {src dst} $gt_mac_port_map {
    lappend TEST_JSON           "$TAB_3[string2json $src]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    lappend TEST_JSON                   "$TAB_5[string2json {match_tx_rx}]: true,"
    lappend TEST_JSON                   "$TAB_5[string2json {test_sequence}]: \["
        set jj      0
        set jj_max [expr [llength $durations_modes] / 2 - 1]
        foreach {duration mode} $durations_modes {
    lappend TEST_JSON                       "$TAB_6\{"
    lappend TEST_JSON                           "$TAB_7[string2json {duration}]: $duration,"
    lappend TEST_JSON                           "$TAB_7[string2json {mode}]: [string2json $mode]"
            if {$jj < $jj_max} { set next "," } else { set next "" }
    lappend TEST_JSON                       "$TAB_6\}$next"
            incr jj
        }
    lappend TEST_JSON                   "$TAB_5\]"
        if {$lanes_config != {}} { set next "," } else { set next "" }
    lappend TEST_JSON               "$TAB_4\}$next"
        if {$lanes_config != {}} {
    lappend TEST_JSON               "$TAB_4[string2json {lane_config}]: \{"
            set lane_config [dict get $lanes_config $src]
            set kk      0
            set kk_max [expr [llength [dict keys $lane_config]] - 1]
            foreach {lane_idx cfg} $lane_config {
    lappend TEST_JSON                   "$TAB_5[string2json $lane_idx]: \{"
                set ll      0
                set ll_max [expr [llength [dict keys $cfg]] - 1]
                foreach {key val} $cfg {
                    if {$ll < $ll_max} { set next "," } else { set next "" }
                    if {$key == {source_addr}} { set json_val [string2json $val] } else { set json_val $val }
    lappend TEST_JSON                       "$TAB_6[string2json $key]: $json_val$next"
                    incr ll
                }
                if {$kk < $kk_max} { set next "," } else { set next "" }
    lappend TEST_JSON                   "$TAB_5\}$next"
                incr kk
            }
    lappend TEST_JSON               "$TAB_4\}"
        }
    lappend TEST_JSON           "$TAB_3\},"
    lappend TEST_JSON           "$TAB_3[string2json $dst]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    lappend TEST_JSON                   "$TAB_5[string2json {mac_to_mac_connection}]: $src"
        if {$lanes_config != {}} { set next "," } else { set next "" }
    lappend TEST_JSON               "$TAB_4\}$next"
        if {$lanes_config != {}} {
    lappend TEST_JSON               "$TAB_4[string2json {lane_config}]: \{"
            set lane_config [dict get $lanes_config $dst]
            set kk      0
            set kk_max [expr [llength [dict keys $lane_config]] - 1]
            foreach {lane_idx cfg} $lane_config {
    lappend TEST_JSON                   "$TAB_5[string2json $lane_idx]: \{"
                set ll      0
                set ll_max [expr [llength [dict keys $cfg]] - 1]
                foreach {key val} $cfg {
                    if {$ll < $ll_max} { set next "," } else { set next "" }
                    if {$key == {source_addr}} { set json_val [string2json $val] } else { set json_val $val }
    lappend TEST_JSON                       "$TAB_6[string2json $key]: $json_val$next"
                    incr ll
                }
                if {$kk < $kk_max} { set next "," } else { set next "" }
    lappend TEST_JSON                   "$TAB_5\}$next"
                incr kk
            }
    lappend TEST_JSON               "$TAB_4\}"
        }
        if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON           "$TAB_3\}$next"
        incr ii
    }
    lappend TEST_JSON       "$TAB_2\}"
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned_gt_mac_lpbk { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"
    set TAB_7 "$TAB_6$TAB_1"

    set test    gt_mac_lpbk
    set file    [gen_pre_canned_file_path $config $test]

    # Check is test applicable
    set gt_macs {}
    set gt_lpbks {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 3} {
            set gt_idx [dict get $cu_cfg gt_idx]
            if {$gt_idx ni $gt_lpbks} {
                lappend gt_lpbks $gt_idx
            }
        } elseif {[dict get $cu_cfg krnl_mode] == 4} {
            set gt_idx [dict get $cu_cfg gt_idx]
            if {$gt_idx ni $gt_macs} {
                lappend gt_macs $gt_idx
            }
        }
    }
    if {$gt_macs == {}} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no GT_MAC CU found"]; # n/a
        return
    }
    if {$gt_lpbks == {}} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no GT_LPBK CU found"]; # n/a
        return
    }

    # Only use 2 GT if more than 2 GT
    set gt_macs  [lindex $gt_macs 0]
    set gt_lpbks [lindex $gt_lpbks 0]

    set mac_addresses_available [dict_get_quiet $config {wizard_actual_config platform mac_addresses_available}]
    if {$mac_addresses_available != {default}} {
        if {$mac_addresses_available == 0} {
            log_message $config {GEN_PRE_CANNED-3} [list $test "no MAC address available"]; # n/a
            return
        } elseif {$mac_addresses_available < [llength $gt_macs]} {
            set num_gt $mac_addresses_available
            set gt_macs  [lrange $gt_macs  0 [expr $num_gt - 1]]; # Needs at least 1 MAC address per GT, reduce number of GT used
            set gt_lpbks [lrange $gt_lpbks 0 [expr $num_gt - 1]]; # Needs at least 1 MAC address per GT, reduce number of GT used
        } elseif {$mac_addresses_available >= [expr [llength $gt_macs] * 4]} {
            set mac_addresses_available {default}; # Enough mac addresses for all lanes of all GTs, do not change the default behaviour
        }
    }
    set lanes_config {}; # default lane config
    if {$mac_addresses_available != {default}} {
        set addr_idx 0
        for {set lane_idx 0} {$lane_idx < 4} {incr lane_idx} {
            foreach gt_idx $gt_macs {
                set cfg {}
                if {$addr_idx < $mac_addresses_available} {
                    dict set cfg source_addr    board_mac_addr_$addr_idx; # Manually assign the board MAC address evenly between GTs
                } else {
                    set cfg {disable_lane true}; # disable lanes that cannot be assigned with mac address
                }
                dict set lanes_config $gt_idx $lane_idx $cfg
                incr addr_idx
            }
        }
    }


    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set durations_modes {1 conf_25gbe_no_fec 1 clear_status 60 run 1 check_status}

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    lappend TEST_JSON       "$TAB_2[string2json {gt_mac}]: \{"
    append_comment_1 TEST_JSON $TAB_3 {,}
    set ii      0
    set ii_max [expr [llength $gt_macs] - 1]
    foreach gt_idx $gt_macs {
    lappend TEST_JSON           "$TAB_3[string2json $gt_idx]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    lappend TEST_JSON                   "$TAB_5[string2json {match_tx_rx}]: true,"
    lappend TEST_JSON                   "$TAB_5[string2json {test_sequence}]: \["
        set jj      0
        set jj_max [expr [llength $durations_modes] / 2 - 1]
        foreach {duration mode} $durations_modes {
    lappend TEST_JSON                       "$TAB_6\{"
    lappend TEST_JSON                           "$TAB_7[string2json {duration}]: $duration,"
    lappend TEST_JSON                           "$TAB_7[string2json {mode}]: [string2json $mode]"
            if {$jj < $jj_max} { set next "," } else { set next "" }
    lappend TEST_JSON                       "$TAB_6\}$next"
            incr jj
        }
    lappend TEST_JSON                   "$TAB_5\]"
        if {$lanes_config != {}} { set next "," } else { set next "" }
    lappend TEST_JSON               "$TAB_4\}$next"
        if {$lanes_config != {}} {
    lappend TEST_JSON               "$TAB_4[string2json {lane_config}]: \{"
            set lane_config [dict get $lanes_config $gt_idx]
            set kk      0
            set kk_max [expr [llength [dict keys $lane_config]] - 1]
            foreach {lane_idx cfg} $lane_config {
    lappend TEST_JSON                   "$TAB_5[string2json $lane_idx]: \{"
                set ll      0
                set ll_max [expr [llength [dict keys $cfg]] - 1]
                foreach {key val} $cfg {
                    if {$ll < $ll_max} { set next "," } else { set next "" }
                    if {$key == {source_addr}} { set json_val [string2json $val] } else { set json_val $val }
    lappend TEST_JSON                       "$TAB_6[string2json $key]: $json_val$next"
                    incr ll
                }
                if {$kk < $kk_max} { set next "," } else { set next "" }
    lappend TEST_JSON                   "$TAB_5\}$next"
                incr kk
            }
    lappend TEST_JSON               "$TAB_4\}"
        }
        if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON           "$TAB_3\}$next"
        incr ii
    }
    lappend TEST_JSON       "$TAB_2\},"


    set durations_modes {1 conf_25gbe_no_fec}

    lappend TEST_JSON       "$TAB_2[string2json {gt_lpbk}]: \{"
    append_comment_1 TEST_JSON $TAB_3 {,}
    set ii      0
    set ii_max [expr [llength $gt_lpbks] - 1]
    foreach gt_idx $gt_lpbks {
    lappend TEST_JSON           "$TAB_3[string2json $gt_idx]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    lappend TEST_JSON                   "$TAB_5[string2json {test_sequence}]: \["
        set jj      0
        set jj_max [expr [llength $durations_modes] / 2 - 1]
        foreach {duration mode} $durations_modes {
    lappend TEST_JSON                       "$TAB_6\{"
    lappend TEST_JSON                           "$TAB_7[string2json {duration}]: $duration,"
    lappend TEST_JSON                           "$TAB_7[string2json {mode}]: [string2json $mode]"
            if {$jj < $jj_max} { set next "," } else { set next "" }
    lappend TEST_JSON                       "$TAB_6\}$next"
            incr jj
        }
    lappend TEST_JSON                   "$TAB_5\]"
    lappend TEST_JSON               "$TAB_4\}"
        if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON           "$TAB_3\}$next"
        incr ii
    }
    lappend TEST_JSON       "$TAB_2\}"
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

proc gen_pre_canned_gt_prbs { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"
    set TAB_7 "$TAB_6$TAB_1"

    set test    gt_prbs
    set file    [gen_pre_canned_file_path $config $test]

    # Check is test applicable
    set gt_prbss {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 6} {
            set gt_idx [dict get $cu_cfg gt_idx]
            if {$gt_idx ni $gt_prbss} {
                lappend gt_prbss $gt_idx
            }
        }
    }
    if {$gt_prbss == {}} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no GT_PRBS CU found"]; # n/a
        return
    }

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set durations_modes {1 conf_25gbe 1 clear_status 60 run 1 check_status}

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    lappend TEST_JSON       "$TAB_2[string2json {gt_prbs}]: \{"
    append_comment_1 TEST_JSON $TAB_3 {,}
    set ii      0
    set ii_max [expr [llength $gt_prbss] - 1]
    foreach gt_idx $gt_prbss {
    lappend TEST_JSON           "$TAB_3[string2json $gt_idx]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    lappend TEST_JSON                   "$TAB_5[string2json {test_sequence}]: \["
        set jj      0
        set jj_max [expr [llength $durations_modes] / 2 - 1]
        foreach {duration mode} $durations_modes {
    lappend TEST_JSON                       "$TAB_6\{"
    lappend TEST_JSON                           "$TAB_7[string2json {duration}]: $duration,"
    lappend TEST_JSON                           "$TAB_7[string2json {mode}]: [string2json $mode]"
            if {$jj < $jj_max} { set next "," } else { set next "" }
    lappend TEST_JSON                       "$TAB_6\}$next"
            incr jj
        }
    lappend TEST_JSON                   "$TAB_5\]"
    lappend TEST_JSON               "$TAB_4\}"
        if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON           "$TAB_3\}$next"
        incr ii
    }
    lappend TEST_JSON       "$TAB_2\}"
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned_stress { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    set TAB_1 "  "
    set TAB_2 "$TAB_1$TAB_1"
    set TAB_3 "$TAB_2$TAB_1"
    set TAB_4 "$TAB_3$TAB_1"
    set TAB_5 "$TAB_4$TAB_1"
    set TAB_6 "$TAB_5$TAB_1"
    set TAB_7 "$TAB_6$TAB_1"

    set test    stress
    set file    [gen_pre_canned_file_path $config $test]

    set target  board

    # Check is test applicable
    set is_power_cu false
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 0} {
            set is_power_cu true
        }
    }

    set memory_names {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 1} {
            set memory_name [dict get $cu_cfg memory_name]
            if {[dict get $cu_cfg target] == $target} {
                if {$memory_name ni $memory_names} {
                    lappend memory_names $memory_name
                }
            }
        }
    }

    set gt_macs {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 4} {
            set gt_idx [dict get $cu_cfg gt_idx]
            if {$gt_idx ni $gt_macs} {
                lappend gt_macs $gt_idx
            }
        }
    }

    set mac_addresses_available [dict_get_quiet $config {wizard_actual_config platform mac_addresses_available}]
    if {$mac_addresses_available != {default}} {
        if {$mac_addresses_available == 0} {
            log_message $config {GEN_PRE_CANNED-3} [list $test "no MAC address available"]; # n/a
            return
        } elseif {$mac_addresses_available < [expr [llength $gt_macs] * 4]} {
            set num_pairs               [expr $mac_addresses_available / 2]
            set mac_addresses_available [expr $num_pairs * 2]
            if {$num_pairs == 0} {
                log_message $config {GEN_PRE_CANNED-3} [list $test "not enough MAC address available"]; # n/a
                return
            } elseif {$num_pairs < [llength $gt_macs]} {
                set gt_macs [lrange $gt_macs 0 [expr $num_pairs - 1]]; # Need at least 2 MAC address per GT, reduce number of GT used
            }
        } elseif {$mac_addresses_available >= [expr [llength $gt_macs] * 4]} {
            set mac_addresses_available {default}; # Enough mac addresses for all lanes of all GTs, do not change the default behaviour
        }
    }

    set lanes_config {}
    # default lane config
    foreach gt_idx $gt_macs {
        dict set lanes_config $gt_idx 0 {tx_mapping 1}
        dict set lanes_config $gt_idx 1 {tx_mapping 0}
        dict set lanes_config $gt_idx 2 {tx_mapping 3}
        dict set lanes_config $gt_idx 3 {tx_mapping 2}
    }
    if {$mac_addresses_available != {default}} {
        set addr_idx 0
        foreach gt_idx $gt_macs {
            for {set lane_idx 0} {$lane_idx < 2} {incr lane_idx} {
                set cfg [dict get $lanes_config $gt_idx $lane_idx]
                if {$addr_idx < $mac_addresses_available} {
                    dict set cfg source_addr board_mac_addr_$addr_idx; # Manually assign the board MAC address evenly between GTs
                } else {
                    set cfg {disable_lane true}; # disable lanes that cannot be assigned with mac address
                }
                dict set lanes_config $gt_idx $lane_idx $cfg
                incr addr_idx
            }
        }
        foreach gt_idx $gt_macs {
            for {set lane_idx 2} {$lane_idx < 4} {incr lane_idx} {
                set cfg [dict get $lanes_config $gt_idx $lane_idx]
                if {$addr_idx < $mac_addresses_available} {
                    dict set cfg source_addr board_mac_addr_$addr_idx; # Manually assign the board MAC address evenly between GTs
                } else {
                    set cfg {disable_lane true}; # disable lanes that cannot be assigned with mac address
                }
                dict set lanes_config $gt_idx $lane_idx $cfg
                incr addr_idx
            }
        }
    }

    set gt_prbss {}
    foreach cu_cfg [dict get $config cu_config] {
        if {[dict get $cu_cfg krnl_mode] == 6} {
            set gt_idx [dict get $cu_cfg gt_idx]
            if {$gt_idx ni $gt_prbss} {
                lappend gt_prbss $gt_idx
            }
        }
    }

    if {!$is_power_cu && ($memory_names == {}) && ($gt_macs == {}) && ($gt_prbss == {})} {
        log_message $config {GEN_PRE_CANNED-3} [list $test "no GT_MAC CU and no GT_PRBS CU and no board memory CU and no power CU found"]; # n/a
        return
    }

    log_message $config {GEN_PRE_CANNED-2} [list $test $file]; # Start

    set     TEST_JSON {}
    lappend TEST_JSON "\{"
    append_top_comment TEST_JSON $TAB_1 {,}
    lappend TEST_JSON "$TAB_1[string2json {testcases}]: \{"
    if {$is_power_cu} {
    lappend TEST_JSON       "$TAB_2[string2json {power}]: \{"
    lappend TEST_JSON           "$TAB_3[string2json {comment}]: [string2json {Update toggle rate according to your test environment}],"
    lappend TEST_JSON           "$TAB_3[string2json {global_config}]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {test_sequence}]: \["
    lappend TEST_JSON                   "$TAB_5\{"
    lappend TEST_JSON                       "$TAB_6[string2json {duration}]: 300,"
    lappend TEST_JSON                       "$TAB_6[string2json {toggle_rate}]: 10"
    lappend TEST_JSON                   "$TAB_5\}"
    lappend TEST_JSON               "$TAB_4\]"
    lappend TEST_JSON           "$TAB_3\}"
        if {([llength $memory_names] > 0) || ([llength $gt_macs] > 0) || ([llength $gt_prbss] > 0)} { set next "," } else { set next "" }
    lappend TEST_JSON       "$TAB_2\}$next"
    }

    if { [llength $memory_names] > 0} {
    lappend TEST_JSON       "$TAB_2[string2json {memory}]: \{"
        set ii      0
        set ii_max [expr [llength $memory_names] - 1]
        foreach memory_name $memory_names {
    lappend TEST_JSON           "$TAB_3[string2json $memory_name]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    append_comment_1 TEST_JSON $TAB_5 {,}
    lappend TEST_JSON                   "$TAB_5[string2json {test_sequence}]: \["
    lappend TEST_JSON                       "$TAB_6\{"
    lappend TEST_JSON                           "$TAB_7[string2json {duration}]: 300,"
    lappend TEST_JSON                           "$TAB_7[string2json {mode}]: [string2json {alternate_wr_rd}]"
    lappend TEST_JSON                       "$TAB_6\}"
    lappend TEST_JSON                   "$TAB_5\]"
    lappend TEST_JSON               "$TAB_4\}"
            if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON           "$TAB_3\}$next"
            incr ii
        }
        if {([llength $gt_macs] > 0) || ([llength $gt_prbss] > 0)} { set next "," } else { set next "" }
    lappend TEST_JSON       "$TAB_2\}$next"
    }


    if { [llength $gt_prbss] > 0} {
        set durations_modes {1 conf_25gbe 1 clear_status 300 run 1 check_status}

    lappend TEST_JSON       "$TAB_2[string2json {gt_prbs}]: \{"
    append_comment_1 TEST_JSON $TAB_3 {,}
        set ii      0
        set ii_max [expr [llength $gt_prbss] - 1]
        foreach gt_idx $gt_prbss {
    lappend TEST_JSON           "$TAB_3[string2json $gt_idx]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    lappend TEST_JSON                   "$TAB_5[string2json {test_sequence}]: \["
            set jj      0
            set jj_max [expr [llength $durations_modes] / 2 - 1]
            foreach {duration mode} $durations_modes {
    lappend TEST_JSON                       "$TAB_6\{"
    lappend TEST_JSON                           "$TAB_7[string2json {duration}]: $duration,"
    lappend TEST_JSON                           "$TAB_7[string2json {mode}]: [string2json $mode]"
            if {$jj < $jj_max} { set next "," } else { set next "" }
    lappend TEST_JSON                       "$TAB_6\}$next"
            incr jj
            }
    lappend TEST_JSON                   "$TAB_5\]"
    lappend TEST_JSON               "$TAB_4\}"
            if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON           "$TAB_3\}$next"
            incr ii
        }
        if {([llength $gt_macs] > 0)} { set next "," } else { set next "" }
    lappend TEST_JSON       "$TAB_2\}$next"
    }

    if { [llength $gt_macs] > 0} {

        set durations_modes {1 conf_25gbe_c74_fec 1 clear_status 300 run 1 check_status}

    lappend TEST_JSON       "$TAB_2[string2json {gt_mac}]: \{"
    append_comment_1 TEST_JSON $TAB_3 {,}
        set ii      0
        set ii_max [expr [llength $gt_macs] - 1]
        foreach gt_idx $gt_macs {
    lappend TEST_JSON           "$TAB_3[string2json $gt_idx]: \{"
    lappend TEST_JSON               "$TAB_4[string2json {global_config}]: \{"
    lappend TEST_JSON                   "$TAB_5[string2json {match_tx_rx}]: true,"
    lappend TEST_JSON                   "$TAB_5[string2json {test_sequence}]: \["
            set jj      0
            set jj_max [expr [llength $durations_modes] / 2 - 1]
            foreach {duration mode} $durations_modes {
    lappend TEST_JSON                       "$TAB_6\{"
    lappend TEST_JSON                           "$TAB_7[string2json {duration}]: $duration,"
    lappend TEST_JSON                           "$TAB_7[string2json {mode}]: [string2json $mode]"
                if {$jj < $jj_max} { set next "," } else { set next "" }
    lappend TEST_JSON                       "$TAB_6\}$next"
                incr jj
            }
    lappend TEST_JSON                   "$TAB_5\]"
            if {$lanes_config != {}} { set next "," } else { set next "" }
    lappend TEST_JSON               "$TAB_4\}$next"
            if {$lanes_config != {}} {
    lappend TEST_JSON               "$TAB_4[string2json {lane_config}]: \{"
                set lane_config [dict get $lanes_config $gt_idx]
                set kk      0
                set kk_max [expr [llength [dict keys $lane_config]] - 1]
                foreach {lane_idx cfg} $lane_config {
    lappend TEST_JSON                   "$TAB_5[string2json $lane_idx]: \{"
                    set ll      0
                    set ll_max [expr [llength [dict keys $cfg]] - 1]
                    foreach {key val} $cfg {
                        if {$ll < $ll_max} { set next "," } else { set next "" }
                        if {$key == {source_addr}} { set json_val [string2json $val] } else { set json_val $val }
    lappend TEST_JSON                       "$TAB_6[string2json $key]: $json_val$next"
                        incr ll
                    }
                    if {$kk < $kk_max} { set next "," } else { set next "" }
    lappend TEST_JSON                   "$TAB_5\}$next"
                    incr kk
                }
    lappend TEST_JSON               "$TAB_4\}"
            }
            if {$ii < $ii_max} { set next "," } else { set next "" }
    lappend TEST_JSON           "$TAB_3\}$next"
            incr ii
        }
    lappend TEST_JSON       "$TAB_2\}"
    }
    lappend TEST_JSON "$TAB_1\}"
    lappend TEST_JSON "\}"

    write_file $file [join $TEST_JSON "\n"]
    dict set config pre_canned $test $TEST_JSON
}

############################################################################################################

proc gen_pre_canned { config_ref } {
    # Dictionary passed as ref.
    upvar 1 $config_ref config
    log_message $config {GEN_PRE_CANNED-1}; # Start

    dict set config pre_canned {}

    gen_pre_canned_verify               config
    gen_pre_canned_power                config
    gen_pre_canned_memory               config board
    gen_pre_canned_memory               config host
    gen_pre_canned_dma                  config
    gen_pre_canned_p2p_card             config
    gen_pre_canned_p2p_nvme             config
    gen_pre_canned_gt_mac               config
    gen_pre_canned_switch               config {10gbe}
    gen_pre_canned_switch               config {25gbe}
    gen_pre_canned_gt_mac_port_to_port  config
    gen_pre_canned_gt_mac_lpbk          config
    gen_pre_canned_gt_prbs              config
    gen_pre_canned_stress               config
}
