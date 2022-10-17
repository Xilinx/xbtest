
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _configure-xclbin:

##########################################################################
Configure xclbin
##########################################################################

.. _configure-xclbin_overview:

********************************************************
Overview
********************************************************

To configure an xclbin, you need to:

  * Select the CU you want to include: :ref:`xbtest_cu_list`.
  * Configure the content of the xclbin itself (as described in this page)

      * Define :ref:`wizard-configuration-json-file`: CU selection and their configurations.

  * Configure |Vitis|_ (see :ref:`configure-vitis`).

          * Add extra connections to the CUs: :ref:`postsys_link-tcl`.

              * CU requires an extra continuous clock.
              * Inter control CU signals (potentially).

          * Specify Vitis & Vivado options: :ref:`vpp-options-file`.

              * Tool specific options: e.g. placement constraints, place and route strategy.

The :ref:`wizard-configuration-json-file` is provided to the |xclbin_generate| workflow:

.. figure:: ./diagram/wizard-configuration.svg
    :align: center

    Wizard configuration

The actual wizard configuration of the xclbin (saved in file named ``wizard_actual_config.json``) is a merge between:

  * Auto wizard configuration: what the platform is capable of.

      * This is automatically generated based on the :ref:`configure-xclbin-platform-metadata`.
      * This configuration is saved in file called ``wizard_auto_config.json``.

  * :ref:`wizard-configuration-json-file`: what you want in the xclbin.

      * You can overwrite any of the auto-configured settings.
      * A copy is saved in file called ``wizard_user_config.json``.

These 3 files are in:

  * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/``

    Where:

      * |<xbtest_build> def|
      * |<dev_platform> def|
      * |<project_name> def|

These configuration JSON files have the same structure:

  * ``default``

      * :ref:`platform <configure-xclbin-platform>`
      * :ref:`build <configure-xclbin-build>`
      * :ref:`cu_configuration <configure-xclbin-cu_configuration>`

  * ``xclbin_configuration``

      * :ref:`platform <configure-xclbin-platform>`
      * :ref:`build <configure-xclbin-build>`
      * :ref:`cu_configuration <configure-xclbin-cu_configuration>`
      * :ref:`cu_selection <configure-xclbin-cu_selection>`

.. note::
    Any default settings can be overwritten inside the ``xclbin_configuration`` section

.. _configure-xclbin-platform-metadata:

********************************************************
Platform metadata
********************************************************

xbtest uses the following |Vitis|_ command to generate a platform metadata JSON file:

  * If ``.xpfm`` file is provided

    .. code-block:: bash

        $ platforminfo -p path/to/your/platform.xpfm -j hardwarePlatform -o <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/platforminfo.json

  * If ``.xsa`` file is provided

    .. code-block:: bash

        $ platforminfo -p path/to/your/platform/hw.xsa -o <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/platforminfo.json

.. note::
    The platform metadata JSON file is saved in ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/platforminfo.json``.

    Where:

      * |<xbtest_build> def|
      * |<dev_platform> def|
      * |<project_name> def|

The following information is extracted from the platform metadata JSON:

  * ``uniqueName``
  * ``extensions``

      * ``xclbin.append_sections.partition_metadata.interfaces[0].interface_uuid``
      * ``raptor2``

          * ``part``
          * ``slrs``
          * ``resources``

              * ``<memory_type>``  where ``<memory_type>`` is ``PLRAM``, ``DDR``, ``HBM`` or ``HOST``.

                  * ``sptag``
                  * ``index``
                  * ``slr``

              * ``gts.<gt_idx>`` where ``<gt_idx>`` is ``0``, ``1``, ...

                  * ``gt_serial_port``
                  * ``diff_clocks``
                  * ``slr_assignment``
                  * ``gt_type``
                  * ``gt_group_select``

If one of the expected information is not present in your platform metadata, you'll have to define everything in the :ref:`wizard-configuration-json-file`.

.. important::
    Do not confuse this platform metadata with xbtest platform definition.

      * The first one is linked to the ``.xpfm`` file present in the development platform package.
        This file contains platform metadata including information on interface, clock, valid SLRs, allocated resources and memory.
        This info is required to build xbtest xclbin.
      * The second is the :ref:`platform-definition-JSON-file` which describes to xbtest SW how to use the xclbin (see :ref:`fill-platform-definition-json`).

.. _wizard-configuration-json-file:

********************************************************
Wizard configuration JSON file: ``wizard_cfg.json``
********************************************************

This file is used as input of the |xclbin_generate| workflow which creates the xclbin (see :ref:`build-xclbin`).
It defines which CUs are present in the xclbin (quantity, localization and some basic configuration).

This JSON file consists of a list of configurations. Each one describes the content of a xclbin.

This file contains multiple sections:

  * ``default``: section used to define parameters values used for all configurations (see :ref:`default-section`)

      * Most of the parameters are automatically extracted from the :ref:`configure-xclbin-platform-metadata`.
      * Overwrite (or add) parameter of the platform definition.

  * ``xclbin_configuration``: sections defining various configuration.

      * Any configuration names are allowed. It's at build time that you select which xclbin you want to generate via the |xclbin_generate| command line option :option:`--wizard_config_name`.
      * CU selections: power, memory, GT_MAC, GT_PRBS and GT_LPBK.

        .. note::
            To test the GT, we recommend using GT_MAC. If there is not enough resource in the FPGA for multiple of them, we suggest using GT_PRBS as it doesn't require a traffic source.

      * Extra CU configuration: any ``default`` settings can be overwritten.

        .. note::
            We recommend to name xbtest_stress, the configuration used to generate the delivered xclbin.

This page will guide you through the creation of :ref:`wizard-configuration-json-file` step by step.
Starting by the :ref:`default-section` then walk you through all supported CU.

This page also contains :ref:`wizard-configuration-examples` for different platforms.
Further you'll find the complete definition of all supported parameters.

You should use and update the :ref:`wizard-configuration-json-file-template` generated during the initialization phase.

.. _default-section:

=====================================================
``default`` section
=====================================================

In this section, you will be able to:

  1. Define where to find power CU floorplan sources.
  2. Include link to |Vitis|_ configuration.
  3. Overwrite (or add) the definition of the platform:

       * Clock: by default, xbtest uses 2 clocks:

           * 300 MHz: AXI infrastructure.
           * 500 MHz: power CU.

       * PLRAM: location (SLR) & selection (multiple PLRAM could be present within the same SLR).

           * Each CU requires a PLRAM connection. To optimize performance, you need to connect the CU to the PLRAM of the same SLR.

       * Location of CU: SLR selection.
       * GT connections: reference clock and port.
       * Memory CU configuration:

           * Connections to the platform memory infrastructure: sptag.
           * Type: single/multi-channel.
           * AXI4 configuration: data size, thread, max supported outstanding transaction.

You only need to overwrite parameter if they are not defined as expected in the platform information.

Link to the power CU floorplan sources and Vitis configuration are defined in the ``build`` section, while ``platform`` & ``cu_configuration`` can be used to overwrite (or define) platform and CU settings:

  * ``build``

      * ``pwr_floorplan_dir``: directory of power CU floorplan sources.
      * ``vpp_options_dir``: directory containing Vitis configuration.
      * ``display_pwr_floorplan``.
      * ``vpp_link_output``.

  * ``platform``

      * ``fpga_part``.
      * ``name``.
      * ``interface_uuid``.
      * ``is_nodma``.
      * ``p2p_support``.
      * ``mac_addresses_available``.
      * ``gt``: ``slr``, ``type``, ``group_select`` (quad).

  * ``cu_configuration``

      * ``power``: Throttle mode (see :ref:`cu_configuration-power`).
      * ``memory``: Type, target/connection, AXI4 configuration (see :ref:`cu_configuration-memory`).
      * ``gt``: Differential clock and port selection (see :ref:`cu_configuration-gt` and :ref:`cu_configuration-gt_mac`).
      * ``gt_mac``: XXV IP selection.
      * ``gt_prbs`` and ``gt_lpbk``
      * ``verify``: SLR and DNA read selection (see :ref:`cu_configuration-verify`)
      * ``clock``: frequency (see :ref:`cu_configuration-clock`).
      * ``plram_selection``: SLR location and selection (see :ref:`cu_configuration-plram_selection`).

.. important::
    With Versal device, the default clock settings should be updated to maximize the AIEngine power consumption (see :ref:`cu_configuration-clock`).

.. _configure-xclbin-platform:

=================================================================
``platform`` parameters of wizard configuration JSON file
=================================================================

The following table describes the parameters supported under the ``platform`` node of the :ref:`wizard-configuration-json-file`.

