
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _p2p-card-test-case-description:

##########################################################################
P2P CARD test case description
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2
   
The goal of this test case is to check P2P communication and available bandwidth between memories available on two |Alveo|_ cards (for example: DDR/HBM) through the PCIe.
Data integrity and write/read bandwidths are measured.

The |P2P CARD| test case consists of writing and reading back data to and from the entire range of the memory under test over and over during a certain period.
A write-read-check cycle is never interrupted, meaning that:

  * Data is always fully sent and read back to and from the entire range of the memory and checked for data integrity.
  * If required, a test |p2p-card-duration| can be extended to perform all write-read-check cycle operations.

The data sent and read back to and from the memory is:

  * Generated via an 8-bit counter that is randomly initialized at the beginning of each write-read-check cycle.
  * Split into buffers which are transferred (via OpenCL™) between the two Alveo cards.

The P2P source is the card selected using the command line option :option:`-d`.
The P2P target is specified using the command line option :option:`-T`.

The memory on the source card is selected using test JSON parameter |p2p-card-source|>. The memory on the target card is specified using test JSON parameter |p2p-card-target|.

The test JSON parameter :ref:`p2p-card-parameter-total_size` can be used to override the quantity of data (in MB) sent and read back to and from the memory for each type of memory available on the card (for example HBM/DDR).
When not specified, :ref:`p2p-card-parameter-total_size` defaults to the minimum between source card memory size and target card memory size.

The write/read bandwidths are computed after all write/read data transfers in each write-read-check cycle and the values are averaged over the test |p2p-card-duration|.

.. important::
    By default, the average read and write bandwidths are not checked against any pass/fail criteria, but this can be overruled by setting :ref:`p2p-card-parameter-check_bw`.

.. important::
    P2P must be enabled on both source and target cards prior running this test case (see :ref:`p2p-tests-set-up`).

.. important::
    NoDMA platforms can only be used as P2P target, selected with option :option:`-T` in the |P2P CARD| test case as P2P transfers are initiated by the DMA engine of the source card.

********************************************************
Test parameters
********************************************************

The mandatory test configuration parameters are listed below.
For more information, see :ref:`p2p-card-test-json-members`.

  * |p2p-card-duration|: The duration of the test (in seconds).
  * |p2p-card-source|: Name of the memory type (for example: DDR/HBM) or tag (for example: DDR[0]/HBM[12]) of memory to access on the source card.

The following optional parameter may also be specified:

  * |p2p-card-target|: Name of the memory type (for example: DDR/HBM) or tag (for example: DDR[0]/HBM[12]) of memory to access on the target card.
  * |p2p-card-buffer_size|: Write/read buffer size.

********************************************************
Main test steps
********************************************************

For each test configuration, the following steps are repeated:

  1. Allocate ``N`` host buffers aligned with memory page size.

       * The number of buffers ``N`` equals :ref:`p2p-card-parameter-total_size` divided by |p2p-card-buffer_size|.
       * The memory page size is detected automatically and displayed at the beginning of the |P2P CARD| test case in ``xbtest.log`` file.

  2. Allocate and initialize the reference buffer used to check data integrity.
  3. Create ``N`` regular buffers on source card.
  4. Create ``N`` P2P buffers on target card.
  5. Import the P2P buffers of the target card to source card context.
  6. Initialize memory on the source card with the reference data.
  7. Write-read-check cycles are repeated for the |p2p-card-duration| of the test.
     One cycle consists of the following steps:

       a. Run P2P write (data is transferred from source card to target card) and measure bandwidth.
       b. Reset the source card memory to 0.
       c. Run P2P read (data is transferred from target card to source card) and measure bandwidth.
       d. Read the source card memory.
       e. Check that the data read by the host on the source card matches the reference data (data integrity).
          The source card memory is written with reference data if data integrity fails.

     .. note::
         These steps constitute a write-read-check cycle which is always entirely executed.
         If :ref:`p2p-card-parameter-stop_on_error` is set, the |P2P CARD| test case aborts in case of write/read transfer or data integrity error.

  8. Compute write and read minimum, maximum, and average bandwidths.
  9. If enabled, compare the average read and write bandwidths against their thresholds.
  10. Release all host and card buffers.

.. _p2p-card-test-json-members:

********************************************************
P2P CARD test JSON members
********************************************************

=====================================================
Definition
=====================================================

The following table shows all members available for this test case.
More details are provided for each member in the subsequent sections.

