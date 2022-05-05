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

source_ipfile example/common.tcl
source_ipfile tcl/messages.tcl

proc init_gui { IPINST } {
    set_property show_ipsymbol false [ipgui::get_canvasspec -of $IPINST]

    set Component_Name [ipgui::add_param $IPINST -name "Component_Name"]
    set_property tooltip "The example project will be called <Component Name>_ex, otherwise this value is unused." $Component_Name

    set Static_Text   [ipgui::add_static_text $IPINST -name Static_Text -text "Customize wizard via TCL console before openning example design. See xbtest platform developer guide"]
}

proc init_params { IPINST } {
    # Make sure MESSAGES_DICT is updated before any other parameter
    set param_list {}
    lappend param_list "PARAM_VALUE.MESSAGES_DICT"
    ipgui::update_params -params_list $param_list $IPINST
}

proc init_meta_params {IPINST} {
  # Config metaparam stores loaded platforminfo
  add_meta_param $IPINST -name config -type string -value {Empty}
}

proc update_config { IPINST PARAM_VALUE.MESSAGES_DICT } {
    set MESSAGES_DICT [get_property VALUE ${PARAM_VALUE.MESSAGES_DICT}]
    set ret_val [dict create]
    dict set ret_val MESSAGES_DICT    $MESSAGES_DICT
    if {[string equal $MESSAGES_DICT {default}]} {
        dict set ret_val MESSAGES_DICT [load_messages_json]; # Set this for messages in example design
    }
    return "\{$ret_val\}"; # Need to add {} so that the dictionary can be returned.  Bug?
}

proc update_PARAM_VALUE.MESSAGES_DICT { IPINST PARAM_VALUE.MESSAGES_DICT } {
    set current_value [get_property VALUE ${PARAM_VALUE.MESSAGES_DICT}]
    if {[string equal $current_value {default}]} {
        set_property VALUE [load_messages_json] ${PARAM_VALUE.MESSAGES_DICT}; # Set this for messages in IP
    }
}
