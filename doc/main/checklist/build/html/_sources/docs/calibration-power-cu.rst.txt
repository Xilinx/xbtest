
.. include:: ../../../shared/links.rst
.. include:: links.rst

.. _calibration-power-cu:

##########################################################################
Calibration - Power CU
##########################################################################

********************************************************
Goal
********************************************************

The goal of this power calibration is to check that the power CU present in the xclbin can exceed the card limit.

Being able to go beyond the card limit allows the check of the safety features of the card (clock throttle/shutdown and regulator shutdown).

As a reminder:

  * Make sure your power CU is designed according to the maximum power you want to achieve:

      * **Not too big**: To have enough granulometry control of the toggle rate to allow power and thermal qualification of your card/platform at precise levels.
      * **Not too small**: You won't be able to test the limit & safety feature of the card.

  * Have a look here for more advices:

      * |power-limitations-considerations-and-general-advises|_

********************************************************
Procedure and test environment
********************************************************

Run the following test (``power_calibration``) under the following conditions:

  * Server at 100% fan with ambient temperature of 20C.
  * AUX cable when applicable.
  * Passive card.
  * Clock throttling: Disabled when applicable.

Use this :download:`power_calibration.json <./data/power_calibration.json>` template:

  * It's a toggle rate ramp from 0 to 100% with a pre-heating step of 120 seconds.
  * You need to provide a toggle rate for heating up you board.

.. warning::
    During this calibration test, your card will be reset by |XRT|_ or some regulators may eventually shut down when reaching their fatal limits.
    This may cause a server reboot.

Run xbtest:

.. code-block:: bash

    $ xbtest -F -d <bdf> -j power_calibration.json -l power_calibration

.. note::
    Log/results will be stored into a folder named: ``power_calibration``.

Zip the log directory that you will attach to your checklist.

.. code-block:: bash

    $ zip -r power_calibration.zip power_calibration

********************************************************
Results and analysis
********************************************************

=====================================================
Graph
=====================================================

A graph will be added in the :ref:`calibration-power-cu-checklist` section.

From the power log file (``power_calibration/power.csv``):

  * Open it in Excel.
  * Create graph (2-D line) with toggle rate, FPGA temperature and board power.

      * Use primary vertical axis for toggle rate and temperature.
      * Use secondary vertical axis for power.
      * Set chart title to: **Power & temperature vs toggle rate**.
      * Set axis titles with data units.

Include graph to your :ref:`checklist-results`.

=====================================================
Analysis
=====================================================

Check every power rail for highest current when the card resets (or the server reboots). These are the last lines of the ``power.csv`` file.

  * For each of them report the cut-off/highest current and its critical limit.

Refer to the |Alveo doc|_ for current/power thresholds and consequent actions.

If your power CU is correctly sized:

  * You should reach board reset/server reboot with a toggle rate of 75-80%.
  * All your power rails should have reached their limit almost simultaneously.

This depends on how the power rails have been consolidated:

  * U50: HBM is powered exclusively from the ``3v3_pex`` and user logic is on the ``12v_pex``.
    So, the power CU has no effect on the ``3v3_pex`` (only the memory CU).
  * U25: BRAM are powered from the ``3v3_pex``, limiting their usage to nearly only the Memory-Subsystem.
  * GT modules (~3.5W) are sometimes powered from the ``3v3_pex``.

=====================================================
Results
=====================================================

Add your results to section :ref:`calibration-power-cu-checklist` of your checklist.
