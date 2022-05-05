
.. include:: ../../../shared/links.rst
.. include:: links.rst

.. _calibration-memory-cu-power:

##########################################################################
Calibration - Memory CU power
##########################################################################

********************************************************
Goal
********************************************************

Check that writing/reading the memory at full speed is not overpowering the card.
The memory (and the infrastructure to access it) consumes power and it may exceed the card limits when used a full capacity.

The HBM memory test is more likely to exceed card limits as it can consume up to **40W** when 32 channels are served at full rate simultaneously (400GB/s).

  * In some card (e.g. u50), the HBM power is coming from the ``3v3_pex`` power rail, which is limited to **10W**.
    So, reading/writing at full rate on all channels will consume too much power, which will cause the card to reset or the server to reboot.

There are multiple ways to keep the power consumption below its limit:

  1. Keeping all memory connections and reduce the access rate.
  2. Reducing memory connections in case of multi-channel memory (e.g. HBM).
  3. Not accessing all channels (or DDR) simultaneously: this is diverting the issue to the SW which leads to complex test JSON file.

The first way has been chosen in xbtest (more flexible). The following sections provides instructions for calibrating the memory CU rate to a target power.

********************************************************
Prerequisite
********************************************************

  1. Check power for all memories present on your card (e.g. DDR, HBM, PS_DDR, PL_DDR):

       * What is the expected memory power consumption?
       * How the memory is powered?

           * Which power rail and its limits?

  2. Is there enough power (with 20% margin)?
     Do not forget that other logic may also runs on that same rail.

       * **YES**: Nothing to do and this checklist page can be safely skipped.
       * **NO**: You'll have to calibrate memory CU write & read rates to not reach the power rail limit.

********************************************************
General steps
********************************************************

.. warning::
    You can skip this entire page if **none** of the memory is under powered.
    You need to define a rate for any memory which could potentially exceed its power supply.

By defining rate, you reduce the quantity of write/read accesses to the memory thus its power consumption:

  1. Run 3 tests provided.
     They all are memory tests with memory CU rate ramps (write and read access rates are increasing gradually).

       * As the memory will run out power, expect the server to reboot or the card to reset.

  2. Save results and plot some graphs in section :ref:`calibration-memory-cu-power-checklist` of your checklist.
  3. Check where the card/memory tramps over.

       * Memory test case produces a result file (``memory_<memory_type>_power.csv``) containing the access rate and the power measured.
       * Extract tipping point rate per test with margin (see below).

  4. Fill your platform definition JSON file with these rates.

     .. note::
        By default, any memory test uses the rate defined in platform definition JSON file.

********************************************************
TO-DO
********************************************************

For all on-board memory types (e.g. HBM, DDR, PS_DDR, PL_DDR):

  * Follow :ref:`rate-detailed-steps` section.
  * Use the example provided as reference.
  * Add your results to the section :ref:`calibration-memory-cu-power-checklist` of your checklist.

This calibration is not applicable for host memory (refer to :ref:`host-memory-configuration` section for its configuration).

.. _rate-detailed-steps:

********************************************************
Detailed steps
********************************************************

Nominal rates, BW and latency thresholds must be defined in the platform definition JSON file.

  * xbtest SW can uses default values for some parameters.

To find these values follow the steps below.

