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
import glob

SCRIPT_VERSION = '1.0'
SCRIPT_FILE    = os.path.basename(__file__)
SCRIPT_DIR     = os.path.dirname(os.path.realpath(__file__))

BUILD_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, 'build'))
sys.path.insert(0, BUILD_DIR)

GEN_IP_CATALOG_PY = os.path.abspath(os.path.join(BUILD_DIR, 'gen_ip_catalog.py'))

from pkg import *

class Options(object):
    def PrintVersion(self):
        log_info('GEN_XCLBIN-5', 'Script ' + SCRIPT_FILE + ' version: ' + SCRIPT_VERSION)

    def printHelp(self):
        log_info('GEN_XCLBIN-6', 'Usage: $ python3 ' + SCRIPT_FILE + ' [options]')
        log_info('GEN_XCLBIN-6', '\t--help                 / -h: Display this message')
        log_info('GEN_XCLBIN-6', '\t--ip_catalog           / -c: Path to IP catalog. IP catalog is automatically generated if not supplied')
        log_info('GEN_XCLBIN-6', '\t--xpfm                 / -x: Path to platform XPFM. This can be a path to either: a .xpfm file or a .xsa file or a .rpm package containing .xfpm file (only if running on CentOS, RedHat or SUSE) or a .deb package containing .xfpm file (only if running on Ubuntu) or a directory containing a .xpfm file')
        log_info('GEN_XCLBIN-6', '\t--init                 / -I: Initialization of some workflow input products. In this mode --project_name defaults to "init" and --config_dir is optional (it should be provided if the platform is missing required metadata)')
        log_info('GEN_XCLBIN-6', '\t--config_dir           / -d: Path to the configuration directory containing wizard configuration JSON file (wizard_cfg.json), Vitis configuration (vvp_cfg), power floorplan configuration (pwr_cfg)')
        log_info('GEN_XCLBIN-6', '\t--project_name         / -p: Project name. This value should only contain alphanumeric characters: a-z, A-Z, 0-9 and _')
        log_info('GEN_XCLBIN-6', '\t--use_lsf              / -l: Run Vitis on LSF to generate xclbin with default LSF command: $ ' + DEFAULT_LSF_CMD)
        log_info('GEN_XCLBIN-6', '\t--lsf_cmd              / -L: Run Vitis on LSF to generate xclbin with LSF command provided as argument.')
        log_info('GEN_XCLBIN-6', '\t--wizard_config_name   / -n: Wizard configuration name. Must be defined in wizard configuration JSON file. Default: ' + DEFAULT_CONFIG_NAME)
        log_info('GEN_XCLBIN-6', '\t--output_dir           / -o: Path to the output directory. Default: ./output/<platform>/<project_name> where <platform> corresponds to xpfm filename')
        log_info('GEN_XCLBIN-6', '\t--verbose              / -V: Turn on verbosity')
        log_info('GEN_XCLBIN-6', '\t--force                / -f: Override output directory if already existing')
        log_info('GEN_XCLBIN-6', '\t--skip_xo_gen          / -Q: Skip XO and xclbin generation')
        log_info('GEN_XCLBIN-6', '\t--skip_xclbin_gen      / -q: Skip xclbin generation')
        log_info('GEN_XCLBIN-6', '\t--skip_dcp_gen         / -r: Skip DCP generation')
        log_info('GEN_XCLBIN-6', '\t--version              / -v: Display version')
        log_info('GEN_XCLBIN-6', '')
        log_info('GEN_XCLBIN-6', 'Examples:')
        log_info('GEN_XCLBIN-6', '\t- Initialization:')
        log_info('GEN_XCLBIN-6', '\t\t$ python3 ' + SCRIPT_FILE + ' --ip_catalog path/to/xbtest_catalog --xpfm path/to/your/platform.xpfm --init')
        log_info('GEN_XCLBIN-6', '\t- Generate xclbin with default wizard configuration name (' + DEFAULT_CONFIG_NAME + '):')
        log_info('GEN_XCLBIN-6', '\t\t$ python3 ' + SCRIPT_FILE + ' --ip_catalog path/to/xbtest_catalog --xpfm path/to/your/platform.xpfm --config_dir path/to/your/config_dir --project_name your_project_name')
        log_info('GEN_XCLBIN-6', '\t- Generate xclbin on LSF:')
        log_info('GEN_XCLBIN-6', '\t\t$ python3 ' + SCRIPT_FILE + ' --ip_catalog path/to/xbtest_catalog --xpfm path/to/your/platform.xpfm --config_dir path/to/your/config_dir --project_name your_project_name --use_lsf')

    def __init__(self):
        self.help = False
        self.version = False
        self.verbose = False
        self.force = False
        self.config_dir = None
        self.wizard_config_name = DEFAULT_CONFIG_NAME
        self.xpfm = None
        self.project_name = None
        self.output_dir = None
        self.ip_catalog = None
        self.skip_xo_gen = False
        self.skip_xclbin_gen = False
        self.skip_dcp_gen = False
        self.use_lsf = False
        self.lsf_cmd = None
        self.init = False

    def getOptions(self, argv):
        log_info('GEN_XCLBIN-62', 'Command line provided: $ ' + str(sys.executable) + ' ' + ' '.join(argv))
        try:
            options, remainder = getopt.gnu_getopt(
                argv[1:],
                'hvVfd:n:x:p:o:c:QqrlL:I',
                [
                    'help',
                    'version',
                    'verbose',
                    'force',
                    'config_dir=',
                    'wizard_config_name=',
                    'xpfm=',
                    'project_name=',
                    'output_dir=',
                    'ip_catalog=',
                    'skip_xo_gen',
                    'skip_xclbin_gen',
                    'skip_dcp_gen',
                    'use_lsf',
                    'lsf_cmd=',
                    'init'
                ]
            )
        except getopt.GetoptError as e:
            self.printHelp()
            exit_error('GEN_XCLBIN-1', str(e))

        log_info('GEN_XCLBIN-63', 'Parsing command line options')
        for opt, arg in options:
            msg = '\t' + str(opt)
            if arg is not None:
                msg += ' ' + str(arg)
            log_info('GEN_XCLBIN-63', msg)

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
            elif opt in ('--config_dir', '-d'):
                self.config_dir = str(arg)
                self.config_dir = os.path.abspath(self.config_dir)
            elif opt in ('--wizard_config_name', '-n'):
                self.wizard_config_name = str(arg)
            elif opt in ('--xpfm', '-x'):
                self.xpfm = str(arg)
                self.xpfm = os.path.abspath(self.xpfm)
            elif opt in ('--project_name', '-p'):
                self.project_name = str(arg)
            elif opt in ('--output_dir', '-o'):
                self.output_dir = str(arg)
                self.output_dir = os.path.abspath(self.output_dir)
            elif opt in ('--ip_catalog', '-c'):
                self.ip_catalog = str(arg)
                self.ip_catalog = os.path.abspath(self.ip_catalog)
            elif opt in ('--skip_xo_gen', '-Q'):
                self.skip_xo_gen = True
            elif opt in ('--skip_xclbin_gen', '-q'):
                self.skip_xclbin_gen = True
            elif opt in ('--skip_dcp_gen', '-r'):
                self.skip_dcp_gen = True
            elif opt in ('--use_lsf', '-l'):
                self.use_lsf = True
            elif opt in ('--lsf_cmd', '-L'):
                self.lsf_cmd = str(arg)
            elif opt in ('--init', '-I'):
                self.init = True
            else:
                exit_error('GEN_XCLBIN-2', 'Command line option not handled: ' + str(opt))

        if len(remainder) > 0:
            self.printHelp()
            exit_error('GEN_XCLBIN-3', 'Unknown command line options: ' + ' '.join(remainder))

        if self.help or self.version:
            exit_info('GEN_XCLBIN-4', 'Script terminating as help/version option provided')

        if not self.init and (self.config_dir is None):
            exit_error('GEN_XCLBIN-9', '--config_dir option not provided')

        if self.xpfm is None:
            exit_error('GEN_XCLBIN-10', '--xpfm option not provided')

        if self.project_name is None:
            if self.init:
                self.project_name = 'init'
                log_info('GEN_XCLBIN-52', 'Setting --project_name to default value (' + self.project_name + ') in --init mode')
            else:
                exit_error('GEN_XCLBIN-11', '--project_name option not provided')

        if self.skip_xclbin_gen and self.init:
            exit_error('GEN_XCLBIN-56', 'Command line option --skip_xclbin_gen option is not supported in --init mode')

        if self.skip_dcp_gen and not self.init:
            exit_error('GEN_XCLBIN-57', 'Command line option --skip_dcp_gen option is only supported in --init mode')

        if (re.match('^.*[^a-zA-Z0-9_].*$', self.project_name)):
            exit_error('GEN_XCLBIN-50', 'Invalid value (' + self.project_name + ') provided for --project_name option. It should contain only alphanumeric characters (A-Z,a-z,0-9 and _)')

        if self.use_lsf and self.lsf_cmd is None:
            self.lsf_cmd = DEFAULT_LSF_CMD

        if self.ip_catalog is None:
            if not os.path.isfile(GEN_IP_CATALOG_PY):
                exit_error('GEN_XCLBIN-93', 'Automatic generation of IP catalog not supported in this release. Please provide path to xbtest IP catalog using option --ip_catalog')