.. table:: ``platform`` parameters of wizard configuration JSON file

    +-------------------------+-------------------+---------------+----------------------------------------------------------------------------------------------------------------+
    | Node name                                                   | Description                                                                                                    |
    +=========================+===================+===============+================================================================================================================+
    | fpga_part               |                   |               | FPGA part number.                                                                                              |
    +-------------------------+-------------------+---------------+----------------------------------------------------------------------------------------------------------------+
    | name                    |                   |               | XSA name.                                                                                                      |
    +-------------------------+-------------------+---------------+----------------------------------------------------------------------------------------------------------------+
    | interface_uuid          |                   |               | XSA interface UUID. See :ref:`platform-interface_uuid`.                                                        |
    +-------------------------+-------------------+---------------+----------------------------------------------------------------------------------------------------------------+
    | is_nodma                |                   |               | Set to ``true`` for NoDMA platform so the DMA pre-canned test will not be included by default.                 |
    |                         |                   |               |                                                                                                                |
    |                         |                   |               | Possible values: ``true`` or ``false``.                                                                        |
    |                         |                   |               |                                                                                                                |
    |                         |                   |               | Defaults to: ``false``.                                                                                        |
    +-------------------------+-------------------+---------------+----------------------------------------------------------------------------------------------------------------+
    | p2p_support             |                   |               | Indicate if the platform supports P2P.                                                                         |
    |                         |                   |               | When set to ``true``, the P2P pre-canned tests will be included in the definition of default pre-canned tests. |
    |                         |                   |               |                                                                                                                |
    |                         |                   |               | Possible values: ``true`` or ``false``.                                                                        |
    |                         |                   |               |                                                                                                                |
    |                         |                   |               | Defaults to: ``true``.                                                                                         |
    +-------------------------+-------------------+---------------+----------------------------------------------------------------------------------------------------------------+
    | mac_addresses_available |                   |               | Number of available board MAC addresses. See :ref:`platform-mac_addresses_available`.                          |
    |                         |                   |               |                                                                                                                |
    |                         |                   |               | Possible values: ``default`` or positive integer.                                                              |
    |                         |                   |               |                                                                                                                |
    |                         |                   |               | Defaults to: ``default``.                                                                                      |
    +-------------------------+-------------------+---------------+----------------------------------------------------------------------------------------------------------------+
    | gt                      | ``<gt_idx>``      |               | GT index. See :ref:`platform-gt`.                                                                              |
    +-------------------------+-------------------+---------------+----------------------------------------------------------------------------------------------------------------+
    |                         |                   | slr           | SLR assignment of the GT. GT capable CU will be assigned to the SLR.                                           |
    |                         |                   |               |                                                                                                                |
    |                         |                   |               | Possible values: ``SLR<x>`` format where ``<x>`` is the SLR index.                                             |
    +                         +                   +---------------+----------------------------------------------------------------------------------------------------------------+
    |                         |                   | type          | Type of GT.                                                                                                    |
    |                         |                   |               |                                                                                                                |
    |                         |                   |               | Possible values: ``GTM`` or ``GTY``                                                                            |
    |                         |                   |               |                                                                                                                |
    |                         |                   |               | Defaults to: ``GTY`` when ``gt_type`` not defined in :ref:`configure-xclbin-platform-metadata`.                |
    +                         +                   +---------------+----------------------------------------------------------------------------------------------------------------+
    |                         |                   | group_select  | GT group (Quad) assignment                                                                                     |
    +-------------------------+-------------------+---------------+----------------------------------------------------------------------------------------------------------------+

.. _platform-mac_addresses_available:

-----------------------------------------------------------
``mac_addresses_available``: Available board MAC addresses
-----------------------------------------------------------

When ``mac_addresses_available`` is:

  * set to ``default`` or greater than the maximum number of necessary MAC addresses for all GT_MAC CUs (1 address per lane for each GT_MAC CU), then all lanes of all GTs are used in the GT pre-canned tests.
  * else, then the GT pre-canned tests will be automatically updated based on the number of available board MAC addresses.
    Some lanes are assigned with an available board MAC address and other lanes are disabled.

      * ``gt_mac.json``: One MAC address is assigned for each lane of each GT_MAC CU (``GT[0].lane[0]``, ``GT[1].lane[0]``, ``GT[0].lane[1]``, ``GT[1].lane[1]``, etc).
      * ``gt_mac_lpbk.json``: Similar to ``gt_mac.json``.
      * ``switch_25gbe.json``: MAC addresses are assigned for each lane pair of each GT_MAC CU (``GT[0].lane[0/1]``, ``GT[1].lane[0/1]``, ``GT[0].lane[2/3]``, ``GT[1].lane[2/3]``, etc).
      * ``switch_10gbe.json``: Similar to ``switch_25gbe.json``.
      * ``stress.json``: Similar to ``switch_25gbe.json``.
      * ``gt_mac_port_to_port.json``: MAC addresses are assigned for each lane connection between two GT_MAC CUs (``GT[0/1].lane[0]``, ``GT[0/1].lane[1]``, etc).

.. _platform-interface_uuid:

-------------------------------------------------------
``interface_uuid``: Platform interface UUID dependency
-------------------------------------------------------

xbtest SW requires the interface UUID defined in the xclbin user metadata to select the compatible xclbin from provided BDF.

By default, it is automatically extracted from the :ref:`configure-xclbin-platform-metadata`.
If not defined in the platform metadata, the |xclbin_generate| workflow will extract it from the xclbin and insert it to the xclbin metadata.

If needed, the interface UUID can also be defined in :ref:`wizard-configuration-json-file` before generating the xclbin.

.. _platform-gt:

-------------------------------------------------------
``gt``: GT platform definition
-------------------------------------------------------

In this section, you can overwrite the FPGA part or the GT location.
If the platform metadata is defined as expected, you should not use this section.

If your platform doesn't contain the GT definition, here is an example of how to declare 2 GTs.
The configuration syntax uses a GT-based indexation.

.. code-block:: JSON

    "platform": {
      "gt": {
        "0": {
          "group_select": ["Quad_X0Y11"],
          "type": "GTY",
          "slr": "SLR2"
        },
        "1": {
          "group_select": ["Quad_X0Y10"],
          "type": "GTY",
          "slr": "SLR2"
        },
      }
    }

.. _configure-xclbin-build:

=================================================================
``build`` Parameters of wizard configuration JSON file
=================================================================

In this required section, you specify the directory location of:

  * Power CU floorplan sources (see :ref:`define-power-cu-floorplan`).
  * |Vitis|_ configuration (see :ref:`configure-vitis`).

The |xclbin_generate| workflow copies the files in the configuration directory into the run directory.
It is recommended to set all paths in the configuration relatively to the |xclbin_generate| output directory so ``xbtest_wizard`` and Vitis can use these local copies instead of the source files directly.

.. tip::
    In :ref:`wizard-configuration-json-file`, use relative path to run directory: ``../``

    .. code-block:: JSON

        "build": {
          "pwr_floorplan_dir" : "../pwr_cfg",
          "vpp_options_dir" : "../vpp_cfg"
        }

The following table describes the parameters supported under the ``build`` node of the :ref:`wizard-configuration-json-file`.

.. table:: ``build`` parameters of wizard configuration JSON file

    +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Node name             | Description                                                                                                                                                        |
    +=======================+====================================================================================================================================================================+
    | pwr_floorplan_dir     | Directory where the floorplan sources of the power CUs are located (see :ref:`define-power-cu-floorplan`):                                                         |
    |                       |                                                                                                                                                                    |
    |                       | * ``dynamic_geometry.json``.                                                                                                                                       |
    |                       | * ``utilization.json``.                                                                                                                                            |
    |                       | * ``invalid.json`` (optional).                                                                                                                                     |
    |                       |                                                                                                                                                                    |
    |                       | Note that the power floorplan sources are not processed/checked if no power cu was selected in :ref:`cu_selection <configure-xclbin-cu_selection>`.                |
    |                       |                                                                                                                                                                    |
    |                       | Build stops after opt design phase if ``dynamic_geometry.json`` or ``utilization.json``  does not exist.                                                           |
    |                       |                                                                                                                                                                    |
    +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | vpp_options_dir       | Specify additive INI file for v++ processing. See :ref:`configure-vitis`.                                                                                          |
    |                       |                                                                                                                                                                    |
    |                       | :ref:`vpp-options-file` file must exist within directory.                                                                                                          |
    |                       |                                                                                                                                                                    |
    |                       | Use with caution as any parameter in this file could overwrite a parameter set by xbtest in the generated ``vpp_link.ini``.                                        |
    +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | display_pwr_floorplan | Enable display of power floorplan. See :ref:`define-power-cu-floorplan`.                                                                                           |
    |                       |                                                                                                                                                                    |
    |                       | If set to ``true``, power floorplan is generated during example design generation, and a Vivado project is generated which can be used to display power floorplan. |
    |                       | This option is available only if power CUs are being generated.                                                                                                    |
    |                       |                                                                                                                                                                    |
    |                       | Possible values: ``true`` or ``false``.                                                                                                                            |
    |                       |                                                                                                                                                                    |
    |                       | Defaults to: ``false``.                                                                                                                                            |
    +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | vpp_link_output       | Select the file type of Vitis linker output. See :ref:`build-vpp_link_output`.                                                                                     |
    |                       |                                                                                                                                                                    |
    |                       | Possible values: ``default``, ``xclbin`` or ``xsa``.                                                                                                               |
    |                       |                                                                                                                                                                    |
    |                       | Defaults to: ``default``.                                                                                                                                          |
    +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+

.. _build-vpp_link_output:

-----------------------------------------------------------
``vpp_link_output``: Vitis linker output
-----------------------------------------------------------

When ``vpp_link_output`` is set to:

 * ``default``: If the FPGA part (``platform.fpga_part``) is ``xcvc*`` and Vitis version is greater than 2022.1, then ``vpp_link_output`` parameter defaults to ``xsa``, else, it defaults to ``xclbin``.
 * ``xsa``: The Vitis linker output is set to ``vpp_link.xsa`` and the Vitis packager is used to generate the an xclbin from this XSA.
 * ``xclbin``: The Vitis linker output is set to ``vpp_link.xclbin``. Then if AIE is used in the xclbin, the Vitis packager is run with this this xclbin to generate the final xclbin.

.. _configure-xclbin-cu_configuration:

=================================================================
``cu_configuration`` parameters of wizard configuration JSON file
=================================================================

Unless your platform is not defined as expected, nearly the entire ``cu_configuration`` will be auto-configured based on the :ref:`configure-xclbin-platform-metadata`.

This automatically filled ``cu_configuration`` is saved into ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/wizard_auto_config.json`` (see :ref:`hw-build-workflows`).

Where:

  * |<xbtest_build> def|
  * |<dev_platform> def|
  * |<project_name> def|

If something is not defined as expected, or you simply want to overwrite the default behaviour, this section explains the various options available.