.. table:: Detailed steps

    +----------+---------------------------------------------------------------------------------------------------------------+--------------------------------------------------+
    | Step     | Description                                                                                                   | Example                                          |
    +==========+===============================================================================================================+==================================================+
    | Step 0   | Check from where the memory is powered.                                                                       | For u50, HBM are powered by ``3v3_pex``.         |
    |          |                                                                                                               |                                                  |
    |          | .. note::                                                                                                     |                                                  |
    |          |     40W is a rough estimation of a 32-channel HBM memory test power consumption at 100% CU rate.              |                                                  |
    +----------+---------------------------------------------------------------------------------------------------------------+--------------------------------------------------+
    | Step 1   | Check if the power rail can cope with memory test power consumption at 100% CU rate:                          |                                                  |
    |          |                                                                                                               |                                                  |
    |          |   * **If there is enough power for the HBM (~40W)**,                                                          |                                                  |
    |          |     then you may use the default nominal CU rate (100%) and skip the next steps.                              |                                                  |
    |          |   * If there is not enough power, follow the next steps.                                                      |                                                  |
    +----------+---------------------------------------------------------------------------------------------------------------+--------------------------------------------------+
    | Step 2   | Remove 20% from the throttling limit of the power rail to find its minimum throttling limit.                  | For u50: as ``3v3_pex`` limit is 10W,            |
    |          |                                                                                                               | use 0.8*10W = 8W power threshold.                |
    +----------+---------------------------------------------------------------------------------------------------------------+--------------------------------------------------+
    | Step 3   | Find the rate corresponding to this power threshold. For each on-board memory type:                           |                                                  |
    |          |                                                                                                               |                                                  |
    |          |   1. Run the **three** test JSON files below.                                                                 |                                                  |
    |          |                                                                                                               |                                                  |
    |          |        * Each of them contains a ramp of rate;                                                                |                                                  |
    |          |          for a different test mode (``simultaneous_wr_rd``, ``only_rd`` and ``only_wr``).                     |                                                  |
    |          |        * For other memory types, update with memory name being calibrated. E.g. ``testcases.memory.HBM``.     |                                                  |
    |          |                                                                                                               |                                                  |
    |          |   2. From each of the three runs, identify the rate at the power threshold.                                   |                                                  |
    |          |                                                                                                               |                                                  |
    |          | .. important::                                                                                                |                                                  |
    |          |     With these files you should reach the critical power threshold which will cause the **board to reset**.   |                                                  |
    |          |                                                                                                               |                                                  |
    |          |       * This is an expected behaviour.                                                                        |                                                  |
    +----------+---------------------------------------------------------------------------------------------------------------+--------------------------------------------------+
    | Step 3.a | For mode: ``simultaneous_wr_rd``, run the ``simultaneous_wr_rd_rate_ramp`` test for each on-board memory:     |                                                  |
    |          |                                                                                                               |                                                  |
    |          | .. code-block:: bash                                                                                          |                                                  |
    |          |                                                                                                               |                                                  |
    |          |     $ xbtest -F -d <bdf> -j simultaneous_wr_rd_rate_ramp_ddr.json -l simultaneous_wr_rd_rate_ramp_ddr         |                                                  |
    |          |     $ xbtest -F -d <bdf> -j simultaneous_wr_rd_rate_ramp_hbm.json -l simultaneous_wr_rd_rate_ramp_hbm         |                                                  |
    |          |                                                                                                               |                                                  |
    |          | Here is the test file:                                                                                        |                                                  |
    |          |                                                                                                               |                                                  |
    |          |   * For DDR: :download:`simultaneous_wr_rd_rate_ramp_ddr.json <./data/simultaneous_wr_rd_rate_ramp_ddr.json>` |                                                  |
    |          |   * For HBM: :download:`simultaneous_wr_rd_rate_ramp_hbm.json <./data/simultaneous_wr_rd_rate_ramp_hbm.json>` |                                                  |
    |          |                                                                                                               |                                                  |
    |          | Zip the log directory and attach it to this checklist:                                                        |                                                  |
    |          |                                                                                                               |                                                  |
    |          | .. code-block:: bash                                                                                          |                                                  |
    |          |                                                                                                               |                                                  |
    |          |     $ zip -r simultaneous_wr_rd_rate_ramp_ddr.zip simultaneous_wr_rd_rate_ramp_ddr                            |                                                  |
    |          |     $ zip -r simultaneous_wr_rd_rate_ramp_hbm.zip simultaneous_wr_rd_rate_ramp_hbm                            |                                                  |
    |          |                                                                                                               |                                                  |
    +----------+---------------------------------------------------------------------------------------------------------------+--------------------------------------------------+
    | Step 3.b | For mode: ``only_rd``, run the ``only_rd_rate_ramp`` test for each on-board memory:                           |                                                  |
    |          |                                                                                                               |                                                  |
    |          | .. code-block:: bash                                                                                          |                                                  |
    |          |                                                                                                               |                                                  |
    |          |     $ xbtest -F -d <bdf> -j only_rd_rate_ramp_ddr.json -l only_rd_rate_ramp_ddr                               |                                                  |
    |          |     $ xbtest -F -d <bdf> -j only_rd_rate_ramp_hbm.json -l only_rd_rate_ramp_hbm                               |                                                  |
    |          |                                                                                                               |                                                  |
    |          | Here is the test file:                                                                                        |                                                  |
    |          |                                                                                                               |                                                  |
    |          |   * For DDR: :download:`only_rd_rate_ramp_ddr.json <./data/only_rd_rate_ramp_ddr.json>`                       |                                                  |
    |          |   * For HBM: :download:`only_rd_rate_ramp_hbm.json <./data/only_rd_rate_ramp_hbm.json>`                       |                                                  |
    |          |                                                                                                               |                                                  |
    |          | Zip the log directory and attach it to this checklist:                                                        |                                                  |
    |          |                                                                                                               |                                                  |
    |          | .. code-block:: bash                                                                                          |                                                  |
    |          |                                                                                                               |                                                  |
    |          |     $ zip -r only_rd_rate_ramp_ddr.zip only_rd_rate_ramp_ddr                                                  |                                                  |
    |          |     $ zip -r only_rd_rate_ramp_hbm.zip only_rd_rate_ramp_hbm                                                  |                                                  |
    |          |                                                                                                               |                                                  |
    +----------+---------------------------------------------------------------------------------------------------------------+--------------------------------------------------+
    | Step 3.c | For mode: ``only_wr``, run ``only_wr_rate_ramp`` test for each on-board memory:                               |                                                  |
    |          |                                                                                                               |                                                  |
    |          | .. code-block:: bash                                                                                          |                                                  |
    |          |                                                                                                               |                                                  |
    |          |     $ xbtest -F -d <bdf> -j only_wr_rate_ramp_ddr.json -l only_wr_rate_ramp_ddr                               |                                                  |
    |          |     $ xbtest -F -d <bdf> -j only_wr_rate_ramp_hbm.json -l only_wr_rate_ramp_hbm                               |                                                  |
    |          |                                                                                                               |                                                  |
    |          | Here is the test file:                                                                                        |                                                  |
    |          |                                                                                                               |                                                  |
    |          |   * For DDR: :download:`only_wr_rate_ramp_ddr.json <./data/only_wr_rate_ramp_ddr.json>`                       |                                                  |
    |          |   * For HBM: :download:`only_wr_rate_ramp_hbm.json <./data/only_wr_rate_ramp_hbm.json>`                       |                                                  |
    |          |                                                                                                               |                                                  |
    |          | Zip the log directory and attach it to this checklist                                                         |                                                  |
    |          |                                                                                                               |                                                  |
    |          | .. code-block:: bash                                                                                          |                                                  |
    |          |                                                                                                               |                                                  |
    |          |     $ zip -r only_wr_rate_ramp_ddr.zip only_wr_rate_ramp_ddr                                                  |                                                  |
    |          |     $ zip -r only_wr_rate_ramp_hbm.zip only_wr_rate_ramp_hbm                                                  |                                                  |
    |          |                                                                                                               |                                                  |
    +----------+---------------------------------------------------------------------------------------------------------------+--------------------------------------------------+
    | Step 4   | Report memory CU nominal rate calibration result for 1 channel only:                                          | ``3v3_pex`` for u50.                             |
    |          | power, read/write BW and latency graphs in section :ref:`calibration-memory-cu-power-checklist`               |                                                  |
    |          | of your checklist.                                                                                            |                                                  |
    |          |                                                                                                               |                                                  |
    |          | Determine the nominal write/read rate based on the power rail limit (see template section).                   |                                                  |
    +----------+---------------------------------------------------------------------------------------------------------------+--------------------------------------------------+
    | Step 5   | Set nominal rate in platform definition JSON file.                                                            | Here is example of rate for definition:          |
    |          |                                                                                                               |                                                  |
    |          | Use the various rates (found in step 3) as nominal value                                                      | .. code-block:: JSON                             |
    |          | in platform definition JSON file for the memory being calibrated.                                             |                                                  |
    |          |                                                                                                               |     "name": "HBM",                               |
    |          |                                                                                                               |     "cu_rate": {                                 |
    |          |                                                                                                               |       "only_wr": {                               |
    |          |                                                                                                               |         "write": {                               |
    |          |                                                                                                               |           "nominal" : 46                         |
    |          |                                                                                                               |         }                                        |
    |          |                                                                                                               |       },                                         |
    |          |                                                                                                               |       "only_rd": {                               |
    |          |                                                                                                               |         "read": {                                |
    |          |                                                                                                               |           "nominal" : 39                         |
    |          |                                                                                                               |         }                                        |
    |          |                                                                                                               |       },                                         |
    |          |                                                                                                               |       "simul_wr_rd": {                           |
    |          |                                                                                                               |         "write": {                               |
    |          |                                                                                                               |           "nominal" : 23                         |
    |          |                                                                                                               |         },                                       |
    |          |                                                                                                               |         "read": {                                |
    |          |                                                                                                               |           "nominal" : 23                         |
    |          |                                                                                                               |         }                                        |
    |          |                                                                                                               |       }                                          |
    |          |                                                                                                               |     }                                            |
    |          |                                                                                                               |                                                  |
    +----------+---------------------------------------------------------------------------------------------------------------+--------------------------------------------------+

