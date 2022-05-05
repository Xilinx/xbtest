
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _fill-platform-definition-json:

##########################################################################
Fill platform definition JSON
##########################################################################

.. _platform-definition-JSON-file:

********************************************************
Platform definition JSON file: ``xbtest_pfm_def.json``
********************************************************

.. include:: share/note-iterative-pkg.rst

xbtest SW is written in a generic way and can be used by any platform.

As each platform has its own characteristics and limits, xbtest uses a :ref:`platform-definition-JSON-file` to limit and check user operation/settings.

For example:

  * Memory: DMA/P2P/CU bandwidth and latency limits and nominal configurations.
  * GT transceiver settings.
  * Power or temperature sensor sources to be monitored.

The |rpm_generate| workflow includes :ref:`platform-definition-JSON-file` in the RPM/DEB packages with xclbin and pre-canned test JSON files.

Further down this page, you will find:

  * :ref:`platform-definition-JSON-file-template` definition.
  * :ref:`platform-definition-JSON-file-examples` for various platforms.
  * :ref:`all-platform-definition-JSON-file-parameters`.

.. _platform-definition-JSON-file-template:

**************************************************************************
Platform definition JSON file template: ``xbtest_pfm_def_template.json``
**************************************************************************

A :ref:`platform-definition-JSON-file-template` is automatically

  * Generated based on the compute units selected in :ref:`wizard-configuration-json-file` when generating an xclbin using |xclbin_generate| workflow.
  * Passed to the |rpm_generate| workflow using xclbin file as carrying vector (embedded in xclbin section ``USER_METADATA``).

You'll have to update the generated template as it contains default values.
This update is done while filling the checklist (see :ref:`complete-checklist`).

********************************************************
Steps to fill platform definition JSON file
********************************************************

The following sections describes the steps necessary to fill :ref:`platform-definition-JSON-file` by updating the generated :ref:`platform-definition-JSON-file-template`.

===================================================================================
Step 1: Generate RPM/DEB package with xbtest platform definition JSON file template
===================================================================================

Follow the steps specified in :ref:`build-rpm-and-deb-packages` to generate an xbtest HW RPM or DEB package containing the :ref:`platform-definition-JSON-file-template` automatically generated and embedded in the xclbin.

Before generating the RPM or DEB, make sure the :ref:`platform-definition-JSON-file` does not exists in the |rpm_generate| workflow configuration directory ``<xbtest_build>/rpm_generate/include/<deploy_platform>/xbtest_pfm_def.json``.

  * |<xbtest_build> def|
  * |<deploy_platform> def|

==========================================================================
Step 2: Complete checklist and update xbtest platform definition JSON file
==========================================================================

Follow the steps specified in the |checklist| using the RPM or DEB package generated in previous step.

Dummy/low values are specified for each parameter in the generated :ref:`platform-definition-JSON-file-template` which must be replaced by actual values while following and completing a |checklist|.

:ref:`platform-definition-JSON-file-template` can be found in ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/sw/test/xbtest_pfm_def_template.json`` where it was written by |xclbin_generate| workflow:

Where:

  * |<xbtest_build> def|
  * |<dev_platform> def|
  * |<project_name> def|

==================================================================================
Step 3: Generate RPM/DEB package with updated xbtest platform definition JSON file
==================================================================================

The updated :ref:`platform-definition-JSON-file` must be saved in the |rpm_generate| workflow include directory ``<xbtest_build>/rpm_generate/include/<deploy_platform>/xbtest_pfm_def.json``

  * |<xbtest_build> def|
  * |<deploy_platform> def|

Finally, generate both xbtest HW RPM and DEB packages containing the updated :ref:`platform-definition-JSON-file`.

.. _platform-definition-JSON-file-examples:

********************************************************
Platform definition JSON file examples
********************************************************

The following table provides example of :ref:`platform-definition-JSON-file` for some platforms:

.. table:: Platform definition JSON file examples

    +------------------------------------+------------------------------+
    | Platform                           | xbtest_pfm_def.json          |
    +====================================+==============================+
    | xilinx-u55c-gen3x16-xdma-base-3    | |u55c xbtest_pfm_def.json|_  |
    +------------------------------------+------------------------------+
    | xilinx-u250-gen3x16-xdma-shell-4.1 | |u250 xbtest_pfm_def.json|_  |
    +------------------------------------+------------------------------+
    | xilinx-u50lv-gen3x4-xdma-base-2    | |u50lv xbtest_pfm_def.json|_ |
    +------------------------------------+------------------------------+

.. _all-platform-definition-JSON-file-parameters:

********************************************************
All platform definition JSON file parameters
********************************************************

The top-level node of the :ref:`platform-definition-JSON-file` is named ``device``.

The following sections describes the parameters supported in :ref:`platform-definition-JSON-file` below the top-level node.

========================================================
``runtime`` parameters of platform definition JSON file
========================================================

The following table describes the parameters supported under the ``runtime`` node of the :ref:`platform-definition-JSON-file`.

