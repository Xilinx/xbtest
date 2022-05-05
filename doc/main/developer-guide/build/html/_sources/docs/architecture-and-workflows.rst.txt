
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _architecture-and-workflow:

##########################################################################
Architecture and workflows
##########################################################################

xbtest sources and workflows will allow you to build and packages an xclbin compatible with the performances and capabilities of your platform.

********************************************************
xbtest compute units architecture
********************************************************

Depending on resources of your platform, here is a view of the various xbtest compute units (CUs) available (along with some of their connectivity).
These CUs contain the resources to test your platform (GT and memories) but also to consume a programmable amount of power.

.. important::
    xbtest requires at least 1 PLRAM is present in your platform.
    If your |Alveo|_ card is fitted with a multi SLR FPGA type, ideally there should be 1 PLRAM per SLR.

.. figure:: ../../../../main/user-guide/source/docs/diagram/alveo-card-block-diagram.svg
    :align: center

    Alveo card block diagram

.. _xbtest_cu_list:

.. table:: Compute units high level overview

    +------------+-------------------------------------------------------------------------------------------------------+
    | CU type    | Description                                                                                           |
    +============+=======================================================================================================+
    | Memory     | * **Single-channel** (e.g. DDR, PL_DDR, HOST):                                                        |
    |            |                                                                                                       |
    |            |     * 1 or more identical CU instances.                                                               |
    |            |     * 1 M_AXI interface per CU.                                                                       |
    |            |                                                                                                       |
    |            | * **Multi-channel** (e.g. HBM, PS_DDR):                                                               |
    |            |                                                                                                       |
    |            |     * Only 1 CU instance.                                                                             |
    |            |     * Multiple M_AXI interfaces.                                                                      |
    |            |                                                                                                       |
    +------------+-------------------------------------------------------------------------------------------------------+
    | Power      | * 1 CU instance per SLR.                                                                              |
    |            | * If not already provided, define its floorplan.                                                      |
    |            |                                                                                                       |
    +------------+-------------------------------------------------------------------------------------------------------+
    | GT_MAC     | * 1 CU instance per GT Quad.                                                                          |
    |            | * 4 lanes per CU instance.                                                                            |
    |            | * 10/25 GbE supported lane rates.                                                                     |
    |            | * Uses and requires license for |XXV|_.                                                               |
    |            |                                                                                                       |
    +------------+-------------------------------------------------------------------------------------------------------+
    | GT_PRBS    | * 64/66b PRBS31 at 25GbE rate generator.                                                              |
    |            | * Ideal for platform which can't support multiple GT MAC CU (resource, timing closure limitation...). |
    |            |                                                                                                       |
    +------------+-------------------------------------------------------------------------------------------------------+
    | GT_LPBK    | * GT rate adaptation loopback CU.                                                                     |
    |            | * Only support 25GbE without FEC.                                                                     |
    |            | * Requires the presence of at least 1 other GT MAC CU.                                                |
    |            |                                                                                                       |
    +------------+-------------------------------------------------------------------------------------------------------+
    | Verify     | * 1 CU instance always included in the xclbin.                                                        |
    |            | * Used to read the FPGA DNA (when available).                                                         |
    |            | * Contains the watchdog and the clock throttling detection.                                           |
    |            |                                                                                                       |
    +------------+-------------------------------------------------------------------------------------------------------+

.. _hw-sources-overview:

********************************************************
HW sources overview
********************************************************

The HW sources used to create and package your xclbin are located in ``<xbtest_local_repo>/src/hw`` directory (see :ref:`xbtest-sources`):

  * ``xbtest_catalog/``: xbtest IP catalog.
  * ``build_source/xbtest_wizard_v6_0/``: xclbin and RPM/DEB build workflows sources.

      * ``xclbin_generate/``: |xclbin_generate| workflow sources.

          * ``cfg/``: Examples of xclbin configuration for various platforms:

              * ``pwr_cfg/``: :ref:`power-floorplan-sources-definition`.
              * ``vpp_cfg/``: |Vitis configuration|.
              * ``wizard_cfg.json``: :ref:`wizard-configuration-json-file`.

      * ``rpm_generate/``: |rpm_generate| workflow sources.

          * ``include/``: Example of files included in RPM/DEB package for various platforms:

              * ``xbtest_pfm_def.json``: :ref:`platform-definition-JSON-file`.