The following table describes the parameters supported under the ``cu_configuration`` node of the :ref:`wizard-configuration-json-file`.

.. table:: ``cu_configuration`` parameters of wizard configuration JSON file

    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    | Node name                                                                         | Description                                                                                                      |
    +=================+===================+===============+===================+=========+==================================================================================================================+
    | clock           | ``<clk_idx>``     |               |                   |         | Clock index. See :ref:`cu_configuration-clock`.                                                                  |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``0`` or ``1``.                                                                                 |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   | freq          |                   |         | Value of the clock frequency in MHz:                                                                             |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         |   * For ``<clk_idx>`` = 0: |ap_clk| clock frequency. Defaults to: 300 Mhz.                                       |
    |                 |                   |               |                   |         |   * For ``<clk_idx>`` = 1: |ap_clk_2| clock frequency. Defaults to: 500 Mhz.                                     |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: in [``200`` ; ``650``].                                                                         |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    | plram_selection | ``<SLRx>``        |               |                   |         | Define the PLRAM sptag to use for the CU located in SLR ``<SLRx>``. See :ref:`cu_configuration-plram_selection`. |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Algorithm selects the first PLRAM found in each SLR for this mapping.                                            |
    |                 |                   |               |                   |         | This can be overwritten for example if the user wants to use the PLRAM from another SLR.                         |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``SLR<x>`` format for the keys where ``<x>`` is the SLR index.                                  |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    | power           | ``<slr_idx>``     |               |                   |         | SLR index. See :ref:`cu_configuration-power`.                                                                    |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: integers.                                                                                       |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   | throttle_mode |                   |         | Mode of the clock throttling module of the power CU.                                                             |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``default``, ``INTERNAL_MACRO``, ``INTERNAL_CLK``, ``EXTERNAL_MACRO`` or ``EXTERNAL_CLK``.      |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Defaults to: ``default``.                                                                                        |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    | gt              | ``<gt_idx>``      |               |                   |         | GT index. See :ref:`cu_configuration-gt`.                                                                        |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: integers.                                                                                       |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   | diff_clocks   |                   |         | GT diff clocks assignment.                                                                                       |
    +                 +                   +---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   | serial_port   |                   |         | GT serial port assignment.                                                                                       |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    | gt_mac          | ``<gt_idx>``      |               |                   |         | GT index. See :ref:`cu_configuration-gt_mac`.                                                                    |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: integers.                                                                                       |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   | ip_sel        |                   |         | IP used in the GT_MAC compute unit.                                                                              |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``xxv`` or ``xbtest_sub_xxv_gt``.                                                               |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Defaults to: ``xxv``.                                                                                            |
    +                 +                   +---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   | enable_rsfec  |                   |         | When set to ``true``, the GT_MAC CU will support RS FEC.                                                         |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``true`` or ``false``.                                                                          |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Defaults to: ``false``.                                                                                          |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    | memory          | ``<memory_type>`` |               |                   |         | Name of the memory type. See :ref:`cu_configuration-memory`.                                                     |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   | global        | target            |         | Memory target used for the memory CU configuration.                                                              |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``board`` or ``host``.                                                                          |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Defaults to: ``host`` for HOST memory type, else ``board``.                                                      |
    +                 +                   +---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   |               | axi_data_size     |         | AXI data size in bits of each port for each memory CU.                                                           |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``512``, ``256``, ``128`` or ``64``.                                                            |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Defaults to: ``512``.                                                                                            |
    +                 +                   +               +-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   |               | axi_id_threads    |         | Maximum quantity of AXI ID threads of each ports for each memory CU.                                             |
    |                 |                   |               |                   |         | The CU will rotate the ID between each transfer.                                                                 |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``1``, ``2``, ``4``, ``8`` or ``16``.                                                           |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Defaults to: ``1``.                                                                                              |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | .. note::                                                                                                        |
    |                 |                   |               |                   |         |     The AXI protocol includes AXI ID transaction identifiers.                                                    |
    |                 |                   |               |                   |         |     A master can use these to identify separate transactions that must be returned in order.                     |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         |     All transactions with a given AXI ID value must remain ordered,                                              |
    |                 |                   |               |                   |         |     but there is no restriction on the ordering of transactions with different ID values.                        |
    |                 |                   |               |                   |         |     This means a single physical port can support out-of-order transactions                                      |
    |                 |                   |               |                   |         |     by acting as a number of logical ports, each of which handles its transactions in order.                     |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         |     By using AXI IDs, a master can issue transactions without waiting for earlier transactions to complete.      |
    |                 |                   |               |                   |         |     This can improve system performance, because it enables parallel processing of transactions.                 |
    +                 +                   +               +-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   |               | axi_outstanding   |         | Maximum quantity of AXI outstanding transactions of each port for each memory CU.                                |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``1``, ``2``, ``4``, ``8``, ``16``, ``32``, ``64``, ``128`` or ``256``.                         |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Defaults to: ``32``.                                                                                             |
    +                 +                   +---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   | specific      | ``<cu_idx>``      |         | Memory CU specific configuration.                                                                                |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         |   * **For single-channel**: Multiple CU can be specified.                                                        |
    |                 |                   |               |                   |         |   * **For multi-channel**: Only one CU can be specified.                                                         |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | .. note::                                                                                                        |
    |                 |                   |               |                   |         |     To override one parameter for one CU, the new specific configuration for all CUs must be specified.          |
    +                 +                   +---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   |               |                   | slr     | SLR assignment of memory CU.                                                                                     |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``SLR<x>`` format where ``<x>`` is the SLR index.                                               |
    +                 +                   +               +                   +---------+------------------------------------------------------------------------------------------------------------------+
    |                 |                   |               |                   | sptag   | List of sptags to be used for each channel memory CU.                                                            |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | * **For single-channel**: Only one sptag can be specified.                                                       |
    |                 |                   |               |                   |         | * **For multi-channel**: Multiple sptag can be specified.                                                        |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    | verify          |                   |               |                   |         | See :ref:`cu_configuration-verify`.                                                                              |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 | slr               |               |                   |         | Define SLR location of the verify CU.                                                                            |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``SLR<x>`` format where ``<x>`` is the SLR index.                                               |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | By default: based on ``CONFIG_SITE`` definition in :ref:`dynamic_geometry-json`.                                 |
    +                 +-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+
    |                 | dna_read          |               |                   |         | Select to access or not the CONFIG_SITE of the platform.                                                         |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Possible values: ``true`` or ``false``.                                                                          |
    |                 |                   |               |                   |         |                                                                                                                  |
    |                 |                   |               |                   |         | Defaults to: based on ``CONFIG_SITE`` definition in :ref:`dynamic_geometry-json`.                                |
    +-----------------+-------------------+---------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------+

.. _cu_configuration-power:

-------------------------------------------------------
``power``: Power CU configuration
-------------------------------------------------------

The configuration parameter |throttle_mode| selects the way all resources included in the power CU are used (clocked/controlled).

To consume as much power as possible, the power CU resources are running on the fast clock |ap_clk_2| (default frequency of 500 MHz).
There are 2 ways to control the power consumed (selection is based on the clocking infrastructure of the platform):

  1. Throttling the clock (default and preferable method).
  2. Throttling the input CE of each resource macro.

For multi SLR FPGA only, throttling can also be coming from another Power CU. This reduces pressure on the clocking structure of the FPGA as only one Power CU contains the throttling mechanism and all other CUs are cascaded from it. The throttle logic doesn't necessarily need to be in SLR0.

AIEngine can't currently be cascaded across multi-SLR.

The following figure shows the different ways of controlling the power CU resources. The description of the throttling mechanism is beyond the scope of this documentation.

.. figure:: ./diagram/power-throttle.svg
    :align: center

    Power throttle

All of these resulting in the following modes of configuration for a Power CU.

.. table:: Power CU throttle mode description

    +--------------------+-------------------------------------------------------------------------------------+-----------------+
    | Throttle mode      | Description                                                                         | Power CU        |
    +====================+=====================================================================================+=================+
    | ``INTERNAL_CLK``   | Clock throttling generated in the power CU.                                         | Source          |
    +--------------------+-------------------------------------------------------------------------------------+-----------------+
    | ``EXTERNAL_CLK``   | Clock throttling coming from another power CU (only possible in multi SLR FPGA).    | Destination     |
    +--------------------+-------------------------------------------------------------------------------------+-----------------+
    | ``INTERNAL_MACRO`` | CE throttling generated in the power CU.                                            | Source          |
    +--------------------+-------------------------------------------------------------------------------------+-----------------+
    | ``EXTERNAL_MACRO`` | CE throttling coming from another power CU (only possible in multi SLR FPGA).       | Destination     |
    +--------------------+-------------------------------------------------------------------------------------+-----------------+

.. note::
    Whatever the configuration selected for each power CU, the SW always controls them all together in identical manner.

The wizard will interconnect all cascaded power CUs with their respective source via the :ref:`generated-vpp-options-file`:

  * All destination ``EXTERNAL_CLK`` to a single source ``INTERNAL_CLK``.
  * All destination ``EXTERNAL_MACRO`` to a single source ``INTERNAL_CLK``.

By default, the wizard will auto-configure the throttle mode of the Power CU with lower index SLR as containing the throttle mechanism (``INTERNAL_CLK``) and all other CUs are hooked to it (``EXTERNAL_CLK``).

If the default configuration is not suitable (e.g. you want to move the source power CU into another SLR), you only need to define the source.
The wizard recognizes the first ``INTERNAL`` defined and automatically selects ``EXTERNAL`` for all other SLR.  If you defined multiple ``INTERNAL``, the wizard would use the lowest index as source for all ``EXTERNAL``.
Alternatively, you can also define all power CU as ``INTERNAL`` (meaning that each of them includes its throttle mechanism).