.. table:: ``runtime`` parameters of platform definition JSON file

    +---------------+---------+----------+------------+---------------------------------------------------------------+
    | Node name     | Type    | Example  | Required   | Description                                                   |
    |               |         |          | / optional |                                                               |
    +===============+=========+==========+============+===============================================================+
    | download_time | integer | 20       | Required   | Expected maximum xclbin download time (specified in seconds). |
    +---------------+---------+----------+------------+---------------------------------------------------------------+

========================================================
``sensor`` parameters of platform definition JSON file
========================================================

The following table describes the parameters supported under the ``sensor`` node of the :ref:`platform-definition-JSON-file`.

.. table:: ``sensor`` parameters of platform definition JSON file

    +---------+---------+--------+------------+------------+----------------------------------------------------------------------------------------+
    | Node name         | Type   | Example    | Required   | Description                                                                            |
    +---------+---------+        +            + / optional +                                                                                        +
    | Level 1 | Level 2 |        |            |            |                                                                                        |
    +=========+=========+========+============+============+========================================================================================+
    | ``0``   | type    | string | "thermal"  | Optional   | Specify sensor type. Supported values are ``electrical``, ``thermal``, ``mechanical``. |
    | / ``1`` |         |        |            |            |                                                                                        |
    | / ...   |         |        |            |            | Index must be starting at ``0`` and incrementing by ``1``: ``0``/``1``/...             |
    |         |         |        |            |            |                                                                                        |
    |         |         |        |            |            | For more details, see :ref:`add-sensor-to-monitor`.                                    |
    +         +---------+--------+------------+------------+----------------------------------------------------------------------------------------+
    |         | id      | string | "fpga_hbm" | Optional   | Specify sensor ID to be monitored.                                                     |
    +---------+---------+--------+------------+------------+----------------------------------------------------------------------------------------+

.. _add-sensor-to-monitor:

---------------------------------------------------
Add sensor to monitor
---------------------------------------------------

Each board has multiple power rails, which could be cascaded and not all are used by the FPGA (see ``xbutil examine``).
For example, the u50 has following rails:

  * ``12v_aux``.
  * ``12v_pex``.
  * ``3v3_pex``.
  * ``vccint`` (which comes from ``12v_aux``).

xbtest uses |XRT Device APIs|_ to gather sensor information.

Some sensors are always monitored by default. You can also define other sensors you want to monitor.

All sources listed under the ``sensor`` node of the :ref:`platform-definition-JSON-file` will be monitored and values will be written in the CSV output files (see |xbtest UG|_).

Try the following command:

.. code-block:: bash

    $ xbtest -d <bdf> -g device_mgmt

This command allows to identify:

  * Which ``type`` and ``id`` are monitored by default.
  * Which ``id`` are supported for each ``type``.

      * This is also reported using the following command:

        .. code-block:: bash

            $ xbutil examine --device <bdf>

.. code-block:: bash

    INFO      :: ITF_077 :: INPUT_PARSER ::         * Supported "electrical" sensor IDs: "12v_aux", "12v_pex", "3v3_pex", "3v3_aux", "vccint", "vccint_io", "ddr_vpp_btm", "ddr_vpp_top", "5v5_system", "1v2_top", "vcc_1v2_btm", "1v8_top", "0v9_vcc", "12v_sw", "mgt_vtt", "3v3_vcc", "hbm_1v2", "vpp2v5", "12v_aux1", "vcc1v2_i", "v12_in_i", "v12_in_aux0_i", "v12_in_aux1_i", "vcc_aux", "vcc_aux_pmc", "vcc_ram", "0v9_vccint_vcu", "power_consumption"
    INFO      :: ITF_077 :: INPUT_PARSER ::         * Supported "thermal" sensor IDs: "pcb_top_front", "pcb_top_rear", "fpga0", "int_vcc", "fpga_hbm"
    INFO      :: ITF_077 :: INPUT_PARSER ::         * Supported "mechanical" sensor IDs: "fpga_fan_1"
    INFO      :: ITF_077 :: INPUT_PARSER ::         * Here are the IDs of sensors recorded by default for each sensor type:
    INFO      :: ITF_077 :: INPUT_PARSER ::             + "electrical": "12v_pex", "12v_aux", "3v3_pex", "vccint", "power_consumption"
    INFO      :: ITF_077 :: INPUT_PARSER ::             + "thermal": "fpga0"
    INFO      :: ITF_077 :: INPUT_PARSER ::             + "mechanical": "fpga_fan_1"

For example, to monitor thermal sensor ``fpga_hbm``:

.. code-block:: JSON

      "sensor": {
        "0": {
          "type": "thermal",
          "id": "fpga_hbm"
        }
      }

========================================================
``gt`` parameters of platform definition JSON file
========================================================

The following table describes the parameters supported under the ``gt`` node of the :ref:`platform-definition-JSON-file`.