These HW sources are structured as:

.. code-block:: bash

    <xbtest_local_repo>/src/hw
    ├── build_source/
    │   └── xbtest_wizard_v6_0/
    │       ├── rpm_generate/
    │       │   ├── build/
    │       │   ├── include/
    │       │   ├── gen_rpm.py
    │       │   └── xbtest_deps.sh
    │       └── xclbin_generate/
    │           ├── build/
    │           ├── cfg/
    │           └── gen_xclbin.py
    └── xbtest_catalog/
        ├── xbtest_sub_xxv_gt_v1_0/
        └── xbtest_wizard_v6_0/

.. _hw-build-workflows:

********************************************************
HW build workflows overview
********************************************************

xbtest HW packages are built with following workflows:

  * |xclbin_generate|: Create the xclbin.
  * |rpm_generate|: Create xbtest HW package.
  * |checklist|: Manual check of the xclbin & packages.

.. _xclbin_generate:
.. _rpm_generate:

.. table:: HW build workflows

    +---------------------+--------------------+---------------------------------------------------------------------------------------+-----------------------------------------------------+-----------------------------------------------------------+
    | Workflow            | Component          | Description                                                                           | Input products                                      | Output products                                           |
    +=====================+====================+=======================================================================================+=====================================================+===========================================================+
    | ``xclbin_generate`` | ``xbtest_wizard``  | Use ``xbtest_wizard`` IP to generate all products required to build an xclbin.        | * Power CU floorplan definition.                    | * XOs: 1 per CU including:                                |
    |                     |                    |                                                                                       | * Wizard configuration JSON.                        |                                                           |
    |                     |                    | From Vivado IP catalog, this workflow creates and customizes the various CU RTL IPs.  | * Vitis INI option file.                            |   * RTL IP customized with some user parameters.          |
    |                     |                    |                                                                                       | * TCL hooks.                                        |   * An XML file defining AXI address map.                 |
    |                     |                    | CUs RTL IPs are finally packaged as XO to be consumed by Vitis linker.                | * Platform XPFM.                                    |                                                           |
    |                     |                    |                                                                                       |                                                     | * User metadata: xclbin user metadata JSON file.          |
    |                     |                    |                                                                                       |                                                     | * Vitis option files.                                     |
    |                     |                    |                                                                                       |                                                     | * AIE compiler outputs.                                   |
    |                     |                    |                                                                                       |                                                     | * ``build_xclbin.sh`` script: commands to generate xclbin |
    |                     |                    |                                                                                       |                                                     |   (AIE compiler, Vitis linker/packager, xclbinutil).      |
    |                     |                    |                                                                                       |                                                     |                                                           |
    +---------------------+--------------------+---------------------------------------------------------------------------------------+-----------------------------------------------------+-----------------------------------------------------------+
    |                     | ``build_xclbin``   | Run Vitis tools required to build the xclbin.                                         | * ``xbtest_wizard`` outputs.                        | * DCP.                                                    |
    |                     |                    |                                                                                       | * Platform XPFM.                                    | * xclbin in which are embedded:                           |
    |                     |                    |                                                                                       |                                                     |                                                           |
    |                     |                    |                                                                                       |                                                     |   * Pre-canned test JSON files.                           |
    |                     |                    |                                                                                       |                                                     |   * Template platform definition JSON file.               |
    |                     |                    |                                                                                       |                                                     |                                                           |
    +---------------------+--------------------+---------------------------------------------------------------------------------------+-----------------------------------------------------+-----------------------------------------------------------+
    | ``rpm_generate``    |                    | Package the xclbin and its customization JSON files to RPM/DEB deliverables.          | * xclbin.                                           | RPM/DEB packages.                                         |
    |                     |                    |                                                                                       | * Pre-canned tests JSON files.                      |                                                           |
    |                     |                    |                                                                                       | * Platform definition JSON file.                    |                                                           |
    |                     |                    |                                                                                       |                                                     |                                                           |
    +---------------------+--------------------+---------------------------------------------------------------------------------------+-----------------------------------------------------+-----------------------------------------------------------+
    | ``checklist``       |                    | Process of verifying the xclbin and updating the platform definition JSON file.       | RPM/DEB packages.                                   | Checklist.                                                |
    |                     |                    |                                                                                       |                                                     |                                                           |
    |                     |                    |   * Updates to the xclbin configuration may be required after checklist is completed. |                                                     |                                                           |
    |                     |                    |                                                                                       |                                                     |                                                           |
    +---------------------+--------------------+---------------------------------------------------------------------------------------+-----------------------------------------------------+-----------------------------------------------------------+