In case of mixed configuration (``CLK`` and ``MACRO``), it's recommended to list all SLR and their respective configuration. If needed, you can also :ref:`overwrite-cascaded-power-cu-connectivity`.

The following table presents different examples of throttle mode configuration considering a FPGA with 4 SLRs (SLR0, SLR1, SLR2 and SLR3):

.. table:: Power CU throttle mode examples

    +------------------------------+------------------------------------------------------------+-------------------------------------------------+----------------------------------------------------+
    | Example                      | Description                                                | Wizard configuration JSON file                  | Illustration                                       |
    +==============================+============================================================+=================================================+====================================================+
    | Default cascade              | By default, power CUs in:                                  | No configuration required                       | .. figure:: ./diagram/power-cu-cascade-default.svg |
    |                              |                                                            |                                                 |     :align: center                                 |
    |                              |   * SLR1, SLR2 and SLR3 are cascaded (``EXTERNAL_CLK``).   |                                                 |                                                    |
    |                              |   * SLR0 is the source (``INTERNAL_CLK``).                 |                                                 |     Default cascade                                |
    +------------------------------+------------------------------------------------------------+-------------------------------------------------+----------------------------------------------------+
    | Cascade with CLK throttle    | You can set the source power CU in another SLR.            | .. code-block:: JSON                            | .. figure:: ./diagram/power-cu-cascade-clk.svg     |
    |                              |                                                            |                                                 |     :align: center                                 |
    |                              | In this example, power CUs in:                             |     "cu_configuration" : {                      |                                                    |
    |                              |                                                            |       "power" : {                               |     Cascade with CLK throttle                      |
    |                              |   * SLR0, SLR1 and SLR3 are cascaded (``EXTERNAL_CLK``).   |         "2" : {                                 |                                                    |
    |                              |   * SLR2 is the source (``INTERNAL_CLK``).                 |           "throttle_mode": "INTERNAL_CLK"       |                                                    |
    |                              |                                                            |         }                                       |                                                    |
    |                              | .. note::                                                  |       }                                         |                                                    |
    |                              |    The wizard recognizes that you've got only one source   |     }                                           |                                                    |
    |                              |    defined and automatically selects ``EXTERNAL_CLK`` for  |                                                 |                                                    |
    |                              |    all other SLR.                                          |                                                 |                                                    |
    |                              |                                                            |                                                 |                                                    |
    +------------------------------+------------------------------------------------------------+-------------------------------------------------+----------------------------------------------------+
    | Cascade with CE throttle     | You can change the type of throttle mode.                  | .. code-block:: JSON                            | .. figure:: ./diagram/power-cu-cascade-ce.svg      |
    |                              |                                                            |                                                 |     :align: center                                 |
    |                              | In this example, power CUs in:                             |     "cu_configuration" : {                      |                                                    |
    |                              |                                                            |       "power" : {                               |     Cascade with CE throttle                       |
    |                              |   * SLR0, SLR2 and SLR3 are cascaded (``EXTERNAL_MACRO``). |         "1" : {                                 |                                                    |
    |                              |   * SLR1 is the source (``INTERNAL_MACRO``).               |           "throttle_mode": "INTERNAL_MACRO"     |                                                    |
    |                              |                                                            |         }                                       |                                                    |
    |                              |                                                            |       }                                         |                                                    |
    |                              | .. note::                                                  |       }                                         |                                                    |
    |                              |    The wizard recognizes that you've got only one source   |     }                                           |                                                    |
    |                              |    defined and automatically selects ``EXTERNAL_MACRO``    |                                                 |                                                    |
    |                              |    for all other SLR.                                      |                                                 |                                                    |
    |                              |                                                            |                                                 |                                                    |
    +------------------------------+------------------------------------------------------------+-------------------------------------------------+----------------------------------------------------+
    | Mixed Control:               | You can mix the throttling control mode                    | .. code-block:: JSON                            | .. figure:: ./diagram/power-cu-cascade-mixed.svg   |
    |                              | but you have to connect clock/CE signals accordingly       |                                                 |     :align: center                                 |
    |   * **not recommended**      | in your :ref:`vpp-options-file`.                           |     "cu_configuration" : {                      |                                                    |
    |                              |                                                            |       "power" : {                               |     Mixed control                                  |
    |                              | In this example, power CUs in:                             |         "0" : {                                 |                                                    |
    |                              |                                                            |           "throttle_mode": "INTERNAL_MACRO"     |                                                    |
    |                              |   * SLR0 (source) and SLR2 are paired: CE throttling.      |         },                                      |                                                    |
    |                              |   * SLR1 (source) and SLR3 are paired: CLK throttling.     |         "1" : {                                 |                                                    |
    |                              |                                                            |           "throttle_mode": "INTERNAL_CLK"       |                                                    |
    |                              |                                                            |         },                                      |                                                    |
    |                              |                                                            |         "2" : {                                 |                                                    |
    |                              |                                                            |           "throttle_mode": "EXTERNAL_MACRO"     |                                                    |
    |                              |                                                            |         },                                      |                                                    |
    |                              |                                                            |         "3" : {                                 |                                                    |
    |                              |                                                            |           "throttle_mode": "EXTERNAL_CLK"       |                                                    |
    |                              |                                                            |         }                                       |                                                    |
    |                              |                                                            |       }                                         |                                                    |
    |                              |                                                            |     }                                           |                                                    |
    +------------------------------+------------------------------------------------------------+-------------------------------------------------+----------------------------------------------------+

.. note::
    Your shell may also include another clock throttling capability.
    It is a safety feature which slows down all clocks going to all CU when the FPGA power is getting closer to its limits.
    This is independent to the ``clock_throttle`` block used internally by the power CU.

.. _cu_configuration-gt:

-------------------------------------------------------
``gt``: Configure GT CUs (GT_MAC, GT_LPBK & GT_PRBS)
-------------------------------------------------------

These 3 CUs depend on the GT location (see :ref:`configure-xclbin-platform`) but also on its connections.
The GT macro has 2 reference input clocks and 1 data port interface.

Whatever CU is connected to the GT, you may have to select the GT reference clock.
You may potentially also select the platform data port if it is not defined (see :ref:`configure-xclbin-platform-metadata`).

  * Expected location: ``hardwarePlatforms.hardwarePlatform.extensions.raptor2.resources.gts.<gt_idx>``

.. warning::
    Ideally GT_MAC CU should be used, but if there is not enough resource in the FPGA, it's recommended to use GT_PRBS (as it doesn't require any traffic source).

The configuration syntax uses the GT-based indexation. Here is an example of GT ref clock and data port definition

.. code-block:: JSON

    "cu_configuration": {
      "gt": {
        "0": {
          "serial_port": ["io_gt_qsfp_00"],
          "diff_clocks": ["io_clk_qsfp_refclka_00"]
        }
      }
    }

Once the GT is defined, you can now define the CU.

.. _cu_configuration-gt_mac:

-------------------------------------------------------
``gt``: Configure GT MAC CU
-------------------------------------------------------

The GT_MAC has 2 configurations:

  * RS-FEC.
  * Sub IP selection.

GT MAC CU uses and requires license for |XXV|_.
Depending on the FPGA used, this IP contains or not the GT macro.

If the GT macro is not part of XXV Ethernet, you need more than this IP alone.
A Sub-system is provided in xbtest HW sources and you'll have to select it by setting the parameter ``ip_sel``.

.. table:: GT_MAC CU IP selection

    +-----------------------+----------------------------------------------------------------+
    | Mode selection        | Description                                                    |
    +=======================+================================================================+
    | ``xxv``               | Use XXV Ethernet LogiCore contains the GT macro.               |
    |                       |                                                                |
    |                       |   * Default.                                                   |
    +-----------------------+----------------------------------------------------------------+
    | ``xbtest_sub_xxv_gt`` | Use a sub-system containing the XXV Ethernet and the GT macro. |
    +-----------------------+----------------------------------------------------------------+

By default, the RS-FEC is not included.
Only include it if needed as it uses a lot of logic (40k FF and 50k LUT) and may impeach timing closure of the xclbin by setting the parameter ``enable_rsfec``.

.. table:: GT_MAC CU RS-FEC selection

    +-----------------------+----------------------------------------------------------------+
    | Mode selection        | Description                                                    |
    +=======================+================================================================+
    | ``false``             | Don't include RS-FEC.                                          |
    |                       |                                                                |
    |                       |   * Default.                                                   |
    +-----------------------+----------------------------------------------------------------+
    | ``true``              | Include RS-FEC.                                                |
    +-----------------------+----------------------------------------------------------------+

.. note::
    GT_LPBK & GT_PRBS CUs have no configuration.

The configuration syntax uses the GT-based indexation:

.. code-block:: JSON

    "cu_configuration": {
      "gt_mac": {
        "0": {
          "ip_sel": "xxv",
          "enable_rsfec": false
        }
      }
    }


.. _cu_configuration-memory:

-------------------------------------------------------
``memory``: Configure memory CU
-------------------------------------------------------

There are 2 sets of settings for the memory type:

  * **Physical**: memory type/location and AXI4 configuration.
  * **CU-related**: multi/single-channel CU location and how CU ports are connected to the memory:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Physical configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Per memory type, the physical configuration parameters are defined in ``global`` section.
It defines the memory CU AXI4 settings and where the memory is located: on board (for example: DDR, HBM) or on the host.

.. code-block:: JSON

    "global" : {
      "target"          : "board",
      "axi_data_size"   : 512,
      "axi_id_threads"  : 1,
      "axi_outstanding" : 32
    }

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
CU-related configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Per memory type, the CU-related configuration is defined in ``specific`` section.
You may have more than one memory banks of same memory type, for example some boards have 4 DDR banks.