.. table:: ``gt`` parameters of platform definition JSON file

    +----------------------+-------------+-------------------------------+-----------+---------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Node name                                                          | Type      | Example | Required   | Description                                                                                                                                                                      |
    +----------------------+-------------+-------------------------------+           +         + / optional +                                                                                                                                                                                  +
    | Level 1              | Level 2     | Level 3                       |           |         |            |                                                                                                                                                                                  |
    +======================+=============+===============================+===========+=========+============+==================================================================================================================================================================================+
    | name                 |             |                               | string    | "top"   | Optional   | GT name. Typically: ``top`` or ``bottom``.                                                                                                                                       |
    |                      |             |                               |           |         |            | Index must be starting at ``0`` and incrementing by ``1``: ``0``/``1``/....                                                                                                      |
    |                      |             |                               |           |         |            |                                                                                                                                                                                  |
    +----------------------+-------------+-------------------------------+-----------+---------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | transceiver_settings | ``module``  | tx_differential_swing_control | integer   | 0       | Required   | Configure the GTY Transceiver ``TXDIFFCTRL`` input to all transmitters.                                                                                                          |
    |                      | / ``cable`` |                               |           |         |            | Possible values: from ``0`` to ``31``.                                                                                                                                           |
    |                      |             |                               |           |         |            |                                                                                                                                                                                  |
    |                      |             |                               |           |         |            | This is the default value of ``gt_tx_diffctrl`` test JSON parameter (when ``gt_settings`` test JSON parameter is set to ``module``/``cable``).                                   |
    |                      |             |                               |           |         |            | See |UG578|_ for details.                                                                                                                                                        |
    +----------------------+-------------+-------------------------------+-----------+---------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                      |             | tx_pre_emphasis               | integer   | 0       | Required   | Configure the GTY Transceiver ``TXPRECURSOR`` input to all transmitters.                                                                                                         |
    |                      |             |                               |           |         |            | Possible values: from ``0`` to ``31``.                                                                                                                                           |
    |                      |             |                               |           |         |            |                                                                                                                                                                                  |
    |                      |             |                               |           |         |            | This is the default value of ``gt_tx_pre_emph`` test JSON parameter (when ``gt_settings`` test JSON parameter is set to ``module``/``cable``).                                   |
    |                      |             |                               |           |         |            | See |UG578|_ for details.                                                                                                                                                        |
    +                      +             +-------------------------------+-----------+---------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                      |             | tx_post_emphasis              | integer   | 0       | Required   | Configure the GTY Transceiver ``TXPOSTCURSOR`` input to all transmitters.                                                                                                        |
    |                      |             |                               |           |         |            | Possible values: from ``0`` to ``31``.                                                                                                                                           |
    |                      |             |                               |           |         |            |                                                                                                                                                                                  |
    |                      |             |                               |           |         |            | This is the default value of ``gt_tx_pre_emph`` test JSON parameter (when ``gt_settings`` test JSON parameter is set to ``module``/``cable``).                                   |
    |                      |             |                               |           |         |            | See |UG578|_ for details.                                                                                                                                                        |
    +                      +             +-------------------------------+-----------+---------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                      |             | rx_equaliser                  | string    | "DFE"   | Required   | Configure the GTY Transceiver ``RXLPMEN`` input to all transmitters.                                                                                                             |
    |                      |             |                               |           |         |            | Possible values: ``DFE`` or ``LPM``.                                                                                                                                             |
    |                      |             |                               |           |         |            |                                                                                                                                                                                  |
    |                      |             |                               |           |         |            | When set to ``LPM``,  the default value of ``gt_rx_use_lpm`` test JSON parameter is set to ``true`` (when ``gt_settings`` test JSON parameter is set to ``module``/``cable``).   |
    |                      |             |                               |           |         |            | See |UG578|_ for details.                                                                                                                                                        |
    +----------------------+-------------+-------------------------------+-----------+---------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

========================================================
``memory`` parameters of platform definition JSON file
========================================================

The following table describes the parameters supported under the ``memory`` node of the :ref:`platform-definition-JSON-file`.

.. table:: ``memory`` parameters of platform definition JSON file

    +-----------------+---------+--------+----------+------------+-------------------------------------------------------------------------------------------------------------------+
    | Node name                 | Type   | Example  | Required   | Description                                                                                                       |
    +-----------------+---------+        +          + / optional +                                                                                                                   +
    | Level 1         | Level 2 |        |          |            |                                                                                                                   |
    +=================+=========+========+==========+============+===================================================================================================================+
    | ``0``           | name    | string | "HBM"    | Required   | Memory type name. Used to identify a CU based on the CU name (not case sensitive).                                |
    | / ``1``         |         |        |          |            | The same memory type names are defined in the wizard configuration JSON file. See :ref:`cu_configuration-memory`. |
    | / ...           |         |        |          |            |                                                                                                                   |
    |                 |         |        |          |            | Index must be starting at ``0`` and incrementing by ``1``: ``0``/``1``/...                                        |
    +-----------------+---------+--------+----------+------------+-------------------------------------------------------------------------------------------------------------------+

----------------------------------------------------------
DMA parameters of platform definition JSON file
----------------------------------------------------------

