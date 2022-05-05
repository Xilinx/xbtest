#!/usr/bin/python3

import os
import sys

SCRIPT_VERSION = '1.0'
SCRIPT_FILE    = os.path.basename(__file__)
SCRIPT_DIR     = os.path.dirname(os.path.realpath(__file__))

from pkg import *

class Options(object):
    def PrintVersion(self):
        log_info('GEN_IP_CATALOG-5', 'Script ' + SCRIPT_FILE + ' version: ' + SCRIPT_VERSION)

    def printHelp(self):
        log_info('GEN_IP_CATALOG-6', 'Usage: $ python3 ' + SCRIPT_FILE + ' [options]')
        log_info('GEN_IP_CATALOG-6', '\t--help         / -h: Display this message')
        log_info('GEN_IP_CATALOG-6', '\t--version      / -v: Display version')
        log_info('GEN_IP_CATALOG-6', '\t--verbose      / -V: Turn on verbosity')
        log_info('GEN_IP_CATALOG-6', '\t--output_dir   / -o: Path to the output directory. Catalog generated in <output_dir>/xbtest_catalog')

    def __init__(self):
        self.help = False
        self.version = False
        self.verbose = False
        self.output_dir = None

    def getOptions(self, argv):
        log_info('GEN_IP_CATALOG-19', 'Command line provided: $ ' + str(sys.executable) + ' ' + ' '.join(argv))
        try:
            options, remainder = getopt.gnu_getopt(
                argv[1:],
                'hvVo:',
                [
                    'help',
                    'version',
                    'verbose',
                    'output_dir='
                ]
            )
        except getopt.GetoptError as e:
            self.printHelp()
            exit_error('GEN_IP_CATALOG-1', str(e))

        log_info('GEN_IP_CATALOG-20', 'Parsing command line options')
        for opt, arg in options:
            msg = '\t' + str(opt)
            if arg is not None:
                msg += ' ' + str(arg)
            log_info('GEN_IP_CATALOG-20', msg)

            if opt in ('--help', '-h'):
                self.printHelp()
                self.help = True
            elif opt in ('--version', '-v'):
                self.PrintVersion()
                self.version = True
            elif opt in ('--verbose', '-V'):
                setup_verbose()
                self.verbose = True
            elif opt in ('--output_dir', '-o'):
                self.output_dir = str(arg)
            else:
                exit_error('GEN_IP_CATALOG-2', 'Command line option not handled: ' + str(opt))

        if len(remainder) > 0:
            self.printHelp()
            exit_error('GEN_IP_CATALOG-3', 'Unknown command line options: ' + ' '.join(remainder))

        if self.help or self.version:
            exit_info('GEN_IP_CATALOG-4', 'Script terminating as help/version option provided')

        if self.output_dir is None:
            exit_error('GEN_IP_CATALOG-9', 'output_dir not defined')


def main(args):
    opt = Options()
    opt.getOptions(args)

    try:
        #######################################################################################################
        # Start
        #######################################################################################################
        script_start_time = start('GEN_IP_CATALOG-7', SCRIPT_FILE)

        #######################################################################################################
        # output_dir
        #######################################################################################################
        output_dir = os.path.abspath(opt.output_dir)
        if not os.path.isdir(output_dir):
            log_info('GEN_IP_CATALOG-10', 'Creating output directory: ' + output_dir)
            os.makedirs(output_dir)
        setup_logfile(os.path.abspath(os.path.join(output_dir, os.path.splitext(SCRIPT_FILE)[0] + '.log')))
        os.chdir(output_dir)

        #######################################################################################################
        # Get list of xbtest_ip_config
        #######################################################################################################
        XBTEST_IP_CONFIG_LIST = []
        for root, dirs, files in os.walk(ROOT_DIR):
            for dir in dirs:
                dir_path = os.path.abspath(os.path.join(ROOT_DIR, dir))
                for root0, dirs0, files0 in os.walk(dir_path):
                    for dir0 in dirs0:
                        dir0_path = os.path.abspath(os.path.join(dir_path, dir0))
                        for root1, dirs1, files1 in os.walk(dir0_path):
                            for file1 in files1:
                                if file1 == 'xbtest_ip_config.yml':
                                    XBTEST_IP_CONFIG_LIST.append(os.path.abspath(os.path.join(dir0_path, file1)))
                            break
                    break
            break
        if len(XBTEST_IP_CONFIG_LIST) == 0:
            exit_error('GEN_IP_CATALOG-11', 'No xbtest_ip_config.yml found for any IP sources in root directory: ' + ROOT_DIR)


        #######################################################################################################
        # Generate catalog
        #######################################################################################################
        for xbtest_ip_config_yml in XBTEST_IP_CONFIG_LIST:
            log_info('GEN_IP_CATALOG-12', 'Using xbtest_ip_config.yml: ' + xbtest_ip_config_yml)

            ###########################################################################
            # load config.yml
            ###########################################################################
            with open(xbtest_ip_config_yml) as infile:
                xbtest_ip_config = yaml.load(infile, Loader=yaml.FullLoader)

            ###########################################################################
            # Get IP name/version
            ###########################################################################
            ip_name_v       = xbtest_ip_config['build']['full_name']
            ip_name_v_split = ip_name_v.split('_v')
            ip_name         = ip_name_v_split[0]
            ip_version      = ip_name_v_split[1]
            log_info('GEN_IP_CATALOG-13', 'Using IP: ')
            log_info('GEN_IP_CATALOG-13', '\t - IP name       : ' + ip_name)
            log_info('GEN_IP_CATALOG-13', '\t - IP version    : ' + ip_version)
            log_info('GEN_IP_CATALOG-13', '\t - IP config yaml: ' + xbtest_ip_config_yml)

            #######################################################################################################
            # Generate wizard IPDEF
            #######################################################################################################
            step = 'run Vivado to generate ' + ip_name_v + ' IPDEF'
            start_time = start_step('GEN_IP_CATALOG-14', step)

            tmp_dir = os.path.abspath(os.path.join(output_dir, 'tmp'))
            if not os.path.isdir(tmp_dir):
                os.makedirs(tmp_dir)

            cmd  = ['vivado', '-mode', 'batch',
                    '-source',  os.path.abspath(os.path.join(SCRIPT_DIR, 'gen_ipdef.tcl')), '-notrace',
                    '-log',     os.path.abspath(os.path.join(tmp_dir, 'gen_ipdef_' + ip_name_v + '_vivado.log')),
                    '-journal', os.path.abspath(os.path.join(tmp_dir, 'gen_ipdef_' + ip_name_v + '_vivado.jou')),
                    '-tclargs', xbtest_ip_config_yml
            ]

            # Move to run directory and launch Vivado: create XO and bash scripts
            log_file_name = os.path.abspath(os.path.join(output_dir, 'gen_ipdef_' + ip_name_v + '.log'))
            exec_step_cmd('GEN_IP_CATALOG-15', step, cmd, log_file_name)

            ipdef_dir = os.path.abspath(os.path.join(output_dir, 'xbtest_catalog', ip_name_v))
            if not os.path.isdir(ipdef_dir):
                exit_error('GEN_IP_CATALOG-16', 'IPDEF directory does not exist: ' + ipdef_dir)
            else:
                log_info('GEN_IP_CATALOG-17', 'IPDEF successfully generated in directory: ' + ipdef_dir)

            end_step('GEN_IP_CATALOG-18', start_time)

        #######################################################################################################
        # Tear down
        #######################################################################################################
        tear_down('GEN_IP_CATALOG-8', SCRIPT_FILE, script_start_time)

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