
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _configure-vitis:

##########################################################################
Configure Vitis
##########################################################################

********************************************************
Overview
********************************************************

Within |xclbin_generate| workflow, |Vitis|_ uses different files:

  * Required Vitis TCL hook Post system linker:

      * To connect extra clock.
      * To connect extra signal (power CU).

  * Optional TCL hooks.

      * Extra place and route constraints: LOC, pBlock (optional).

  * Required Vitis options file:

      * Link to TCL hooks.
      * Vivado settings:

          * Place and route strategy.
          * LSF.

You should use the templates generated during the initialization phase (see Workflows initialization).

.. _required-tcl-hooks:

********************************************************
Required Vitis TCL hooks
********************************************************

.. _postsys_link-tcl:

======================================================
Post system linker TCL hook: ``postsys_link.tcl``
======================================================

Updates of :ref:`postsys_link-tcl-template` are done in procedure ``postsys_link_body``.

---------------------------------------------------
Connect continuous clock
---------------------------------------------------

xbtest should be used with a platform created with subsystem v2.0 (or greater).
This sets of IP's ensures a standard clocking structure across platform.
It contains the User Clocking Subsystem (UCS).
This IP creates the 2 clocks used by any Vitis CU (including xbtest).
The UCS can throttle (slow down) the CU clocks when the board is reaching its power or temperature limits.

To ensure reliable measurements, xbtest internal timer can't be slowed down.
So xbtest requires stable clocks.
The continuous (non-throttled) version of each clock can be output by the UCS subsystem and needs to be connected to each CU.
This is done via a :ref:`postsys_link-tcl`.

If you don't connect the continuous clocks to the CUs, xbtest SW will report an error.

As described in following sections, you can use and update the generated :ref:`postsys_link-tcl-template` or alternatively create the commands from scratch.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Using generated template
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In :ref:`postsys_link-tcl-template`, update the call to the procedure (``connect_continuous_clocks``) according to:

  * Presence or absence of UCS subsystem.
  * UCS subsystem version and instance name.

.. code-block::

    connect_continuous_clocks <ucs_name> <ucs_version>

By default, in the template, the connection of continuous clocks is set for UCS subsystem v3.0 and instance named ulp_ucs.
Update according to your platform.

.. code-block::

    # connect_continuous_clocks ulp_ucs 0; # No UCS present, continuous clock is not supported
    # connect_continuous_clocks ulp_ucs 2; # UCS subsystem version v2
    connect_continuous_clocks ulp_ucs 3; # UCS subsystem version v3

The following table describes the supported value of ``connect_continuous_clocks`` procedure inputs:

.. table:: ``connect_continuous_clocks`` inputs

    +-------------------+-------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Input             | Value | Description                                                                                                                                                               |
    +===================+=======+===========================================================================================================================================================================+
    | ``<ucs_name>``    | /     | The UCS may not be called ``ulp_ucs``, update accordingly.                                                                                                                |
    +-------------------+-------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``<ucs_version>`` | 0     | No UCS present: continuous clock is not supported.                                                                                                                        |
    |                   |       | The CU continuous inputs clock will be connected to Vitis CU clocks.                                                                                                      |
    +                   +-------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                   | 2     | UCS subsystem version v2:                                                                                                                                                 |
    |                   |       |                                                                                                                                                                           |
    |                   |       | * Set ``ENABLE_KERNEL_CONT_CLOCK`` property of UCS instance to ``true`` and connect UCS port ``clk_kernel_cont`` to first CU continuous clock ``ap_clk_cont``.            |
    |                   |       | * Set ``ENABLE_KERNEL2_CONT_CLOCK`` property of UCS instance to ``true`` and connect UCS port ``clk_kernel2_cont`` to second CU continuous clock ``ap_clk_2_cont``.       |
    +                   +-------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                   | 3     | UCS subsystem version v3:                                                                                                                                                 |
    |                   |       |                                                                                                                                                                           |
    |                   |       | * Set ``ENABLE_CONT_KERNEL_CLOCK_00`` property of UCS instance to ``true`` and connect UCS port ``aclk_kernel_00_cont`` to first CU continuous clock ``ap_clk_cont``.     |
    |                   |       | * Set ``ENABLE_CONT_KERNEL_CLOCK_01`` property of UCS instance to ``true`` and connect UCS port ``aclk_kernel_01_cont`` to second CU continuous clock ``ap_clk_2_cont``.  |
    +-------------------+-------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Create commands from scratch
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have access to a Vivado project of the platform, you can identify the UCS name, version or simply create the TCL commands to connect continuous clocks from scratch. For example, for UCS subsystem v2:

  1. Open the project.
  2. Open block diagram of the dynamic region (called ``ulp``).
  3. Double-click on the UCS instance to re-customize it. In the following example, the instance is called ``ulp_ucs``:

     .. figure:: ./images/ulp-ucs-inst.png
         :align: center

         ``ulp_ucs`` instance

  4. Enable both ``kernel`` and ``kernel2`` continuous clocks:

     .. figure:: ./images/ulp-ucs-customize.png
         :align: center

         Customize ``ulp_ucs``

     This will create two new ports ``clk_kernel_cont`` and ``clk_kernel2_cont``.
  5. In the block diagram, connect them ``ap_clk_cont`` and ``ap_clk_2_cont`` port of all xbtest IP.
  6. Check the TCL console window to get the equivalent TCL command of the manual steps you've just done.
  7. Add these commands in your :ref:`postsys_link-tcl`.