The following figures represents the different HW build workflows and their inputs/outputs:

.. figure:: ./diagram/hw-build-workflows.svg
    :align: center

    HW build workflows

Here is the default location of the various files present in the diagram:

.. table:: ``xclbin_generate`` file locations

    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | File                        | Description / location                                                                                                                                            |
    +=============================+===================================================================================================================================================================+
    | **Input products**                                                                                                                                                                              |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | IP catalog                  | Provided IP catalog:                                                                                                                                              |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_catalog>``                                                                                                                                          |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Vitis INI                   | Configuration of Vitis (see :ref:`configure-vitis`):                                                                                                              |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/cfg/<dev_platform>/vpp_cfg/vpp.ini``                                                                                         |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Post system linker TCL hook | Required Vitis TCL hook (see :ref:`required-tcl-hooks`):                                                                                                          |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/cfg/<dev_platform>/vpp_cfg/post_syslink.tcl``                                                                                |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Optional TCL hook           | Optional Vitis TCL hook (see :ref:`optional-tcl-hooks`):                                                                                                          |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/cfg/<dev_platform>/vpp_cfg/place_design_pre.tcl``                                                                            |
    |                             |   * ``<xbtest_build>/xclbin_generate/cfg/<dev_platform>/vpp_cfg/route_design_pre.tcl``                                                                            |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Power CU configuration      | Configuration of the power cu (see :ref:`define-power-cu-floorplan`):                                                                                             |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/cfg/<dev_platform>/pwr_cfg``                                                                                                 |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Wizard configuration        | Define and configure the content of the xclbin (see :ref:`wizard-configuration-json-file`):                                                                       |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/cfg/<dev_platform>/pwr_cfg``                                                                                                 |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **Intermediate products**                                                                                                                                                                       |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``build_xclbin`` script     | Actual script used to run Vitis:                                                                                                                                  |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/build_xclbin.sh``                                                              |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Vitis option files          | Various intermediate Vitis files:                                                                                                                                 |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/vpp_link.ini``                                                                 |
    |                             |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/vpp_package.ini``                                                              |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Wizard configuration files  | Various intermediate configuration files (see :ref:`configure-xclbin_overview`):                                                                                  |
    |                             |                                                                                                                                                                   |
    | * auto                      |   * Extracted from the platform: ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/wizard_auto_config.json``                         |
    | * user                      |   * Copy of the input wizard configuration JSON: ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/wizard_user_config.json``         |
    | * actual                    |   * Merge of the 2 previous configurations: ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/wizard_actual_config.json``            |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | XOs                         | Generated XOs from the IP catalog based on the configuration. These XOs will be used by Vitis:                                                                    |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/kernel_xo``                                                                    |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | AIE compiler outputs        | AIE compiler results:                                                                                                                                             |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/libadf.a``                                                                     |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | User metadata               | User metadata which will be inserted in the xclbin. Internally used to transfer information between workflows.                                                    |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/user_metadata.json``                                                           |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **Output products**                                                                                                                                                                             |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | xclbin                      | Generated xclbin:                                                                                                                                                 |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/<project_name>.xclbin``                                                                 |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | JSON templates              | Template provided as reference for manual editing or calibration (see :ref:`select-pre-canned-tests` and :ref:`platform-definition-JSON-file`):                   |
    |                             |                                                                                                                                                                   |
    | * Pre-canned test           |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/sw/test/*.json``                                                                   |
    | * Platform definition       |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/sw/xbtest_pfm_def_template.json``                                                  |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | DCP                         | Vivado design checkpoint:                                                                                                                                         |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/vpp_link/<...>/prj.runs/impl_1/level0_wrapper_postroute_physopt.dcp``          |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+

.. table:: ``rpm_generate`` file locations

    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | File                        | Description / location                                                                                                                                            |
    +=============================+===================================================================================================================================================================+
    | **Input products**                                                                                                                                                                              |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | xclbin                      | xclbin copied from its generated location:                                                                                                                        |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/rpm_generate/include/<deploy_platform>/xclbin/xbtest_stress.xclbin``                                                                         |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | JSON files                  | Updated templates after checklist filling (see :ref:`select-pre-canned-tests` and :ref:`platform-definition-JSON-file`):                                          |
    |                             |                                                                                                                                                                   |
    | * Pre-canned test           |   * ``<xbtest_build>/rpm_generate/include/<deploy_platform>/test/*.json``                                                                                         |
    | * Platform definition       |   * ``<xbtest_build>/rpm_generate/include/<deploy_platform>/xbtest_pfm_def.json``                                                                                 |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | **Output products**                                                                                                                                                                             |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Packages                    | RPM/DEB packages:                                                                                                                                                 |
    |                             |                                                                                                                                                                   |
    |                             |   * ``<xbtest_build>/rpm_generate/xbtest-<...>.rpm``                                                                                                              |
    |                             |   * ``<xbtest_build>/rpm_generate/xbtest-<...>.deb``                                                                                                              |
    |                             |                                                                                                                                                                   |
    +-----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Where:

  * |<xbtest_build> def|
  * |<xbtest_catalog> def|
  * |<dev_platform> def|
  * |<project_name> def|

These files are structured as follow:

.. code-block:: bash

    ├── <xbtest_catalog>
    └── <xbtest_build>/
        ├── xclbin_generate/
        │   ├── cfg/<dev_platform>/
        │   │   ├── pwr_cfg/
        │   │   │   ├── dynamic_geometry.json
        │   │   │   ├── utilization.json
        │   │   │   └── invalid.json
        │   │   ├── vpp_cfg/
        │   │   │   ├── postsys_link.tcl
        │   │   │   ├── place_design_pre.tcl
        │   │   │   ├── route_design_pre.tcl
        │   │   │   └── vpp.ini
        │   │   └── wizard_cfg.json
        │   └── output/<dev_platform>/<project_name>/
        │       ├── <project_name>.xclbin
        │       └── u_ex/run/
        │           ├── vpp_link/link/vivado/vpl/prj/prj.runs/impl_1/level0_wrapper_postroute_physopt.dcp
        │           ├── kernel_xo/
        │           ├── user_metadata.json
        │           ├── wizard_actual_config.json
        │           ├── wizard_auto_config.json
        │           ├── wizard_user_config.json
        │           ├── vpp_link.ini
        │           ├── vpp_package.ini
        │           ├── libadf.a
        │           ├── build_xclbin.sh
        │           └── sw/
        │               ├──  test/*.json
        │               └── xbtest_pfm_def_template.json
        └── rpm_generate/
            ├── include/
            │   └── <deploy_platform>/
            │       ├── test/*.json
            │       └── xbtest_pfm_def.json
            ├── xbtest-<...>.rpm
            └── xbtest-<...>.deb

=====================================================
``xclbin_generate`` workflow overview
=====================================================

This diagram shows the major steps of the workflow with its input and output products:

.. figure:: ./diagram/xclbin-generate-workflow.svg
    :align: center

    ``xclbin_generate`` workflow overview
