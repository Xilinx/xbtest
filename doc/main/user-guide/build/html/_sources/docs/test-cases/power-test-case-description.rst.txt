
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _power-test-case-description:

##########################################################################
Power test case description
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2

The goal of this test case is to allow the control of the card power consumption.
This is achieved by adjusting the |power-toggle_rate| of the clock, which drives all flip-flops, DSPs, block RAMs, UltraRAMs and AIEs of the |xclbin| present in the power CU.
Sensor values (power, temperature, power rails current/voltage and fan speed) are read every second using |XRT Device APIs|_.

********************************************************
Test parameters
********************************************************

The mandatory test configuration parameters are listed below.
For more information, see :ref:`power-test-json-members`.

  * |power-duration|: The duration of the test, measured in seconds.
  * |power-toggle_rate|: The toggle rate, specified in %, driving the sites of the |xclbin| present in the power CU.

********************************************************
Main test steps
********************************************************

The measurement of the card rest power, which lasts a few seconds, is always performed when the |Power| test case starts.
For each test configuration, the following steps are repeated:

  1. The |power-toggle_rate| is set to the power CU.
  2. For the defined |power-duration|, sensor values are read and reported every second.
  3. When the test completes, it always passes because no checks are made on the consumed power.
     The user is responsible for monitoring the consumed power, which is displayed by the |Application software|.

.. warning::
    The power CU has been intentionally designed to exceed the power capacity of the card.
    You might damage your card and cause your server/workstation to reboot if you try to for example (but not limited to):

    * Use a high |power-toggle_rate|.
    * Use a particularly demanding test sequence (for example, alternating between a low and a high |power-toggle_rate| for short periods of time).

.. important::
    xbtest reports the entire power consumed by the card (for active card, fan speed is also reported).

********************************************************
Power and temperature limits
********************************************************

To limit potential damage to the |Alveo|_ card in cases of accidental misuse or demanding test environmental conditions, the following basic safety mechanisms are in place.

  * **Temperature Limit**: A critical warning is generated when the temperature limit is reached.
  * **Power Limit**: A critical warning is generated when the power limit is reached.

Temperature and power limits are defined in the platform definition JSON.

The list of sensors monitored is available in the :ref:`device-management-task-description`.

********************************************************
Power budget and calibration
********************************************************

To establish the relationship between |power-toggle_rate| and power, a simple calibration method can be used.
An example of calibration is starting from 0%, increasing the |power-toggle_rate| by 5 %, and for each |power-toggle_rate| step, letting the power and temperature stabilize for two minutes.
There are numerous considerations to consider when creating this relationship.

.. important::

      * xbtest always reports the total power of the card obtained via the |XRT Device APIs|_.
      * Ensure that the environmental conditions (for example, temperature) used during calibration are similar to the conditions used in testing.

.. _toggle-rate-step-requirement:

=====================================================
Toggle rate step requirement
=====================================================

By default, xbtest limits the toggle rate steps to 10 % per second as most of the power regulators (& the FPGA) have a step load requirement.

For example, if the |power-toggle_rate| is initially set to 25 %, it will take 4 seconds to set a new target |power-toggle_rate| of 65 % as the actual toggle rate will gradually increase every second: 35 %, 45 %, 55 % and finally 65 %.

This ramp can be disabled using the parameter :ref:`power-parameter-disable_toggle_ramp`. When disabled, ensure that |power-toggle_rate| never steps (down or up) by more than around 20 % per second.

=====================================================
Actual power available
=====================================================

The distribution of the power across the various regulators also limits which power is available for xbtest to control.
For example, on an Alveo U50 card, although the power budget of the card is 75W, up to 10W are reserved for the HBM.
This means that Power CU can only control up to 65W. It also means that the Memory CU must be in use to have a card power consumption higher than 65W.

Moreover, the total power budget of the card is not entirely available.
The actual power available would be impacted by the efficiency and current limitation of the various regulators.
For information about various sensors and power rails limits, refer to the specific |Alveo doc|_.
With the same example (U50 card), the actual power thresholds will be lower than 65W and 10W.

=====================================================
Components present on the card
=====================================================

The card might be fitted with other ICs (such as co-processor, memories, and so forth) on which xbtest has no control.
During calibration, ensure these components behave like similarly to normal test operations.

.. note::
    xbtest can only control power of memory directly connected to the FPGA.