.. table:: P2P CARD test case members

    +-----------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | Member                                  | Memory type override | Mandatory / optional | Description                                                                            |
    +=========================================+======================+======================+========================================================================================+
    | :ref:`p2p-card-parameter-test_sequence` | No                   | Mandatory            | Describes the sequence of tests to perform.                                            |
    +-----------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | :ref:`p2p-card-parameter-check_bw`      | Yes                  | Optional             | Enable bandwidth checking. Disabled by default.                                        |
    +-----------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | :ref:`p2p-card-parameter-stop_on_error` | Yes                  | Optional             | Enable stop test case on error. Disabled by default.                                   |
    +-----------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | |p2p-card-hi_thresh_wr|                 | Only                 | Optional             | Overwrite high threshold of the write/read bandwidth (MB/s) for specified memory type. |
    |                                         |                      |                      |                                                                                        |
    | |p2p-card-hi_thresh_rd|                 |                      |                      |                                                                                        |
    +-----------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | |p2p-card-lo_thresh_wr|                 | Only                 | Optional             | Overwrite low threshold of the write/read bandwidth (MB/s) for specified memory type.  |
    |                                         |                      |                      |                                                                                        |
    | |p2p-card-lo_thresh_rd|                 |                      |                      |                                                                                        |
    +-----------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | :ref:`p2p-card-parameter-total_size`    | Only                 | Optional             | Total amount of data (MB) per bandwidth measurement for specified memory type.         |
    +-----------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+

----

=====================================================
Basic examples
=====================================================

The following is a basic example of a |P2P CARD| test case targeting all DDR and HBM memories available on the card.
All memories are tested serially.

.. code-block:: JSON

    "p2p_card": {
      "global_config": {
        "test_sequence": [
          { "duration": 10, "source": "DDR" },
          { "duration": 10, "source": "HBM" }
        ]
      }
    }


Some test JSON members can be overwritten for all memories based on memory type using the test JSON member ``memory_type_config`` which child members are memory type names.

Following is an example of |P2P CARD| test case where the comparison of the average read and write bandwidths against thresholds is enabled only for all memories of type HBM.

.. code-block:: JSON

    "p2p_card": {
      "global_config": {
        "stop_on_error": true,
        "test_sequence": [
          { "duration": 10, "source": "DDR" },
          { "duration": 10, "source": "HBM" }
        ]
      },
      "memory_type_config": {
        "HBM": {
          "check_bw": true,
          "hi_thresh_wr": 9000,
          "hi_thresh_rd": 9000,
          "lo_thresh_wr": 5000,
          "lo_thresh_rd": 5000
        }
      }
    }

.. note::
    By default, bandwidths are not checked, so :ref:`p2p-card-parameter-check_bw` is set to ``true``.

The following example shows how to run |P2P CARD| test case only for one (identified by memory tag DDR[1]) of the memories of the type named DDR on source card, overriding :ref:`p2p-card-parameter-total_size` value to 1GB:

.. code-block:: JSON

    "p2p_card": {
      "global_config": {
        "test_sequence": [
          { "duration": 10, "source": "DDR[1]" }
        ]
      },
      "memory_type_config": {
        "DDR": {
          "total_size" : 1024
        }
      }
    }

----

.. _p2p-card-parameter-test_sequence:

=====================================================
``test_sequence``
=====================================================

Mandatory. Describes the sequence of tests to perform.
Tests are performed serially, and a failure in one test does not stop the sequence (the next test will be launched).
There is no limitation to the length of the test sequence.

This field contains a list of tests, each test being defined by an object of key–value parameters pairs: ``[ {}, {}, {} ]``.

The following table defines the parameters supported in the P2P CARD test sequence:

.. _p2p-card-parameter-test_sequence-duration:
.. _p2p-card-parameter-test_sequence-source:
.. _p2p-card-parameter-test_sequence-target:
.. _p2p-card-parameter-test_sequence-buffer_size:

.. table:: P2P CARD Test Sequence Parameters

    +-------------------+----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Member            | Mandatory / optional | Description                                                                                                                                                                |
    +===================+======================+============================================================================================================================================================================+
    | ``duration``      | Mandatory            | The duration of the test in seconds; Range [1, 2\ :sup:`32`\-1].                                                                                                           |
    +-------------------+----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``source``        | Mandatory            | Name of the memory type (for example: DDR/HBM) or tag (for example DDR[0]/HBM[12]) of memory on the source card.                                                           |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |   * The index must be within the range specified in the platform definition file.                                                                                          |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |       * When a test is defined by memory type. One test is created for each memory tag of the memory type.                                                                 |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |         .. note::                                                                                                                                                          |
    |                   |                      |             The memory tags applicable for each memory type are displayed when the |P2P CARD| test case starts.                                                            |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |       * The test fails when the name provided does not match any of the memory type available in the |xclbin| or if the memory tag to test is not connected in the xclbin. |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |         .. tip::                                                                                                                                                           |
    |                   |                      |             Memory information can be retrieved using the following command:                                                                                               |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |             .. code-block:: bash                                                                                                                                           |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |                 $ xbutil examine --device <BDF> --report memory                                                                                                            |
    |                   |                      |                                                                                                                                                                            |
    +-------------------+----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``target``        | Optional             | Name of the memory type (for example: DDR/HBM) or tag (for example DDR[0]/HBM[12]) of memory on the target card.                                                           |
    |                   |                      | Similar as |p2p-card-source| parameter.                                                                                                                                    |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      | By default, when not specified, one test will be created for one bank of each memory type on the target card.                                                              |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      | .. note::                                                                                                                                                                  |
    |                   |                      |     The memory tags applicable for each memory type are displayed when the |P2P CARD| test case starts.                                                                    |
    |                   |                      |                                                                                                                                                                            |
    +-------------------+----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``buffer_size``   | Optional             | Write/read buffer size in MB. Range [1, ``max_buffer_size``] where ``max_buffer_size`` equals the memory size capped at 2048 MB.                                           |
    |                   |                      | Default: specified in the :ref:`ug-platform-definition`, typically 256 MB.                                                                                                 |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      | The number of buffers used in the test equals :ref:`p2p-card-parameter-total_size` divided by |p2p-card-buffer_size|.                                                      |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      | .. warning::                                                                                                                                                               |
    |                   |                      |     One FD is opened for each buffer when importing target OpenCL buffers to the source OpenCL context.                                                                    |
    |                   |                      |     Make sure the soft resource limit for maximum number of open file descriptors is greater than number of buffers required for each test.                                |
    |                   |                      |     For example, you can get this limit using the following command:                                                                                                       |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |     .. code-block:: bash                                                                                                                                                   |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |         $ ulimit -Sn                                                                                                                                                       |
    +-------------------+----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

.. note::
    The different |Alveo|_ cards have different memory types.

    The following command, using option :option:`-g`, allows to identify the names of available memory types and associated memory tags on the card selected with card BDF ``<BDF>``:

    .. code-block:: bash

        $ xbtest -d <BDF> -g p2p_card

For example:

  * **Single test**:

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 50, "source": "DDR" } ]

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 50, "source": "HBM" } ]

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 50, "source": "DDR", "target": "HBM" } ]

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 50, "source": "DDR", "target": "HBM[0]" } ]

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 50, "source": "DDR[0]", "target": "HBM[0]" } ]

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 50, "source": "DDR[0]", "target": "HBM[0]", "buffer_size": 128 } ]

  * **Multiple tests**:

      * .. code-block:: JSON

            "test_sequence": [
              { "duration": 50, "source": "DDR[0]", "target": "DDR[0]" },
              { "duration": 20, "source": "DDR[1]", "target": "DDR[1]" },
              { "duration": 10, "source": "DDR[2]", "target": "DDR[2]" }
            ]

        .. note::
            If the memory tags ``DDR[0]`` and ``DDR[1]`` are available for the memory type named ``DDR`` in the |xclbin| on the source card,
            and the memory tags ``DDR[0]``, ``DDR[1]``, ``DDR[2]`` and ``DDR[3]`` are available for the memory type named ``HBM`` on the target card then the sequence set to:

            .. code-block:: JSON

                "test_sequence": [
                  { "duration": 15, "source": "DDR[0]", "target": "DDR[0]" },
                  { "duration": 15, "source": "DDR[0]", "target": "DDR[1]" },
                  { "duration": 15, "source": "DDR[0]", "target": "DDR[2]" },
                  { "duration": 15, "source": "DDR[0]", "target": "DDR[3]" },
                  { "duration": 15, "source": "DDR[1]", "target": "DDR[0]" },
                  { "duration": 15, "source": "DDR[1]", "target": "DDR[1]" },
                  { "duration": 15, "source": "DDR[1]", "target": "DDR[2]" },
                  { "duration": 15, "source": "DDR[1]", "target": "DDR[3]" }
                ]

            is equivalent to the sequence:

            .. code-block:: JSON

                "test_sequence": [ { "duration": 15, "source": "DDR", "target": "DDR" } ]

----

.. _p2p-card-parameter-check_bw:

=====================================================
``check_bw``
=====================================================

Optional;
Type           : boolean;
Possible values: ``false`` or ``true``;
Default        : ``false``.

By setting this member to ``true``, average bandwidth measurements will be compared against defined thresholds.
When set to ``false``, no average bandwidth measurement will be checked.