def gen_wizard_tcl(setup_cfg, ip_prop):
    WIZARD_TCL = []
    # Create project
    prj_name = 'tmp_wizard_prj'
    prj_dir  = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'tmp', prj_name))
    os.makedirs(prj_dir)

    part = None
    if BOARD in setup_cfg[PLATFORM_INFO]:
        if PART in setup_cfg[PLATFORM_INFO][BOARD]:
            part = setup_cfg[PLATFORM_INFO][BOARD][PART]
    if part is None:
        log_warning('GEN_XCLBIN-49', 'Part not found in platform metadata')
        WIZARD_TCL += [ 'create_project ' + prj_name + ' ' + prj_dir ]
    else:
        log_info('GEN_XCLBIN-49', 'Using part (' + part + ') found in platform metadata')
        WIZARD_TCL += [ 'create_project -part ' + part + ' ' + prj_name + ' ' + prj_dir ]
    # Set IP repository
    WIZARD_TCL += [ 'set_property  ip_repo_paths  ' + setup_cfg[IP_CATALOG] + ' [current_project]' ]
    WIZARD_TCL += [ 'update_ip_catalog' ]
    # Created xbtest_wizard IP and set its properties
    WIZARD_TCL += [ 'create_ip -name '        + setup_cfg[IP_INFO][NAME]  \
                           + ' -vendor '      + setup_cfg[IP_INFO][VENDOR]  \
                           + ' -library '     + setup_cfg[IP_INFO][LIBRARY] \
                           + ' -version '     + setup_cfg[IP_INFO][VERSION] \
                           + ' -module_name ' + setup_cfg[MODULE_NAME] \
    ]
    # Set xbtest_wizard IP properties
    WIZARD_TCL += [ 'set_property -dict [list \\' ]
    for prop_name in ip_prop.keys():
        WIZARD_TCL += [ '\tCONFIG.' + prop_name + ' {' + str(ip_prop[prop_name]) + '} \\' ]
    WIZARD_TCL += [ '] [get_ips ' + setup_cfg[MODULE_NAME] + ']' ]
    # Generate target
    xci_file = os.path.abspath(os.path.join(prj_dir, prj_name + '.srcs', 'sources_1', 'ip', setup_cfg[MODULE_NAME], setup_cfg[MODULE_NAME] + '.xci'))
    WIZARD_TCL += [ 'generate_target {instantiation_template} [get_files ' + xci_file + ']' ]
    WIZARD_TCL += [ 'update_compile_order -fileset sources_1' ]
    # Open IP Example Design
    WIZARD_TCL += [ 'open_example_project -verbose -force -in_process -dir ' + setup_cfg[OUTPUT_DIR] + ' [get_ips  ' + setup_cfg[MODULE_NAME] + ']' ]

    wizard_tcl = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'wizard.tcl'))
    with open(wizard_tcl, mode='w') as outfile:
        outfile.write('\n'.join(WIZARD_TCL))
    return wizard_tcl

