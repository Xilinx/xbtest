#!/usr/bin/python3

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

import os
import sys

SCRIPT_VERSION = '1.0'
SCRIPT_FILE    = os.path.basename(__file__)
SCRIPT_DIR     = os.path.dirname(os.path.realpath(__file__))

BUILD_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, 'build'))
sys.path.insert(0, BUILD_DIR)

from pkg import *

class Options(object):
    def PrintVersion(self):
        log_info('GEN_RPM-5', 'Script ' + SCRIPT_FILE + ' version: ' + SCRIPT_VERSION)

    def printHelp(self):
        DEPLOY_NAME_EXAMPLE = 'xilinx-u50lv-gen3x4-xdma-base'
        DEPLOY_VERSION_EXAMPLE = '2'
        DEPENDENCY_EXAMPLE = 'for CentOS/Red Hat: "xilinx-u50lv-gen3x4-xdma-base=2-123456" or for Ubuntu: "xilinx-u50lv-gen3x4-xdma-base (= 2-123456)"'

        log_info('GEN_RPM-6', 'Usage: $ python3 ' + SCRIPT_FILE + ' [options]')
        log_info('GEN_RPM-6', '\t--help             / -h: Display this message')
        log_info('GEN_RPM-6', '\t--version          / -v: Display version')
        log_info('GEN_RPM-6', '\t--verbose          / -V: Turn on verbosity')
        log_info('GEN_RPM-6', '\t--force            / -f: Override output directory if already existing')
        log_info('GEN_RPM-6', '\t--include_dir      / -i: Include directory: location of files to be included in package (xclbin, xbtest_pfm_def.json and pre-canned test JSON files). Default ./include/<deploy_name>-<deploy_version>')
        log_info('GEN_RPM-6', '\t--output_dir       / -o: Path to the output directory. Default ./output/<date>_<time>/')
        log_info('GEN_RPM-6', '\t--pkg_release      / -r: Package release. Default ' + str(DEFAULT_PKG_RELEASE))
        log_info('GEN_RPM-6', '\t--deploy_name      / -n: Deployment platform name, e.g. ' + DEPLOY_NAME_EXAMPLE)
        log_info('GEN_RPM-6', '\t--deploy_version   / -m: Deployment platform version, e.g. ' + DEPLOY_VERSION_EXAMPLE)
        log_info('GEN_RPM-6', '\t--dependency       / -D: Dependendy of output package, e.g. ' + DEPENDENCY_EXAMPLE)
        log_info('GEN_RPM-6', 'Note: Generated xbtest package will be named: xbtest-<deploy_name>-<deploy_version> and will depend on package: <deploy_name> = <deploy_version>')
        log_info('GEN_RPM-6', 'Examples:')
        log_info('GEN_RPM-6', '\t python3 ' + SCRIPT_FILE + ' --deploy_name ' + DEPLOY_NAME_EXAMPLE + ' --deploy_version ' + DEPLOY_VERSION_EXAMPLE)

    def __init__(self):
        self.help = False
        self.version = False
        self.verbose = False
        self.force = False
        self.include_dir = None
        self.output_dir = None
        self.pkg_release = str(DEFAULT_PKG_RELEASE)
        self.deploy_name = None
        self.deploy_version = None
        self.dependency = []

    def getOptions(self, argv):
        log_info('GEN_RPM-49', 'Command line provided: $ ' + str(sys.executable) + ' ' + ' '.join(argv))
        try:
            options, remainder = getopt.gnu_getopt(
                argv[1:],
                'hvVfi:o:r:n:m:D:',
                [
                    'help',
                    'version',
                    'verbose',
                    'force',
                    'include_dir=',
                    'output_dir=',
                    'pkg_release=',
                    'deploy_name=',
                    'deploy_version=',
                    'dependency='
                ]
            )
        except getopt.GetoptError as e:
            self.printHelp()
            exit_error('GEN_RPM-1', str(e))

        log_info('GEN_RPM-50', 'Parsing command line options')
        for opt, arg in options:
            msg = '\t' + str(opt)
            if arg is not None:
                msg += ' ' + str(arg)
            log_info('GEN_RPM-50', msg)

            if opt in ('--help', '-h'):
                self.printHelp()
                self.help = True
            elif opt in ('--version', '-v'):
                self.PrintVersion()
                self.version = True
            elif opt in ('--verbose', '-V'):
                setup_verbose()
                self.verbose = True
            elif opt in ('--force', '-f'):
                self.force = True
            elif opt in ('--include_dir', '-i'):
                self.include_dir = str(arg)
                self.include_dir = os.path.abspath(self.include_dir)
            elif opt in ('--output_dir', '-o'):
                self.output_dir = str(arg)
                self.output_dir = os.path.abspath(self.output_dir)
            elif opt in ('--pkg_release', '-r'):
                self.pkg_release = str(arg)
            elif opt in ('--deploy_name', '-n'):
                self.deploy_name = str(arg)
            elif opt in ('--deploy_version', '-m'):
                self.deploy_version = str(arg)
            elif opt in ('--dependency', '-D'):
                self.dependency += [str(arg)]
            else:
                exit_error('GEN_RPM-2', 'Command line option not handled: ' + str(opt))

        if len(remainder) > 0:
            self.printHelp()
            exit_error('GEN_RPM-3', 'Unknown command line options: ' + ' '.join(remainder))

        if self.help or self.version:
            exit_info('GEN_RPM-4', 'Script terminating as help/version option provided')

        if self.deploy_name is None:
            exit_error('GEN_RPM-9', '--deploy_name option not provided')
        if self.deploy_version is None:
            exit_error('GEN_RPM-9', '--deploy_version option not provided')

        for dep in self.dependency:
            log_info('GEN_RPM-51', 'Dependency provided: ' + dep)


def calib_xbtest_pfm_def_mem(xbtest_pfm_def, mem_name, key3, key4, tc, param, unit):
    for k0 in xbtest_pfm_def.keys():
        l0 = k0.lower()
        if 'device' != l0:
            continue

        for k1 in xbtest_pfm_def[k0].keys():
            l1 = k1.lower()
            if 'memory' != l1:
                continue

            for mem_idx,mem_def in xbtest_pfm_def[k0][k1].items():
                name = None
                for k2 in mem_def.keys():
                    l2 = k2.lower()
                    if 'name' != l2:
                        continue

                    if mem_def[k2] != mem_name:
                        continue

                    name = mem_def[k2]

                if name is None:
                    continue

                for k3 in mem_def.keys():
                    l3 = k3.lower()
                    if key3 != l3:
                        continue

                    for k4 in mem_def[k3].keys():
                        l4 = k4.lower()
                        if key4 == l4:
                            return tc + ' ' + param + ' = ' + str(mem_def[k3][k4]) + unit
    return ''

def calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, mem_name, key3, key4, key5, key6, param, unit):
    for k0 in xbtest_pfm_def.keys():
        l0 = k0.lower()
        if 'device' != l0:
            continue

        for k1 in xbtest_pfm_def[k0].keys():
            l1 = k1.lower()
            if 'memory' != l1:
                continue

            for mem_idx,mem_def in xbtest_pfm_def[k0][k1].items():
                name = None
                for k2 in mem_def.keys():
                    l2 = k2.lower()
                    if 'name' != l2:
                        continue

                    if mem_def[k2] != mem_name:
                        continue

                    name = mem_def[k2]

                if name is None:
                    continue

                for k3 in mem_def.keys():
                    l3 = k3.lower()
                    if key3 != l3:
                        continue

                    for k4 in mem_def[k3].keys():
                        l4 = k4.lower()
                        if key4 != l4:
                            continue

                        for k5 in mem_def[k3][k4].keys():
                            l5 = k5.lower()
                            if key5 != l5:
                                continue

                            for k6 in mem_def[k3][k4][k5].keys():
                                l6 = k6.lower()
                                if key6 == l6:
                                    return param + ' = ' + str(mem_def[k3][k4][k5][k6]) + unit
    return ''

def main(args):
    opt = Options()
    opt.getOptions(args)

    try:
        #######################################################################################################
        # Start
        #######################################################################################################
        script_start_time = start('GEN_RPM-7', SCRIPT_FILE)

        deploy = opt.deploy_name + '-' + opt.deploy_version
        target = 'xbtest-' + deploy
        log_info('GEN_RPM-11', 'Using deployment platform: ' + deploy )

        #######################################################################################################
        # import_xbtest_cfg
        #######################################################################################################
        import xbtest_hw_cfg as xbtest_cfg

        #######################################################################################################
        # create_output_dir
        #######################################################################################################
        if opt.output_dir is not None:
            output_dir = opt.output_dir
        else:
            now = datetime.datetime.now()
            output_dir =        str(now.year)          + '-' + str(now.month).zfill(2)  + '-' + str(now.day).zfill(2)
            output_dir += '_' + str(now.hour).zfill(2) + '-' + str(now.minute).zfill(2) + '-' + str(now.second).zfill(2)
            output_dir = os.path.abspath(os.path.join(CWD, 'output', output_dir))

        if os.path.isdir(output_dir):
            if not opt.force:
                exit_error('GEN_RPM-12', 'Output directory already exists (see --force to override): ' + output_dir)
            else:
                log_info('GEN_RPM-47', 'Removing output directory already existing as --force option is provided: ' + output_dir)
                try:
                    shutil.rmtree(output_dir)
                except OSError as e:
                    exit_error('GEN_RPM-48', 'Failed to remove output directory: ' + output_dir + '. Exception caught: ' + str(e))

                if os.path.isdir(output_dir):
                    exit_error('GEN_RPM-48', 'Failed to remove output directory: ' + output_dir + '. Directory still exists')

        log_info('GEN_RPM-13', 'Creating output directory: ' + output_dir)
        os.makedirs(output_dir)
        setup_logfile(os.path.abspath(os.path.join(output_dir, os.path.splitext(SCRIPT_FILE)[0] + '.log')))

        os.chdir(output_dir)

        #######################################################################################################
        # get_setup: date, distribution ID
        #######################################################################################################
        build_date=get_date_long()
        build_date_short=get_date_short()

        # Get distribution_id
        step = 'get distribution ID'
        start_time = start_step('GEN_RPM-14', step)
        cmd = [ 'lsb_release', '-is']
        log_file_name = os.path.abspath(os.path.join(output_dir, 'lsb_release_is.log'))
        exec_step_cmd('GEN_RPM-15', step, cmd, log_file_name)
        log_file = open(log_file_name, mode='r')
        for line in log_file:
            distribution_id = line.split('\n')[0]
            break
        log_file.close()

        if distribution_id not in SUPPORTED_DIST_ID:
            exit_error('GEN_RPM-14', 'Invalid Distribution ID: ' + distribution_id + '. Supported values are ' + str(SUPPORTED_DIST_ID))

        end_step('GEN_RPM-16', start_time)

        log_info('GEN_RPM-15', 'System:')
        log_info('GEN_RPM-16', '\t - Distribution ID: ' + distribution_id)

        #######################################################################################################
        # get_include_dir
        #######################################################################################################
        if opt.include_dir is not None:
            include_dir = opt.include_dir
            log_debug('GEN_RPM-19', 'Using provided include_dir')
        else:
            include_dir = os.path.abspath(os.path.join(SCRIPT_DIR, 'include', deploy))
            log_debug('GEN_RPM-19', 'Using default include_dir')

        log_info('GEN_RPM-19', 'Using include_dir: ' + include_dir )

        if not os.path.isdir(include_dir):
            exit_error('GEN_RPM-17', 'Configuration directory does not exist: ' + include_dir)

        xclbin              = os.path.abspath(os.path.join(include_dir, 'xclbin', 'xbtest_stress.xclbin'))
        xbtest_pfm_def_json = os.path.abspath(os.path.join(include_dir, 'xbtest_pfm_def.json'))
        test_dir            = os.path.abspath(os.path.join(include_dir, 'test'))

        xclbin_modified_timestamp = os.path.getmtime(xclbin)

        if not os.path.isfile(xclbin):
            exit_error('GEN_RPM-18', 'xclbin does not exist: ' + xclbin)

        log_debug('GEN_RPM-19', 'Using xclbin: ' + xclbin )

        if not os.path.isfile(xbtest_pfm_def_json):
            user_xbtest_pfm_def = False
            xbtest_pfm_def_json = os.path.abspath(os.path.join(output_dir, 'xbtest_pfm_def.json'))
            log_info('GEN_RPM-41', 'Platform definition JSON file will be extracted from xclbin to: ' + xbtest_pfm_def_json)
        else:
            user_xbtest_pfm_def = True
            log_info('GEN_RPM-19', 'Using provided platform definition JSON file: ' + xbtest_pfm_def_json)

        if not os.path.isdir(test_dir):
            user_pre_canned = False
            test_dir = os.path.abspath(os.path.join(output_dir, 'test'))
            log_info('GEN_RPM-41', 'Pre-canned tests will be extracted from xclbin to: ' + test_dir)
            os.makedirs(test_dir)
        else:
            user_pre_canned = True
            log_info('GEN_RPM-19', 'Using provided pre-canned test directory: ' + test_dir)

        #######################################################################################################
        # extract_user_metadata
        #######################################################################################################
        step = 'extract user metadata from xclbin: ' + xclbin
        start_time = start_step('GEN_RPM-29', step)
        user_metadata_json = os.path.abspath(os.path.join(output_dir, 'user_metadata.json'))
        cmd = [
            'xclbinutil',
            '-i', xclbin ,
            '--dump-section', 'USER_METADATA:RAW:' + user_metadata_json
        ]
        log_file_name = os.path.abspath(os.path.join(output_dir, 'xclbinutil.log'))
        exec_step_cmd('GEN_RPM-20', step, cmd, log_file_name)

        USER_METADATA = json_load('GEN_RPM-44', 'user_metadata.json', user_metadata_json)

        end_step('GEN_RPM-23', start_time)

        #######################################################################################################
        # get_xbtest_pfm_def
        #######################################################################################################
        if not user_xbtest_pfm_def:
            log_info('GEN_RPM-42', 'Extract platform definition JSON file from xclbin')
            with open(xbtest_pfm_def_json, 'w') as outfile:
                json.dump(USER_METADATA[XBTEST_PFM_DEF], outfile, sort_keys=False, indent=2)

        log_debug('GEN_RPM-43', 'Check platform definition JSON file syntax: ' + xbtest_pfm_def_json)
        # Check JSON format by loading it
        xbtest_pfm_def = json_load('GEN_RPM-45', 'platform definition JSON file', xbtest_pfm_def_json)

        #######################################################################################################
        # get_pre_canned
        #######################################################################################################

        PRECANNED_TESTS = []
        if user_pre_canned:
            for root, dirs, files in os.walk(test_dir):
                for file in files:
                    if os.path.splitext(file)[1].lower() == '.json':
                        PRECANNED_TESTS += [ file ]
                break
        else:
            log_info('GEN_RPM-42', 'Extract pre-canned test JSON files from xclbin')
            for test, TEST_JSON in USER_METADATA[PRE_CANNED].items():
                log_debug('GEN_RPM-43', '\t - Extacting pre-canned test: ' + test)
                PRECANNED_TESTS += [ test + '.json' ]
                with open(os.path.abspath(os.path.join(test_dir, test + '.json')), 'w') as outfile:
                    json.dump(TEST_JSON, outfile, sort_keys=False, indent=2)


        verify_json = os.path.abspath(os.path.join(test_dir, 'verify.json'))
        if not os.path.isfile(verify_json):
            exit_error('GEN_RPM-18', 'Pre-canned test JSON file verify does not exist: ' + verify_json)

        log_debug('GEN_RPM-43', 'Check pre-canned test JSON files syntax')
        for precanned_test_json in PRECANNED_TESTS:
            log_debug('GEN_RPM-43', '\t - Checking ' + os.path.abspath(os.path.join(test_dir, precanned_test_json)))
            # Check JSON format by loading it
            TMP = json_load('GEN_RPM-46', 'pre-canned test JSON file', os.path.abspath(os.path.join(test_dir, precanned_test_json)))

        #######################################################################################################
        # get_version_uuid
        #######################################################################################################
        major = USER_METADATA[BUILD_INFO][XBTEST][VERSION][MAJOR]
        minor = USER_METADATA[BUILD_INFO][XBTEST][VERSION][MINOR]
        interface_uuid = None
        if INTERFACE_UUID in USER_METADATA[BUILD_INFO][BOARD].keys():
            interface_uuid  = USER_METADATA[BUILD_INFO][BOARD][INTERFACE_UUID]
        INTERNAL_RELEASE = USER_METADATA[BUILD_INFO][XBTEST][INTERNALRELEASE]

        log_info('GEN_RPM-22', target + ' info:')
        log_info('GEN_RPM-22', '\t - Major version: ' + str(major))
        log_info('GEN_RPM-22', '\t - Minor version: ' + str(minor))
        if interface_uuid is not None:
            log_info('GEN_RPM-22', '\t - Interface uuid: ' + interface_uuid)

        #######################################################################################################
        # get_pkg_metadata
        #######################################################################################################
        package = {}
        package[NAME]           = xbtest_cfg.get_pkg_name(deploy)
        package[VERSION]        = xbtest_cfg.get_pkg_version(major, minor)
        package[RELEASE]        = str(opt.pkg_release)
        if INTERNAL_RELEASE:
            package[RELEASE] += '.INTERNAL'
        package[SUMMARY]        = xbtest_cfg.get_pkg_summary(deploy)
        package[DESCRIPTION]    = xbtest_cfg.get_pkg_description(deploy, major, minor, build_date_short, opt.pkg_release, distribution_id, interface_uuid)
        if INTERNAL_RELEASE:
            package[DESCRIPTION] =  '**INTERNAL ** INTERNAL ** INTERNAL ** INTERNAL ** INTERNAL ** INTERNAL ** INTERNAL ** INTERNAL**' + '\n' \
                                    + package[DESCRIPTION] + '\n' \
                                    + '**INTERNAL ** INTERNAL ** INTERNAL ** INTERNAL ** INTERNAL ** INTERNAL ** INTERNAL ** INTERNAL**'
        package[CHANGELOG]      = xbtest_cfg.get_pkg_changelog(deploy, major, minor)
        package[INSTALL_DIR]    = xbtest_cfg.get_pkg_install_dir(deploy)
        package[PRE_INST_MSG]   = xbtest_cfg.get_pkg_pre_inst_msg(deploy, package[INSTALL_DIR])
        package[POST_INST_MSG]  = xbtest_cfg.get_pkg_post_inst_msg(deploy, package[INSTALL_DIR])

        log_info('GEN_RPM-24', target + ' package metadata:')
        for key, value in package.items():
            log_info('GEN_RPM-24', '\t- ' + key + ' : ' + str(value))

        #######################################################################################################
        # create_pkg_files: Create the file necessary to generate the packages
        #######################################################################################################
        if distribution_id in DIST_RPM:
            architecture = 'noarch'

            for dirname in ['BUILDROOT', 'RPMS', 'SOURCES', 'SPECS', 'SRPMS', 'BUILD']:
                dir = os.path.abspath(os.path.join(output_dir, dirname))
                os.makedirs(dir)
                os.chmod(dir, 493); # octal 0755

            dest_base = os.path.abspath(os.path.join(output_dir, 'BUILD'))

            #######################################################################################################
            # create_spec_file
            #######################################################################################################
            spec_file_name = os.path.abspath(os.path.join(output_dir, 'SPECS', 'specfile.spec'))
            log_info('GEN_RPM-25', 'Creating ' + target + ' spec file: ' + spec_file_name)

            SPEC_FILE = []
            SPEC_FILE += [ '' ]
            SPEC_FILE += [ '# Generated by xbtest ' + SCRIPT_FILE ]
            SPEC_FILE += [ '' ]
            SPEC_FILE += [ 'Name: ' + package[NAME] ]
            SPEC_FILE += [ 'Version: ' + package[VERSION] ]
            SPEC_FILE += [ 'Release: ' + package[RELEASE] ]
            SPEC_FILE += [ 'Vendor: Xilinx Inc' ]
            SPEC_FILE += [ 'License: Xilinx' ];
            SPEC_FILE += [ 'Summary: ' + package[SUMMARY] ]
            SPEC_FILE += [ 'BuildArchitectures: ' + architecture ]
            SPEC_FILE += [ 'Buildroot: %{_topdir}' ]
            SPEC_FILE += [ 'Requires: xbtest-sw-' + str(major) ]
            SPEC_FILE += [ 'Requires: ' + opt.deploy_name + ' = ' + opt.deploy_version ]
            SPEC_FILE += [ 'Requires: xrt' ]

            for dep in opt.dependency:
                SPEC_FILE += [ 'Requires: ' + dep ]

            SPEC_FILE += [ '' ]
            SPEC_FILE += [ '%description' ]
            SPEC_FILE += [ package[DESCRIPTION] ]
            SPEC_FILE += [ '' ]
            SPEC_FILE += [ '%pre' ]
            SPEC_FILE += [ 'echo -e "' + package[PRE_INST_MSG] + '"' ]
            SPEC_FILE += [ '' ]
            SPEC_FILE += [ '%post' ]
            SPEC_FILE += [ 'echo -e "' + package[POST_INST_MSG] + '"' ]
            SPEC_FILE += [ '' ]

            SPEC_FILE += [ '%install' ]
            SPEC_FILE += [ 'mkdir -p %{buildroot}' + package[INSTALL_DIR] + '/xclbin' ]
            SPEC_FILE += [ 'install -m 0644 xclbin/xbtest_stress.xclbin %{buildroot}' + package[INSTALL_DIR] + '/xclbin/xbtest_stress.xclbin' ]
            SPEC_FILE += [ 'install -m 0644 xbtest_pfm_def.json %{buildroot}' + package[INSTALL_DIR] + '/xbtest_pfm_def.json' ]
            SPEC_FILE += [ 'install -m 0644 config.json %{buildroot}' + package[INSTALL_DIR] + '/config.json' ]
            SPEC_FILE += [ 'install -m 0644 README.md %{buildroot}' + package[INSTALL_DIR] + '/README.md' ]
            SPEC_FILE += [ 'mkdir -p %{buildroot}' + package[INSTALL_DIR] + '/test' ]
            for precanned_test_json in PRECANNED_TESTS:
                SPEC_FILE += [ 'install -m 0644 test/'+ precanned_test_json + ' %{buildroot}' + package[INSTALL_DIR] + '/test/' + precanned_test_json ]
            SPEC_FILE += [ 'mkdir -p %{buildroot}' + package[INSTALL_DIR] + '/license' ]
            SPEC_FILE += [ 'install -m 0644 license/LICENSE     %{buildroot}' + package[INSTALL_DIR] + '/license/LICENSE' ]

            SPEC_FILE += [ '' ]
            SPEC_FILE += [ '%files' ]
            SPEC_FILE += [ '%defattr(-,root,root)' ]
            SPEC_FILE += [ INSTALL_BASEDIR ]
            SPEC_FILE += [ '' ]
            SPEC_FILE += [ '%changelog' ]
            SPEC_FILE += [ '* ' + build_date_short + ' Xilinx Inc <support@xilinx.com> - ' + package[VERSION] + '-' + package[RELEASE] ]
            SPEC_FILE += [ '- ' + package[CHANGELOG] ]

            with open(spec_file_name, mode='w') as outfile:
                outfile.write('\n'.join(SPEC_FILE))

        else:
            architecture = 'all'
            deb_name = package[NAME] + '_' + package[VERSION] + '-' + package[RELEASE] + '_' + architecture
            dest_base  = os.path.abspath(os.path.join(output_dir, deb_name))
            os.makedirs(dest_base)
            os.chmod(dest_base, 493); # octal 0755
            debian_dir = os.path.abspath(os.path.join(dest_base, 'DEBIAN'))
            os.makedirs(debian_dir)

            #######################################################################################################
            # create_control_file
            #######################################################################################################
            control_file_name = os.path.abspath(os.path.join(debian_dir, 'control'))
            log_info('GEN_RPM-26', 'Creating ' + target + ' control file: ' + control_file_name)

            # Replace \n with \n+SPACE to be compatible with deb package format
            package[DESCRIPTION] = package[DESCRIPTION].replace('\n', '\n ')

            CONTROL = []
            CONTROL += [ 'Package: ' + package[NAME] ]
            CONTROL += [ 'Architecture: ' + architecture]
            CONTROL += [ 'Version: ' + package[VERSION] + '-' + package[RELEASE] ]
            CONTROL += [ 'Priority: optional' ]
            CONTROL += [ 'Description: ' + package[DESCRIPTION] ]
            CONTROL += [ 'Maintainer: Xilinx Inc' ]
            CONTROL += [ 'Section: devel' ]
            depends = [
                'xbtest-sw-' + str(major),
                opt.deploy_name + ' (>= ' + opt.deploy_version + ')',
                opt.deploy_name + ' (<< ' + opt.deploy_version + '.~)',
                'xrt'
            ]
            for dep in opt.dependency:
                depends += [dep]

            CONTROL += [ 'Depends: ' + ', '.join(depends) ]
            CONTROL += [ '' ]

            with open(control_file_name, mode='w') as outfile:
                outfile.write('\n'.join(CONTROL))

            #######################################################################################################
            # create_preinst_file
            #######################################################################################################
            preinst_file_name = os.path.abspath(os.path.join(debian_dir, 'preinst'))
            log_info('GEN_RPM-27', 'Creating ' + target + ' preinst file: ' + preinst_file_name)

            PRE_INST = []
            PRE_INST += [ 'echo -e "' + package[PRE_INST_MSG] + '"' ]

            with open(preinst_file_name, mode='w') as outfile:
                outfile.write('\n'.join(PRE_INST))

            os.chmod(preinst_file_name, 509); # octal 775

            #######################################################################################################
            # create_postinst_file
            #######################################################################################################
            postinst_file_name = os.path.abspath(os.path.join(debian_dir, 'postinst'))
            log_info('GEN_RPM-28', 'Creating ' + target + ' postinst file: ' + postinst_file_name)

            POST_INST = []
            POST_INST += [ 'echo -e "' + package[POST_INST_MSG] + '"' ]

            with open(postinst_file_name, mode='w') as outfile:
                outfile.write('\n'.join(POST_INST))

            os.chmod(postinst_file_name, 509); # octal 775

            #######################################################################################################
            # create_changelog_file
            #######################################################################################################
            changelog_dir = dest_base
            for subdir in ['usr', 'share', 'doc', package[NAME]]:
                changelog_dir = os.path.abspath(os.path.join(changelog_dir, subdir))
                os.makedirs(changelog_dir)

            changelog_file_name = os.path.abspath(os.path.join(changelog_dir, 'changelog.Debian'))
            log_info('GEN_RPM-29', 'Creating ' + target + ' changelog file: ' + changelog_file_name)

            CHANGE_LOG = []
            CHANGE_LOG += [ '' ]
            CHANGE_LOG += [ package[NAME] + ' (' + package[VERSION] + '-' + package[RELEASE] + ') xilinx; urgency=medium' ]
            CHANGE_LOG += [ '' ]
            CHANGE_LOG += [ '  * ' + package[CHANGELOG] ]
            CHANGE_LOG += [ '' ]
            CHANGE_LOG += [ '-- Xilinx Inc <support@xilinx.com> ' + build_date_short + ' 00:00:00 +0000' ]
            CHANGE_LOG += [ '' ]
            CHANGE_LOG += [ '' ]
            CHANGE_LOG += [ '' ]

            with open(changelog_file_name, mode='w') as outfile:
                outfile.write('\n'.join(CHANGE_LOG))

            changelog_tar_name = os.path.abspath(os.path.join(changelog_dir, 'changelog.Debian.gz'))
            with tarfile.open(changelog_tar_name, "w:gz") as tar:
                tar.add(changelog_file_name)
            os.remove(changelog_file_name)

            # Set the dest_base for dpkg
            inst_dir_loc = ''
            tmp = package[INSTALL_DIR]
            while True:
                tmp = os.path.split(tmp)
                if tmp[1] == '':
                    break
                inst_dir_loc = os.path.join(tmp[1], inst_dir_loc)
                tmp = tmp[0]

            dest_base = os.path.abspath(os.path.join(dest_base, inst_dir_loc))

        #######################################################################################################
        # copy_pkg_files
        #######################################################################################################
        log_info('GEN_RPM-30', 'Copying packaged files')

        SRC_DEST_LIST = [
            {SRC: os.path.abspath(os.path.join(BUILD_DIR, 'license', 'LICENSE')),   DST: 'license'},
            {SRC: xclbin,                                                           DST: 'xclbin'},
            {SRC: xbtest_pfm_def_json,                                              DST: ''},
        ]
        for precanned_test_json in PRECANNED_TESTS:
            SRC_DEST_LIST += [
                {SRC: os.path.abspath(os.path.join(test_dir, precanned_test_json)),   DST: 'test'},
            ]

        for src_dest in SRC_DEST_LIST:
            src = src_dest[SRC]
            dst = dest_base
            if src_dest[DST] != '':
                dst = os.path.abspath(os.path.join(dst, src_dest[DST]))
            copy_source_file('GEN_RPM-31', src, dst)

        #######################################################################################################
        # extra_pkg_files
        #######################################################################################################
        # config.json
        config_json = os.path.abspath(os.path.join(dest_base, 'config.json'))
        log_info('GEN_RPM-32', 'Creating ' + config_json)
        with open(config_json, 'w') as outfile:
            json.dump(USER_METADATA, outfile, sort_keys=False, indent=2)


        # README.md
        README = []

        README += ['<!--']
        with open(os.path.abspath(os.path.join(BUILD_DIR, 'license', 'LICENSE'))) as f:
            README += f.read().splitlines()
        README += ['-->']

        README += ['']
        README += ['# Package info']
        README += ['']
        README += ['The following table presents xclbin package information:']
        README += ['']
        README += ['| Version | Release number | Architecture | Build date |']
        README += ['|---|---|---|---|']
        README += ['| ' + package[VERSION] + ' | ' + package[RELEASE] + ' | ' + architecture + ' | '  + build_date_short + ' |']
        README += ['']

        README += ['# Build info']
        README += ['']
        README += ['The following table presents xclbin build information:']
        README += ['']
        README += ['| Build number | Build date |']
        README += ['|---|---|']
        README += ['| ' + str(USER_METADATA[BUILD_INFO][XBTEST][BUILD]) + ' | ' + USER_METADATA[BUILD_INFO][XBTEST][DATE] + ' |']
        README += ['']
        README += ['# Development Platform']
        README += ['']
        README += ['The following table presents information on the development platform used to build the xclbin:']
        README += ['']
        README += ['| Name | Interface UUID |']
        README += ['|---|---|']
        README += ['| ' + USER_METADATA[BUILD_INFO][BOARD][NAME] + ' | ' + USER_METADATA[BUILD_INFO][BOARD][INTERFACE_UUID] + ' |']
        README += ['']

        README += ['# Pre-canned Tests']
        README += ['']
        README += ['The following pre-canned tests are included:']
        README += ['']
        for precanned_test_json in PRECANNED_TESTS:
            README += ['  * ' + os.path.splitext(os.path.basename(precanned_test_json))[0]  ]
        README += ['']


        GT_README_ARRAY = []

        for cu_idx,cu_def in USER_METADATA[DEFINITION][COMPUTE_UNITS].items():
            if MODE not in cu_def.keys():
                continue
            if cu_def[MODE] not in [3, 4, 6]:
                continue

            GT_README_ROW = {}
            GT_README_ROW['cu_name']        = ''
            GT_README_ROW['cu_location']    = ''
            GT_README_ROW['gt_idx']         = ''
            GT_README_ROW['gt']             = ''
            GT_README_ROW['gt_type']        = ''
            GT_README_ROW['cu_type']        = ''
            GT_README_ROW['group_select']   = ''
            GT_README_ROW['serial_port']    = ''
            GT_README_ROW['diff_clocks']    = ''
            GT_README_ROW['plram']          = ''

            if len(cu_def[CONNECTIVITY]) == 0:
                GT_README_ROW['plram'] = 'none'
            else:
                GT_README_ROW['plram'] = cu_def[CONNECTIVITY]['0']

            if NAME in cu_def.keys():
                GT_README_ROW['cu_name'] = cu_def[NAME]
            if SLR in cu_def.keys():
                GT_README_ROW['cu_location'] = 'SLR' + str(cu_def[SLR])

            if cu_def[MODE] == 3:
                GT_README_ROW['cu_type'] = 'LPBK'
            elif cu_def[MODE] == 4:
                GT_README_ROW['cu_type'] = 'MAC'
            elif cu_def[MODE] == 6:
                GT_README_ROW['cu_type'] = 'PRBS'

            if CU_TYPE_CONFIGURATION in cu_def.keys():
                if GT_INDEX in cu_def[CU_TYPE_CONFIGURATION].keys():
                    GT_README_ROW['gt_idx'] = str(cu_def[CU_TYPE_CONFIGURATION][GT_INDEX])
                    GT_README_ROW['gt']     = 'GT[' + str(GT_README_ROW['gt_idx']) + ']'

                    if GT in USER_METADATA[DEFINITION].keys():
                        for gt_idx,gt_def in USER_METADATA[DEFINITION][GT].items():
                            if gt_idx == GT_README_ROW['gt_idx']:

                                if GT_TYPE in gt_def.keys():
                                    GT_README_ROW['gt_type']        = gt_def[GT_TYPE]
                                if GT_GROUP_SELECT in gt_def.keys():
                                    GT_README_ROW['group_select']   = gt_def[GT_GROUP_SELECT]
                                if GT_SERIAL_PORT in gt_def.keys():
                                    GT_README_ROW['serial_port']    = gt_def[GT_SERIAL_PORT]
                                if GT_DIFF_CLOCKS in gt_def.keys():
                                    GT_README_ROW['diff_clocks']    = gt_def[GT_DIFF_CLOCKS]

            GT_README_ARRAY.append(GT_README_ROW)

        if len(GT_README_ARRAY) > 0:
            README += ['# GT']
            README += ['']
            README += ['The following table describes the GTs present in the xclbin:']
            README += ['']
            README += ['| CU Name | CU Location | GT | GT type | CU type | Group Select | Serial port | Differential clocks | CU PLRAM Connection |']
            README += ['|---|---|---|---|---|---|---|---|---|']
            for GT_README_ROW in GT_README_ARRAY:
                README += ['| '
                    + GT_README_ROW['cu_name']        + ' | '
                    + GT_README_ROW['cu_location']    + ' | '
                    + GT_README_ROW['gt']             + ' | '
                    + GT_README_ROW['gt_type']        + ' | '
                    + GT_README_ROW['cu_type']        + ' | '
                    + GT_README_ROW['group_select']   + ' | '
                    + GT_README_ROW['serial_port']    + ' | '
                    + GT_README_ROW['diff_clocks']    + ' | '
                    + GT_README_ROW['plram']          + ' |'
                ]
            README += ['']
            README += ['Check the documentation of your card for the location of the GT connectors.']
            README += ['']


        MEMORY_README_ARRAY = []

        for cu_idx,cu_def in USER_METADATA[DEFINITION][COMPUTE_UNITS].items():
            if MODE not in cu_def.keys():
                continue
            if cu_def[MODE] != 1:
                continue

            MEMORY_README_ROW = {}
            MEMORY_README_ROW['cu_name']        = ''
            MEMORY_README_ROW['cu_location']    = ''
            MEMORY_README_ROW['memory_name']    = ''
            MEMORY_README_ROW['memory_target']  = ''
            MEMORY_README_ROW['calibration']    = ''
            MEMORY_README_ROW['cu_type']        = ''
            MEMORY_README_ROW['axi_data_size']  = ''
            MEMORY_README_ROW['axi_threads']    = ''
            MEMORY_README_ROW['channels']       = ''
            MEMORY_README_ROW['plram']          = ''

            if len(cu_def[CONNECTIVITY]) == 0:
                MEMORY_README_ROW['plram'] = 'none'
            else:
                MEMORY_README_ROW['plram'] = cu_def[CONNECTIVITY]['0']
                channels = []
                for key,val in cu_def[CONNECTIVITY].items():
                    if key != '0':
                        channels += [val]
                if len(channels) > 0:
                    MEMORY_README_ROW['channels'] = ', '.join(channels)

            if NAME in cu_def.keys():
                MEMORY_README_ROW['cu_name'] = cu_def[NAME]
            if SLR in cu_def.keys():
                MEMORY_README_ROW['cu_location'] = 'SLR' + str(cu_def[SLR])

            if CU_TYPE_CONFIGURATION in cu_def.keys():
                if MEMORY_TYPE in cu_def[CU_TYPE_CONFIGURATION].keys():
                    MEMORY_README_ROW['memory_name']    = cu_def[CU_TYPE_CONFIGURATION][MEMORY_TYPE]

                    if MEMORY in USER_METADATA[DEFINITION].keys():
                        for mem_idx,mem_def in USER_METADATA[DEFINITION][MEMORY].items():
                            if mem_def[NAME] == MEMORY_README_ROW['memory_name']:
                                if TARGET in mem_def.keys():
                                    MEMORY_README_ROW['memory_target'] = mem_def[TARGET]
                                if TYPE in mem_def.keys():
                                    MEMORY_README_ROW['cu_type'] = mem_def[TYPE]
                                if AXI_DATA_SIZE in mem_def.keys():
                                    MEMORY_README_ROW['axi_data_size'] = str(mem_def[AXI_DATA_SIZE])
                                if NUM_AXI_THREAD in mem_def.keys():
                                    MEMORY_README_ROW['axi_threads'] = str(mem_def[NUM_AXI_THREAD])

                    calibration = []
                    tmp = calib_xbtest_pfm_def_mem(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'dma_config',         'buffer_size',  'DMA',      'buffer size',  ' MB')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'dma_config',         'total_size',   'DMA',      'total size',   ' MB')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'p2p_card_config',    'buffer_size',  'P2P_CARD', 'buffer size',  ' MB')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'p2p_card_config',    'total_size',   'P2P_CARD', 'total size',   ' MB')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'p2p_nvme_config',    'buffer_size',  'P2P_NVME', 'buffer size',  ' MB')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'p2p_nvme_config',    'total_size',   'P2P_NVME', 'total size',   ' MB')
                    if (tmp != ''): calibration += [tmp]

                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_rate', 'only_wr',      'write', 'nominal', 'only_wr rate',             ' %')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_rate', 'only_rd',      'read',  'nominal', 'only_rd rate',             ' %')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_rate', 'simul_wr_rd',  'write', 'nominal', 'simul_wr_rd write rate',   ' %')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_rate', 'simul_wr_rd',  'read',  'nominal', 'simul_wr_rd read rate',    ' %')
                    if (tmp != ''): calibration += [tmp]

                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_outstanding', 'only_wr',      'write', 'nominal', 'only_wr outstanding',             '')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_outstanding', 'only_rd',      'read',  'nominal', 'only_rd outstanding',             '')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_outstanding', 'simul_wr_rd',  'write', 'nominal', 'simul_wr_rd write outstanding',   '')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_outstanding', 'simul_wr_rd',  'read',  'nominal', 'simul_wr_rd read outstanding',    '')
                    if (tmp != ''): calibration += [tmp]

                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_burst_size', 'only_wr',      'write', 'nominal', 'only_wr burst size',             ' Bytes')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_burst_size', 'only_rd',      'read',  'nominal', 'only_rd burst size',             ' Bytes')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_burst_size', 'simul_wr_rd',  'write', 'nominal', 'simul_wr_rd write burst size',   ' Bytes')
                    if (tmp != ''): calibration += [tmp]
                    tmp = calib_xbtest_pfm_def_mem_cu(xbtest_pfm_def, MEMORY_README_ROW['memory_name'], 'cu_burst_size', 'simul_wr_rd',  'read',  'nominal', 'simul_wr_rd read burst size',    ' Bytes')
                    if (tmp != ''): calibration += [tmp]

                    if len(calibration) > 0:
                        MEMORY_README_ROW['calibration'] += ', '.join(calibration)


            MEMORY_README_ARRAY.append(MEMORY_README_ROW)

        if len(MEMORY_README_ARRAY) > 0:
            README += ['# Memory']
            README += ['']
            README += ['The following table describes the memories present in the xclbin:']
            README += ['']
            README += ['| CU Name | CU Location | Memory Name | Memory Target | Calibration | CU type | AXI data size (bits) | Number of AXI threads | CU Channel Connectivity | CU PLRAM Connection |']
            README += ['|---|---|---|---|---|---|---|---|---|---|']
            for MEMORY_README_ROW in MEMORY_README_ARRAY:
                README += ['| '
                    + MEMORY_README_ROW['cu_name']        + ' | '
                    + MEMORY_README_ROW['cu_location']    + ' | '
                    + MEMORY_README_ROW['memory_name']    + ' | '
                    + MEMORY_README_ROW['memory_target']  + ' | '
                    + MEMORY_README_ROW['calibration']    + ' | '
                    + MEMORY_README_ROW['cu_type']        + ' | '
                    + MEMORY_README_ROW['axi_data_size']  + ' | '
                    + MEMORY_README_ROW['axi_threads']    + ' | '
                    + MEMORY_README_ROW['channels']       + ' | '
                    + MEMORY_README_ROW['plram']          + ' |'
                ]
            README += ['']


        POWER_README_ARRAY = []

        for cu_idx,cu_def in USER_METADATA[DEFINITION][COMPUTE_UNITS].items():
            if MODE not in cu_def.keys():
                continue
            if cu_def[MODE] != 0:
                continue

            POWER_README_ROW = {}
            POWER_README_ROW['cu_name']        = ''
            POWER_README_ROW['cu_location']    = ''
            POWER_README_ROW['aie_support']    = ''
            POWER_README_ROW['throttle']       = ''
            POWER_README_ROW['plram']          = ''

            if len(cu_def[CONNECTIVITY]) == 0:
                POWER_README_ROW['plram'] = 'none'
            else:
                POWER_README_ROW['plram'] = cu_def[CONNECTIVITY]['0']

            if NAME in cu_def.keys():
                POWER_README_ROW['cu_name'] = cu_def[NAME]
            if SLR in cu_def.keys():
                POWER_README_ROW['cu_location'] = 'SLR' + str(cu_def[SLR])

            if CU_TYPE_CONFIGURATION in cu_def.keys():
                if THROTTLE_MODE in cu_def[CU_TYPE_CONFIGURATION].keys():
                    POWER_README_ROW['throttle']    = cu_def[CU_TYPE_CONFIGURATION][THROTTLE_MODE]

                if USE_AIE in cu_def[CU_TYPE_CONFIGURATION].keys():
                    if cu_def[CU_TYPE_CONFIGURATION][USE_AIE]:
                        POWER_README_ROW['aie_support'] = 'yes'
                    else:
                        POWER_README_ROW['aie_support'] = 'no'

            POWER_README_ARRAY.append(POWER_README_ROW)

        if len(POWER_README_ARRAY) > 0:
            README += ['# Power']
            README += ['']
            README += ['The following table describes the power CUs present in the xclbin:']
            README += ['']
            README += ['| CU Name | CU Location | AIE support | Throttle | CU PLRAM Connection |']
            README += ['|---|---|---|---|---|']
            for POWER_README_ROW in POWER_README_ARRAY:
                README += ['| '
                    + POWER_README_ROW['cu_name']        + ' | '
                    + POWER_README_ROW['cu_location']    + ' | '
                    + POWER_README_ROW['aie_support']    + ' | '
                    + POWER_README_ROW['throttle']       + ' | '
                    + POWER_README_ROW['plram']          + ' |'
                ]
            README += ['']


        VERIFY_README_ARRAY = []

        for cu_idx,cu_def in USER_METADATA[DEFINITION][COMPUTE_UNITS].items():
            if MODE not in cu_def.keys():
                continue
            if cu_def[MODE] != 5:
                continue

            VERIFY_README_ROW = {}
            VERIFY_README_ROW['cu_name']        = ''
            VERIFY_README_ROW['cu_location']    = ''
            VERIFY_README_ROW['dna_support']    = ''
            VERIFY_README_ROW['plram']          = ''

            if len(cu_def[CONNECTIVITY]) == 0:
                VERIFY_README_ROW['plram'] = 'none'
            else:
                VERIFY_README_ROW['plram'] = cu_def[CONNECTIVITY]['0']

            if NAME in cu_def.keys():
                VERIFY_README_ROW['cu_name'] = cu_def[NAME]
            if SLR in cu_def.keys():
                VERIFY_README_ROW['cu_location'] = 'SLR' + str(cu_def[SLR])

            if CU_TYPE_CONFIGURATION in cu_def.keys():
                if DNA_READ in cu_def[CU_TYPE_CONFIGURATION].keys():
                    if cu_def[CU_TYPE_CONFIGURATION][DNA_READ]:
                        VERIFY_README_ROW['dna_support'] = 'yes'
                    else:
                        VERIFY_README_ROW['dna_support'] = 'no'

            VERIFY_README_ARRAY.append(VERIFY_README_ROW)

        if len(VERIFY_README_ARRAY) > 0:
            README += ['# Verify']
            README += ['']
            README += ['The following table describes the verify CUs present in the xclbin:']
            README += ['']
            README += ['| CU Name | CU Location | DNA read support | CU PLRAM Connection |']
            README += ['|---|---|---|---|']
            for VERIFY_README_ROW in VERIFY_README_ARRAY:
                README += ['| '
                    + VERIFY_README_ROW['cu_name']        + ' | '
                    + VERIFY_README_ROW['cu_location']    + ' | '
                    + VERIFY_README_ROW['dna_support']    + ' | '
                    + VERIFY_README_ROW['plram']          + ' |'
                ]
            README += ['']

        README += ['# Clocks']
        README += ['']
        README += ['The following table describes the clock configuration of the CUs present in the xclbin:']
        README += ['']
        README += ['| Clock | Frequency (MHz) |']
        README += ['|---|---|']
        for clk_idx,clk_freq in USER_METADATA[DEFINITION][CLOCKS].items():
            README += ['| ' + clk_idx + ' | ' + str(clk_freq) + ' |']
        README += ['']
        README += ['']


        readme_md = os.path.abspath(os.path.join(dest_base, 'README.md'))
        log_info('GEN_RPM-32', 'Creating ' + readme_md)
        with open(readme_md, 'w') as outfile:
            outfile.write('\n'.join(README))

        #######################################################################################################
        # generate_pkg
        #######################################################################################################
        if distribution_id in DIST_RPM:
            step = 'generate RPM package'
            start_time = start_step('GEN_RPM-33', step)
            cmd = [
                'rpmbuild',
                '--verbose',
                '--define', '_topdir ' + output_dir,
                '-bb', spec_file_name
            ]
            log_file_name = os.path.abspath(os.path.join(output_dir, 'rpmbuild.log'))
            exec_step_cmd('GEN_RPM-34', step, cmd, log_file_name)
            end_step('GEN_RPM-35', start_time)

            pkg  = package[NAME] + '-' + package[VERSION] + '-' + package[RELEASE] + '.' + architecture
            src  = os.path.abspath(os.path.join(output_dir, 'RPMS', architecture, pkg + '.rpm'))
            dst  = os.path.abspath(os.path.join(CWD,                              pkg + '.rpm'))
        else:
            step = 'generate DEB package'
            start_time = start_step('GEN_RPM-36', step)
            cmd = [
                'dpkg-deb',
                '--build', deb_name
            ]
            log_file_name = os.path.abspath(os.path.join(output_dir, 'dpkg-deb.log'))
            exec_step_cmd('GEN_RPM-37', step, cmd, log_file_name)
            end_step('GEN_RPM-38', start_time)

            pkg = package[NAME] + '_' + package[VERSION] + '-' + package[RELEASE] + '_' + architecture
            src  = os.path.abspath(os.path.join(output_dir, pkg + '.deb'))
            dst  = os.path.abspath(os.path.join(CWD,        pkg + '.deb'))

        log_info('GEN_RPM-39', 'Package generated successfully: ' + src)
        log_info('GEN_RPM-40', 'Copy output package: ' + dst)
        shutil.copy(src, dst)

        # Check xclbin not too old
        xclbin_datetime =  datetime.datetime.fromtimestamp(xclbin_modified_timestamp)
        now = datetime.datetime.now()
        delta = now - xclbin_datetime
        if delta.days > datetime.timedelta(days=0).days:
            log_warning('GEN_RPM-52', 'The xclbin provided was built ' + str(delta.days) + ' days ago. Are you sure you are using the correct xclbin?')


        #######################################################################################################
        # Tear down
        #######################################################################################################
        tear_down('GEN_RPM-8', SCRIPT_FILE, script_start_time)

    except OSError as o:
        print(o)
        raise RuntimeError(o.errno)
    except AssertionError as a:
        print(a)
        raise RuntimeError(1)
    except Exception as e:
        print(e)
        raise RuntimeError(1)
    finally:
        print('')

    sys.exit(1)

if __name__ == '__main__':
    main(sys.argv)