Default bandwidth limits are defined in :ref:`ug-platform-definition` and are displayed at the beginning of the tests.

The bandwidth limits can be overwritten using the following parameters:

  * :ref:`p2p-card-parameter-hi_thresh_wr-rd`.
  * :ref:`p2p-card-parameter-lo_thresh_wr-rd`.

----

.. _p2p-card-parameter-stop_on_error:

=====================================================
``stop_on_error``
=====================================================

Optional;
Type           : boolean;
Possible values: ``false`` or ``true``;
Default        : ``false``.

By default, the write-read-check cycles are always executed during the entire test |p2p-card-duration| even if errors occurred during a cycle.
By setting this member to ``true``, the |P2P CARD| test case will stop in case of write / read transfer or data integrity error.

----

.. _p2p-card-parameter-hi_thresh_wr-rd:

.. _p2p-card-parameter-hi_thresh_wr:

.. _p2p-card-parameter-hi_thresh_rd:

=====================================================
``hi_thresh_wr``, ``hi_thresh_rd``
=====================================================

Optional;
Type           : integer;
Possible values: from 1 to 2\ :sup:`32`\-1;
Default        : specified in the :ref:`ug-platform-definition`.

Overwrite high threshold of the P2P write/read bandwidth (MB/s) specified in the :ref:`ug-platform-definition` for specified memory type.
After all bandwidth measurements made during the test |p2p-card-duration| are complete, if the measured bandwidth is greater than this threshold, the test fails.

----

.. _p2p-card-parameter-lo_thresh_wr-rd:

.. _p2p-card-parameter-lo_thresh_wr:

.. _p2p-card-parameter-lo_thresh_rd:

=====================================================
``lo_thresh_wr``, ``lo_thresh_rd``
=====================================================

Optional;
Type   : integer;
Range  : [1, 2\ :sup:`32`\-1];
Default: specified in the :ref:`ug-platform-definition`.

Overwrite low threshold of the P2P write/read bandwidth (MB/s) specified in the :ref:`ug-platform-definition` for specified memory type.
After all bandwidth measurements made during the test |p2p-card-duration| are complete, if the measured bandwidth is lower than this threshold, the test fails.
Low threshold must be lower than high threshold.

----

.. _p2p-card-parameter-total_size:

=====================================================
``total_size``
=====================================================

Optional;
Type           : integer;
Possible values: from minimum buffer size to memory size;
Default        : memory size.

Override the total amount of data (in MB) per transfer cycle for specified memory type.
When not specified, it defaults to the memory size.
This must be a multiple of the |p2p-card-buffer_size| parameter for all tests in the :ref:`p2p-card-parameter-test_sequence`.

----

********************************************************
Output files
********************************************************

All P2P measurements are stored in output CSV files which are generated in xbtest logging directory.
The values are stored in CSV type format with one column for each information type.

.. important::
    If the command line option :option:`-L` is used while calling the |Application software|, no output file is generated.

In the |P2P CARD| test case, two different CSV files are used to store all test results.
They are named with the following convention:

  * ``p2p_card_detail.csv``
  * ``p2p_card_result.csv``

=====================================================
``p2p_card_detail.csv`` output file
=====================================================

This file contains all intermediate bandwidth measurements for all memory types available on the card (for example: DDR/HBM).
There is one line of result for every write-read-check cycle of each test of the :ref:`p2p-card-parameter-test_sequence`.
The following table summarizes the content of this file, where the following columns represent groups of columns present in the file for a platform
containing a memory type named DDR with the two tags DDR[0] and DDR[1] associated and
containing also a memory type named HBM with the 32 tags associated: HBM[0] to HBM[31]:

* **write results**: Group of columns for P2P write results.
* **read results**: Group of columns for P2P read results.

.. table:: Example: ``p2p_card_detail.csv``

    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | Test | source memory tag | target memory tag | buffer size (MB) | Cycle ID | Data integrity | write results | read results |
    +======+===================+===================+==================+==========+================+===============+==============+
    | 1    | DDR[0]            | DDR[0]            | 256              | 0        | OK             | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | 1    | DDR[0]            | DDR[0]            | 256              | 1        | OK             | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | ...  | ...               | ...               | ...              | ...      | ...            | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | 2    | DDR[1]            | DDR[0]            | 256              | 0        | OK             | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | 2    | DDR[1]            | DDR[0]            | 256              | 1        | OK             | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | ...  | ...               | ...               | ...              | ...      | ...            | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | 3    | HBM[0]            | DDR[0]            | 256              | 0        | OK             | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | ...  | ...               | ...               | ...              | ...      | ...            | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | 4    | HBM[1]            | DDR[0]            | 256              | 0        | OK             | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | ...  | ...               | ...               | ...              | ...      | ...            | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+
    | 34   | HBM[31]           | DDR[0]            | 256              | 0        | OK             | ...           | ...          |
    +------+-------------------+-------------------+------------------+----------+----------------+---------------+--------------+

