
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _build-xclbin:

##########################################################################
Build xclbin
##########################################################################

********************************************************
Overview
********************************************************

After following the steps specified in previous chapters, you can generate the xclbin using the |xclbin_generate| workflow.

|xclbin_generate| workflow runs:

  * ``xbtest_wizard`` IP with the xclbin configuration.
  * |Vitis|_ tools (aiecompiler, v++ linker and packager, xclbinutil) which generates the xclbin.

``xbtest_wizard`` will set the output xclbin name to: ``<wizard_config_name>.xclbin``.

According to your Vitis tools version, a different minor version of xbtest sources might be required.

Most of :ref:`wizard-configuration-json-file` parameters can be auto-configured based on the platform metadata.
In this case these parameters should not be specified in :ref:`wizard-configuration-json-file`.

********************************************************
``xclbin_generate`` input and output products
********************************************************

The required structure and file naming of the |xclbin_generate| workflow input products and location of output products is detailed in following table where:

  * |<xbtest_build> def|
  * |<dev_platform> def|
  * |<project_name> def|

.. table:: ``xclbin_generate`` workflow input and output products

    +---------------------------------------------------------------------+-------------------------------------------------------+--------------------------------------+-------------------+-----------------------------------------------------------------------------------------------------------------------------+
    | File/Directory name                                                                                                                                                | Required/optional | Description                                                                                                                 |
    +---------------------------------------------------------------------+-------------------------------------------------------+--------------------------------------+                   +                                                                                                                             +
    | Level 1                                                             | Level 2                                               | Level 3                              |                   |                                                                                                                             |
    +=====================================================================+=======================================================+======================================+===================+=============================================================================================================================+
    | **Input products**                                                                                                                                                                                                                                                                                                   |
    +---------------------------------------------------------------------+-------------------------------------------------------+--------------------------------------+-------------------+-----------------------------------------------------------------------------------------------------------------------------+
    | <xbtest_build>/xclbin_generate/cfg/<dev_platform>                   | pwr_cfg                                               | dynamic_geometry.json                | Required          | Power CU floorplan definition: available, invalid sites and utilization.                                                    |
    +---------------------------------------------------------------------+-------------------------------------------------------+--------------------------------------+-------------------+                                                                                                                             +
    |                                                                     |                                                       | invalid.json                         | Optional          |   * :ref:`dynamic_geometry-json`                                                                                            |
    +                                                                     +                                                       +--------------------------------------+-------------------+   * :ref:`invalid-json`                                                                                                     +
    |                                                                     |                                                       | utilization.json                     | Required          |   * :ref:`utilization-json`                                                                                                 |
    +                                                                     +-------------------------------------------------------+--------------------------------------+-------------------+-----------------------------------------------------------------------------------------------------------------------------+
    |                                                                     | vpp_cfg                                               | vpp.ini                              | Required          | Vitis configuration: INI option file and TCL hooks .                                                                        |
    |                                                                     |                                                       |                                      |                   | (post system linker, optional others e.g. ``place_design_pre.tcl``, ``route_design_pre.tcl``)                               |
    +                                                                     +-------------------------------------------------------+--------------------------------------+-------------------+                                                                                                                             +
    |                                                                     |                                                       | postsys_link.tcl                     | Required          |                                                                                                                             |
    +                                                                     +                                                       +--------------------------------------+-------------------+                                                                                                                             +
    |                                                                     |                                                       | <other_scripts>.tcl                  | Optional          |                                                                                                                             |
    +                                                                     +-------------------------------------------------------+--------------------------------------+-------------------+-----------------------------------------------------------------------------------------------------------------------------+
    |                                                                     | wizard_cfg.json                                       |                                      | Required          | :ref:`wizard-configuration-json-file`: xclbin configuration, CU type and quantities depending on the platform architecture. |
    |                                                                     |                                                       |                                      |                   | (e.g. Clock frequency, CU SLR assignment, CU PLRAM connectivity, Memory CU connectivity, etc.)                              |
    +---------------------------------------------------------------------+-------------------------------------------------------+--------------------------------------+-------------------+-----------------------------------------------------------------------------------------------------------------------------+
    | **Output products**                                                                                                                                                                                                                                                                                                  |
    +---------------------------------------------------------------------+-------------------------------------------------------+--------------------------------------+-------------------+-----------------------------------------------------------------------------------------------------------------------------+
    | <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name> | <project_name>.xclbin                                 |                                      | Required          | xclbin.                                                                                                                     |
    +                                                                     +-------------------------------------------------------+--------------------------------------+-------------------+-----------------------------------------------------------------------------------------------------------------------------+
    |                                                                     | u_ex/run/vpp_link/link/vivado/vpl/prj/prj.runs/impl_1 | level0_wrapper_postroute_physopt.dcp | Required          | DCP.                                                                                                                        |
    +---------------------------------------------------------------------+-------------------------------------------------------+--------------------------------------+-------------------+-----------------------------------------------------------------------------------------------------------------------------+

