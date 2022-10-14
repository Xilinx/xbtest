
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _environment-setup-and-workflows-initialization:

##########################################################################
Environment setup and workflows initialization
##########################################################################

********************************************************
Overview
********************************************************

This page describes the setup of working environment required to build xbtest packages:

  * Tools dependencies...

It also describes a simple procedure to create templates and placeholders that you'll need for:

  * Creating the power CU.
  * Adding configuration and constraint to |Vitis|_.

.. _xbtest-sources:

********************************************************
xbtest sources
********************************************************

Get xbtest sources and packages using the following command:

.. code-block:: bash

    $ git clone https://github.com/Xilinx/xbtest --branch 6.0 <xbtest_local_repo>

The HW sources are located in ``<xbtest_local_repo>/src/hw``.

The host application packages are located in ``<xbtest_local_repo>/pkg/sw``.

********************************************************
Platform
********************************************************

A |Vitis|_ development platform XPFM (or HW XSA) is required (see |xclbin_generate| option :option:`--xpfm`).

Make sure your platform is supported by xbtest and contains the required metadata (see :ref:`developer-guide-prerequisite`).

.. _environment-setup:

********************************************************
Environment setup
********************************************************

=====================================================
Vitis tools
=====================================================

You need a standard Unix environment with |Vitis|_ tools installed.

  1. Execute the following commands to set up the Vitis environment for building xbtest:

       * For bash:

         .. code-block:: bash

             $ source <Vitis_Installation_Path>/Vitis/<Vitis_Version>/settings64.sh

       * For CSH:

         .. code-block:: bash

             $ source <Vitis_Installation_Path>/Vitis/<Vitis_Version>/settings64.csh

  2. A license for the AIE compiler is required to successfully build the power CU with AIE.

       * If you have an AIE compiler license, set the environment variable ``XILINXD_LICENSE_FILE`` to include that license before building xbtest xclbin.

       * If you do not have an AIE compiler license, do not use AIE in the power CU by setting ``AIE_UTILIZATION`` to 0 in your ``utilization.json`` configuration.

  3. Check Vitis tools are loaded:

     .. code-block:: bash

         $ which vitis
         $ which v++
         $ which aiecompiler
         $ which xclbinutil
         $ which platforminfo

=====================================================
Dependencies script
=====================================================

Download and install all xbtest workflows dependencies:

  1. Run xbtest dependencies script as super user:

     .. code-block:: bash

         $ sudo <xbtest_build>/rpm_generate/xbtest_deps.sh

  2. Check tools are loaded:

     .. code-block:: bash

         $ which python3

Where:

  * |<xbtest_build> def|

.. _workflows-initialization:

********************************************************
Workflows initialization
********************************************************

=====================================================
Goal
=====================================================

The goal of this initialization is to generate, based on your platform, templates required in |xclbin_generate| workflow:

  1. :ref:`initialize-using-xclbin_generate` to generate the following templates:

       * :ref:`wizard-configuration-json-file-template`.
       * :ref:`vitis-configuration-templates` which includes:

           * :ref:`vpp-options-file-template`.
           * :ref:`postsys_link-tcl-template`.
           * :ref:`place_design_pre-tcl-template`.
           * :ref:`route_design_pre-tcl-template`.

  2. :ref:`initialize-power-floorplan-sources` to generate the following templates:

       * Initialize :ref:`power-floorplan-templates`.

Once the initialization is completed, you'll be able to use and customize generated templates as explained in later in this documentation.

If the platform metadata is not defined as expected, the content of the templates may be wrong but this documentation explain how to overwrite them if needed.

.. _templates-description:

=====================================================
Templates description
=====================================================

In the initialization, the following templates will be generated.

.. _power-floorplan-templates:

---------------------------------------------------
Power floorplan templates: ``pwr_cfg``
---------------------------------------------------