The following table describes the DMA parameters supported under the ``memory`` node of the :ref:`platform-definition-JSON-file`.

These are not applicable for host memory and for NoDMA platforms.

.. table:: DMA Parameters of Platform Definition JSON file

    +-----------------+----------------+-------------+---------+-----------+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------+
    | Node name                                                | Type      | Example  | Required   | Description                                                                                                                                |
    +-----------------+----------------+-------------+---------+           +          + / optional +                                                                                                                                            +
    | Level 1         | Level 2        | Level 3     | Level 4 |           |          |            |                                                                                                                                            |
    +=================+================+=============+=========+===========+==========+============+============================================================================================================================================+
    | ``0``           | dma_bw         | ``write``   | average | integer   | 5000     | Optional   | Average ``write``/``read`` DMA BW threshold (in MBps).                                                                                     |
    | / ``1``         |                | / ``read``  |         |           |          |            |                                                                                                                                            |
    | / ...           |                |             |         |           |          |            | If specified, high and low thresholds default to:                                                                                          |
    |                 |                |             |         |           |          |            |                                                                                                                                            |
    |                 |                |             |         |           |          |            | * high = average + 25%                                                                                                                     |
    |                 |                |             |         |           |          |            | * low  = average - 25%                                                                                                                     |
    +-----------------+----------------+-------------+---------+-----------+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------+
    |                 |                |             | high    | integer   | 16384    | Optional   | High ``write``/``read`` DMA BW threshold (in MBps).                                                                                        |
    |                 |                |             |         |           |          |            |                                                                                                                                            |
    |                 |                |             |         |           |          |            | If high and average thresholds are not specified, default: based on PCIe speed/width = 256MBps * (2^(speed-1)) * width.                    |
    +                 +                +             +---------+-----------+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------+
    |                 |                |             | low     | integer   | 9830     | Optional   | Low ``write``/``read`` DMA BW threshold (in MBps).                                                                                         |
    |                 |                |             |         |           |          |            |                                                                                                                                            |
    |                 |                |             |         |           |          |            | If low and average thresholds are not specified, default: high -40%                                                                        |
    +                 +----------------+-------------+---------+-----------+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------+
    |                 | dma_config     | buffer_size |         | integer   | 1        | Optional   | Define default DMA buffer size (in MB). If not defined the default buffer size is 256 MB (or equals memory size if it is below 256 MB).    |
    |                 |                |             |         |           |          |            |                                                                                                                                            |
    |                 |                |             |         |           |          |            | Recommendation therefore is to use more than one buffer for DMA accesses to HBM on Gen3x4 platforms (e.g. set to 128MB for HBM on Gen3x4). |
    +                 +----------------+-------------+---------+-----------+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------+
    |                 |                | total_size  |         | integer   | 256      | Optional   | Define default DMA total size (in MB). If not defined the default total size is equal to the memory size.                                  |
    +-----------------+----------------+-------------+---------+-----------+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------+

----------------------------------------------------------
P2P CARD parameters of platform definition JSON file
----------------------------------------------------------

The following table describes the P2P CARD parameters supported under the ``memory`` node of the :ref:`platform-definition-JSON-file`.

These are not applicable for host memory and if platform does not support P2P.

.. table:: P2P CARD parameters of platform definition JSON file

    +-----------------+-----------------+-------------+---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
    | Node name                                                 | Type      | Example  | Required   | Description                                                                                                                                  |
    +-----------------+-----------------+-------------+---------+           +          + / optional +                                                                                                                                              +
    | Level 1         | Level 2         | Level 3     | Level 4 |           |          |            |                                                                                                                                              |
    +=================+=================+=============+=========+===========+==========+============+==============================================================================================================================================+
    | ``0``           | p2p_card_bw     | ``write``   | average | integer   | 5000     | Optional   | Average ``write``/``read`` P2P CARD BW threshold (in MBps).                                                                                  |
    | / ``1``         |                 | / ``read``  |         |           |          |            |                                                                                                                                              |
    | / ...           |                 |             |         |           |          |            | If specified, high and low thresholds default to:                                                                                            |
    |                 |                 |             |         |           |          |            |                                                                                                                                              |
    |                 |                 |             |         |           |          |            | * high = average + 25 %                                                                                                                      |
    |                 |                 |             |         |           |          |            | * low  = average - 25 %                                                                                                                      |
    +-----------------+-----------------+-------------+---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
    |                 |                 |             | high    | integer   | 16384    | Optional   | High ``write``/``read`` P2P CARD BW threshold (in MBps).                                                                                     |
    |                 |                 |             |         |           |          |            |                                                                                                                                              |
    |                 |                 |             |         |           |          |            | If high and average thresholds are not specified, default: based on PCIe speed/width = 256 MBps * (2^(speed-1)) * width.                     |
    +                 +                 +             +---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
    |                 |                 |             | low     | integer   | 1        | Optional   | Low ``write``/``read`` P2P CARD BW threshold (in MBps).                                                                                      |
    |                 |                 |             |         |           |          |            |                                                                                                                                              |
    |                 |                 |             |         |           |          |            | If low and average thresholds are not specified, Default: 1                                                                                  |
    +                 +-----------------+-------------+---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
    |                 | p2p_card_config | buffer_size |         | integer   | 1        | Optional   | Define default P2P CARD buffer size (in MB). If not defined the default buffer size is 256 MB (or equals memory size if it is below 256 MB). |
    +                 +-----------------+-------------+---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
    |                 |                 | total_size  |         | integer   | 256      | Optional   | Define default P2P CARD total size (in MB). If not defined the default total size is equal to the memory size.                               |
    +-----------------+-----------------+-------------+---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+