This section describes the quantity of memory CU, their location and how each CU is connected to the memory via the following sets of parameters:

  * ``slr``: Location of the CU.
  * ``sptag``: The system port tag (sptag) is a symbolic identifier that represents a platform port, such as HBM, DDR, PLRAM. Vitis connects the memory CU to the ``sptag`` listed.

Per memory type, you list as many memory CU you want (CU-index based definition: ``0``, ``1``, ``2``, ...).

.. code-block:: JSON

    "specific" : {
      "0" : {
        "slr"   : ,
        "sptag" :
      },
      "1" : {
        "slr"   : ,
        "sptag" :
      },
      "2" : {
        "slr"   : ,
        "sptag" :
      }
    }

Although multiple CUs can share the same ``sptag``, a memory type may also have multiple ``sptag`` (e.g. HBM has 32 ports).
Memory port definition is described in :ref:`configure-xclbin-platform-metadata`.
When multiple CUs are connected to the same ``sptag``, they will all share the available port capabilities (e.g. bandwidth).

The memory CU has 2 modes: single or multi-channel.
The mode selection is done via the allocation of ``sptag`` (thus port) to the CU.
If the ``sptag`` contains more than 1 element, a multi-channel memory CU is selected.
The multi-channel CU will have as many channels as ``sptag`` listed.

.. note::
    By default, If a memory type definition contains:

      * Only 1 ``sptag``, a single-channel memory CU will be selected. this will maximize the performance.
      * Multiple ``sptag``, a multi-channel memory CU will be automatically selected (with as many channels as ``sptag`` quantity).

For multi-channel CU, xbtest SW aggregates all individual results for easy display and show case the combined performances.

Although the HBM has 32 ports, you could connect 32 single-channel memory CU.
This is not recommended, as xbtest SW will report 32 individual sets of results (e.g. reported bandwidth will be  ~12.5 GB/s per channel).
While with 32 multi-channels memory CU, xbtest SW will report the accumulated results (~400 GB/s, in this case).

Here are some examples of configuration, both ``global`` and ``specific`` sections are fully described but they should be automatically extracted from the platforminfo (see :ref:`configure-xclbin-platform-metadata`).

.. table:: Example of Memory CU configuration

    +---------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------+
    | Memory type                                                                     | Description                                                                                         | Example                                                                          |
    +=================================================================================+=====================================================================================================+==================================================================================+
    | **32-channel HBM memory CU and 1 single-channel HOST memory CU**                | The ``HBM.specific`` section contains 1 element (0), thus, there is only 1 memory CU present.       | .. code-block:: JSON                                                             |
    |                                                                                 |                                                                                                     |                                                                                  |
    |                                                                                 |   * The ``sptag`` list contains 32 elements. So it will be a multi-channel memory CU with 32 ports. |     "memory" : {                                                                 |
    |                                                                                 |                                                                                                     |       "HBM" : {                                                                  |
    |                                                                                 | The ``HOST.specific`` section contains 1 element (0), thus, there is only 1 memory CU present.      |         "global" : {                                                             |
    |                                                                                 |                                                                                                     |           "target"          : "board",                                           |
    |                                                                                 |   * Only 1 ``sptag`` is listed, so it will be a single-channel memory CU.                           |           "axi_data_size"   : 512,                                               |
    |                                                                                 |                                                                                                     |           "axi_id_threads"  : 1,                                                 |
    |                                                                                 |                                                                                                     |           "axi_outstanding" : 32                                                 |
    |                                                                                 |                                                                                                     |         },                                                                       |
    |                                                                                 |                                                                                                     |         "specific" : {                                                           |
    |                                                                                 |                                                                                                     |           "0" : {                                                                |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR0",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : [                                                          |
    |                                                                                 |                                                                                                     |               "HBM[0]",  "HBM[1]",  "HBM[2]",  "HBM[3]",                         |
    |                                                                                 |                                                                                                     |               "HBM[4]",  "HBM[5]",  "HBM[6]",  "HBM[7]",                         |
    |                                                                                 |                                                                                                     |               "HBM[8]",  "HBM[9]",  "HBM[10]", "HBM[11]",                        |
    |                                                                                 |                                                                                                     |               "HBM[12]", "HBM[13]", "HBM[14]", "HBM[15]",                        |
    |                                                                                 |                                                                                                     |               "HBM[16]", "HBM[17]", "HBM[18]", "HBM[19]",                        |
    |                                                                                 |                                                                                                     |               "HBM[20]", "HBM[21]", "HBM[22]", "HBM[23]",                        |
    |                                                                                 |                                                                                                     |               "HBM[24]", "HBM[25]", "HBM[26]", "HBM[27]",                        |
    |                                                                                 |                                                                                                     |               "HBM[28]", "HBM[29]", "HBM[30]", "HBM[31]"                         |
    |                                                                                 |                                                                                                     |             ]                                                                    |
    |                                                                                 |                                                                                                     |           }                                                                      |
    |                                                                                 |                                                                                                     |         }                                                                        |
    |                                                                                 |                                                                                                     |       },                                                                         |
    |                                                                                 |                                                                                                     |       "HOST" : {                                                                 |
    |                                                                                 |                                                                                                     |         "global" : {                                                             |
    |                                                                                 |                                                                                                     |           "target"          : "host",                                            |
    |                                                                                 |                                                                                                     |           "axi_data_size"   : 512,                                               |
    |                                                                                 |                                                                                                     |           "axi_id_threads"  : 1,                                                 |
    |                                                                                 |                                                                                                     |           "axi_outstanding" : 32                                                 |
    |                                                                                 |                                                                                                     |         },                                                                       |
    |                                                                                 |                                                                                                     |         "specific" : {                                                           |
    |                                                                                 |                                                                                                     |           "0" : {                                                                |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR1",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : ["HOST[0]"]                                                |
    |                                                                                 |                                                                                                     |           }                                                                      |
    |                                                                                 |                                                                                                     |         }                                                                        |
    |                                                                                 |                                                                                                     |       }                                                                          |
    |                                                                                 |                                                                                                     |     }                                                                            |
    +---------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------+
    |  **16-channel HBM memory CU**                                                   |  The ``HBM.specific`` section contains 1 element (0), thus, there is only 1 memory CU present.      | .. code-block:: JSON                                                             |
    |                                                                                 |                                                                                                     |                                                                                  |
    |                                                                                 |  The ``sptag`` list contains 16 elements.                                                           |     "memory" : {                                                                 |
    |                                                                                 |  So, it will be a multi-channel memory CU with 16 ports.                                            |       "HBM" : {                                                                  |
    |                                                                                 |                                                                                                     |         "global" : {                                                             |
    |                                                                                 |                                                                                                     |           "target"          : "board",                                           |
    |                                                                                 |                                                                                                     |           "axi_data_size"   : 256,                                               |
    |                                                                                 |                                                                                                     |           "axi_id_threads"  : 1,                                                 |
    |                                                                                 |                                                                                                     |           "axi_outstanding" : 32                                                 |
    |                                                                                 |                                                                                                     |         },                                                                       |
    |                                                                                 |                                                                                                     |         "specific" : {                                                           |
    |                                                                                 |                                                                                                     |           "0" : {                                                                |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR0",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : [                                                          |
    |                                                                                 |                                                                                                     |               "HBM[0:1]",   "HBM[2:3]",   "HBM[4:5]",   "HBM[6:7]",              |
    |                                                                                 |                                                                                                     |               "HBM[8:9]",   "HBM[10:11]", "HBM[12:13]", "HBM[14:15]",            |
    |                                                                                 |                                                                                                     |               "HBM[16:17]", "HBM[18:19]", "HBM[20:21]", "HBM[22:23]",            |
    |                                                                                 |                                                                                                     |               "HBM[24:25]", "HBM[26:27]", "HBM[28:29]", "HBM[30:31]"             |
    |                                                                                 |                                                                                                     |             ]                                                                    |
    |                                                                                 |                                                                                                     |           }                                                                      |
    |                                                                                 |                                                                                                     |         }                                                                        |
    |                                                                                 |                                                                                                     |       }                                                                          |
    |                                                                                 |                                                                                                     |     }                                                                            |
    +---------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------+
    | **8-channel HBM memory CU**                                                     |                                                                                                     | .. code-block:: JSON                                                             |
    |                                                                                 |                                                                                                     |                                                                                  |
    |                                                                                 |                                                                                                     |     "memory" : {                                                                 |
    |                                                                                 |                                                                                                     |       "HBM" : {                                                                  |
    |                                                                                 |                                                                                                     |         "specific" : {                                                           |
    |                                                                                 |                                                                                                     |           "0" : {                                                                |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR0",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : [                                                          |
    |                                                                                 |                                                                                                     |               "HBM[0:3]",   "HBM[4:7]",   "HBM[8:11]",  "HBM[12:15]",            |
    |                                                                                 |                                                                                                     |               "HBM[16:19]", "HBM[20:23]", "HBM[24:27]", "HBM[28:31]"             |
    |                                                                                 |                                                                                                     |             ]                                                                    |
    |                                                                                 |                                                                                                     |           }                                                                      |
    |                                                                                 |                                                                                                     |         }                                                                        |
    |                                                                                 |                                                                                                     |       }                                                                          |
    |                                                                                 |                                                                                                     |     }                                                                            |
    +---------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------+
    | **4 single-channel DDR memory CUs**                                             | The ``DDR.specific`` section contains 4 elements (``0``/``1``/``2``/``3``),                         | .. code-block:: JSON                                                             |
    |                                                                                 | thus, there are 4 memory CUs present.                                                               |                                                                                  |
    |                                                                                 |                                                                                                     |     "memory": {                                                                  |
    |                                                                                 |   * As each of them is using a single ``sptag``, this will be 4 single-channel memory CUs.          |       "DDR" : {                                                                  |
    |                                                                                 |                                                                                                     |         "global" : {                                                             |
    |                                                                                 |                                                                                                     |           "target"          : "board",                                           |
    |                                                                                 |                                                                                                     |           "axi_data_size"   : 512,                                               |
    |                                                                                 |                                                                                                     |           "axi_id_threads"  : 1,                                                 |
    |                                                                                 |                                                                                                     |           "axi_outstanding" : 32                                                 |
    |                                                                                 |                                                                                                     |         },                                                                       |
    |                                                                                 |                                                                                                     |         "specific" : {                                                           |
    |                                                                                 |                                                                                                     |           "0" : {                                                                |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR0",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : ["DDR[0]"]                                                 |
    |                                                                                 |                                                                                                     |           },                                                                     |
    |                                                                                 |                                                                                                     |           "1" : {                                                                |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR1",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : ["DDR[1]"]                                                 |
    |                                                                                 |                                                                                                     |           },                                                                     |
    |                                                                                 |                                                                                                     |           "2" : {                                                                |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR2",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : ["DDR[2]"]                                                 |
    |                                                                                 |                                                                                                     |           },                                                                     |
    |                                                                                 |                                                                                                     |           "3" : {                                                                |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR3",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : ["DDR[3]"]                                                 |
    |                                                                                 |                                                                                                     |           }                                                                      |
    |                                                                                 |                                                                                                     |         }                                                                        |
    |                                                                                 |                                                                                                     |       }                                                                          |
    |                                                                                 |                                                                                                     |     }                                                                            |
    +---------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------+
    | **3 single-channel DDR memory CUs**                                             | DDR in SLR2 is not tested (how to disconnect 1 CU).                                                 | .. code-block:: JSON                                                             |
    |                                                                                 |                                                                                                     |                                                                                  |
    |                                                                                 | The ``DDR.specific`` section contains 3 elements (``0``/``1``/``2``),                               |     "memory": {                                                                  |
    |                                                                                 | thus, there are 3 memory CUs present.                                                               |       "DDR" : {                                                                  |
    |                                                                                 |                                                                                                     |         "specific" : {                                                           |
    |                                                                                 |   * SLR2 & sptag DDR[2] are not present.                                                            |           "0" : {                                                                |
    |                                                                                 |   * Note the CU-index based from 0 to 2.                                                            |             "slr"   : "SLR0",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : ["DDR[0]"]                                                 |
    |                                                                                 |                                                                                                     |           },                                                                     |
    |                                                                                 |                                                                                                     |           "1" : {                                                                |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR1",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : ["DDR[1]"]                                                 |
    |                                                                                 |                                                                                                     |           },                                                                     |
    |                                                                                 |                                                                                                     |           "2" : {                                                                |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR3",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : ["DDR[3]"]                                                 |
    |                                                                                 |                                                                                                     |           }                                                                      |
    |                                                                                 |                                                                                                     |         }                                                                        |
    |                                                                                 |                                                                                                     |       }                                                                          |
    |                                                                                 |                                                                                                     |     }                                                                            |
    +---------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------+
    | **4-channel memory CU with identical ``sptag`` and 1 single-channel memory CU** | The ``PS_DDR.specific`` section contains 1 element, thus, there is only 1 memory CU present.        | .. code-block:: JSON                                                             |
    |                                                                                 |                                                                                                     |                                                                                  |
    |                                                                                 |   * The ``sptag`` list contains 4 elements.                                                         |     "memory": {                                                                  |
    |                                                                                 |     So, it will be a multi-channel memory CU with 4 ports.                                          |       "PS_DDR": {                                                                |
    |                                                                                 |                                                                                                     |         "global" : {                                                             |
    |                                                                                 | .. note::                                                                                           |           "target"          : "board",                                           |
    |                                                                                 |     The same ``sptag`` is used 4 times, meaning that memory will be shared across all 4 channels.   |           "axi_data_size"   : 128,                                               |
    |                                                                                 |                                                                                                     |           "axi_id_threads"  : 1,                                                 |
    |                                                                                 | The ``PL_DDR.specific`` section contains 1 element, thus, there is only 1 memory CU present.        |           "axi_outstanding" : 32                                                 |
    |                                                                                 |                                                                                                     |         },                                                                       |
    |                                                                                 |   * Only 1 ``sptag`` listed, thus, it will be a single-channel memory CU.                           |         "specific": {                                                            |
    |                                                                                 |                                                                                                     |           "0": {                                                                 |
    |                                                                                 | As these memory type names (``PS_DDR``/``PL_DDR``) are new,                                         |             "slr"   : "SLR0",                                                    |
    |                                                                                 | the entire ``global`` section must be defined.                                                      |             "sptag" : [                                                          |
    |                                                                                 |                                                                                                     |               "DDR[1]", "DDR[1]", "DDR[1]", "DDR[1]"                             |
    |                                                                                 |                                                                                                     |             ]                                                                    |
    |                                                                                 |                                                                                                     |           }                                                                      |
    |                                                                                 |                                                                                                     |         }                                                                        |
    |                                                                                 |                                                                                                     |       },                                                                         |
    |                                                                                 |                                                                                                     |       "PL_DDR": {                                                                |
    |                                                                                 |                                                                                                     |         "global" : {                                                             |
    |                                                                                 |                                                                                                     |           "target"          : "board",                                           |
    |                                                                                 |                                                                                                     |           "axi_data_size"   : 256,                                               |
    |                                                                                 |                                                                                                     |           "axi_id_threads"  : 1,                                                 |
    |                                                                                 |                                                                                                     |           "axi_outstanding" : 32                                                 |
    |                                                                                 |                                                                                                     |         },                                                                       |
    |                                                                                 |                                                                                                     |         "specific": {                                                            |
    |                                                                                 |                                                                                                     |           "0": {                                                                 |
    |                                                                                 |                                                                                                     |             "slr"   : "SLR0",                                                    |
    |                                                                                 |                                                                                                     |             "sptag" : ["DDR[0]"]                                                 |
    |                                                                                 |                                                                                                     |           }                                                                      |
    |                                                                                 |                                                                                                     |         }                                                                        |
    |                                                                                 |                                                                                                     |       }                                                                          |
    |                                                                                 |                                                                                                     |     }                                                                            |
    +---------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------+