********************************************************
Results and analysis
********************************************************

=====================================================
Graph
=====================================================

For each test run, add the following graphs in section :ref:`calibration-memory-cu-power-checklist` of your checklist.

From the power log file (``<log_dir>/memory_<memory type>_power.csv``, e.g. ``simultaneous_wr_rd_rate_ramp/memory_HBM_power.csv``):

  * Open it in Excel.
  * For ``simultaneous_wr_rd_rate_ramp`` and ``only_rd_rate_ramp`` runs, remove first rows where ``test_mode`` = ``only_wr``
    as it contains results coming from the initialization of the memory (prior the actual readings).
  * Create graph (2-D line) with ``12v_pex power``, ``3v3_pex power`` and ``12v_aux power``.

      * Use data of ``read rate (%)`` column for horizontal axis.
      * Set chart title to: **Power vs CU rate for <memory_type> <test_mode>**.
      * Set axis titles with data units.

Find the memory log file:

  * For single-channel:
    ``<log_dir>/memory_<tag>_result.csv``, e.g. simultaneous_wr_rd_rate_ramp/memory_ddr[0]_result.csv``.

  * For multi-channel:
    ``<log_dir>/memory_<tag>_ch_0_result.csv``, e.g. ``simultaneous_wr_rd_rate_ramp/memory_hbm[0]_ch_0_result.csv``.

Then:

  * Open it in Excel.
  * For ``simultaneous_wr_rd_rate_ramp`` and ``only_rd_rate_ramp`` runs, remove first rows where ``test_mode`` = ``only_wr``
    as it contains results coming from the initialization of the memory (prior the actual readings).
  * Create graph (2-D line) with ``average total write+read BW (MBps)``, ``average write BW (MBps)`` and ``average read BW (MBps)``.

      * Use data of ``read rate (%)`` column for horizontal axis.
      * Set chart title to: **BW vs CU rate for <memory_type> <test_mode>**.
      * Set axis titles with data units.

  * Create graph (2-D line) with ``write burst latency (ns)``.

      * Use data of ``read rate (%)`` column for horizontal axis.
      * Set chart title to: **Write latency vs CU rate for <memory_type> <test_mode>**.
      * Set axis titles with data units.

  * Create similar graph but with ``read burst latency (ns)``.

=====================================================
Results
=====================================================

Add your results to section :ref:`calibration-memory-cu-power-checklist` of your checklist.