----------------------------------------------------------
P2P NVME parameters of platform definition JSON file
----------------------------------------------------------

The following table describes the P2P NVME parameters supported under the ``memory`` node of the :ref:`platform-definition-JSON-file`.

These are not applicable for host memory and if platform does not support P2P.

.. table:: P2P NVME parameters of platform definition JSON file

    +-----------------+-----------------+-------------+---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
    | Node name                                                 | Type      | Example  | Required   | Description                                                                                                                                  |
    +-----------------+-----------------+-------------+---------+           +          + / optionaL +                                                                                                                                              +
    | Level 1         | Level 2         | Level 3     | Level 4 |           |          |            |                                                                                                                                              |
    +=================+=================+=============+=========+===========+==========+============+==============================================================================================================================================+
    | ``0``           | p2p_nvme_bw     | ``write``   | average | integer   | 5000     | Optional   | Average ``write``/``read`` P2P NVME BW threshold (in MBps).                                                                                  |
    | / ``1``         |                 | / ``read``  |         |           |          |            |                                                                                                                                              |
    | / ...           |                 |             |         |           |          |            | If specified, high and low thresholds default to:                                                                                            |
    |                 |                 |             |         |           |          |            |                                                                                                                                              |
    |                 |                 |             |         |           |          |            | * high = average + 25 %                                                                                                                      |
    |                 |                 |             |         |           |          |            | * low  = average - 25 %                                                                                                                      |
    +-----------------+-----------------+-------------+---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
    |                 |                 |             | high    | integer   | 16384    | Optional   | High ``write``/``read`` P2P NVME BW threshold (in MBps).                                                                                     |
    |                 |                 |             |         |           |          |            |                                                                                                                                              |
    |                 |                 |             |         |           |          |            | If high and average thresholds are not specified, default: based on PCIe speed/width = 256 MBps * (2^(speed-1)) * width.                     |
    +                 +                 +             +---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
    |                 |                 |             | low     | integer   | 1        | Optional   | Low ``write``/``read`` P2P NVME BW threshold (in MBps).                                                                                      |
    |                 |                 |             |         |           |          |            |                                                                                                                                              |
    |                 |                 |             |         |           |          |            | If low and average thresholds are not specified, Default: 1                                                                                  |
    +                 +-----------------+-------------+---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
    |                 | p2p_nvme_config | buffer_size |         | integer   | 1        | Optional   | Define default P2P NVME buffer size (in MB). If not defined the default buffer size is 256 MB (or equals memory size if it is below 256 MB). |
    +                 +-----------------+-------------+---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
    |                 |                 | total_size  |         | integer   | 256      | Optional   | Define default P2P NVME total size (in MB). If not defined the default total size is equal to the memory size.                               |
    +-----------------+-----------------+-------------+---------+-----------+----------+------------+----------------------------------------------------------------------------------------------------------------------------------------------+

----------------------------------------------------------
CU parameters of platform definition JSON file
----------------------------------------------------------

The following table describes the CU parameters supported under the ``memory`` node of the :ref:`platform-definition-JSON-file`.