.. _cu_configuration-verify:

-------------------------------------------------------
``verify``: Configure verify CU
-------------------------------------------------------

The verify CU is always present in the xclbin and includes the following hardware safety mechanisms:

  * **Watchdog**: Stops all CUs after a programmable delay (default 15 seconds) in the case of the application software failing to perform the watchdog reset.
  * **Status Register**:

    * Detects and prevents multiple instances of application software trying to control/access the same |Alveo|_ card.
    * Detects if CU clocks have been throttled down.
      CU Clocks could have been slowed down automatically to prevent over-powering the card. Slower clock will affect test results.

  * **DNA** : Reports the FPGA DNA value. It uses the DNA_PORT2 of CONFIG_SITE macro (see |UG909|_).
    The location (SLR) of this ``CONFIG_SITE`` is automatically detected when creating the power floorplan (see :ref:`initialize-power-floorplan-sources`) and added to the :ref:`dynamic_geometry-json`.

    .. note::
        In case of multi SLR, only the first CONFIG_SITE found will be listed.
        This will dictate the SLR location of the verify CU.

If a ``CONFIG_SITE`` is available in various SLR in your platform, you can overwrite the default SLR selection.
This will move the verify CU in the selected SLR.
If no ``CONFIG_SITE`` is not available in your platform, you can manually disable the DNA read, but the verify CU will still be present in your xclbin.

.. code-block:: JSON

    "verify" : {
        "slr": "SLR2",
        "dna_read": false
    },

.. _cu_configuration-clock:

-------------------------------------------------------
``clock``: Clock speed
-------------------------------------------------------

xbtest uses 2 clocks:

.. _ap-clk:
.. _ap-clk-2:

.. table:: xbtest clocks

    +--------------+----------------+----------------+-------------------+------------------------------------------------------------------------+
    | CU RTL Name  | Wizard index   | Vitis name     | Default frequency | Description                                                            |
    +==============+================+================+===================+========================================================================+
    | ``ap_clk``   | 0              | ``DATA_CLK``   | 300 MHz           | CU <-> memory connection (DDR/HBM/PLRAM/HOST)                          |
    +--------------+----------------+----------------+-------------------+------------------------------------------------------------------------+
    | ``ap_clk_2`` | 1              | ``KERNEL_CLK`` | 500 MHz           | Only used by power CU. Fast clock to consume as much power as possible |
    +--------------+----------------+----------------+-------------------+------------------------------------------------------------------------+

It's possible to change their default value.

With Versal board, the AIEngine are used to consume power.
The power of AIEngine is controlled by the quantity of data passing through them.
The data are generated on the |ap_clk|.

To maximize the power consumption, the data rate generation should be aligned with the maximum data throughput of the AIEngine.

The AIEngine throughput is depending on their operational frequency (typically 1250MHz, but you need to check your platform settings)

.. math::

    \frac{ AIE\ frequency * AIE\ data\ width } { Data\ generator\ width } = \frac{ 12500\  MHz * 32\  bits } { 128\  bits } = 312.5\  MHz

.. caution::
    Increasing |ap_clk| clock frequency too much may have an adverse impact on timing closure, as this clock is used by all CUs.

.. note::
    By default, you should not need to define any clock settings unless you're using AIEngine.

**Default clock configuration**

.. code-block:: JSON

    "cu_configuration": {
      "clock": {
        "0": {
          "freq": 300
        },
        "1": {
          "freq": 500
        }
      }
    }

**Versal Board clock configuration**

For Versal, note that:

  * |ap_clk| is updated to match AIEngine data rate.
  * |ap_clk_2| can be also increased.

.. code-block:: JSON

    "cu_configuration": {
      "clock": {
        "0": {
          "freq": 313
        },
        "1": {
          "freq": 600
        }
      }
    }