********************************************************
``xclbin_generate`` Workflow Command Line Options
********************************************************

The |xclbin_generate| workflow supports the following command line options described in next sections.
You can always refer to the help of the workflow for a quick summary of the various options.
Each option can be specified fully or in short manner.

.. contents::
    :depth: 1
    :local:

----

.. _xclbin_generate-help:

=====================================================
-h, --help: Display help
=====================================================

.. option:: -h, --help

    Display |xclbin_generate| workflow help message.

----

=====================================================
-c, --ip_catalog: Provide IP catalog
=====================================================

.. option:: -c <xbtest_catalog>, --ip_catalog <xbtest_catalog>

    Mandatory.
    Path to xbtest IP catalog.

----

=====================================================
-x, --xpfm: Select Platform XPFM
=====================================================

.. option:: -x path/to/platform.xpfm, --xpfm path/to/platform.xpfm

    Mandatory.
    Path to platform XPFM.
    This can be a path to either a:

      * ``.xpfm`` file.
      * ``.xsa`` file.
      * ``.rpm`` package (only if running on CentOS, Red Hat or SUSE) containing ``.xfpm`` file.
      * ``.deb`` package (only if running on Ubuntu) containing ``.xfpm`` file.
      * Directory containing a ``.xpfm`` file.

----

=====================================================
-I, --init: Enable initialization
=====================================================

.. option:: -I, --init

    Initialization of some workflow input products.

    When enabled:

      * Option :option:`--config_dir` is optional.
      * If option :option:`--project_name` is not provided, then it defaults to ``init``.

    See :ref:`workflows-initialization`.

----

=====================================================
-d, --config_dir: Provide configuration directory
=====================================================

.. option:: -d path/to/your/config_dir, --config_dir path/to/your/config_dir

    Path to the configuration directory containing the following folders:

      * :ref:`wizard-configuration-json-file`
      * Vitis configuration: ``vpp_cfg``.
      * Power floorplan configuration: ``pwr_cfg``.

----

=====================================================
-p, --project_name: Set project name
=====================================================

.. option:: -p <name>, --project_name <name>

    Set the name of the project. This value should only contain alphanumeric characters: ``a-z``, ``A-Z``, ``0-9`` and ``_``.

----

=====================================================
-l, --use_lsf: Enable LSF
=====================================================

.. option:: -l, --use_lsf

    Run Vitis on LSF using default LSF command.

    According to your LSF infrastructure, you may have to update the ``bsub`` command using :option:`--lsf_cmd` option.

    Use option |--help| to get the default LSF command.

----

=====================================================
-L, --lsf_cmd: Provide LSF command
=====================================================

.. option:: -L <cmd>, --lsf_cmd <cmd>

    Run Vitis on LSF using provided LSF command.
    This overrides default LSF command and you must provide the entire ``bsub`` command and options.

----

=======================================================
-n, --wizard_config_name: Set wizard configuration name
=======================================================

.. option:: -n <name>, --wizard_config_name <name>

    Set wizard configuration name.
    Must be defined in wizard configuration JSON file.
    Default: ``xbtest_stress``.

----

=====================================================
-o, --output_dir: Provide output directory
=====================================================

.. option:: -o path/to/your/output_dir, --output_dir path/to/your/output_dir

    Path to the output directory.

    Default: ``./output/<dev_platform>/<project_name>`` where:

      * |<dev_platform> def|

----

.. _xclbin_generate-verbose:

=====================================================
-V, --verbose: Enable verbosity
=====================================================

.. option:: -V, --verbose

    Turn on verbosity.
    When enabled, Wizard and Vitis messages will also be reported in the console.

----

=====================================================
-f, --force: Force an operation
=====================================================

.. option:: -f, --force

    Override output directory if already existing.

----

=====================================================
-q, --skip_xclbin_gen: Skip xclbin generation
=====================================================

.. option:: -q, --skip_xclbin_gen

    Skip xclbin generation. Cannot be used with option :option:`--init`.

    Use this option when creating the power CU floorplan (in tandem with ``display_pwr_flooplan``).

    See :ref:`define-power-cu-floorplan`.

----

=====================================================
-Q, --skip_xo_gen: Skip XO generation
=====================================================