.. table:: CU parameters of platform definition JSON file

    +-----------------+----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    | Node name                                                             | Type      | Example  | Required                | Description                                                                                             |
    +-----------------+----------------+-------------+------------+---------+           +          + / optional              +                                                                                                         +
    | Level 1         | Level 2        | Level 3     | Level 4    | Level 5 |           |          |                         |                                                                                                         |
    +=================+================+=============+============+=========+===========+==========+=========================+=========================================================================================================+
    | ``0``           | cu_bw          | only_wr     | write      | average | integer   | 1000     | Required                | Average write BW threshold (in MBps) in ``only_wr`` test mode.                                          |
    | / ``1``         |                |             |            |         |           |          |                         |                                                                                                         |
    | / ...           |                |             |            |         |           |          |   * if ``high`` and     | If specified, high and low thresholds default to:                                                       |
    |                 |                |             |            |         |           |          |     ``low``             |                                                                                                         |
    |                 |                |             |            |         |           |          |     not specified       |   * high = average + 10 %                                                                               |
    |                 |                |             |            |         |           |          |                         |   * low  = average - 10 %                                                                               |
    +-----------------+----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | high    | integer   | 1100     | Required                | High write BW threshold (in MBps) in ``only_wr`` test mode.                                             |
    |                 |                |             |            |         |           |          | if ``average``          |                                                                                                         |
    |                 |                |             |            |         |           |          | not specified           |                                                                                                         |
    +                 +                +             +            +---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | low     | integer   | 900      | Required                | Low write BW threshold (in MBps) in ``only_wr`` test mode.                                              |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |   * if ``average``      |                                                                                                         |
    |                 |                |             |            |         |           |          |     not specified       |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | only_rd     | read       | average | integer   | 1000     | Required                | Average write BW threshold (in MBps) in ``only_rd`` test mode.                                          |
    |                 |                |             |            |         |           |          | if ``high`` and ``low`` |                                                                                                         |
    |                 |                |             |            |         |           |          | not specified           | If specified, high and low thresholds default to:                                                       |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * high = average + 10 %                                                                               |
    |                 |                |             |            |         |           |          |                         |   * low  = average - 10 %                                                                               |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | high    | integer   | 1100     | Required                | High write BW threshold (in MBps) in ``only_rd`` test mode.                                             |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |   * if ``average``      |                                                                                                         |
    |                 |                |             |            |         |           |          |     not specified       |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    +                 +                +             +            +---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | low     | integer   | 900      | Required                | Low write BW threshold (in MBps) in ``only_rd`` test mode.                                              |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |   * if ``average``      |                                                                                                         |
    |                 |                |             |            |         |           |          |     not specified       |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | alt_wr_rd   | ``write``  | average | integer   | 1000     | Optional                | Average ``write``/``read`` BW threshold (in MBps) in ``alternate_wr_rd`` test mode.                     |
    |                 |                |             | / ``read`` |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: (cu_bw.only_wr. ``write``/``read``.average + cu_bw.only_rd. ``write``/``read``.average)/4. |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         | If specified, high and low thresholds default to:                                                       |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * high = average + 10 %                                                                               |
    |                 |                |             |            |         |           |          |                         |   * low  = average - 10 %                                                                               |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | high    | integer   | 1100     | Optional                | High ``write``/``read`` BW threshold (in MBps) in ``alternate_wr_rd`` test mode.                        |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: (cu_bw.only_wr. ``write``/``read``.high + cu_bw.only_rd. ``write``/``read``.high )/4.      |
    +                 +                +             +            +---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | low     | integer   | 900      | Optional                | Low ``write``/``read`` BW threshold (in MBps) in ``alternate_wr_rd`` test mode.                         |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: (cu_bw.only_wr. ``write``/``read``.low+ cu_bw.only_rd. ``write``/``read``.low )/4.         |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | simul_wr_rd | ``write``  | average | integer   | 1000     | Optional                | Average ``write``/``read`` BW threshold (in MBps) in ``simultaneous_wr_rd`` test mode.                  |
    |                 |                |             | / ``read`` |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: (cu_bw.only_wr. ``write``/``read``.average + cu_bw.only_rd. ``write``/``read``.average)/4. |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         | If specified, high and low thresholds default to:                                                       |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * high = average + 10 %                                                                               |
    |                 |                |             |            |         |           |          |                         |   * low  = average - 10 %                                                                               |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | high    | integer   | 1100     | Optional                | High ``write``/``read`` BW threshold (in MBps) in ``simultaneous_wr_rd`` test mode.                     |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: (cu_bw.only_wr. ``write``/``read``.high + cu_bw.only_rd. ``write``/``read``.high )/4.      |
    +                 +                +             +            +---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | low     | integer   | 900      | Optional                | Low ``write``/``read`` BW threshold (in MBps) in ``simultaneous_wr_rd`` test mode.                      |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: (cu_bw.only_wr. ``write``/``read``.low+ cu_bw.only_rd. ``write``/``read``.low )/4.         |
    +                 +----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 | cu_latency     | only_wr     | write      | average | integer   | 100      | Required                | Average write Latency threshold (in ns) in ``only_wr`` test mode.                                       |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |   * if ``high`` and     | If specified, high and low thresholds default to:                                                       |
    |                 |                |             |            |         |           |          |     ``low``             |                                                                                                         |
    |                 |                |             |            |         |           |          |     not specified       |   * high = average + 10 %                                                                               |
    |                 |                |             |            |         |           |          |                         |   * low  = average - 10 %                                                                               |
    +                 +----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | high    | integer   | 110      | Required                | High write Latency threshold (in ns) in ``only_wr`` test mode.                                          |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |   * if ``average``      |                                                                                                         |
    |                 |                |             |            |         |           |          |     not specified       |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    +                 +                +             +            +---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | low     | integer   | 90       | Required                | Low write Latency threshold (in ns) in ``only_wr`` test mode.                                           |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |   * if ``average``      |                                                                                                         |
    |                 |                |             |            |         |           |          |     not specified       |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | only_rd     | read       | average | integer   | 100      | Required                | Average read Latency threshold (in ns) in ``only_rd`` test mode.                                        |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |   * if ``high`` and     | If specified, high and low thresholds default to:                                                       |
    |                 |                |             |            |         |           |          |     ``low``             |                                                                                                         |
    |                 |                |             |            |         |           |          |     not specified       |   * high = average + 10 %                                                                               |
    |                 |                |             |            |         |           |          |                         |   * low  = average - 10 %                                                                               |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | high    | integer   | 110      | Required                | High read Latency threshold (in ns) in ``only_rd`` test mode.                                           |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |   * if ``average``      |                                                                                                         |
    |                 |                |             |            |         |           |          |     not specified       |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    +                 +                +             +            +---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | low     | integer   | 90       | Required                | Low read Latency threshold (in ns) in ``only_rd`` test mode.                                            |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |   * if ``average``      |                                                                                                         |
    |                 |                |             |            |         |           |          |     not specified       |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | alt_wr_rd   | ``write``  | average | integer   | 100      | Optional                | Average ``write``/``read`` Latency threshold (in ns) in ``alternate_wr_rd`` test mode.                  |
    |                 |                |             | / ``read`` |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_latency.only_wr/rd. ``write``/``read``.average                                          |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         | If specified, high and low thresholds default to:                                                       |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * high = average + 10 %                                                                               |
    |                 |                |             |            |         |           |          |                         |   * low  = average - 10 %                                                                               |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | high    | integer   | 110      | Optional                | High ``write``/``read`` Latency threshold (in ns) in ``alternate_wr_rd`` test mode.                     |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_latency.only_wr/rd. ``write``/``read``.high                                             |
    +                 +                +             +            +---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | low     | integer   | 90       | Optional                | Low ``write``/``read`` Latency threshold (in ns) in ``alternate_wr_rd`` test mode.                      |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_latency.only_wr/rd. ``write``/``read``.low                                              |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | simul_wr_rd | ``write``  | average | integer   | 100      | Optional                | Average ``write``/``read`` Latency threshold (in ns) in ``simultaneous_wr_rd`` test mode.               |
    |                 |                |             | / ``read`` |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         | * Default: cu_latency.only_wr/rd. ``write``/``read``.high                                               |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         | If specified, high and low thresholds are computed as:                                                  |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * high = average + 10 %                                                                               |
    |                 |                |             |            |         |           |          |                         |   * low  = average - 10 %                                                                               |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | high    | integer   | 110      | Optional                | High ``write``/``read`` Latency threshold (in ns) in ``simultaneous_wr_rd`` test mode.                  |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_latency.only_wr/rd. ``write``/``read``.high                                             |
    +                 +                +             +            +---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                |             |            | low     | integer   | 90       | Optional                | Low ``write``/``read`` Latency threshold (in ns) in ``simultaneous_wr_rd`` test mode.                   |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_latency.only_wr/rd. ``write``/``read``.low                                              |
    +                 +----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 | cu_rate        | only_wr     | write      | nominal | integer   | 47       | Optional                | Nominal write CU rate (in %) in ``only_wr`` test mode.                                                  |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: 100.                                                                                       |
    +                 +----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | only_rd     | read       | nominal | integer   | 40       | Optional                | Nominal read CU rate (in %) in ``only_rd`` test mode.                                                   |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: 100.                                                                                       |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | alt_wr_rd   | ``write``  | nominal | integer   | 40       | Optional                | Nominal ``write``/``read`` CU rate (in %) in ``alternate_wr_rd`` test mode.                             |
    |                 |                |             | / ``read`` |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_rate.only_wr/rd. ``write``/``read``.nominal                                             |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | simul_wr_rd | ``write``  | nominal | integer   | 23       | Optional                | Nominal ``write``/``read`` CU rate (in %) in ``simultaneous_wr_rd`` test mode.                          |
    |                 |                |             | / ``read`` |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_rate.only_wr/rd. ``write``/``read``.nominal                                             |
    +                 +----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 | cu_burst_size  | only_wr     | write      | nominal | integer   | 2048     | Optional                | Nominal write burst size (in Bytes) in ``only_wr`` test mode.                                           |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: 64*AXI data size if AXI data size = 512 bits, else 128*AXI data size                       |
    |                 |                |             |            |         |           |          |                         |   * Possible values: 128, 256, 512, 1024, 2048, 4096                                                    |
    +                 +----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | only_rd     | read       | nominal | integer   | 2048     | Optional                | Nominal read burst size (in Bytes) in ``only_rd`` test mode.                                            |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: 64*AXI data size if AXI data size = 512 bits, else 128*AXI data size                       |
    |                 |                |             |            |         |           |          |                         |   * Possible values: 128, 256, 512, 1024, 2048, 4096                                                    |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | alt_wr_rd   | ``write``  | nominal | integer   | 2048     | Optional                | Nominal write/read burst size (in Bytes) in ``alternate_wr_rd`` test mode.                              |
    |                 |                |             | / ``read`` |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_burst_size.only_wr/rd. ``write``/``read``.nominal                                       |
    |                 |                |             |            |         |           |          |                         |   * Possible values: 128, 256, 512, 1024, 2048, 4096                                                    |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | simul_wr_rd | ``write``  | nominal | integer   | 1024     | Optional                | Nominal write/read burst size (in Bytes) in ``simultaneous_wr_rd`` test mode.                           |
    |                 |                |             | / ``read`` |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_burst_size.only_wr/rd. ``write``/``read``.nominal                                       |
    |                 |                |             |            |         |           |          |                         |   * Possible values: 128, 256, 512, 1024, 2048, 4096                                                    |
    +                 +----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 | cu_outstanding | only_wr     | write      | nominal | integer   | 4        | Optional                | Nominal maximum number of outstanding writes in ``only_wr`` test mode.                                  |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: 0 (not limited)                                                                            |
    |                 |                |             |            |         |           |          |                         |   * Possible values: 0 to 255                                                                           |
    +                 +----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | only_rd     | read       | nominal | integer   | 4        | Optional                | Nominal maximum number of outstanding reads in ``only_rd`` test mode.                                   |
    |                 |                |             |            |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: 0 (not limited)                                                                            |
    |                 |                |             |            |         |           |          |                         |   * Possible values: 0 to 255                                                                           |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | alt_wr_rd   | ``write``  | nominal | integer   | 4        | Optional                | Nominal maximum number of outstanding writes/reads in ``alternate_wr_rd`` test mode.                    |
    |                 |                |             | / ``read`` |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_outstanding.only_wr/rd. ``write``/``read``.nominal                                      |
    |                 |                |             |            |         |           |          |                         |   * Possible values: 0 to 255                                                                           |
    +                 +                +-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+
    |                 |                | simul_wr_rd | ``write``  | nominal | integer   | 4        | Optional                | Nominal maximum number of outstanding writes/reads in ``simultaneous_wr_rd`` test mode.                 |
    |                 |                |             | / ``read`` |         |           |          |                         |                                                                                                         |
    |                 |                |             |            |         |           |          |                         |   * Default: cu_outstanding.only_wr/rd. ``write``/``read``.nominal                                      |
    |                 |                |             |            |         |           |          |                         |   * Possible values: 0 to 255                                                                           |
    +-----------------+----------------+-------------+------------+---------+-----------+----------+-------------------------+---------------------------------------------------------------------------------------------------------+