.. _cu_configuration-plram_selection:

-------------------------------------------------------
``plram_selection``: PLRAM connections
-------------------------------------------------------

By default, a CU is connected to the first (lower index) PLRAM available in the SLR.
If the FPGA is 1 SLR, it still may have multiple PLRAM. All CUs within a SLR are connected to the same PLRAM.

With this configuration, you'll be able to select which PLRAM is used for each given SLR.
It also means that all CU present in the SLR will be connected to the selected PLRAM.

If the selected PLRAM could be in another SLR, this will reduce the Memory Sub-System logic present in the CU SLR but increase cross SLR logic/routing.

.. note::
    By default, you should not need to define any PLRAM selection as this is extracted from the :ref:`configure-xclbin-platform-metadata`.


You need to create a mapping between ``slr`` and (``sptag`` & ``index``).

For example, if a FPGA has 4 SLRs with 2 PLRAM per SLR, then normally CU will use PRLAM[0/2/4/6].
If you want to force SLR0 to use the second PLRAM, you need to map (from :ref:`configure-xclbin-platform-metadata`)

  * ``slr`` (SLR0), ``sptag`` (PLRAM) and ``index`` (1).

The following shows how to use the second PLRAM of SLR\ ``0``\ :

.. code-block:: JSON

    "cu_configuration": {
      "plram_selection": {
        "SLR3": "PLRAM[6]",
        "SLR2": "PLRAM[4]",
        "SLR1": "PLRAM[2]",
        "SLR0": "PLRAM[1]"
      }
    }

.. _configure-xclbin-cu_selection:

=============================================================
``cu_selection`` Parameters of wizard configuration JSON file
=============================================================

The following table describes the parameters supported under the ``cu_selection`` node of the :ref:`wizard-configuration-json-file`.

.. table:: ``cu_selection`` parameters of wizard configuration JSON file

    +-----------------------+--------------------------------------------------------------------+
    | Node name             | Description                                                        |
    +=======================+====================================================================+
    | power                 | Select power CUs to be included specifying list of SLR indexes.    |
    |                       |                                                                    |
    |                       | Possible values: ``<slr_idx>`` in ``cu_configuration.power``.      |
    |                       |                                                                    |
    |                       | Defaults: none.                                                    |
    +-----------------------+--------------------------------------------------------------------+
    | gt_mac                | Select GT_MAC CUs to be included specifying list of GT indexes.    |
    |                       |                                                                    |
    |                       | Possible values: ``<gt_idx>`` in ``cu_configuration.gt_mac``.      |
    |                       |                                                                    |
    |                       | Defaults: none.                                                    |
    +-----------------------+--------------------------------------------------------------------+
    | gt_prbs               | Select GT_PRBS CUs to be included specifying list of GT indexes.   |
    |                       |                                                                    |
    |                       | Possible values: ``<gt_idx>`` in ``cu_configuration.gt``.          |
    |                       |                                                                    |
    |                       | Defaults: none.                                                    |
    +-----------------------+--------------------------------------------------------------------+
    | gt_lpbk               | Select GT_LPBK CUs to be included specifying list of GT indexes.   |
    |                       |                                                                    |
    |                       | Possible values:                                                   |
    |                       |                                                                    |
    |                       | Defaults: none.                                                    |
    +-----------------------+--------------------------------------------------------------------+
    | memory                | Select memory CUs to be included specifying list of memory types.  |
    |                       |                                                                    |
    |                       | Possible values: ``<memory_type>`` in ``cu_configuration.memory``. |
    |                       |                                                                    |
    |                       | Defaults: none.                                                    |
    +-----------------------+--------------------------------------------------------------------+

=====================================================
Auto-configuration examples
=====================================================

The following table describes some examples of how to override the auto-configuration.
The exact content of the file is described further, but these examples shows how everything is merged.

-------------------------------------------------------
Override GT definition
-------------------------------------------------------

For older platform like ``xilinx_u50lv_gen3x4_xdma_2_202010_1``, the GT definition in platform metadata is not as expected by xbtest.
The auto-configured GT parameters at dictionary key ``io_gt_qsfp_00`` are unset and you need to define the GT entirely.

.. table:: Override GT Definition

    +-----------------------------------------------------------+----------------------------------------------------------+------------------------------------------------------------+
    | Auto wizard configuration (platform metadata)             | Wizard configuration JSON (provided by user)             | Actual wizard configuration (merged)                       |
    +===========================================================+==========================================================+============================================================+
    | .. code-block:: JSON                                      | .. code-block:: JSON                                     | .. code-block:: JSON                                       |
    |                                                           |                                                          |                                                            |
    |     {                                                     |     {                                                    |     {                                                      |
    |       "default" : {                                       |       "default": {                                       |       "xbtest_stress" : {                                  |
    |         "platform" : {                                    |         "platform": {                                    |         "platform" : {                                     |
    |           "gt" : {                                        |           "gt": {                                        |           "gt" : {                                         |
    |              "io_gt_qsfp_00" : {                          |             "0": {                                       |              "0" : {                                       |
    |                "slr" : "SLR1",                            |               "group_select" : [                         |                "slr" : "SLR1",                             |
    |                "type" : "GTY",                            |                 "Quad_X0Y7"                              |                "type" : "GTY",                             |
    |                "group_select" : []                        |               ],                                         |                "group_select" : ["Quad_X0Y7"]              |
    |              }                                            |               "type" : "GTY",                            |              }                                             |
    |           }                                               |               "slr" : "SLR1"                             |           }                                                |
    |         },                                                |             }                                            |         },                                                 |
    |         "cu_configuration" : {                            |           }                                              |         "cu_configuration" : {                             |
    |           "gt" : {                                        |         },                                               |           "gt" : {                                         |
    |             "io_gt_qsfp_00" : {                           |         "cu_configuration": {                            |             "0" : {                                        |
    |               "diff_clocks" : ["io_clk_qsfp_refclka_00"], |           "gt": {                                        |               "diff_clocks" : ["io_clk_qsfp_refclka_00"],  |
    |               "serial_port" : []                          |             "0": {                                       |               "serial_port" : ["io_gt_qsfp_00"]            |
    |             }                                             |               "serial_port" : ["io_gt_qsfp_00"],         |             }                                              |
    |           },                                              |               "diff_clocks" : ["io_clk_qsfp_refclka_00"] |           },                                               |
    |           "gt_mac" : {                                    |             }                                            |           "gt_mac" : {                                     |
    |             "io_gt_qsfp_00" : {                           |           },                                             |             "0" : {                                        |
    |               "ip_sel" : "xxv",                           |           "gt_mac": {                                    |               "ip_sel" : "xxv",                            |
    |               "enable_rsfec" : false                      |             "0": {                                       |               "enable_rsfec" : false                       |
    |             }                                             |               "ip_sel" : "xxv",                          |             }                                              |
    |           }                                               |               "enable_rsfec" : false                     |           }                                                |
    |         }                                                 |              }                                           |         }                                                  |
    |       }                                                   |           }                                              |       }                                                    |
    |     }                                                     |         }                                                |     }                                                      |
    |                                                           |       }                                                  |                                                            |
    |                                                           |     }                                                    |                                                            |
    +-----------------------------------------------------------+----------------------------------------------------------+------------------------------------------------------------+

-------------------------------------------------------
Define new memory type
-------------------------------------------------------

Some platforms require definition of new memory types (e.g. u25 PS_DDR, PL_DDR).
In this case, you need to specify all parameters of these new memory types.
Auto-configured and new user-defined memory types are present in the actual wizard configuration.

.. table:: Define new memory type

    +-----------------------------------------------+------------------------------------------------------+------------------------------------------------------+
    | Auto wizard configuration (platform metadata) | Wizard configuration JSON (provided by user)         | Actual wizard configuration (merged)                 |
    +===============================================+======================================================+======================================================+
    | .. code-block:: JSON                          | .. code-block:: JSON                                 | .. code-block:: JSON                                 |
    |                                               |                                                      |                                                      |
    |     "memory" : {                              |     "memory": {                                      |     "memory": {                                      |
    |       "DDR" : {                               |       "PL_DDR": {                                    |       "DDR" : {                                      |
    |         "global" : {                          |         "global" : {                                 |         "global" : {                                 |
    |           "target" : "board",                 |           "target" : "board",                        |           "target" : "board",                        |
    |           "axi_data_size" : 512,              |           "axi_data_size" : 256,                     |           "axi_data_size" : 512,                     |
    |           "axi_id_threads" : 1,               |           "axi_id_threads" : 1,                      |           "axi_id_threads" : 1,                      |
    |           "axi_outstanding" : 32              |           "axi_outstanding" : 32                     |           "axi_outstanding" : 32                     |
    |         },                                    |         },                                           |         },                                           |
    |         "specific" : {                        |         "specific": {                                |         "specific" : {                               |
    |           "0" : {                             |           "0": {                                     |           "0" : {                                    |
    |             "slr" : "SLR0",                   |             "slr" : "SLR0",                          |              "slr" : "SLR0",                         |
    |             "sptag" : ["DDR[0]"]              |             "sptag" : ["DDR[0]"]                     |              "sptag" : ["DDR[0]"]                    |
    |           },                                  |           }                                          |           },                                         |
    |           "1" : {                             |         }                                            |           "1" : {                                    |
    |             "slr" : "SLR1",                   |       },                                             |             "slr" : "SLR1",                          |
    |             "sptag" : ["DDR[1]"]              |       "PS_DDR": {                                    |             "sptag" : ["DDR[1]"]                     |
    |           }                                   |         "global" : {                                 |           }                                          |
    |         }                                     |           "target" : "board",                        |         }                                            |
    |       }                                       |           "axi_data_size" : 128,                     |       },                                             |
    |     }                                         |           "axi_id_threads" : 1,                      |       "PL_DDR": {                                    |
    |                                               |           "axi_outstanding" : 32                     |         "global" : {                                 |
    |                                               |         },                                           |           "target" : "board",                        |
    |                                               |         "specific": {                                |           "axi_data_size" : 256,                     |
    |                                               |           "0": {                                     |           "axi_id_threads" : 1,                      |
    |                                               |             "slr"   : "SLR0",                        |           "axi_outstanding" : 32                     |
    |                                               |             "sptag" : [                              |         },                                           |
    |                                               |               "DDR[1]", "DDR[1]", "DDR[1]", "DDR[1]" |         "specific": {                                |
    |                                               |             ]                                        |           "0": {                                     |
    |                                               |           }                                          |             "slr" : "SLR0",                          |
    |                                               |         }                                            |             "sptag" : ["DDR[0]"]                     |
    |                                               |       }                                              |           }                                          |
    |                                               |     }                                                |         }                                            |
    |                                               |                                                      |       },                                             |
    |                                               |                                                      |       "PS_DDR": {                                    |
    |                                               |                                                      |         "global" : {                                 |
    |                                               |                                                      |           "target" : "board",                        |
    |                                               |                                                      |           "axi_data_size" : 128,                     |
    |                                               |                                                      |           "axi_id_threads" : 1,                      |
    |                                               |                                                      |           "axi_outstanding" : 32                     |
    |                                               |                                                      |         },                                           |
    |                                               |                                                      |         "specific": {                                |
    |                                               |                                                      |           "0": {                                     |
    |                                               |                                                      |             "slr" : "SLR0",                          |
    |                                               |                                                      |             "sptag" : [                              |
    |                                               |                                                      |               "DDR[1]", "DDR[1]", "DDR[1]", "DDR[1]" |
    |                                               |                                                      |             ]                                        |
    |                                               |                                                      |           }                                          |
    |                                               |                                                      |         }                                            |
    |                                               |                                                      |       }                                              |
    |                                               |                                                      |     }                                                |
    +-----------------------------------------------+------------------------------------------------------+------------------------------------------------------+