def update_interface_uuid(setup_cfg, src_xclbin, dst_xclbin):
    #######################################################################################################
    # Extract user metadata
    #######################################################################################################
    step = 'extract user metadata from xclbin: ' + src_xclbin
    start_time = start_step('GEN_XCLBIN-78', step)
    user_metadata_json = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'user_metadata.json'))
    cmd = [
        'xclbinutil',
        '-i', src_xclbin,
        '--dump-section', 'USER_METADATA:RAW:' + user_metadata_json
    ]
    log_file_name = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'xclbinutil_dump_user_metadata.log'))
    exec_step_cmd('GEN_XCLBIN-79', step, cmd, log_file_name)

    USER_METADATA = json_load('GEN_XCLBIN-80', 'user_metadata.json', user_metadata_json)

    if USER_METADATA['build_info']['board']['interface_uuid'] != 'NOT DEFINED':
        log_debug('GEN_XCLBIN-81', 'Found interface UUID in user metadata: ' + USER_METADATA['build_info']['board']['interface_uuid'])
        return False

    end_step('GEN_XCLBIN-82', start_time)

    log_info('GEN_XCLBIN-83', 'Interface UUID is not defined in xclbin user metadata, try to set with value from xclbin partition metadata')

    #######################################################################################################
    # Extract partition metadata
    #######################################################################################################
    step = 'extract partition metadata from xclbin: ' + src_xclbin
    start_time = start_step('GEN_XCLBIN-84', step)
    partition_metadata_json = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'partition_metadata.json'))
    cmd = [
        'xclbinutil',
        '-i', src_xclbin,
        '--dump-section', 'PARTITION_METADATA:JSON:' + partition_metadata_json
    ]
    log_file_name = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'xclbinutil_dump_partition_metadata.log'))
    exec_step_cmd('GEN_XCLBIN-85', step, cmd, log_file_name)

    PARTITION_METADATA = json_load('GEN_XCLBIN-86', 'partition_metadata.json', partition_metadata_json)
    # "partition_metadata":
    # {
    #     "interfaces":
    #     [
    #         {
    #             "interface_uuid": "1bc7d707db36a1b5fb6a2de650465889"

    # Find interface UUID in partition metadata
    found = False
    if 'partition_metadata' in PARTITION_METADATA.keys():
        if 'interfaces' in PARTITION_METADATA['partition_metadata'].keys():
            if len(PARTITION_METADATA['partition_metadata']['interfaces']) > 0:
                if 'interface_uuid' in PARTITION_METADATA['partition_metadata']['interfaces'][0].keys():
                    interface_uuid = PARTITION_METADATA['partition_metadata']['interfaces'][0]['interface_uuid']
                    log_debug('GEN_XCLBIN-87', 'Found interface UUID in xclbin partition metadata: ' + interface_uuid)
                    USER_METADATA['build_info']['board']['interface_uuid'] = interface_uuid
                    found = True

    if not found:
        log_warning('GEN_XCLBIN-88', 'Interface UUID not found in xclbin partition metadata. Unable to set interface UUID in xclbin user metadata. To resolve this, define interface UUID in wizard_cfg.json and re-build xclbin')
        return False

    end_step('GEN_XCLBIN-89', start_time)

    #######################################################################################################
    # Update interface_uuid in xclbin user metadata
    #######################################################################################################
    step = 'update interface_uuid in xclbin user metadata: ' + dst_xclbin
    start_time = start_step('GEN_XCLBIN-90', step)

    with open(user_metadata_json, 'w') as outfile:
        json.dump(USER_METADATA, outfile, sort_keys=False, indent=2)

    cmd = [
        'xclbinutil',
        '-i', src_xclbin,
        '-o', dst_xclbin,
        '--replace-section', 'USER_METADATA:RAW:' + user_metadata_json
    ]
    log_file_name = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'xclbinutil_replace_user_metadata.log'))
    exec_step_cmd('GEN_XCLBIN-91', step, cmd, log_file_name)

    end_step('GEN_XCLBIN-92', start_time)
    return True