.. option:: -Q, --skip_xo_gen

    Skip XO and xclbin generation.

    This is more a debug option as the workflow generates all Vivado inputs necessary to run the wizard example design but will stop before running Vitis.

----

=====================================================
-r, --skip_dcp_gen: Skip DCP generation
=====================================================

.. option:: -r, --skip_dcp_gen

    Skip DCP generation. Must be used with option :option:`--init`.

    Use this option when initialization mode is enabled.

    See :ref:`workflows-initialization`.

----

=====================================================
-v, --version: Display version
=====================================================

.. option:: -v, --version

    Display |xclbin_generate| workflow version.

----

********************************************************
Run ``xclbin_generate`` workflow
********************************************************

|xclbin_generate| is a python workflow to run with python3.

This workflow will create a run directory per xclbin build ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/``

  * |<xbtest_build> def|
  * |<dev_platform> def|
  * |<project_name> def|

.. note::
    The jobs can be run on LSF using command line option :option:`--use_lsf`. By default, they are run locally.

The output xclbin is ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/<project_name>.xclbin``

  * E.g. ``<xbtest_build>/xclbin_generate/output/xilinx_u50lv_gen3x4_xdma_2_202010_1/xbtest_stress/xbtest_stress.xclbin``

The ``xclbin_generate`` workflow is run using the following commands:

  1. Move to ``xclbin_generate`` directory

    .. code-block:: bash

        $ cd <xbtest_build>/xclbin_generate

  2. Run the workflow:

    .. code-block:: bash

        $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> \
                                --xpfm path/to/platform.xpfm \ 
                                --config_dir ./cfg/<dev_platform> \
                                --project_name <project_name>

    For example:

       * Example command for u55c:

         .. code-block:: bash

             $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> \
                                     --xpfm path/to/your/xilinx_u55c_gen3x16_xdma_3_202210_1.xpfm \
                                     --config_dir ./cfg/xilinx_u55c_gen3x16_xdma_3_202210_1 \
                                     --project_name xbtest_stress

       * Example command for u55c selecting another configuration present in :ref:`wizard-configuration-json-file`:

         .. code-block:: bash

             $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> \
                                     --xpfm path/to/your/xilinx_u55c_gen3x16_xdma_3_202210_1.xpfm \
                                     --config_dir ./cfg/xilinx_u55c_gen3x16_xdma_3_202210_1 \
                                     --project_name memory_only \
                                     --wizard_config_name xbtest_memory

       * Example command for u250 providing development RPM as input XPFM on CentOS/Red Hat/SUSE:

         .. code-block:: bash

             $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> \
                                     --xpfm path/to/your/xilinx-u250-gen3x16-xdma-4.1-202210-1-dev-1-3512975.noarch.rpm \
                                     --config_dir ./cfg/xilinx_u250_gen3x16_xdma_4_1_202210_1 \
                                     --project_name xbtest_stress

       * Example command for u55c specifying Vitis run on LSF with default LSF command:

         .. code-block:: bash

             $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> \
                                     --xpfm path/to/your/xilinx_u55c_gen3x16_xdma_3_202210_1.xpfm \
                                     --config_dir ./cfg/xilinx_u55c_gen3x16_xdma_3_202210_1 \
                                     --project_name xbtest_stress \
                                     --use_lsf

At the end of the xclbin generation, |xclbin_generate| workflow output contains ``[GEN_XCLBIN-45]`` message, like the following:

.. code-block:: bash
    :emphasize-lines: 8

    INFO: [GEN_XCLBIN-41] Executing: $ bash ./build_xclbin.sh
    INFO: [GEN_XCLBIN-41] Log file: <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/vitis.log
    INFO: [GEN_XCLBIN-42] ************************** End of step. Elapsed time: 4:40:23


    INFO: [GEN_XCLBIN-43] *** [2021-09-24, 20:26:15] Starting step: rename and move generated xclbin
    INFO: [GEN_XCLBIN-44] xclbin found: <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/output/xbtest_stress.xclbin
    INFO: [GEN_XCLBIN-45] xclbin renamed and moved to: <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/<project_name>.xclbin
    INFO: [GEN_XCLBIN-47] ************************** End of step. Elapsed time: 0:00:1


    INFO: [GEN_XCLBIN-8] --------------------------------------------------------------------------------------
    INFO: [GEN_XCLBIN-8] [2021-09-24, 20:26:16] gen_xclbin.py END. Total Elapsed Time: 4:45:27
    INFO: [GEN_XCLBIN-8] --------------------------------------------------------------------------------------