Where:

  * **Test**: Index of current test within the :ref:`p2p-card-parameter-test_sequence`. Index of first test is 1.
  * **source memory tag**: Tested memory name on source card.
  * **target memory tag**: Tested memory name on target card.
  * **buffer size (MB)**: Size of buffers transferred during the test.
  * **Cycle ID**: Index of the write-read-check cycle: the number of cycles depends on test |p2p-card-duration| and quantity of data transferred.
  * **Data integrity**: Data integrity result for the current write-read-check cycle.
  * **write results**: This group contains the following columns:

      * **live write BW (MBps)**: P2P write BW measurements for the current write-read-check cycle.
      * **minimum write BW (MBps)**: Minimum of P2P write BW measurements.
      * **average write BW (MBps)**: Average of P2P write BW measurements.
      * **maximum write BW (MBps)**: Maximum of P2P write BW measurements.

  * **read results**: This group contains the following columns:

      * **live read BW (MBps)**: P2P read BW measurements for the current write-read-check cycle.
      * **minimum read BW (MBps)**: Minimum of P2P read BW measurements.
      * **average read BW (MBps)**: Average of P2P read BW measurements.
      * **maximum read BW (MBps)**: Maximum of P2P read BW measurements.

=====================================================
``p2p_card_result.csv`` output file
=====================================================

For each test of the :ref:`p2p-card-parameter-test_sequence`, a new row containing the test configuration and results computed is present in this file.
The following table summarizes the content of this file, where the following columns represent groups of columns present in the file (see description below) for a platform
containing a memory type named DDR with the two tags DDR[0] and DDR[1] associated and
containing also a memory type named HBM with the 32 tags associated HBM[0] to HBM[31]:

  * **configuration**: Group of columns for P2P write/read configuration.
  * **write results**: Group of columns for P2P write results.
  * **read results**: Group of columns for P2P read results.

.. table:: Example: ``p2p_card_result.csv``

    +------+-------------------+-------------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | Test | source memory tag | target memory tag | duration (s)  | configuration | Number of cycles | Data integrity | write results | read results |
    +======+===================+===================+===============+===============+==================+================+===============+==============+
    | 1    | DDR[0]            | DDR[0]            | 10            | ...           | ...              | OK             | ...           | ...          |
    +------+-------------------+-------------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | 2    | DDR[1]            | DDR[0]            | 10            | ...           | ...              | OK             | ...           | ...          |
    +------+-------------------+-------------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | 3    | HBM[0]            | DDR[0]            | 10            | ...           | ...              | OK             | ...           | ...          |
    +------+-------------------+-------------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | 4    | HBM[1]            | DDR[0]            | 10            | ...           | ...              | OK             | ...           | ...          |
    +------+-------------------+-------------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | ...  | ...               | ...               | ...           | ...           | ...              | ...            | ...           | ...          |
    +------+-------------------+-------------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | 34   | HBM[31]           | DDR[0]            | 10            | ...           | ...              | OK             | ...           | ...          |
    +------+-------------------+-------------------+---------------+---------------+------------------+----------------+---------------+--------------+

Where:

  * **Test**: Index of current test within the :ref:`p2p-card-parameter-test_sequence`. Index of first test is 1.
  * **source memory tag**: Tested memory name on source card.
  * **target memory tag**: Tested memory name on target card.
  * **duration (s)**: Test duration.
  * **configuration**: This group contains the following columns:

      * **buffer size (MB)**: Size of buffers transferred during the test.
      * **number of buffers**: Quantity of buffers transferred in each write-read-check cycle.
      * **total size (MB)**: Total quantity of data transferred in each write-read-check cycle.

  * **Number of cycles**: Total number of write-read-check cycles performed: the number of cycles depends on test |p2p-card-duration| and quantity of data transferred.
  * **Data integrity**: Data integrity result.
  * **write results**: This group contains the following columns:

      * **minimum write BW (MBps)**: Minimum of P2P write BW measurements.
      * **average write BW (MBps)**: Average of P2P write BW measurements.
      * **maximum write BW (MBps)**: Maximum of P2P write BW measurements.

  * **read results**: This group contains the following columns:

      * **minimum read BW (MBps)**: Minimum of P2P read BW measurements.
      * **average read BW (MBps)**: Average of P2P read BW measurements.
      * **maximum read BW (MBps)**: Maximum of P2P read BW measurements.