.. _overwrite-cascaded-power-cu-connectivity:

---------------------------------------------------
Overwrite cascaded power CU connectivity
---------------------------------------------------

By default, when destination power CUs are specified (see :ref:`cu_configuration-power`), they are automatically connected to the first source power CU found in the :ref:`generated-vpp-options-file`.

You can override the default connections in your :ref:`postsys_link-tcl` for any destination power CU:

  * Disconnect clock and control signals from default a source power CU.
  * Connect clock and control signals from new source power CU of same :ref:`cu_configuration-power` type.

The following ports of must be connected:

.. table:: Power CU throttle connections

    +----------------------+---------------------------+
    | Source power CU port | Destination power CU port |
    +======================+===========================+
    | ``pwr_clk_out``      | ``pwr_clk_in``            |
    +----------------------+---------------------------+
    | ``pwr_throttle_out`` | ``pwr_throttle_in``       |
    +----------------------+---------------------------+
    | ``pwr_FF_en_out``    | ``pwr_FF_en_in``          |
    +----------------------+---------------------------+
    | ``pwr_DSP_en_out``   | ``pwr_DSP_en_in``         |
    +----------------------+---------------------------+
    | ``pwr_BRAM_en_out``  | ``pwr_BRAM_en_in``        |
    +----------------------+---------------------------+
    | ``pwr_URAM_en_out``  | ``pwr_URAM_en_in``        |
    +----------------------+---------------------------+

.. note::
    The format of power CU name is ``krnl_powertest_slr<slr_idx>_1`` where ``<slr_idx>`` represents the index of the SLR where the CU is located.
    For example:

      * Power CU in SLR0 is called ``krnl_powertest_slr0_1``.
      * Power CU in SLR1 is called ``krnl_powertest_slr1_1``.

.. _optional-tcl-hooks:

********************************************************
Optional TCL hooks
********************************************************

Other TCL hooks may be defined to be used as different steps of the |Vitis|_ build flow.
Refer to Vitis documentation for how to define them.

Examples of :ref:`place_design_pre-tcl` and :ref:`route_design_pre-tcl` used to help meeting timing requirements are provided in :ref:`xclbin-timing-closure-tips`.

Template & place holder :ref:`place_design_pre-tcl-template` and :ref:`route_design_pre-tcl-template` can also be used as reference: see :ref:`templates-description`.

.. _place_design_pre-tcl:

=====================================================
Pre-placer TCL hook: ``place_design_pre.tcl``
=====================================================

---------------------------------------------------
NOC Constraints (Versal)
---------------------------------------------------

**TODO**

.. _route_design_pre-tcl:

=====================================================
Pre-router TCL hook: ``route_design_pre.tcl``
=====================================================

**TODO**

.. _generated-vpp-options-file:

********************************************************
Generated Vitis options file: ``vpp_link.ini``
********************************************************

This file is automatically generated by the |xclbin_generate| workflow.

