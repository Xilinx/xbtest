
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

##########################################################################
Overview
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2
   
********************************************************
Architecture overview
********************************************************

The solution comprises:

  * |Application software|: Runs on the host.
  * |xclbin|: Downloaded to the card.
    Includes compute units (CUs): verify, power, memory, and/or GT (GT MAC, GT PRBS, GT LPBK).

The following block diagram shows an |Alveo|_ card with an example of deployment platform and CUs (part of the xclbin).
Per CU type (power, memory and GT), the presence and the quantity of available CUs depends on card and platform capabilities (refer to the respective documentation).

.. figure:: ../diagram/alveo-card-block-diagram.svg
    :align: center

    Alveo card block diagram

Application software and xclbin are used in conjunction to test on-board memories (for example DDR, HBM) and GTs while the card is consuming a programmable amount of power.

xbtest is common for all supported platforms.
Multiple Alveo cards can be tested simultaneously.

Host memory can also be tested separately if slave bridge feature is available.

.. _xclbin:

********************************************************
Hardware overview
********************************************************

The |xclbin| includes the following CU types which test different areas of the card hardware:

  * **Power**: Throttles the clock of flip-flops, DSPs, block RAMs, UltraRAMs and AIEs present in the logic of the xclbin, to control their power consumption.
  * **Memory**: Measures the read and write bandwidths & latencies while performing a data integrity check on the data transmitted and received.
  * **GT MAC**, **GT PRBS** & **GT LPBK**: Checks GT transceivers of the |Alveo|_ card at 10 Gigabit Ethernet (10 GbE) and 25 Gigabit Ethernet (25 GbE) lane rates.

Any xclbin also contains the **verify** CU which includes the following hardware safety mechanisms:

  * **Watchdog**: Stops all CUs after a programmable delay (default 15 seconds) in the case of the application software failing to perform the watchdog reset.
  * **Status Register**:

    * Detects and prevents multiple instances of |Application software| trying to control/access the same Alveo card.
    * Detects if CU clocks have been throttled down. 
      CU Clocks could have been slowed down automatically to prevent over-powering the card. 
      Slower clock will affect test results.

  * **DNA** : Reports the FPGA DNA value (when accessible).

.. note::
    Watchdog status and clock throttling detection are monitored on a regular basis during test execution.

The xclbin is packaged in |Platform specific libraries|.

.. _platform-specific-libraries:

********************************************************
Platform specific libraries overview
********************************************************

The |Application software| supports heterogeneous |Alveo|_ card installation by the addition of xbtest |Platform specific libraries|.

.. important::
    The platform specific library files should not be edited or modified.
    See :ref:`install-xbtest` section.

.. _pre-canned-test-json-files:
.. _platform-definition-json-file:

In addition to the |xclbin|, the platform specific libraries also contain:

  * |Platform definition JSON file|: Specifies the platform specific characteristics and limits of xbtest.
    See :ref:`ug-platform-definition`.
  * |Pre-canned test JSON files|: Set of pre-canned tests which use one or more of the available test cases according to platform capabilities.
    See :ref:`pre-canned-tests-description`.

These files are automatically selected by the application software.

.. _application-software:
.. _common-software:
.. _test-software:

********************************************************
Software overview
********************************************************

The |Application software| automatically detects the number and type of CUs present in the |xclbin| (power, memory, or GT MAC).

.. figure:: ../diagram/software-model.svg
    :align: center

    Software model

To enable simultaneous support for multiple versions of the software, xbtest application software is split into two different applications:

  * |Common software|: In charge of dispatching the test:

      * It selects, configures, and launches the |Test software| based on the selected deployment platform under test.
      * xbtest must be run from the |Common software|.

  * |Test software|: The actual software which performs the tests:

      * Each of the |test cases| (power, memory and GT) run independently.
      * The |DMA|, |P2P CARD| and |P2P NVME| test cases run prior to all test cases.
      * It is only run by the |Common software|.
      * It uses two JSON configuration files:

        * |Test JSON file|: User can provide his own test JSON file or use one of the |Pre-canned test JSON files|.
        * |Platform definition JSON file|: Selected automatically.

The following steps are performed to launch a test:

  1. Checks the provided :ref:`command-line-options` for validity and unsupported combinations.
  2. Checks integrity of all |Platform specific libraries| currently installed.
  3. Selects from the targeted card provided with command line option :option:`-d`.

       * Compatible platform specific library (based on interface UUID).
       * Supported |Test software| version.

  4. Launches |Test software| on the targeted card with:

       * Provided pre-canned test (:option:`-c`) or test JSON file (:option:`-j`).
       * Platform definition JSON file and xclbin selected in previous step.

The |Test software| also manages the watchdog present in the different CUs and checks that the Alveo card is not in use by another instance of the application.

A sensor thread can be customized (see :ref:`device-management-task-description`).