********************************************************
Platform definition JSON file template
********************************************************

Here is a template/view of :ref:`platform-definition-JSON-file` containing all the parameters listed above:

.. code-block::

    {
      "device" : {
        "runtime" : {
          "download_time" : <download_time>
        },
        "sensor": {
          "<sensor_idx>": {
            "type": "<type>",
            "id": "<id>"
          }
        },
        "gt" : {
          "<gt_idx>" : {
            "transceiver_settings" : {
              "<module/cable>" : {
                "tx_differential_swing_control" : <tx_differential_swing_control>,
                "tx_pre_emphasis" : <tx_pre_emphasis>,
                "tx_post_emphasis" : <tx_post_emphasis>,
                "rx_equaliser" : "<rx_equaliser>"
              }
            }
          }
        },
        "memory" : {
          "<mem_idx>": {
            "name": "<name>",
            "dma_bw": {
              "write": {
                "average": <average>
              },
              "read": {
                "average": <average>
              }
            },
            "dma_config": {
              "buffer_size": <buffer_size>,
              "total_size": <total_size>
            },
            "p2p_card_bw": {
              "write": {
                "average": <average>
              },
              "read": {
                "average": <average>
              }
            },
            "p2p_card_config": {
              "buffer_size": <buffer_size>,
              "total_size": <total_size>
            },
            "p2p_nvme_bw": {
              "write": {
                "average": <average>
              },
              "read": {
                "average": <average>
              }
            },
            "p2p_nvme_config": {
              "buffer_size": <buffer_size>,
              "total_size": <total_size>
            },
            "cu_rate": {
              "only_wr": {
                "write": {
                  "nominal": <nominal>
                }
              },
              "only_rd": {
                "read": {
                  "nominal": <nominal>
                }
              },
              "simul_wr_rd": {
                "write": {
                  "nominal": <nominal>
                },
                "read": {
                  "nominal": <nominal>
                }
              }
            },
            "cu_outstanding": {
              "only_wr": {
                "write": {
                  "nominal": <nominal>
                }
              },
              "only_rd": {
                "read": {
                  "nominal": <nominal>
                }
              },
              "simul_wr_rd": {
                "write": {
                  "nominal": <nominal>
                },
                "read": {
                  "nominal": <nominal>
                }
              }
            },
            "cu_bw": {
              "only_wr": {
                "write": {
                  "average": <average>
                }
              },
              "only_rd": {
                "read": {
                  "average": <average>
                }
              },
              "simul_wr_rd": {
                "write": {
                  "average": <average>
                },
                "read": {
                  "average": <average>
                }
              }
            },
            "cu_latency": {
              "only_wr": {
                "write": {
                  "average": <average>
                }
              },
              "only_rd": {
                "read": {
                  "average": <average>
                }
              },
              "simul_wr_rd": {
                "write": {
                  "average": <average>
                },
                "read": {
                  "average": <average>
                }
              }
            }
          }
        }
      }
    }