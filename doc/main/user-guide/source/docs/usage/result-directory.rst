
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _result-directory:

##########################################################################
Result directory
##########################################################################

With any display that is used, xbtest stores all |test cases| specific result files into one directory, in which xbtest also stores all messages into two log files:

  * When running multiple tests:

      * ``common.log``: Contains all messages and results.
      * ``common_summary.log``: Only the most important messages and results.

  * When running a single test:

      * ``xbtest.log``: Contains all messages and results.
      * ``summary.log``: Only the most important messages and results.

The result directory can be specified using command line option :option:`-l` or disabled using :option:`-L`.
By default, each xbtest run creates its own result directory in the current working directory.

.. _multi-tests-result-directory :

********************************************************
Multi tests result directory
********************************************************

In this use case, the result directory is named by default ``./xbtest_logs/<DATE>_<TIME>``, where the sub-directory is named with the following, separated with an underscore "_":

  * ``<DATE>``: Start of xbtest session date (year, month and day, separated with a dash "-").
  * ``<TIME>``: Start of xbtest session time (hour, minute and second, separated with a dash "-").

For example, the default logging directory can be: ``./xbtest_logs/2022-01-06_13-42-28``.

For each card targeted, a sub directory is created ``./xbtest_logs/<DATE>_<TIME>/<BDF>``, where:

  * ``<BDF>``: Card BDF (see :ref:`identifying-a-deployment-platform`), separated with a dash "-".

For example:

.. code-block:: bash

    ./xbtest_logs/2022-01-06_13-42-28/
    ├── 0000-af-00-1/
    ├── 0000-d8-00-1/
    └── 0000-5e-00-1/

For each test run of selected card, a sub directory is created ``./xbtest_logs/<DATE>_<TIME>/<BDF>/<TEST IDX>_<TEST NAME>`` , where:

  * ``<TEST IDX>``: 3-digit number identifying the test.
  * ``<TEST NAME>``: Test name set from the pre-canned test name or the test JSON file name.

For example:

.. code-block:: bash

    ./xbtest_logs/2022-01-06_13-42-28/0000-af-00-1/
    ├── 001_verify/
    ├── 002_stress/
    ├── 003_memory_host/
    └── 004_my_test/

---------------------------------------------------
Card status CSV output file
---------------------------------------------------

This results file is generated when multiple tests are run
It contains card and test status for all targeted cards.
There is one line of result for every second of each test.

All columns present in the file are defined as:

  * **Total elapsed (s)**: Total time in seconds elapsed since xbtest common started.
  * **Card status**: For each card with BDF ``<BDF>``, this group contains the following columns:

      * ``<BDF>`` **ongoing test name**: same format as log directory: ``<3-digit id>_<name>`` (see :ref:`multi-tests-result-directory`).
      * ``<BDF>`` **ongoing test time (s)**: Elapsed time in second since ongoing test started.
      * ``<BDF>`` **measurement ID**: Measurement identifier. ID of first measurement is 1. 
      * ``<BDF>`` **power (W)**: FPGA power in W. Set to n/a when no measurement available (ID = 0).
      * ``<BDF>`` **temperature (C)**: FPGA temperature in C. Set to n/a when no measurement available (ID = 0).

.. _single-test-result-directory:

********************************************************
Single test result directory
********************************************************

In this use case, the result directory is named by default ``./xbtest_logs/<DATE>_<TIME>_<BDF>``, where the sub-directory is named with the following, separated with an underscore "_":

  * ``<DATE>``: Start of xbtest session date (year, month and day, separated with a dash "-").
  * ``<TIME>``: Start of xbtest session time (hour, minute and second, separated with a dash "-").
  * ``<BDF>``: Card BDF (bus, domain, function separated with a dash "-"). See :ref:`identifying-a-deployment-platform`.

For example, the default logging directory can be: ``./xbtest_logs/2022-01-06_13-50-55_0000-5e-00-1``.