
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _gt-prbs-test-case-description:

##########################################################################
GT PRBS test case description
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2

The goal of this test case is to allow verification of GT transceivers on |Alveo|_ cards at 25GbE lane rates. The 4 lanes of the GT transceiver are tested simultaneously.

This compute unit (CU) is composed by PRBS-31 generator & checker which sends & verifies 66b data at 25GbE rate. It's possible to inject a single error any lane.
The PRBS checker compares the incoming 66b to a newly created 66b PRBS based on the previous data received.

To increase robustness to error, the PRBS checker, once in lock, uses a reference PRBS and compare incoming data with this free-running generated reference PRBS.
This reference PRBS is synced with the incoming data if there are less than 10% of error during the comparison.
If there are more than 6 errors between the reference PRBS and the received 66b of data, the reference PRBS is resync to the data.
The SW can disable the usage the reference PRBS.

.. figure:: ../diagram/gt_prbs-block_diagram.svg
    :align: center

    GT PRBS CU block diagram

.. _gt-prbs-test-set-up:

.. include:: ../shared/gt-test-set-up.rst

In addition, GT testing can be achieved by:

  * The use of a protocol analyzer with a compatible electrical or optical interface.
    This is the most complex method of connection as not only will the interfaces require validation with the GTs, the RX and TX paths will be independent.

.. _gt-prbs-gt-settings:

.. include:: ../shared/gt-settings.rst

********************************************************
Main test steps
********************************************************

A test is generally composed of four steps and a definition of the hardware environment (see :ref:`gt-prbs-test-json-members`).
The following are typical test steps:

  1. Configuration.
  2. Clear status.
  3. Run.
  4. Report/check status.

========================================================
Test parameters
========================================================

The mandatory test configuration parameters are listed below.
For more information, see :ref:`gt-prbs-test-json-members`.

  * |gt-prbs-duration|: The duration of the test, measured in seconds.
  * |gt-prbs-mode|: Mode of the compute unit.


********************************************************
Status
********************************************************

GT PRBS CU provides per lane the following status:

  * PRBS error detected since the last clear.
  * The quantity of 66b word received (and an approximate rate computation based on the test duration)

      * In case of error, the quantity of erroneous 66b word is also reported and its percentage representation.

  * Null PRBS seed received.
  * Null PRBS seed used during PRBS generation.


.. _gt-prbs-test-json-members:

********************************************************
GT PRBS test JSON members
********************************************************

Here is an example of GT PRBS test cases.
Some test JSON members can be overwritten for each lane using the test JSON member ``lane_config`` which child members are lane indexes.

----

=====================================================
Electrical/optical loopback example
=====================================================

.. code-block:: JSON

    "gt_prbs": {
      "0": {
        "global_config": {
          "test_sequence": [
            { "duration":  1, "mode": "conf_25gbe"   },
            { "duration":  1, "mode": "clear_status" },
            { "duration": 60, "mode": "run"          },
            { "duration":  1, "mode": "check_status" }
          ]
        }
      }
    }

----

=====================================================
Definition
=====================================================

The following table shows all members available for this test case.
More details are provided for each member in the subsequent sections.

.. table:: GT PRBS test JSON members

    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------+
    | Member                                            | Lane override | Mandatory / optional | Description                                             |
    +===================================================+===============+======================+=========================================================+
    | :ref:`gt-prbs-parameter-test_sequence`            | No            | Mandatory            | Describes the sequence of tests to perform.             |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------+
    | :ref:`gt-prbs-parameter-disable_ref_prbs`         | No            | Optional             | Disable the usage of reference free running PRBS        |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------+
    | :ref:`gt-prbs-parameter-gt_settings`              | No            | Optional             | Selects the GT default configuration.                   |
    |                                                   |               |                      | See |GT PRBS JSON Member|.                              |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------+
    | :ref:`gt-prbs-parameter-gt_tx_diffctrl`           | Yes           | Optional             | Select the Driver Swing Control.                        |
    |                                                   |               |                      | See |GT PRBS JSON Member|.                              |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------+
    | :ref:`gt-prbs-parameter-gt_tx_pre_emph`           | Yes           | Optional             | Select Transmitter pre-cursor TX pre-emphasis control.  |
    |                                                   |               |                      | See |GT PRBS JSON Member|.                              |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------+
    | :ref:`gt-prbs-parameter-gt_tx_post_emph`          | Yes           | Optional             | Select Transmitter post-cursor TX pre-emphasis control. |
    |                                                   |               |                      | See |GT PRBS JSON Member|.                              |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------+
    | :ref:`gt-prbs-parameter-gt_tx_polarity`           | Yes           | Optional             | Select TX Polarity.                                     |
    |                                                   |               |                      | See |GT PRBS JSON Member|.                              |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------+
    | :ref:`gt-prbs-parameter-gt_rx_use_lpm`            | Yes           | Optional             | Select RX Equalizer.                                    |
    |                                                   |               |                      | See |GT PRBS JSON Member|.                              |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------+
    | :ref:`gt-prbs-parameter-gt_loopback`              | Yes           | Optional             | Select GT internal loopback.                            |
    |                                                   |               |                      | See |GT PRBS JSON Member|.                              |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------+