-------------------------------------------------------
Override existing memory type
-------------------------------------------------------

xbtest can auto configure 3 memory types: DDR, HBM, HOST.
You can override memory ``global`` configuration of any auto-configured memory type.

.. table:: Override existing memory type

    +-----------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------+
    | Auto wizard configuration (platform metadata)             | Wizard configuration JSON (provided by user) | Actual wizard configuration (merged)                      |
    +===========================================================+==============================================+===========================================================+
    | .. code-block:: JSON                                      | .. code-block:: JSON                         | .. code-block:: JSON                                      |
    |                                                           |                                              |                                                           |
    |     "memory" : {                                          |     "memory" : {                             |     "memory" : {                                          |
    |       "HBM" : {                                           |       "HBM" : {                              |       "HBM" : {                                           |
    |         "global" : {                                      |         "global" : {                         |         "global" : {                                      |
    |           "target" : "board",                             |           "axi_data_size" : 256              |           "target" : "board",                             |
    |           "axi_data_size" : 512,                          |         }                                    |           "axi_data_size" : 256,                          |
    |           "axi_id_threads" : 1,                           |       }                                      |           "axi_id_threads" : 1,                           |
    |           "axi_outstanding" : 32                          |     }                                        |           "axi_outstanding" : 32                          |
    |         },                                                |                                              |         },                                                |
    |         "specific" : {                                    |                                              |         "specific" : {                                    |
    |           "0" : {                                         |                                              |           "0" : {                                         |
    |             "slr" : "SLR0",                               |                                              |             "slr" : "SLR0",                               |
    |             "sptag" : [                                   |                                              |             "sptag" : [                                   |
    |               "HBM[0]",  "HBM[1]",  "HBM[2]",  "HBM[3]",  |                                              |               "HBM[0]",  "HBM[1]",  "HBM[2]",  "HBM[3]",  |
    |               "HBM[4]",  "HBM[5]",  "HBM[6]",  "HBM[7]",  |                                              |               "HBM[4]",  "HBM[5]",  "HBM[6]",  "HBM[7]",  |
    |               "HBM[8]",  "HBM[9]",  "HBM[10]", "HBM[11]", |                                              |               "HBM[8]",  "HBM[9]",  "HBM[10]", "HBM[11]", |
    |               "HBM[12]", "HBM[13]", "HBM[14]", "HBM[15]", |                                              |               "HBM[12]", "HBM[13]", "HBM[14]", "HBM[15]", |
    |               "HBM[16]", "HBM[17]", "HBM[18]", "HBM[19]", |                                              |               "HBM[16]", "HBM[17]", "HBM[18]", "HBM[19]", |
    |               "HBM[20]", "HBM[21]", "HBM[22]", "HBM[23]", |                                              |               "HBM[20]", "HBM[21]", "HBM[22]", "HBM[23]", |
    |               "HBM[24]", "HBM[25]", "HBM[26]", "HBM[27]", |                                              |               "HBM[24]", "HBM[25]", "HBM[26]", "HBM[27]", |
    |               "HBM[28]", "HBM[29]", "HBM[30]", "HBM[31]"  |                                              |               "HBM[28]", "HBM[29]", "HBM[30]", "HBM[31]"  |
    |             ]                                             |                                              |             ]                                             |
    |           }                                               |                                              |           }                                               |
    |         }                                                 |                                              |         }                                                 |
    |       }                                                   |                                              |       }                                                   |
    |     }                                                     |                                              |     }                                                     |
    +-----------------------------------------------------------+----------------------------------------------+-----------------------------------------------------------+

.. _wizard-configuration-examples:

=====================================================
Wizard configuration examples
=====================================================

The following table provides example of :ref:`wizard-configuration-json-file` for some platforms:

.. table:: Wizard configuration examples

    +---------------------------------------+-------------------------------------------+--------------------------+
    | Platform                              | Description                               | wizard_cfg.json          |
    +=======================================+===========================================+==========================+
    | xilinx_u55c_gen3x16_xdma_3_202210_1   | U55c example:                             | |u55c wizard_cfg.json|_  |
    |                                       |                                           |                          |
    |                                       |   * Power CU in 2 SLRs.                   |                          |
    |                                       |   * Two GT_MAC CUs.                       |                          |
    |                                       |   * One 32-channel HBM memory CU.         |                          |
    |                                       |   * One single-channel HOST memory CU.    |                          |
    |                                       |                                           |                          |
    +---------------------------------------+-------------------------------------------+--------------------------+
    | xilinx_u250_gen3x16_xdma_4_1_202210_1 | U250 example:                             | |u250 wizard_cfg.json|_  |
    |                                       |                                           |                          |
    |                                       |   * Power CUs in 4 SLRs.                  |                          |
    |                                       |   * One GT_MAC CU.                        |                          |
    |                                       |   * One GT_PRBS CU.                       |                          |
    |                                       |   * Four single-channel DDR memory CUs.   |                          |
    |                                       |   * One single-channel HOST memory CU.    |                          |
    |                                       |                                           |                          |
    +---------------------------------------+-------------------------------------------+--------------------------+
    | xilinx_u50lv_gen3x4_xdma_2_202010_1   | U50lv example:                            | |u50lv wizard_cfg.json|_ |
    |                                       |                                           |                          |
    |                                       |   * Power CUs in 2 SLRs.                  |                          |
    |                                       |   * One GT_MAC CU.                        |                          |
    |                                       |   * One 32-channel HBM memory CU.         |                          |
    |                                       |                                           |                          |
    +---------------------------------------+-------------------------------------------+--------------------------+

=====================================================
Wizard configuration JSON file template
=====================================================

Here is a template/view of wizard configuration JSON file containing all the parameters listed above:

.. code-block::

    {
      "default": {
        "platform": {
          "fpga_part": "<fpga_part>",
          "name": "<name>",
          "interface_uuid": "<interface_uuid>",
          "is_nodma": true/false,
          "p2p_support": true/false,
          "mac_addresses_available": <mac_addresses_available>,
          "gt": {
            "<gt_idx>": {
              "slr": "<slr>",
              "type": "<type>",
              "group_select": ["<group_select>"]
            }
          }
        },
        "build": {
          "pwr_floorplan_dir": "../pwr_cfg",
          "vpp_options_dir": "../vpp_cfg",
          "display_pwr_floorplan": true/false
        },
        "cu_configuration": {
          "clock": {
            "<clk_idx>": {
              "freq": <freq>
            }
          },
          "plram_selection": {
            "<slr>": "<plram_sptag>"
          },
          "verify": {
            "slr": "<slr>",
            "dna_read": true/false
          },
          "gt": {
            "<gt_idx>": {
              "serial_port": ["<serial_port>"],
              "diff_clocks": ["<diff_clocks>"]
            }
          },
          "gt_mac": {
            "<gt_idx>": {
              "ip_sel": "<ip_sel>",
              "enable_rsfec": true/false
            }
          },
          "power": {
            "<slr_idx>": {
              "throttle_mode": "<throttle_mode>"
            }
          },
          "memory": {
            "<mem_type>": {
              "global": {
                "target": "<target>",
                "axi_data_size": <axi_data_size>,
                "axi_id_threads": <axi_id_threads>,
                "axi_outstanding": <axi_outstanding>
              },
              "specific": {
                "<cu_idx>": {
                  "sptag": [
                    "ch0_sptag",  "ch1_sptag", "..."
                  ],
                  "slr": "<slr>"
                }
              }
            }
          }
        }
      },
      "xbtest_stress": {
        "cu_selection": {
          "power": [<slr_idx>],
          "gt_mac": [<gt_idx>],
          "gt_prbs": [<gt_idx>],
          "memory": ["<mem_type>"]
        }
      }
    }