The following power floorplan templates are generated:

  * ``dynamic_geometry.json``: Required :ref:`dynamic_geometry-json` defining available primitives in platform dynamic region: **do not edit**.
  * ``utilization_template.json``: Templates of required :ref:`utilization-json` defining power CUs sites utilization: 0% set for all site types.
  * ``invalid_template.json``: Templates of optional :ref:`invalid-json` defining invalid primitives to be excluded: a few sites invalidated as example.

.. _vitis-configuration-templates:

---------------------------------------------------
Vitis configuration templates: ``vpp_cfg``
---------------------------------------------------

.. _vpp-options-file-template:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Vitis options file template: ``vpp.ini``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The template of required :ref:`vpp-options-file`:

  * References:

      * :ref:`postsys_link-tcl`.
      * :ref:`place_design_pre-tcl`.
      * :ref:`route_design_pre-tcl`.

  * Sets ``remote_ip_cache`` option.
  * Provide example of build strategy/directives.

Example/possible content of this template:

.. code-block:: INI

    remote_ip_cache=../../../remote_ip_cache

    # TCL hooks
    [advanced]
    param=compiler.userPostSysLinkOverlayTcl=../../vpp_cfg/postsys_link.tcl

    [vivado]
    prop=run.impl_1.STEPS.PLACE_DESIGN.TCL.PRE=../../vpp_cfg/place_design_pre.tcl
    prop=run.impl_1.STEPS.ROUTE_DESIGN.TCL.PRE=../../vpp_cfg/route_design_pre.tcl

    # Build strategy/directives
    [vivado]
    # prop=run.impl_1.strategy=Performance_EarlyBlockPlacement
    # prop=run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED=true
    # prop=run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=Explore
    # prop=run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE=Explore
    # prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE=Explore
    # prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true

.. _postsys_link-tcl-template:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Post system linker TCL hook template: ``postsys_link.tcl``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This template of required :ref:`postsys_link-tcl` includes:

  * Continuous clocks connectivity (by default set for UCS subsystem **v3.0** called ``ulp_ucs``).
  * Example of power CU external throttle mode connectivity (by default 4 power CUs with throttle source in SLR0).

Example/possible content:

.. code-block::

    #########################################################################################
    # Post system linker TCL hook
    # This is a generated template file
    # How to use. In procedure postsys_link_body:
    # 1) Update continuous clocks connectivity: UCS name and version
    # => Select one call of procedure connect_continuous_clocks
    # 2) Update power CU connectivity for external throttle mode depending on the CU
    # configuration in wizard configuration JSON file
    # => Update/add/remove source/destination power CUs in calls of procedure connect_power_cu_throttle
    #########################################################################################
    ###################################### Update here ######################################
    proc postsys_link_body {} {
      #### Continuous clocks connectivity
      # connect_continuous_clocks ulp_ucs 0; # No UCS present, continuous clock is not supported
      # connect_continuous_clocks ulp_ucs 2; # UCS subsystem version v2
      connect_continuous_clocks ulp_ucs 3; # UCS subsystem version v3

      #### Power CU connectivity for external throttle mode
      # For example:
      # - source power CU in SLR0 (krnl_powertest_slr0_1)
      # - destination power CUs in SLR1/SLR2/SLR3 (krnl_powertest_slr1_1/krnl_powertest_slr2_1krnl_powertest_slr3_1)
      connect_power_cu_throttle krnl_powertest_slr0_1 krnl_powertest_slr1_1
      connect_power_cu_throttle krnl_powertest_slr0_1 krnl_powertest_slr2_1
      connect_power_cu_throttle krnl_powertest_slr0_1 krnl_powertest_slr3_1
    }

    ################################### DO NOT EDIT #####################################
    proc connect_continuous_clocks { ucs_name ucs_version} {
      # Set names depending on UCS version
      if {$ucs_version == 0} {
        connect_bd_net [get_bd_pins krnl_*/ap_clk]   [get_bd_pins krnl_*/ap_clk_cont]
        connect_bd_net [get_bd_pins krnl_*/ap_clk_2] [get_bd_pins krnl_*/ap_clk_2_cont]
        return
      } elseif {$ucs_version == 2} {
        set clk_prop_name_0 ENABLE_KERNEL_CONT_CLOCK
        set clk_prop_val_0 true
        set clk_port_0 clk_kernel_cont
        set clk_prop_name_1 ENABLE_KERNEL2_CONT_CLOCK
        set clk_prop_val_1 true
        set clk_port_1 clk_kernel2_cont
      } elseif {$ucs_version == 3} {
        set clk_prop_name_0 ENABLE_CONT_KERNEL_CLOCK_00
        set clk_prop_val_0 true
        set clk_port_0 aclk_kernel_00_cont
        set clk_prop_name_1 ENABLE_CONT_KERNEL_CLOCK_01
        set clk_prop_val_1 true
        set clk_port_1 aclk_kernel_01_cont
      } else {
        common::send_msg_id {XBTEST_POSTSYS_LINK-1} {ERROR} "Failed to connect continuous clocks. UCSversion   ($ucs_version) not defined in connect_continuous_clocks in your postsys_link.tcl"
      }
      # Check the UCS cell exists
      if {[get_bd_cells $ucs_name] == {}} {
        common::send_msg_id {XBTEST_POSTSYS_LINK-2} {ERROR} "Failed to connect continuous clocks. UCS cell($ucs_name)   not found. Check cell name in BD"
      }
      # Enable UCS kernel continuous clocks outputs
      foreach {prop val} [dict create $clk_prop_name_0 $clk_prop_val_0 $clk_prop_name_1 $clk_prop_val_0] {
        # Check property exists
        if {![regexp -nocase -- ".*CONFIG.${prop}.*" [list_property [get_bd_cells $ucs_name]]]} {
          common::send_msg_id {XBTEST_POSTSYS_LINK-3} {ERROR} "Failed to connect continuous clocks. UCScell property   (CONFIG.$prop) does not exists. Check UCS susbsystem ($ucs_name) version"
        }
        set_property CONFIG.$prop $val [get_bd_cells $ucs_name]
      }
      # Connect UCS continuous clocks outputs to clock inputs of all xbtest compute units continuous
      foreach {src dst} [dict create $clk_port_0 ap_clk_cont $clk_port_1 ap_clk_2_cont] {
        if {[get_bd_pins $ucs_name/$src] == {}} {
          common::send_msg_id {XBTEST_POSTSYS_LINK-4} {ERROR} "Failed to connect continuous clocks. UCScell pin   ($ucs_name/$src) not found. Check cell pin name in BD"
        }
        connect_bd_net [get_bd_pins $ucs_name/$src] [get_bd_pins krnl_*/$dst]
      }
    }
    proc connect_power_cu_throttle { src_pwr_cu_name dst_pwr_cu_name } {
      # Only connect if both source and destination power CU are present in the BD
      foreach pwr_cu_name [list $src_pwr_cu_name $dst_pwr_cu_name] {
        if {[get_bd_cells $pwr_cu_name] == {}} {
          common::send_msg_id {XBTEST_POSTSYS_LINK-5} {WARNING} "Cannot connect $src_pwr_cu_name to$dst_pwr_cu_name.   Power CU cell ($pwr_cu_name) not found"
          return
        }
      }
      # Connect outputs of source power CU to inputs of destination power CU
      connect_bd_net [get_bd_pins $src_pwr_cu_name/pwr_clk_out]     [get_bd_pins $dst_pwr_cu_namepwr_clk_in]
      connect_bd_net [get_bd_pins $src_pwr_cu_name/pwr_FF_en_out]   [get_bd_pins $dst_pwr_cu_namepwr_FF_en_in]
      connect_bd_net [get_bd_pins $src_pwr_cu_name/pwr_DSP_en_out]  [get_bd_pins $dst_pwr_cu_namepwr_DSP_en_in]
      connect_bd_net [get_bd_pins $src_pwr_cu_name/pwr_BRAM_en_out] [get_bd_pins $dst_pwr_cu_namepwr_BRAM_en_in]
      connect_bd_net [get_bd_pins $src_pwr_cu_name/pwr_URAM_en_out] [get_bd_pins $dst_pwr_cu_namepwr_URAM_en_in]
    }
    # Execute body
    postsys_link_body