----

.. _gt-prbs-parameter-test_sequence:

=====================================================
``test_sequence``
=====================================================

Mandatory. Describes the sequence of tests to perform.
Tests are performed serially, and a failure in one test does not stop the sequence (the next test will be launched).
There is no limitation to the length of the test sequence.

This field contains a list of tests, each test being defined by an object of key–value parameters pairs: ``[ {}, {}, {} ]``.

The following table defines the parameters supported in the GT MAC test sequence:

.. _gt-prbs-parameter-test_sequence-duration:
.. _gt-prbs-parameter-test_sequence-mode:

.. table:: GT MAC test sequence parameters

    +-------------------+----------------------+------------------------------------------------------------------+
    | Member            | Mandatory / optional | Description                                                      |
    +===================+======================+==================================================================+
    | ``duration``      | Mandatory            | The duration of the test in seconds; Range [1, 2\ :sup:`32`\-1]. |
    +-------------------+----------------------+------------------------------------------------------------------+
    | ``mode``          | Mandatory            | Mode of the compute unit. See the following table.               |
    +-------------------+----------------------+------------------------------------------------------------------+

.. table:: ``mode`` possible values

    +-------------------------------+-----------------------------------------------------------------------------------------+
    | Possible value                | Description                                                                             |
    +===============================+=========================================================================================+
    | ``conf_25gbe``                | Apply the settings specified in the configuration parameters to the GT hardware.        |
    +-------------------------------+-----------------------------------------------------------------------------------------+
    | ``clear_status``              | Read and clear the CU status registers, but ignore the values returned in the counters. |
    |                               | It is intended to be used after a ``conf_25gbe`` operation to clear the status errors.  |
    +-------------------------------+-----------------------------------------------------------------------------------------+
    | ``run``                       | Enable the PRBS checker.                                                                |
    +-------------------------------+-----------------------------------------------------------------------------------------+
    | ``check_status``              | Read the CU status registers. Check for any error                                       |
    |                               | If an error is detected the overall test will be flagged as a fail.                     |
    +-------------------------------+-----------------------------------------------------------------------------------------+
    | ``tx_rx_rst``                 | Initiate a reset of the GT wizard TX and RX paths.                                      |
    +-------------------------------+-----------------------------------------------------------------------------------------+
    | ``insert_error_lane_<idx>``   | Insert a single PRBS error for lane <idx>: e.g. ``insert_error_lane_0``.                |
    +-------------------------------+-----------------------------------------------------------------------------------------+

An example of a :ref:`gt-prbs-parameter-test_sequence` is:

.. code-block:: JSON

    "test_sequence": [
      { "duration":  1, "mode": "conf_25gbe"   },
      { "duration":  1, "mode": "clear_status" },
      { "duration": 60, "mode": "run"          },
      { "duration":  1, "mode": "check_status" }
    ]

This will:

  * Apply the configuration to the GT, wait for 1 seconds.
  * Wait for 1 seconds then clear the status registers.
  * Start the PRBS term and wait for 60 seconds.
  * wait for 1 second before reading the status registers and check the results. Then, clear the status registers.

----

.. _gt-prbs-parameter-disable_ref_prbs:

=====================================================
``disable_ref_prbs``
=====================================================

Optional;
Type           : boolean;
Possible values: ``true`` or ``false``;
Default        : ``false``

This configuration will be applied to the four lanes simultaneously.

When ``false`` the reference free running PRBS will be used to compare with incoming data (once locked and if error rate is below 10%).

When ``true`` the reference PRBS is never used and incomings data is always used to predict the next one.

----

.. _gt-prbs-parameter-gt_settings-JSON-members:

.. include:: ../shared/gt-settings-JSON-members.rst

More info can be found here: |GT PRBS Settings|.
Further details on each of settings can be found in |UG578|_.

----

.. _gt-prbs-parameter-gt_settings:

.. include:: ../shared/gt-parameter-gt_settings.rst

----

.. _gt-prbs-parameter-gt_tx_diffctrl:

.. include:: ../shared/gt-parameter-gt_tx_diffctrl.rst

----

.. _gt-prbs-parameter-gt_tx_pre_emph:

.. include:: ../shared/gt-parameter-gt_tx_pre_emph.rst

----

.. _gt-prbs-parameter-gt_tx_post_emph:

.. include:: ../shared/gt-parameter-gt_tx_post_emph.rst

----

.. _gt-prbs-parameter-gt_tx_polarity:

.. include:: ../shared/gt-parameter-gt_tx_polarity.rst

----

.. _gt-prbs-parameter-gt_rx_use_lpm:

.. include:: ../shared/gt-parameter-gt_rx_use_lpm.rst

----

.. _gt-prbs-parameter-gt_loopback:

.. include:: ../shared/gt-parameter-gt_loopback.rst

----

********************************************************
Output file
********************************************************

No result file is created by the GT PRBS test case.