=====================================================
Tests running
=====================================================

Other test cases, like memory (DDR or HBM) and GT MAC, have a significant impact on the power consumed.
Make sure that the calibration is done while using these other feature as per nominal load.

  * **DDR**: When running four DDRs simultaneously, the memory test consumes approximately 20 W (write mode) or 15 W (read mode).
  * **HBM**: For example, when eight HBM ports are used, the memory test consumes between 7 W and 8 W.
  * **GT**: When two GT MAC CUs are present, the 25 GbE mode uses ±6 W more than the 10 GbE mode.
  * **Logic**: Memory and GT CUs, and the memory subsystem also consume several watts.

.. note::
    These values are indicative and might vary from card to card. They also depend on test environmental conditions, such as cooling.

Care must be taken when mixing test case types or when changing the mode of other tests while the power test is running.
For example, power varies when the memory test changes from ``only_rd`` to ``only_wr`` mode.
Power will decrease when a |Memory| test case ends.
``simultaneous_wr_rd`` mode is usually the memory test mode consuming the most power.

.. _power-test-json-members:

********************************************************
Power test JSON members
********************************************************

=====================================================
Example
=====================================================

The following is an example of a |Power| test case running for 60 seconds at a |power-toggle_rate| of 15 %.

.. code-block:: JSON

    "power": {
      "global_config": {
        "test_sequence": [ { "duration": 60, "toggle_rate": 15 } ]
      }
    }

----

=====================================================
Definition
=====================================================

The following table shows all members available for this test case.
More details are provided for each member in the subsequent sections.

.. table:: Power test case members

    +--------------------------------------------+----------------------+-------------------------------------------------------------------------------------+
    | Member                                     | Mandatory / optional | Description                                                                         |
    +============================================+======================+=====================================================================================+
    | :ref:`power-parameter-test_sequence`       | Mandatory            | Describes the sequence of tests to perform.                                         |
    |                                            |                      | A test is defined by the following values:                                          |
    |                                            |                      |                                                                                     |
    |                                            |                      |   * |power-duration|: In seconds.                                                   |
    |                                            |                      |   * |power-toggle_rate|: Toggle rate.                                               |
    +--------------------------------------------+----------------------+-------------------------------------------------------------------------------------+
    | |power-disable_reg|                        | Optional             | Disable usage of all flip-flops of the |xclbin| present in the power CU.            |
    +--------------------------------------------+----------------------+-------------------------------------------------------------------------------------+
    | |power-disable_dsp|                        | Optional             | Disable usage of all DSPs of the |xclbin| present in the power CU.                  |
    +--------------------------------------------+----------------------+-------------------------------------------------------------------------------------+
    | |power-disable_bram|                       | Optional             | Disable usage of all block RAMs of the |xclbin| present in the power CU.            |
    +--------------------------------------------+----------------------+-------------------------------------------------------------------------------------+
    | |power-disable_uram|                       | Optional             | Disable usage of all UltraRAMs of the |xclbin| present in the power CU.             |
    +--------------------------------------------+----------------------+-------------------------------------------------------------------------------------+
    | |power-disable_aie|                        | Optional             | Disable usage of all AIEs of the |xclbin| present in the power CU.                  |
    +--------------------------------------------+----------------------+-------------------------------------------------------------------------------------+
    | :ref:`power-parameter-disable_toggle_ramp` | Optional             | Disable ramp to reach target toggle rate (see :ref:`toggle-rate-step-requirement`). |
    +--------------------------------------------+----------------------+-------------------------------------------------------------------------------------+

----

.. _power-parameter-test_sequence:

=====================================================
``test_sequence``
=====================================================

Mandatory. Describes the sequence of tests to perform.
Tests are performed serially, and a failure in one test does not stop the sequence (the next test will be launched).
There is no limitation to the length of the test sequence.

This field contains a list of tests, each test being defined by an object of key–value parameters pairs: ``[ {}, {}, {} ]``.

The following table defines the parameters supported in the Power test sequence:

.. _power-parameter-test_sequence-duration:
.. _power-parameter-test_sequence-toggle_rate:

.. table:: Power test sequence parameters

    +-------------------+----------------------+-----------------------------------------------------------------------------------------------+
    | Member            | Mandatory / optional | Description                                                                                   |
    +===================+======================+===============================================================================================+
    | ``duration``      | Mandatory            | The duration of the test in seconds; Range [1, 2\ :sup:`32`\-1].                              |
    +-------------------+----------------------+-----------------------------------------------------------------------------------------------+
    | ``toggle_rate``   | Mandatory            | Toggle rate (in %) driving the sites of the |xclbin| present in the power CU; Range [0, 100]. |
    +-------------------+----------------------+-----------------------------------------------------------------------------------------------+

For example:

  * **Single test**:

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 40, "toggle_rate": 75 } ]

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 40, "toggle_rate": 85 } ]

  * **Multiple tests**:

      * .. code-block:: JSON

            "test_sequence": [
              { "duration":  40, "toggle_rate": 15 },
              { "duration": 240, "toggle_rate": 30 },
              { "duration": 120, "toggle_rate": 40 },
              { "duration":  20, "toggle_rate": 50 }
            ]

----

.. _power-parameter-disable_reg-dsp-bram-uram-aie:

.. _power-parameter-disable_reg:

.. _power-parameter-disable_dsp:

.. _power-parameter-disable_bram:

.. _power-parameter-disable_uram:

.. _power-parameter-disable_aie:

======================================================================================
``disable_reg``, ``disable_dsp``, ``disable_bram``, ``disable_uram``, ``disable_aie``
======================================================================================

Optional;
Type           : boolean;
Possible values: ``true`` or ``false``;
Default        : ``false``

By default, all flip-flops, DSPs, block RAMs, and UltraRAMs of the |xclbin| present in the power CU are enabled.

  * When ``disable_reg`` is set to ``true``, all flip-flops of the xclbin present in the power CU are disabled.
  * When ``disable_dsp`` is set to ``true``, all DSPs of the xclbin present in the power CU are disabled.
  * When ``disable_bram`` is set to ``true``, all block RAMs of the xclbin present in the power CU are disabled.
  * When ``disable_uram`` is set to ``true``, all UltraRAMs of the xclbin present in the power CU are disabled.
  * When ``disable_aie`` is set to ``true``, all AIEs of the xclbin present in the power CU are disabled.

----

.. _power-parameter-disable_toggle_ramp:

====================================================================
``disable_toggle_ramp``
====================================================================

Optional;
Type           : boolean;
Possible values: ``true`` or ``false``;
Default        : ``false``

By default, the target |power-toggle_rate| will be set gradually to the power CU load using steps (see :ref:`toggle-rate-step-requirement`).

  * When set to ``true``, the target |power-toggle_rate| will be set directly to the power CU.

----

********************************************************
Output files
********************************************************

All power measurements are stored in an output CSV file named ``power.csv`` which is generated in xbtest logging directory.
The values are stored in CSV type format with one column for each information type.

.. important::
    If the command line option :option:`-L` is used while calling the |Application software|, no output file is generated.

All measurements from all :ref:`power-parameter-test_sequence` are combined into a single file.

A new line is written in this file every time power measurements are available.
At a minimum, the following values are recorded:

  * **Global time (s)**: Global elapsed time since the ``Test`` software execution started.
  * **Test**: Index of current test within the :ref:`power-parameter-test_sequence`. Index of first test is 1.
    The first rows of the file with test and |power-toggle_rate| set to 0 corresponds to the measurement of the card rest power.
  * **Test time (s)**: Timestamp of the measurement.
    Timestamp of first measurement is 0 for a given test within the :ref:`power-parameter-test_sequence`.
  * **Toggle rate (%)**: |power-toggle_rate| in % currently set to the power CU.
  * **measurement ID**: Measurement identifier. ID of first measurement is 1.
  * **Measurement valid**: Set to ``OK`` if the ``Test`` software was able to successfully gets power and temperature measurements via the |XRT Device APIs|_, otherwise set to ``KO``.
  * **Mechanical measurements**: Group of one or more columns recording measurements for each mechanical sensor source monitored by xbtest.

    * Card fan: for passive card, ``0`` will be reported.

  * **Thermal measurements**: Group of one or more columns recording measurements for each thermal sensor source monitored by xbtest.

    * FPGA temperature.

  * **Electrical measurements**: Group of one or more columns recording detailed measurements for each electrical sensor source monitored by xbtest.

    * Card power.
    * Current ,voltage and power of 3v3_pex, 12v_pex, vccint and 12v_aux (and an auxiliary cable is used).

See :ref:`device-management-task-description` for more information on the sensor sources monitored by xbtest.