It contains the following Vitis options:

  * Clock configuration:

      * Clock frequency.
      * Disable clock frequency scaling.

   * SLR assignment of each CU.
   * One PLRAM connection per CU.
   * Memory connections (for memory CU).
   * CU inter-connections:

       * Verify CU watchdog alarm.
       * Power CU default connectivity.

.. _vpp-options-file:

********************************************************
Vitis options file: ``vpp.ini``
********************************************************

You can add extra |Vitis|_ options via the INI file :ref:`vpp-options-file` (see ``vpp_options_dir`` parameter in :ref:`wizard-configuration-json-file`).
This is passed to Vitis linker with ``--config`` command line option of v++. You can use and updated generated :ref:`vpp-options-file-template`.

.. important::
    The content of :ref:`vpp-options-file` provided using ``vpp_options_dir`` overwrites any value set by |xclbin_generate| workflow in the :ref:`generated-vpp-options-file`.
    Make sure there are no conflicts.

These extra Vitis configurations are typically used to set referenced to for example:

  * TCL hooks:

      * :ref:`postsys_link-tcl` (required) or other optional TCL hooks.

  * Vivado implementation directives:

      * ``xbtest_wizard`` does not use any directive by default.
        Those can be added by the user if needed.

Refer to Vitis documentation for supported Vitis options.

=====================================================
``remote_ip_cache``
=====================================================

|Vitis|_ caches intermediate synthesis result.
In case of successive builds, the synthesis can be speeded up by reusing previous synthesized block.

Tell Vitis to store the cache under ``<xbtest_build>/xclbin_generate/output/<dev_platform>/remote_ip_cache`` folder by adding the following to your :ref:`vpp-options-file` (at the top of the file).

.. code-block:: INI

    remote_ip_cache=../../../remote_ip_cache/

Where:

  * |<xbtest_build> def|
  * |<dev_platform> def|

=====================================================
Relative Paths
=====================================================

The |xclbin_generate| workflow copies the files in the configuration directory into the run directory.
It is recommended to set all paths in the configuration relatively to the |xclbin_generate| output directory so ``xbtest_wizard`` and |Vitis|_ can use these local copies instead of the source files directly.

In :ref:`vpp-options-file`, use relative path to run directory: ``../../``

.. code-block:: INI

    [advanced]
    param=compiler.userPostSysLinkOverlayTcl=../../vpp_cfg/postsys_link.tcl

    [vivado]
    prop=run.impl_1.STEPS.PLACE_DESIGN.TCL.PRE=../../vpp_cfg/place_design_pre.tcl
    prop=run.impl_1.STEPS.ROUTE_DESIGN.TCL.PRE=../../vpp_cfg/route_design_pre.tcl

********************************************************
Vitis configuration examples
********************************************************

The following table provides examples of |Vitis|_ configuration for different platforms:

.. table:: Vitis configuration examples

    +---------------------------------------+-------------------------------+
    | Platform                              | Examples                      |
    +=======================================+===============================+
    | xilinx_u55c_gen3x16_xdma_3_202210_1   | |u55c postsys_link.tcl|_      |
    +                                       +-------------------------------+
    |                                       | |u55c place_design_pre.tcl|_  |
    +                                       +-------------------------------+
    |                                       | |u55c route_design_pre.tcl|_  |
    +                                       +-------------------------------+
    |                                       | |u55c vpp.ini|_               |
    +---------------------------------------+-------------------------------+
    | xilinx_u250_gen3x16_xdma_4_1_202210_1 | |u250 postsys_link.tcl|_      |
    +                                       +-------------------------------+
    |                                       | |u250 place_design_pre.tcl|_  |
    +                                       +-------------------------------+
    |                                       | |u250 route_design_pre.tcl|_  |
    +                                       +-------------------------------+
    |                                       | |u250 vpp.ini|_               |
    +---------------------------------------+-------------------------------+
    | xilinx_u50lv_gen3x4_xdma_2_202010_1   | |u50lv postsys_link.tcl|_     |
    +                                       +-------------------------------+
    |                                       | |u50lv place_design_pre.tcl|_ |
    +                                       +-------------------------------+
    |                                       | |u50lv route_design_pre.tcl|_ |
    +                                       +-------------------------------+
    |                                       | |u50lv vpp.ini|_              |
    +---------------------------------------+-------------------------------+