.. _place_design_pre-tcl-template:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Pre-placer TCL hook template: ``place_design_pre.tcl``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The generated template of optional :ref:`place_design_pre-tcl` is empty. It is given as place holder.

.. _route_design_pre-tcl-template:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Pre-router TCL hook template: ``route_design_pre.tcl``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The generated template of optional :ref:`route_design_pre-tcl` is empty. It is given as place holder.

.. _wizard-configuration-json-file-template:

---------------------------------------------------------------
Wizard configuration JSON file template: ``wizard_cfg.json``
---------------------------------------------------------------

The template of required :ref:`wizard-configuration-json-file` contains

  * Mandatory ``default`` build parameters.

  * CU selection based on platform metadata and example of configuration:

      * ``xbtest_stress``: Default.
      * ``xbtest_power_fp``: Display power floorplan.

Example/possible content:

.. code-block:: JSON

    {
      "default" : {
        "build" : {
          "pwr_floorplan_dir" : "../pwr_cfg",
          "vpp_options_dir" : "../vpp_cfg"
        }
      },
      "xbtest_stress" : {
        "cu_selection" : {
          "power" : [0,1,2],
          "gt_mac" : [0,1],
          "memory" : ["HBM","HOST"]
        }
      },
      "xbtest_power_fp" : {
        "build" : {
          "display_pwr_floorplan" : true
        },
        "cu_selection" : {
          "power" : [0,1,2]
        }
      }
    }

.. _initialize-using-xclbin_generate:

=====================================================
Initialize using ``xclbin_generate``
=====================================================

In this step, run the |xclbin_generate| workflow as detailed below with command line option :option:`--init`, and save the generated templates in ``<xbtest_build>/xclbin_generate/cfg/<dev_platform>``

  * |<xbtest_catalog> def|
  * |<xbtest_build> def|
  * |<dev_platform> def|

.. note::
    All command line options are described in another section of this documentation.
    Only :option:`--init` and command line option :option:`--xpfm` are used at this stage.

A DCP is required to create the power CU templates.
By default, a DCP will be created.
A post PhysOpt DCP is enough, there is no need to be able to place and route (nor close timing).