def main(args):
    #######################################################################################################
    # Parse command line options
    #######################################################################################################
    opt = Options()
    opt.getOptions(args)

    setup_cfg = {}
    setup_cfg[PROJECT_NAME] = opt.project_name
    setup_cfg[MODULE_NAME]  = 'u'

    try:
        #######################################################################################################
        # Start
        #######################################################################################################
        script_start_time = start('GEN_XCLBIN-7', SCRIPT_FILE)

        #######################################################################################################
        # Get platform name
        #######################################################################################################
        if os.path.isfile(opt.xpfm):
            platform = os.path.splitext(os.path.basename(opt.xpfm))[0]
        elif os.path.isdir(opt.xpfm):
            platform = os.path.basename(opt.xpfm)
        else:
            exit_error('GEN_XCLBIN-12', XPFM + ' not found: ' + opt.xpfm)

        log_debug('GEN_XCLBIN-13', 'Using provided ' + XPFM + ': ' + opt.xpfm)

        #######################################################################################################
        # Create output directory
        #######################################################################################################
        if opt.output_dir is not None:
            setup_cfg[OUTPUT_DIR] = opt.output_dir
        else:
            setup_cfg[OUTPUT_DIR] = os.path.abspath(os.path.join(CWD, 'output', platform, setup_cfg[PROJECT_NAME]))

        if os.path.isdir(setup_cfg[OUTPUT_DIR]):
            if not opt.force:
                exit_error('GEN_XCLBIN-17', OUTPUT_DIR + ' already exists (see --force to override): ' + setup_cfg[OUTPUT_DIR])
            else:
                log_info('GEN_XCLBIN-60', 'Removing ' + OUTPUT_DIR + ' already existing as --force option is provided: ' + setup_cfg[OUTPUT_DIR])
                try:
                    shutil.rmtree(setup_cfg[OUTPUT_DIR])
                except OSError as e:
                    exit_error('GEN_XCLBIN-61', 'Failed to remove ' + OUTPUT_DIR + ': ' + setup_cfg[OUTPUT_DIR] + '. Exception caught: ' + str(e))

                if os.path.isdir(setup_cfg[OUTPUT_DIR]):
                    exit_error('GEN_XCLBIN-61', 'Failed to remove ' + OUTPUT_DIR + ': ' + setup_cfg[OUTPUT_DIR] + '. Directory still exists')

        log_info('GEN_XCLBIN-18', 'Creating ' + OUTPUT_DIR + ': ' + setup_cfg[OUTPUT_DIR])
        os.makedirs(setup_cfg[OUTPUT_DIR])
        setup_logfile(os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], os.path.splitext(SCRIPT_FILE)[0] + '.log')))

        #######################################################################################################
        # Get platform XPFM
        #######################################################################################################
        step = 'get platform XPFM'
        start_time = start_step('GEN_XCLBIN-66', step)

        setup_cfg[XPFM] = None
        xpfm_ext = None

        if os.path.isdir(opt.xpfm):
            xpfm_dir = opt.xpfm
        elif os.path.isfile(opt.xpfm):
            #######################################################################################################
            # Get file extension
            #######################################################################################################
            xpfm_ext = os.path.splitext(os.path.basename(opt.xpfm))[1].lower()

            # Check extension of provided xpfm file
            if xpfm_ext not in SUPPORTED_XPFM_EXT:
                exit_error('GEN_XCLBIN-67', 'Unsupported ' + XPFM + ' file extension ' + xpfm_ext + ' (supported: ' + str(SUPPORTED_XPFM_EXT) + '): ' + opt.xpfm)

            if xpfm_ext in ['.xpfm', '.xsa']:
                xpfm_dir = os.path.dirname(opt.xpfm)
                setup_cfg[XPFM] = opt.xpfm
            else:
                #######################################################################################################
                # Get distribution ID
                #######################################################################################################
                cmd = [ 'lsb_release', '-is']
                log_file_name = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'lsb_release_is.log'))
                exec_step_cmd('GEN_XCLBIN-68', step, cmd, log_file_name=log_file_name)
                log_file = open(log_file_name, mode='r')
                for line in log_file:
                    distribution_id = line.split('\n')[0]
                    break
                log_file.close()
                # Check distribution ID v. development package extension
                if xpfm_ext == '.rpm':
                    SUPPORTED_DIST_ID = [DIST_ID_CENTOS, DIST_ID_REDHAT, DIST_ID_SLES]
                elif xpfm_ext == '.deb':
                    SUPPORTED_DIST_ID = [DIST_ID_UBUNTU]
                if distribution_id not in SUPPORTED_DIST_ID:
                    exit_error('GEN_XCLBIN-69', 'Unable to extract ' + XPFM + ' ' + xpfm_ext + ' file on ' + distribution_id + ': ' + opt.xpfm)
                log_info('GEN_XCLBIN-70', 'Running on distribution: ' + distribution_id)

                #######################################################################################################
                # Extract development package
                #######################################################################################################
                log_debug('GEN_XCLBIN-71', 'Extract provided ' + XPFM + ' package: ' + opt.xpfm)

                xpfm_dir = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'xsa'))
                if xpfm_ext == '.rpm':
                    os.makedirs(xpfm_dir)
                    os.chdir(xpfm_dir)
                    cmd = ['rpm2cpio', opt.xpfm, '|', 'cpio', '-idmv']
                    log_file_name = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'rpm2cpio_cpio_idmv.log'))
                    exec_step_cmd('GEN_XCLBIN-72', step, ' '.join(cmd), log_file_name=log_file_name, shell=True)
                elif xpfm_ext == '.deb':
                    cmd = ['dpkg-deb', '-X', opt.xpfm, xpfm_dir]
                    log_file_name = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'dpkg_deb_X.log'))
                    exec_step_cmd('GEN_XCLBIN-73', step, cmd, log_file_name=log_file_name)

        if setup_cfg[XPFM] is None:
            #######################################################################################################
            # Find .xpfm in directory
            #######################################################################################################
            xpfm_files = []
            xpfm_ext = '.xpfm'
            for dir,_,_ in os.walk(xpfm_dir):
                xpfm_files = glob.glob(os.path.join(dir,'*'+xpfm_ext))
                if (len(xpfm_files) > 0):
                    break

            if (len(xpfm_files) > 0):
                log_debug('GEN_XCLBIN-74', 'Found ' + XPFM + ' files: ' + str(xpfm_files))
                setup_cfg[XPFM] = xpfm_files[0]
            else:
                exit_error('GEN_XCLBIN-75', XPFM + ' not found in directory: ' + xpfm_dir)

        log_debug('GEN_XCLBIN-76', 'Found ' + XPFM + ': ' + setup_cfg[XPFM])
        end_step('GEN_XCLBIN-77', start_time)

        config_dir = None
        if opt.config_dir is not None:
            #######################################################################################################
            # Load wizard configuration JSON file
            #######################################################################################################
            config_dir = opt.config_dir
            if not os.path.isdir(config_dir):
                exit_error('GEN_XCLBIN-14', 'Configuration directory (provided with --config_dir) does not exist: ' + config_dir)

            wizard_cfg_file = os.path.abspath(os.path.join(config_dir, 'wizard_cfg.json'))
            if not os.path.isfile(wizard_cfg_file):
                exit_error('GEN_XCLBIN-14', WIZARD_CONFIG_JSON + ' does not exist: ' + wizard_cfg_file)

            log_debug('GEN_XCLBIN-15', 'Loading ' + WIZARD_CONFIG_JSON + ': ' + wizard_cfg_file)
            wizard_cfg = json_load('GEN_XCLBIN-58', WIZARD_CONFIG_JSON, wizard_cfg_file)

            if not opt.init:
                #######################################################################################################
                # Check provided wizard configuration name
                #######################################################################################################
                if (opt.wizard_config_name not in wizard_cfg):
                    exit_error('GEN_XCLBIN-16', WIZARD_CONFIG_JSON + ' does not contain provided configuration: ' + opt.wizard_config_name)

            #######################################################################################################
            # Save user configuration directory
            #######################################################################################################
            copy_source_dir('GEN_XCLBIN-19', config_dir, setup_cfg[OUTPUT_DIR])

        #######################################################################################################
        # Get IP catalog
        #######################################################################################################
        if opt.ip_catalog is not None:
            setup_cfg[IP_CATALOG] = opt.ip_catalog

            if not os.path.isdir(setup_cfg[IP_CATALOG]):
                exit_error('GEN_XCLBIN-20', 'Provided xbtest IP catalog does not exist: ' + setup_cfg[IP_CATALOG])

            log_debug('GEN_XCLBIN-21', 'Using provided xbtest IP catalog: ' + setup_cfg[IP_CATALOG])

            setup_cfg[IP_CATALOG] = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'xbtest_catalog'))

            copy_source_dir('GEN_XCLBIN-19', opt.ip_catalog, setup_cfg[IP_CATALOG])

        else:
            setup_cfg[IP_CATALOG] = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'xbtest_catalog'))

            #######################################################################################################
            # Check xbtest_catalog not in output directory
            #######################################################################################################
            if os.path.isdir(setup_cfg[IP_CATALOG]):
                #######################################################################################################
                # Check xbtest_catalog not in user configuration directory
                #######################################################################################################
                if config_dir is not None:
                    ip_catalog_chk = os.path.abspath(os.path.join(config_dir, 'xbtest_catalog'))
                    if os.path.isdir(ip_catalog_chk):
                        exit_error('GEN_XCLBIN-64', 'xbtest IP catalog was found in provided config directory. It should not be saved there: ' + ip_catalog_chk)

                if not opt.force:
                    exit_error('GEN_XCLBIN-65', 'xbtest IP catalog already exists in output directory (see --force to override): ' + setup_cfg[IP_CATALOG])
                else:
                    #######################################################################################################
                    # Remove xbtest_catalog in output directory
                    #######################################################################################################
                    log_info('GEN_XCLBIN-60', 'Removing xbtest IP catalog already existing as --force option is provided: ' + setup_cfg[IP_CATALOG])
                    try:
                        shutil.rmtree(setup_cfg[IP_CATALOG])
                    except OSError as e:
                        exit_error('GEN_XCLBIN-61', 'Failed to remove xbtest IP catalog: ' + setup_cfg[IP_CATALOG] + '. Exception caught: ' + str(e))

                    if os.path.isdir(setup_cfg[IP_CATALOG]):
                        exit_error('GEN_XCLBIN-61', 'Failed to remove xbtest IP catalog: ' + setup_cfg[IP_CATALOG] + '. Directory still exists')

            #######################################################################################################
            # Generate IP catalog
            #######################################################################################################
            step = 'generate IP catalog'
            start_time = start_step('GEN_XCLBIN-22', step)

            cmd = [ 'python3', GEN_IP_CATALOG_PY, '--output_dir', setup_cfg[OUTPUT_DIR] ]
            if opt.verbose:
                cmd.append('--verbose')

            exec_step_cmd('GEN_XCLBIN-23', step, cmd)

            if not os.path.isdir(setup_cfg[IP_CATALOG]):
                exit_error('GEN_XCLBIN-24', 'Failed to generate xbtest IP catalog. Directory does not exist: ' + setup_cfg[IP_CATALOG])

            end_step('GEN_XCLBIN-26', start_time)

        # Initialize IP info
        setup_cfg[IP_INFO] = {}
        wizard_name_v = os.path.split(os.path.split(SCRIPT_DIR)[0])[1]; # TODO: should get this from xbtest_ip_config.yml
        [setup_cfg[IP_INFO][NAME],          wizard_version_u]                   = wizard_name_v.split('_v')
        [setup_cfg[IP_INFO][VERSION_MAJOR], setup_cfg[IP_INFO][VERSION_MINOR]]  = wizard_version_u.split('_')
        setup_cfg[IP_INFO][VENDOR]     = 'xilinx.com'
        setup_cfg[IP_INFO][LIBRARY]    = 'ip'
        setup_cfg[IP_INFO][VERSION]    = str(setup_cfg[IP_INFO][VERSION_MAJOR]) + '.' + str(setup_cfg[IP_INFO][VERSION_MINOR])
        setup_cfg[IP_INFO][VLNV]       = setup_cfg[IP_INFO][VENDOR] + ':' + setup_cfg[IP_INFO][LIBRARY] + ':' + setup_cfg[IP_INFO][NAME] + ':' + setup_cfg[IP_INFO][VERSION]
        setup_cfg[IP_INFO][NAME_V]     = setup_cfg[IP_INFO][NAME] + '_v' + setup_cfg[IP_INFO][VERSION_MAJOR] + '_' + setup_cfg[IP_INFO][VERSION_MINOR]

        #######################################################################################################
        # Check wizard exists in IP catalog
        #######################################################################################################
        if not os.path.isdir(os.path.join(setup_cfg[IP_CATALOG], setup_cfg[IP_INFO][NAME_V])):
            exit_error('GEN_XCLBIN-27', 'Wizard IP ' + setup_cfg[IP_INFO][VLNV] + 'does not exists in :' + setup_cfg[IP_CATALOG])
        log_debug('GEN_XCLBIN-28', 'Using wizard IP: ' + setup_cfg[IP_INFO][VLNV])

        #######################################################################################################
        # Move to output directory
        #######################################################################################################
        os.chdir(setup_cfg[OUTPUT_DIR])

        #######################################################################################################
        # Extract platform metadata from XPFM
        #######################################################################################################
        step = 'extract platform metadata from ' + XPFM
        start_time = start_step('GEN_XCLBIN-29', step)

        platform_info_json = os.path.join(setup_cfg[OUTPUT_DIR], 'platforminfo.json')
        cmd = ['platforminfo', '-p', setup_cfg[XPFM], '-o', platform_info_json]

        if xpfm_ext == '.xsa':
            # For XSA, the platforminfo returned = value of hardwarePlatform node
            log_info('GEN_XCLBIN-48', 'Loading platform metadata from provided XSA')
            cmd += ['-j']
        else:
            # For xpfm, the value of hardwarePlatform node is in platforminfo returned at:
            #       - for Flat platform: hardwarePlatforms.hardwarePlatform node
            #       - for DFX platform: hardwarePlatforms.reconfigurablePartitions[0].hardwarePlatform node
            # hardwarePlatform node is found by the tool and its value is returned when providing option: -j hardwarePlatform
            log_info('GEN_XCLBIN-48', 'Loading platform metadata from provided XPFM')
            cmd += ['-j', 'hardwarePlatform']

        log_file_name = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'platforminfo.log'))
        exec_step_cmd('GEN_XCLBIN-30', step, cmd, log_file_name=log_file_name)

        setup_cfg[PLATFORM_INFO] = json_load('GEN_XCLBIN-59', PLATFORM_INFO, platform_info_json)

        end_step('GEN_XCLBIN-31', start_time)

        #######################################################################################################
        # Generate wizard run script
        #######################################################################################################
        step = 'generate wizard run script'
        start_time = start_step('GEN_XCLBIN-32', step)

        ip_prop = {}
        ip_prop[XPFM] = setup_cfg[XPFM]
        if not opt.init:
            ip_prop[C_INIT] = False
            ip_prop[WIZARD_CONFIG_NAME] = opt.wizard_config_name
        if config_dir is not None:
            ip_prop[WIZARD_CONFIG_JSON] = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'wizard_cfg.json'))
        wizard_tcl = gen_wizard_tcl(setup_cfg, ip_prop)

        end_step('GEN_XCLBIN-33', start_time)

        #######################################################################################################
        # Write the export script
        #######################################################################################################
        EXPORT_SCRIPT = []
        EXPORT_SCRIPT += ['#!/bin/bash']
        EXPORT_SCRIPT += ['']
        EXPORT_SCRIPT += ['SCRIPT_FILE="' + os.path.abspath(os.path.join(SCRIPT_DIR, SCRIPT_FILE)) + '"']
        EXPORT_SCRIPT += ['BUILD_DIR="' + BUILD_DIR + '"']
        EXPORT_SCRIPT += ['PROJECT_NAME="' + setup_cfg[PROJECT_NAME] + '"']
        EXPORT_SCRIPT += ['PLATFORM="' + platform + '"']
        EXPORT_SCRIPT += ['EXPORT="export_${PLATFORM}_${PROJECT_NAME}"']
        EXPORT_SCRIPT += ['BUILD_SOURCES="./${EXPORT}/build_sources/' + wizard_name_v + '/xclbin_generate"']
        EXPORT_SCRIPT += ['IP_CATALOG_SRC="' + setup_cfg[IP_CATALOG] + '"']
        EXPORT_SCRIPT += ['IP_CATALOG_DST="./${EXPORT}/ip_catalog"']
        EXPORT_SCRIPT += ['XSA_DIR_SRC="' + xpfm_dir + '"']
        EXPORT_SCRIPT += ['XSA_DIR_DST="./${EXPORT}/xsa/' + os.path.basename(xpfm_dir) + '"']
        if config_dir is not None:
            EXPORT_SCRIPT += ['CONFIG_DIR_SRC="' + config_dir + '"']
            EXPORT_SCRIPT += ['CONFIG_DIR_DST="./${EXPORT}/cfg"']

        EXPORT_SCRIPT += ['OUTPUT_DIR_SRC="' + setup_cfg[OUTPUT_DIR] + '"']
        EXPORT_SCRIPT += ['OUTPUT_DIR_DST="${BUILD_SOURCES}/output/${PLATFORM}/' + os.path.basename(setup_cfg[OUTPUT_DIR]) + '"']

        EXPORT_SCRIPT += ['']
        EXPORT_SCRIPT += ['mkdir -p ${BUILD_SOURCES}  && cp -rL ${SCRIPT_FILE}      $_']
        EXPORT_SCRIPT += ['mkdir -p ${BUILD_SOURCES}  && cp -rL ${BUILD_DIR}        $_']
        EXPORT_SCRIPT += ['']
        EXPORT_SCRIPT += ['mkdir -p ${OUTPUT_DIR_DST} && cp -rL ${OUTPUT_DIR_SRC}/*   $_']
        EXPORT_SCRIPT += ['mkdir -p ${IP_CATALOG_DST} && cp -rL ${IP_CATALOG_SRC}/*   $_']
        EXPORT_SCRIPT += ['mkdir -p ${XSA_DIR_DST}    && cp -rL ${XSA_DIR_SRC}/*      $_']

        if config_dir is not None:
            EXPORT_SCRIPT += ['mkdir -p ${BUILD_SOURCES}/cfg && cp -rL ${CONFIG_DIR_SRC}/*   $_']

        EXPORT_SCRIPT += ['']
        EXPORT_SCRIPT += ['cat <<EOF > ./${BUILD_SOURCES}/rerun.sh']
        EXPORT_SCRIPT += ['#\!/bin/bash']
        EXPORT_SCRIPT += ['']
        EXPORT_SCRIPT += ['# Rerun xclbin_generate workflow']
        EXPORT_SCRIPT += ['']
        EXPORT_SCRIPT += ['python3 gen_xclbin.py \\']
        EXPORT_SCRIPT += ['    --ip_catalog         ../../../ip_catalog \\']
        EXPORT_SCRIPT += ['    --xpfm               ../../../xsa/' + os.path.basename(xpfm_dir) + ' \\']
        EXPORT_SCRIPT += ['    --project_name       ' + setup_cfg[PROJECT_NAME] + '_rerun \\']
        if config_dir is not None:
            EXPORT_SCRIPT += ['    --config_dir         ./cfg \\']
        if opt.init:
            EXPORT_SCRIPT += ['    --init \\']
        if not opt.init:
            EXPORT_SCRIPT += ['    --wizard_config_name ' + opt.wizard_config_name + ' \\']
        if opt.verbose:
            EXPORT_SCRIPT += ['    --verbose \\']
        if opt.skip_xo_gen:
            EXPORT_SCRIPT += ['    --skip_xo_gen \\']
        if opt.skip_xclbin_gen:
            EXPORT_SCRIPT += ['    --skip_xclbin_gen \\']
        if opt.skip_dcp_gen:
            EXPORT_SCRIPT += ['    --skip_dcp_gen \\']
        EXPORT_SCRIPT += ['']
        EXPORT_SCRIPT += ['EOF']
        EXPORT_SCRIPT += ['chmod a+x ${BUILD_SOURCES}/rerun.sh']
        EXPORT_SCRIPT += ['']
        EXPORT_SCRIPT += ['tar -czvf ${EXPORT}.tar.gz ./${EXPORT}']
        EXPORT_SCRIPT += ['']
        EXPORT_SCRIPT += ['echo "Successfully exported: ./${EXPORT}.tar.gz"']
        EXPORT_SCRIPT += ['']
        EXPORT_SCRIPT += ['echo "Re-run using following commands:"']
        EXPORT_SCRIPT += ['echo "\t tar -xf ./${EXPORT}.tar.gz"']
        EXPORT_SCRIPT += ['echo "\t cd ${BUILD_SOURCES}"']
        EXPORT_SCRIPT += ['echo "\t ./rerun.sh"']

        export_sh = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'export.sh'))
        log_info('GEN_XCLBIN-94', 'Writing: ' + export_sh)
        with open(export_sh, mode='w') as outfile:
            outfile.write('\n'.join(EXPORT_SCRIPT))

        os.chmod(export_sh, 493); # octal 0755

        #######################################################################################################
        # Terminates if not generating the XO
        #######################################################################################################
        if opt.skip_xo_gen:
            log_info('GEN_XCLBIN-34', 'Script terminating as XO generation is skipped')
            tear_down('GEN_XCLBIN-8', SCRIPT_FILE, script_start_time)

        #######################################################################################################
        # Run wizard: create XOs and Vitis run script
        #######################################################################################################
        step = 'run wizard: create XOs and Vitis run script'
        start_time = start_step('GEN_XCLBIN-35', step)

        vitis_path = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], setup_cfg[MODULE_NAME] + '_ex', 'run'))
        cfg_template_dir  = os.path.abspath(os.path.join(vitis_path, 'cfg_template'))

        cmd = [ 'vivado', '-mode', 'batch',
                '-journal',  os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'tmp', 'tmp_wizard_vivado.jou')),
                '-log',      os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'tmp', 'tmp_wizard_vivado.log')),
                '-source',   wizard_tcl, '-notrace'
        ]
        if opt.verbose:
            cmd.append('-verbose')
        log_file_name = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'wizard.log'))
        exec_step_cmd('GEN_XCLBIN-36', step, cmd, log_file_name=log_file_name, use_console=opt.verbose)
        end_step('GEN_XCLBIN-37', start_time)

        #######################################################################################################
        # Terminates if not generating the xclbin or DCP
        #######################################################################################################
        if opt.skip_dcp_gen and opt.init:
            log_info('GEN_XCLBIN-53', 'Workflow templates were generated in ' + cfg_template_dir)
            log_info('GEN_XCLBIN-55', 'Initialization successful')
            log_info('GEN_XCLBIN-38', 'Script terminating as DCP generation is skipped')
            tear_down('GEN_XCLBIN-8', SCRIPT_FILE, script_start_time)
        elif opt.skip_xclbin_gen:
            log_info('GEN_XCLBIN-38', 'Script terminating as xclbin generation is skipped')
            tear_down('GEN_XCLBIN-8', SCRIPT_FILE, script_start_time)

        #######################################################################################################
        # Move to Vitis run directory
        #######################################################################################################
        os.chdir(vitis_path)

        #######################################################################################################
        # Run Vitis to create xclbin or a DCP
        #######################################################################################################
        if opt.init:
            step = 'run Vitis to create a DCP'
        else:
            step = 'run Vitis to create xclbin'
        start_time = start_step('GEN_XCLBIN-39', step)

        log_info('GEN_XCLBIN-40', 'Vitis run directory: ' + vitis_path)

        cmd = 'bash ./build_xclbin.sh'
        if opt.lsf_cmd is not None:
            cmd = opt.lsf_cmd + ' "' + cmd + '"'

        log_file_name = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], 'vitis.log'))
        exec_step_cmd('GEN_XCLBIN-41', step, cmd, log_file_name=log_file_name, use_console=opt.verbose, shell=True)
        end_step('GEN_XCLBIN-42', start_time)

        if opt.init:
            #######################################################################################################
            # Terminate if not generating xclbin
            #######################################################################################################
            log_info('GEN_XCLBIN-53', 'Workflow templates were generated in ' + cfg_template_dir)
            log_info('GEN_XCLBIN-54', 'A DCP was generated in output directory')
            log_info('GEN_XCLBIN-55', 'Initialization successful')
        else:
            #######################################################################################################
            # Update, copy and rename generated xclbin
            #######################################################################################################
            step = 'update, copy and rename generated xclbin'
            start_time = start_step('GEN_XCLBIN-43', step)
            src_xclbin_dir  = os.path.abspath(os.path.join(vitis_path, 'output'))
            src_xclbin      = None
            for fname in os.listdir(src_xclbin_dir):
                if fname.endswith('.xclbin'):
                    src_xclbin = os.path.abspath(os.path.join(src_xclbin_dir, fname))
                    log_info('GEN_XCLBIN-44', 'xclbin found: ' + src_xclbin)
                    break
            if src_xclbin is None:
                exit_error('GEN_XCLBIN-46', 'xclbin not found in Vitis output directory ' + src_xclbin_dir)

            dst_xclbin = os.path.abspath(os.path.join(setup_cfg[OUTPUT_DIR], setup_cfg[PROJECT_NAME] + '.xclbin'))

            if not update_interface_uuid(setup_cfg, src_xclbin, dst_xclbin):
                shutil.copy2(src_xclbin, dst_xclbin)

            log_info('GEN_XCLBIN-45', 'xclbin successfully generated: ' + dst_xclbin)

            end_step('GEN_XCLBIN-47', start_time)

        #######################################################################################################
        # Tear down
        #######################################################################################################
        tear_down('GEN_XCLBIN-8', SCRIPT_FILE, script_start_time)

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
