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

import json
import os
import sys
import shutil
import types
import glob
import getopt
import subprocess
import signal
import copy
import datetime
import re
import inspect
import getopt
import pkg_resources

for pkg in pkg_resources.working_set:
    if pkg.key == 'pyyaml':
        import yaml

if 'yaml' not in sys.modules:
    print('Warning: pyyaml pyhton module not installed. This is needed to generate IP catalog.')

import logging
from io import StringIO

# Get the root logger
logger = logging.getLogger('')
logger.setLevel(logging.INFO)
# stream
log_stream = StringIO()
string_handler = logging.StreamHandler(stream=log_stream)
string_handler.setLevel(logging.INFO)
# stream
console_handler = logging.StreamHandler(stream=sys.stdout)
console_handler.setLevel(logging.INFO)
# formatter
formatter = logging.Formatter('%(levelname)s: %(message)s')
# add
string_handler.setFormatter(formatter)
console_handler.setFormatter(formatter)
logger.addHandler(string_handler)
logger.addHandler(console_handler)

def setup_verbose():
    logger.setLevel(logging.DEBUG)
    string_handler.setLevel(logging.DEBUG)
    console_handler.setLevel(logging.DEBUG)

def setup_logfile(log_file):
    with open(log_file, 'w') as fd:
        log_stream.seek(0)
        shutil.copyfileobj(log_stream, fd)
    file_handler = logging.FileHandler(log_file, 'a')
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    logger.removeHandler(string_handler)

def exit_msg(level, id, msg):
    log_msg(level, id, msg)
    if level == logging.ERROR:
        sys.exit(1)
    else:
        sys.exit(0)

def exit_info(id, msg):
    exit_msg(logging.INFO, id, msg)

def exit_error(id, msg):
    exit_msg(logging.ERROR, id, msg)

def format_time_str(time_in):
    return time_in.strftime('%Y-%m-%d, %H:%M:%S')
def format_msg(id, msg):
    return '[' + id + '] ' + msg

def log_debug(id, msg):
    logger.debug(format_msg(id,msg))
def log_info(id, msg):
    logger.info(format_msg(id,msg))
def log_warning(id, msg):
    logger.warning(format_msg(id,msg))
def log_error(id, msg):
    logger.error(format_msg(id,msg))
def log_msg(level, id, msg):
    logger.log(level, format_msg(id,msg))

CWD = os.getcwd(); # get current working directory

ROOT_DIR = os.path.split(os.path.dirname(os.path.realpath(__file__)))[0]
ROOT_DIR = os.path.split(ROOT_DIR)[0]
ROOT_DIR = os.path.split(ROOT_DIR)[0]
ROOT_DIR = os.path.split(ROOT_DIR)[0]
DEFAULT_CONFIG_NAME = 'xbtest_stress'
DEFAULT_LSF_CMD = 'bsub -I -R "select[type=X86_64 && (osdistro=rhel || osdistro=centos) && (osver == ws7 || osver == cent7)] rusage[mem=48000]" -N -q long -W 48:00'

SUPPORTED_XPFM_EXT = ['.xpfm', '.xsa', '.rpm', '.deb']

DIST_ID_CENTOS  = 'CentOS'
DIST_ID_UBUNTU  = 'Ubuntu'
DIST_ID_REDHAT  = 'RedHatEnterprise'
DIST_ID_SLES    = 'SUSE'
SUPPORTED_DIST_ID = [
    DIST_ID_CENTOS,
    DIST_ID_UBUNTU,
    DIST_ID_REDHAT,
    DIST_ID_SLES,
]

# setup parameters
IP_CATALOG          = 'ip_catalog'
IP_INFO             = 'ip_info'
VLNV                = 'vlnv'
VENDOR              = 'vendor'
LIBRARY             = 'library'
NAME                = 'name'
VERSION             = 'version'
VERSION_MAJOR       = 'version_major'
VERSION_MINOR       = 'version_minor'
NAME_V              = 'name_v'
PROJECT_NAME        = 'Project name'
MODULE_NAME         = 'Module name'
OUTPUT_DIR          = 'Output directory'
PLATFORM_INFO       = 'Platform info JSON file'
BOARD               = 'board'
PART                = 'part'

# xbtest_wizard user_parameters
XPFM                = 'xpfm'
WIZARD_CONFIG_JSON  = 'wizard_config_json'
WIZARD_CONFIG_NAME  = 'wizard_config_name'
C_INIT              = 'C_INIT'