You can skip the DCP generation phase if you already have one.
Any DCP suits (after physOpt, place or route phases).

  1. Move to ``xclbin_generate`` sources directory:

     .. code-block:: bash

         $ cd <xbtest_build>/xclbin_generate

  2. Run ``xclbin_generate`` workflow with :option:`--init` mode enabled and either:

       * Generate DCP:

       .. code-block:: bash

           $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> --xpfm path/to/your/platform.xpfm --init

       * Or, if you already have a DCP, then use the :option:`--skip_dcp_gen` option:

       .. code-block:: bash

           $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> --xpfm path/to/your/platform.xpfm --init --skip_dcp_gen

       * If a required platform metadata is missing or not defined as expected, the initialization may fail.
         In that case, you can define this metadata in your a :ref:`wizard-configuration-json-file`
         This will allow the initialization to proceed and the other templates to be generated.

         Define the :ref:`wizard-configuration-json-file` in your configuration directory: ``path/to/your/config_dir/wizard_cfg.json``

         Run the workflow with option :option:`--config_dir`:

         .. code-block:: bash

             $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> --xpfm path/to/your/platform.xpfm --init --config_dir path/to/your/config_dir


  3. At the end of the initialization, |xclbin_generate| workflow output contains ``[GEN_XCLBIN-53]``, ``[GEN_XCLBIN-54]`` and ``[GEN_XCLBIN-55]`` messages, like the following:

     .. code-block:: bash
         :emphasize-lines: 4,5,6

         STATUS: [GEN_XCLBIN-41] -- Executing command: bash ./build_xclbin.sh
         INFO: [GEN_XCLBIN-41] Command finished. Duration: 0:48:54
         STATUS: [GEN_XCLBIN-42] **** End of step: run Vitis to generate a DCP. Elapsed time: 0:51:32
         INFO: [GEN_XCLBIN-53] Workflow templates were generated in <xbtest_build>/xclbin_generate/output/xilinx_u55c_gen3x16_xdma_3_202210_1/init/u_ex/run/cfg_template
         INFO: [GEN_XCLBIN-54] A DCP was generated in output directory
         INFO: [GEN_XCLBIN-55] Initialization successful
         INFO: [GEN_XCLBIN-8] --------------------------------------------------------------------------------------
         INFO: [GEN_XCLBIN-8] [2021-11-09, 19:47:59] gen_xclbin.py END
         INFO: [GEN_XCLBIN-8] --------------------------------------------------------------------------------------

     If option was used :option:`--skip_dcp_gen`, no DCP is generated
     and |xclbin_generate| workflow output contains ``[GEN_XCLBIN-53]``, ``[GEN_XCLBIN-55]`` and ``[GEN_XCLBIN-38]`` messages, like the following:

     .. code-block:: bash
         :emphasize-lines: 4,5,6

         STATUS: [GEN_XCLBIN-36] -- Executing command: vivado -mode batch -verbose -journal <xbtest_build>/xclbin_generate/output/xilinx_u55c_gen3x16_xdma_3_202210_1/init/tmp/tmp_wizard_vivado.jou -log <xbtest_build>/xclbin_generate/output/xilinx_u55c_gen3x16_xdma_3_202210_1/init/tmp/tmp_wizard_vivado.log -source <xbtest_build>/xclbin_generate/output/xilinx_u55c_gen3x16_xdma_3_202210_1/init/wizard.tcl
         INFO: [GEN_XCLBIN-36] Command finished. Duration: 0:01:37
         STATUS: [GEN_XCLBIN-37] **** End of step: run Vivado to create XOs and Vitis run script. Elapsed time: 0:02:37
         INFO: [GEN_XCLBIN-53] Workflow templates were generated in <xbtest_build>/xclbin_generate/output/xilinx_u55c_gen3x16_xdma_3_202210_1/init/u_ex/run/cfg_template
         INFO: [GEN_XCLBIN-55] Initialization successful
         INFO: [GEN_XCLBIN-38] Script terminating as DCP generation is skipped
         INFO: [GEN_XCLBIN-8] --------------------------------------------------------------------------------------
         INFO: [GEN_XCLBIN-8] [2021-11-10, 10:40:23] gen_xclbin.py END
         INFO: [GEN_XCLBIN-8] --------------------------------------------------------------------------------------

  4. Finally, copy the generated templates:

       a. Create the destination directory:

          .. code-block:: bash

              $ mkdir -p <xbtest_build>/xclbin_generate/cfg/<dev_platform>

       b. Copy the generated templates

          .. code-block:: bash

              $ cp -r <xbtest_build>/xclbin_generate/output/<dev_platform>/init/u_ex/run/cfg_template/* <xbtest_build>/xclbin_generate/cfg/<dev_platform>

.. _initialize-power-floorplan-sources:

=====================================================
Initialize power floorplan sources
=====================================================

The power CU configuration requires 3 files (see :ref:`define-power-cu-floorplan`).
The section explains how to create the templates which you will edit later according to your card power requirements.

Run provided TCL script ``gen_dynamic_geometry.tcl`` as detailed below.
The generated templates will be saved in ``<xbtest_build>/xclbin_generate/cfg/<dev_platform>/pwr_cfg``.

  * |<xbtest_build> def|
  * |<dev_platform> def|

You need a DCP generated with your platform:

  * If you don't have one already, it can be generated in previous steps (:ref:`initialize-using-xclbin_generate`) with |xclbin_generate| workflow using command line option :option:`--init`.
  * If you've got one, there are 2 ways of generating templates depending if you've opened the DCP with Vivado or not:

      * :ref:`batch-mode`: You don't open the DCP.
      * :ref:`interactive-mode`: You've already opened the DCP in Vivado.

---------------------------------------------------
Inputs
---------------------------------------------------

The following table describes the script inputs, where:

  * |<xbtest_build> def|
  * |<dev_platform> def|

.. table:: Power floorplan initialization inputs

    +-------------------------+------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------+
    | Input                   | Description                                                                        | Example                                                                                                                                         |
    +=========================+====================================================================================+=================================================================================================================================================+
    | ``<dcp_name>``          | Path to DCP                                                                        | ``<xbtest_build>/xclbin_generate/output/<dev_platform>/init/u_ex/run/vpp_link/link/vivado/vpl/prj/prj.runs/impl_1/level0_wrapper_opt.dcp``      |
    +-------------------------+------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``<pwr_floorplan_dir>`` | Path to output directory where :ref:`power-floorplan-templates` will be generated. | ``<xbtest_build>/xclbin_generate/cfg/<dev_platform>/pwr_cfg``                                                                                   |
    +-------------------------+------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``<dynamic_pblocks>``   | List the names of each pblock of dynamic region (usually one pblock per SLR).      | ``pblock_dynamic_SLR0 pblock_dynamic_SLR1``                                                                                                     |
    | ``<dynamic_pblocks>``   | Pblock names depend on your platform.                                              |                                                                                                                                                 |
    +-------------------------+------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------+

.. _batch-mode:

---------------------------------------------------
Batch mode
---------------------------------------------------

In this mode, you don't need to open manually the DCP, the script will do all the steps for you.

Use the following commands:

  1. Move to ``xclbin_generate`` sources directory:

     .. code-block:: bash

         $ cd <xbtest_build>/xclbin_generate

  2. Opens Vivado in batch mode and run script which reads the DCP and generates the templates:

     .. code-block:: bash

         $ vivado -mode tcl -source <xbtest_catalog>/xbtest_wizard_v6_0/tcl/power/gen_dynamic_geometry.tcl -tclargs <dcp_name> <pwr_floorplan_dir> <dynamic_pblocks>

     Example command:

     .. code-block:: bash

         $ vivado -mode tcl \
                  -source  <xbtest_catalog>/xbtest_wizard_v6_0/tcl/power/gen_dynamic_geometry.tcl \
                  -tclargs <xbtest_build>/xclbin_generate/output/<dev_platform>/init/u_ex/run/vpp_link/link/vivado/vpl/prj/prj.runs/impl_1/level0_wrapper_opt.dcp \
                           <xbtest_build>/xclbin_generate/cfg/<dev_platform>/pwr_cfg \
                           pblock_dynamic_SLR0 pblock_dynamic_SLR1 pblock_dynamic_SLR2

Where:

  * |<xbtest_catalog> def|
  * |<xbtest_build> def|
  * |<dev_platform> def|

.. _interactive-mode:

---------------------------------------------------
Interactive mode
---------------------------------------------------

If your DCP is already opened, you can use the following commands.

In the Vivado TCL console:

  1. Open a DCP of the platform:

     .. code-block::

         open_checkpoint <xbtest_build>/xclbin_generate/output/<dev_platform>/init/u_ex/run/vpp_link/link/vivado/vpl/prj/prj.runs/impl_1/level0_wrapper_opt.dcp

  2. Set script inputs:

     .. code-block::

         set argv [list <xbtest_build>/xclbin_generate/output/<dev_platform>/init/u_ex/run/vpp_link/link/vivado/vpl/prj/prj.runs/impl_1/level0_wrapper_opt.dcp \
                        <xbtest_build>/xclbin_generate/cfg/<dev_platform>/pwr_cfg \
                        pblock_dynamic_SLR0 pblock_dynamic_SLR1 pblock_dynamic_SLR2 ]
         set argc [llength $argv]
         set DCP_OPENED true

  3. Source provided TCL script:

     .. code-block::

         source <xbtest_catalog>/xbtest_wizard_v6_0/tcl/power/gen_dynamic_geometry.tcl

Where:

  * |<xbtest_catalog> def|
  * |<xbtest_build> def|
  * |<dev_platform> def|