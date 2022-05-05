
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _understanding-xbtest-messages:

##########################################################################
Understanding xbtest messages
##########################################################################

The |Application software| outputs messages into log files.
Each message is generated with the format ``<severity> :: <ID> :: <headers> :: <message>``.
The following table describes these message fields, separated by "``::``".

.. table:: Message fields

    +----------------+----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field          | Example                          | Description                                                                                                                                                                                             |
    +================+==================================+=========================================================================================================================================================================================================+
    | ``<severity>`` | ``INFO``                         | Possible severities are:                                                                                                                                                                                |
    |                |                                  |                                                                                                                                                                                                         |
    |                |                                  |   * ``INFO``: General information about the progress of a test; for example, the start of a particular step of the test sequence.                                                                       |
    |                |                                  |   * ``STATUS``: Message showing intermediate progress of a test; for example, measurements.                                                                                                             |
    |                |                                  |   * ``WARNING``: Message that does not alter the progress of the test. User action might be taken or might be reserved.                                                                                 |
    |                |                                  |   * ``CRIT_WARN``: Message that does alter the progress or the results of the test. User action is strongly recommended.                                                                                |
    |                |                                  |   * ``PASS``: Message returned in the case of successful check.                                                                                                                                         |
    |                |                                  |   * ``ERROR``: Message returned in the case of failed check. This does not interrupt any test cases or tests.                                                                                           |
    |                |                                  |   * ``FAILURE``: The only message level which aborts all test cases/tests. For example, in cases of:                                                                                                    |
    |                |                                  |                                                                                                                                                                                                         |
    |                |                                  |       * SW/HW incompatibility.                                                                                                                                                                          |
    |                |                                  |       * Test JSON file typo or wrong settings/members.                                                                                                                                                  |
    |                |                                  |       * User interruption: ``CTRL+C``.                                                                                                                                                                  |
    |                |                                  |       * Another interrupt: for example, card reset.                                                                                                                                                     |
    |                |                                  |                                                                                                                                                                                                         |
    +----------------+----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``<ID>``       | ``GEN_039``                      | Unique identifier for a message.                                                                                                                                                                        |
    |                |                                  | The ID is formed as follows: ``<string>_<number>``, where:                                                                                                                                              |
    |                |                                  |                                                                                                                                                                                                         |
    |                |                                  |   * ``<string>``: One string as a 3-letter code which identifies the type of the message:                                                                                                               |
    |                |                                  |                                                                                                                                                                                                         |
    |                |                                  |       * ``GEN``: (general) message not specific to any test case.                                                                                                                                       |
    |                |                                  |       * ``ITF``: (interface) message related to device interface (for example OpenCL) and Test JSON file.                                                                                               |
    |                |                                  |       * ``JPR``: JSON file parser.                                                                                                                                                                      |
    |                |                                  |       * ``MGT``: (management) control and safety features.                                                                                                                                              |
    |                |                                  |       * ``CMN``: (common) used by different test cases.                                                                                                                                                 |
    |                |                                  |       * ``VER``: |Verify| test case specific.                                                                                                                                                           |
    |                |                                  |       * ``DMA``: |DMA| test case specific.                                                                                                                                                              |
    |                |                                  |       * ``P2P``: |P2P CARD| and |P2P NVME| test cases specific.                                                                                                                                         |
    |                |                                  |       * ``MEM``: |Memory| test case specific.                                                                                                                                                           |
    |                |                                  |       * ``PWR``: |Power| test case specific.                                                                                                                                                            |
    |                |                                  |       * ``ETH``: |GT MAC|, |GT PRBS| and |GT LPBK| test cases specific.                                                                                                                                 |
    |                |                                  |                                                                                                                                                                                                         |
    |                |                                  |   * ``<number>``: One number per type. This is a unique 3-digit number identifying the message.                                                                                                         |
    |                |                                  |                                                                                                                                                                                                         |
    +----------------+----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``<headers>``  | ``GENERAL``                      | Identifier of the message originator.                                                                                                                                                                   |
    |                |                                  | In most case it is composed by a single level ``<header>``, but it can also be composed by different levels:                                                                                            |
    |                |                                  | ``<header> :: <2nd header>`` or even ``<header> :: <2nd header> :: <3rd header>``:                                                                                                                      |
    |                |                                  |                                                                                                                                                                                                         |
    |                |                                  |   * ``<header>``: Originator. For example, ``POWER`` messages originate from the |Power| test case.                                                                                                     |
    |                |                                  |   * ``<2nd header>``: This second header is used to distinguish each individual message when multiple test cases of same type can run in parallel. For example:                                         |
    |                |                                  |                                                                                                                                                                                                         |
    |                |                                  |       * **|Memory| test cases**: Multiple memory types identified by ``<memory type name>``, for example ``HBM``, ``DDR``.                                                                              |
    |                |                                  |       * **|GT MAC| test cases**: Multiple GT lanes identified by ``Lane[<idx>]`` with ``<idx>`` the index of the lane.                                                                                  |
    |                |                                  |                                                                                                                                                                                                         |
    |                |                                  |   * ``<3rd header>``: This third header is used in |Memory| test case to distinguish each individual message when multiple memory of same type can run in parallel.                                     |
    |                |                                  |     For example:                                                                                                                                                                                        |
    |                |                                  |                                                                                                                                                                                                         |
    |                |                                  |       * **DDR memory type**: ``<tag>`` is used, for example ``DDR[0]``, ``DDR[1]``.                                                                                                                     |
    |                |                                  |                                                                                                                                                                                                         |
    +----------------+----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``<message>``  | ``Start of session at: <time>``  | Actual message content.                                                                                                                                                                                 |
    +----------------+----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

To get more information about a message, use command line option :option:`-m`. Information about provided message ID is reported in ``GEN_033`` messages.

For example, use the command:

.. code-block:: bash

    $ xbtest -d 0000:d9:00.1 -m MEM_023

This command reports:

.. code-block:: bash

    INFO :: GEN_033 :: COMMAND_LINE :: The message "MEM_023" is:
    INFO :: GEN_033 :: COMMAND_LINE :: - Severity : ERROR
    INFO :: GEN_033 :: COMMAND_LINE :: - Content : Data integrity test fail <optional channel info>
    INFO :: GEN_033 :: COMMAND_LINE :: - Details : Global message reporting that the data integrity was not maintained during the test. An error has been detected in the read data
    INFO :: GEN_033 :: COMMAND_LINE :: - Resolution : Check previous error for details about which section of the test failed

This presents the following information:

  * **Severity**: Level of the message.
  * **Content**: A generic version of the message content.
    As the same message can be used by multiple tests, or multiple times by the same test, when described in the console, some sections will be kept generic (usage of "<>" to describe their content).
    During a test, these sections will be replaced by actual value related to the test.
  * **Details**: Contains more information about the message, for example context, reason.
  * **Resolution**: Possible origin or solution to the message.
    This is only applicable for the message with the following severity levels: ``WARNING``, ``CRIT_WARN``, ``ERROR`` and ``FAILURE``.