def start(id, file):
    start_time = datetime.datetime.now().replace(microsecond=0)
    log_info(id, '--------------------------------------------------------------------------------------')
    log_info(id, '[' + format_time_str(start_time) + '] Starting ' + file)
    log_info(id, '--------------------------------------------------------------------------------------')
    return start_time

def tear_down(id, file, start_time):
    end_time = datetime.datetime.now().replace(microsecond=0)
    elapsed_time = end_time - start_time
    log_info(id, '--------------------------------------------------------------------------------------')
    log_info(id, '[' + format_time_str(end_time) + '] ' + file + ' END. Total Elapsed Time: ' + str(elapsed_time))
    log_info(id, '--------------------------------------------------------------------------------------')
    sys.exit(0)

def copy_source_dir(id, src_dir, dest_dir):
    log_debug(id, 'Source copied locally to: ' + src_dir)
    if not os.path.isdir(dest_dir):
        os.makedirs(dest_dir)
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            shutil.copy(os.path.abspath(os.path.join(src_dir, file)), dest_dir)
            os.chmod(os.path.abspath(os.path.join(dest_dir, file)), 511); # octal 777
        for dir in dirs:
            dst = os.path.abspath(os.path.join(dest_dir, dir))
            shutil.copytree(os.path.abspath(os.path.join(src_dir, dir)), dst)
            os.chmod(dst, 511); # octal 777
        break   #prevent descending into sub-folders

def copy_source_file(id, src_file, dest_dir):
    if not os.path.isfile(src_file):
        exit_error(id, 'Source file does not exist: ' + src_file)
    if not os.path.isdir(dest_dir):
        os.makedirs(dest_dir)
    log_debug(id, 'Source copied locally to: ' + src_file)
    shutil.copy(src_file, dest_dir)

def check_log_error(id, step, log_file_name):
    # check for error in log
    log_file = open(log_file_name, mode='r')
    step_error = False
    for line in log_file:
        txt = 'ERROR: ['
        if txt == line[0:len(txt)-1]:
            step_error = True
            print(line)
    log_file.close()
    if step_error:
        exit_error(id, 'Messages containing pattern "ERROR: [" found in step: ' + step + '. Please check: ' + log_file_name)

def start_step(id, step):
    start_time = datetime.datetime.now().replace(microsecond=0)
    log_info(id, '*** [' + format_time_str(start_time) + '] Starting step: ' + step)
    return start_time

def end_step(id, start_time):
    elapsed_time = datetime.datetime.now().replace(microsecond=0) - start_time
    log_info(id, '************************** End of step. Elapsed time: ' + str(elapsed_time) + '\n\n')

def exec_step_cmd(id, step, cmd, log_file_name = None, use_console = False, shell = False, ignore_error = False, env = None, expect_fail = False):
    if not shell:
        cmd_str = ' '.join(cmd)
    else:
        cmd_str = cmd

    log_info(id, 'Executing: $ ' + cmd_str)

    proc = subprocess.Popen(cmd, shell=shell, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=env)

    if log_file_name is not None:
        log_info(id, 'Log file: ' + log_file_name)
        log_file = open(log_file_name, mode='w')

    for line in proc.stdout:
        if use_console:
            sys.stdout.write(line)
            sys.stdout.flush()
        if log_file_name is not None:
            log_file.write(line)
            log_file.flush()

    proc.wait()

    if not ignore_error:
        err_log_msg = ''
        if log_file_name is not None:
            log_file.close()
            check_log_error(id, step, log_file_name)
            err_log_msg = '. Check log for more details: ' + log_file_name

        if not expect_fail and proc.returncode != 0:
            exit_error(id, 'Step ' + step + ' failed: Unexpected non-zero return code (' + str(proc.returncode) + ') for command: ' + cmd_str + err_log_msg)
        elif expect_fail and proc.returncode == 0:
            exit_error(id, 'Step ' + step + ' failed: Unexpected zero return code for command: ' + cmd_str + err_log_msg)

def json_load(id, name, file):
    json_data = {}
    if not os.path.isfile(file):
        exit_error(id, 'Failed to load ' + name + '. File does not exist: ' + file)
    with open(file) as infile:
        try:
            json_data = json.load(infile)
        except ValueError as e:
            exit_error(id, 'Failed to load ' + name + '. File contains invalid JSON content: ' + file + '. JSON parser error: ' + str(e))
    return json_data
