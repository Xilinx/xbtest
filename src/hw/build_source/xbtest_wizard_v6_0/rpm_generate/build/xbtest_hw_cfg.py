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

from pkg import *

def get_pkg_name(deploy):
    return 'xbtest-' + deploy
def get_pkg_version(major, minor):
    return str(major) + '.' + str(minor)
def get_pkg_summary(deploy):
    return 'xbtest-' + deploy + ' xbtest package'
def get_pkg_description(deploy, major, minor, build_date_short, pkg_release, dist_id, interface_uuid):
    description = []
    description += [ 'Xilinx Inc xbtest-' + deploy + ' v' + str(major) + '.' + str(minor) + ' xbtest package.' ]
    description += [ 'Built on ' + str(build_date_short) + '.' ]
    description += [ 'Built from source CL ' + str(pkg_release) + '.' ]
    description += [ 'Built with ' + dist_id]
    description += [ 'Requires interface UUID(s):' ]
    if interface_uuid is not None:
        description += [ '- ' + interface_uuid ]
    return '\n'.join(description)
def get_pkg_changelog(deploy, major, minor):
    return 'Release of xbtest xclbin package HW v' + str(major) + '.' + str(minor) + ' for deployment platform ' + deploy
def get_pkg_install_dir(deploy):
    return os.path.abspath(os.path.join(INSTALL_BASEDIR, 'lib', deploy))
def get_pkg_pre_inst_msg(deploy, install_dir):
    pre_inst_msg = []
    pre_inst_msg += [ '' ]
    pre_inst_msg += [ 'Installing xbtest-' + deploy + ' package in ${RPM_INSTALL_PREFIX}' + install_dir]
    pre_inst_msg += [ '' ]
    return '\n'.join(pre_inst_msg)
def get_pkg_post_inst_msg(deploy, install_dir):
    post_inst_msg = []
    post_inst_msg += [ '' ]
    post_inst_msg += [ 'xbtest-' + deploy + ' package installed successfully in ${RPM_INSTALL_PREFIX}' + install_dir ]
    post_inst_msg += [ '' ]
    return '\n'.join(post_inst_msg)