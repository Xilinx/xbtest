
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _dma-test-case-description:

##########################################################################
DMA test case description
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2
   
The goal of this test case is to check communication and available bandwidth between host and memories available on the |Alveo|_ card (for example: DDR/HBM) through the PCIe.
Data integrity and write/read bandwidths are measured.

The |DMA| test case consists of writing and reading back data to and from the entire range of the memory under test over and over during a certain period.
A write-read-check cycle is never interrupted, meaning that:

  * Data is always fully sent and read back to and from the entire range of the memory and checked for data integrity.
  * If required, a test |dma-duration| can be extended to perform all write-read-check cycle operations.

The data sent and read back to and from the memory is:

  * Generated via an 8-bit counter that is randomly initialized at the beginning of each write-read-check cycle.
  * Split into buffers which are transferred (via OpenCL™) to or from the Alveo card.

The test JSON parameter :ref:`dma-parameter-total_size` can be used to override the quantity of data (in MB) sent and read back to and from the memory for each type of memory available on the card (for example HBM/DDR).
When not specified, :ref:`dma-parameter-total_size` defaults to the memory size.

The write/read bandwidths are computed after all write/read data transfers in each write-read-check cycle and the values are averaged over the test |dma-duration|.

.. important::
    By default, the average read and write bandwidths are not checked against any pass/fail criteria, but this can be overruled by setting :ref:`dma-parameter-check_bw`.

********************************************************
Test parameters
********************************************************

The mandatory test configuration parameters are listed below.
For more information, see :ref:`dma-test-json-members`.

  * |dma-duration|: The duration of the test (in seconds).
  * |dma-target|: Name of the memory type (for example: DDR/HBM) or tag (for example: DDR[0]/HBM[12]) of memory to access.

The following optional parameter may also be specified:

  * |dma-buffer_size|: Write/read buffer size.

********************************************************
Main test steps
********************************************************

For each test configuration, the following steps are repeated:

  1. Allocate ``N`` host buffers aligned with memory page size.

       * The number of buffers ``N`` equals :ref:`dma-parameter-total_size` divided by |dma-buffer_size|.
       * The memory page size is detected automatically and displayed at the beginning of the |DMA| test case in ``xbtest.log`` file.

  2. Allocate and initialize the reference buffer used to check data integrity.
  3. Write-read-check cycles are repeated for the |dma-duration| of the test.
     One cycle consists of the following steps:

       a. Set host buffers with reference data (8-bit counter).
       b. Write host buffers to the card memory, measure bandwidth.
       c. Reset host buffers to 0.
       d. Read from the card memory, measure bandwidth.
       e. Check that the host buffers contain the same data as the reference buffers (data integrity).
          Host buffers are set with reference data if data integrity fails.

     .. note::
         These steps constitute a write-read-check cycle which is always entirely executed. If :ref:`dma-parameter-stop_on_error` is set, the |DMA| test case aborts in case of write/read transfer or data integrity error.

  4. Compute write and read minimum, maximum, and average bandwidths.
  5. If enabled, compare the average read and write bandwidths against their thresholds.
  6. Release all host buffers.

********************************************************
Low DMA bandwidth troubleshooting
********************************************************

The DMA test always reports the read and write bandwidths.
There are many factors influencing these bandwidths:

  * Server PCIe architecture.
  * PCIe load:

      * Running other DMA tests.
      * Loading |xclbin| on other cards.

  * PCIe link training:

      * xbtest reports a message if the PCIe is not operating at its best rate.
      * The Linux command ``lspci`` can also report the speed and the quantity of lanes in use.

  * CPU affinity (NUMA nodes): the CPU affinity of the card is reported by the following command:

    .. code-block:: bash

        $ xbutil examine --device <BDF> --report pcie-info

    Use the Linux command ``taskset`` to run xbtest on the desired CPUs.
    For example:

    .. code-block:: bash

        $ taskset -c 0,2,4,6,8,10 xbtest -d <BDF> -c dma

.. _dma-test-json-members:

********************************************************
DMA test JSON members
********************************************************

=====================================================
Definition
=====================================================

The following table shows all members available for this test case.
More details are provided for each member in the subsequent sections.

.. table:: DMA test case members

    +------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | Member                             | Memory Type Override | Mandatory / Optional | Description                                                                            |
    +====================================+======================+======================+========================================================================================+
    | :ref:`dma-parameter-test_sequence` | no                   | mandatory            | Describes the sequence of tests to perform.                                            |
    +------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | :ref:`dma-parameter-check_bw`      | yes                  | optional             | Enable bandwidth checking. Disabled by default.                                        |
    +------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | :ref:`dma-parameter-stop_on_error` | yes                  | optional             | Enable stop test case on error. Disabled by default.                                   |
    +------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | |dma-hi_thresh_wr|                 | only                 | optional             | Overwrite high threshold of the write/read bandwidth (MB/s) for specified memory type. |
    |                                    |                      |                      |                                                                                        |
    | |dma-hi_thresh_rd|                 |                      |                      |                                                                                        |
    +------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | |dma-lo_thresh_wr|                 | only                 | optional             | Overwrite low threshold of the write/read bandwidth (MB/s) for specified memory type.  |
    |                                    |                      |                      |                                                                                        |
    | |dma-lo_thresh_rd|                 |                      |                      |                                                                                        |
    +------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+
    | :ref:`dma-parameter-total_size`    | only                 | optional             | Total amount of data (MB) per bandwidth measurement for specified memory type.         |
    +------------------------------------+----------------------+----------------------+----------------------------------------------------------------------------------------+

----

=====================================================
Basic examples
=====================================================

The following is a basic example of a |DMA| test case targeting all DDR and HBM memories available on the card. All memories are tested serially.

.. code-block:: JSON

    "dma": {
      "global_config": {
        "test_sequence": [
          { "duration": 10, "target": "DDR" },
          { "duration": 10, "target": "HBM" }
        ]
      }
    }


Some test JSON members can be overwritten for all memories based on memory type using the test JSON member ``memory_type_config`` which child members are memory type names.

Following is an example of |DMA| test case where the comparison of the average read and write bandwidths against thresholds is enabled only for all memories of type HBM.

.. code-block:: JSON

    "dma": {
      "global_config": {
        "stop_on_error": true,
        "test_sequence": [
          { "duration": 10, "target": "DDR" },
          { "duration": 10, "target": "HBM" }
        ]
      },
      "memory_type_config": {
        "HBM": {
          "check_bw": true,
          "hi_thresh_wr": 13000,
          "hi_thresh_rd": 13000,
          "lo_thresh_wr": 9000,
          "lo_thresh_rd": 9000
        }
      }
    }

.. note::
    By default, bandwidths are not checked, so :ref:`dma-parameter-check_bw` is set to ``true``.

The following example shows how to run |DMA| test case only for one (identified by memory tag DDR[1]) of the memories of the type named DDR, overriding :ref:`dma-parameter-total_size` value to 1GB:

.. code-block:: JSON

    "dma": {
      "global_config": {
        "test_sequence": [
          { "duration": 10, "target": "DDR[1]" }
        ]
      },
      "memory_type_config": {
        "DDR": {
          "total_size" : 1024
        }
      }
    }

----

.. _dma-parameter-test_sequence:

=====================================================
``test_sequence``
=====================================================

Mandatory. Describes the sequence of tests to perform.
Tests are performed serially, and a failure in one test does not stop the sequence (the next test will be launched).
There is no limitation to the length of the test sequence.

This field contains a list of tests, each test being defined by an object of key–value parameters pairs: ``[ {}, {}, {} ]``.

The following table defines the parameters supported in the DMA test sequence:

.. _dma-parameter-test_sequence-duration:
.. _dma-parameter-test_sequence-target:
.. _dma-parameter-test_sequence-buffer_size:

.. table:: DMA test sequence parameters

    +-------------------+----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Member            | Mandatory / optional | Description                                                                                                                                                                |
    +===================+======================+============================================================================================================================================================================+
    | ``duration``      | Mandatory            | The duration of the test in seconds; Range [1, 2\ :sup:`32`\-1].                                                                                                           |
    +-------------------+----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``target``        | Mandatory            | Name of the memory type (for example: DDR/HBM) or tag (for example DDR[0]/HBM[12]) of memory to access:                                                                    |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |   * The index must be within the range specified in the platform definition file.                                                                                          |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |       * When a test is defined by memory type. One test is created for each memory tag of the memory type.                                                                 |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      |         .. note::                                                                                                                                                          |
    |                   |                      |             The memory tags applicable for each memory type are displayed when the |DMA| test case starts.                                                                 |
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
    | ``buffer_size``   | Optional             | Write/read buffer size in MB. Range [1, ``max_buffer_size``] where ``max_buffer_size`` equals the memory size capped at 2048 MB.                                           |
    |                   |                      | Default: specified in the :ref:`ug-platform-definition`, typically 256 MB.                                                                                                 |
    |                   |                      |                                                                                                                                                                            |
    |                   |                      | The number of buffers used in the test equals :ref:`dma-parameter-total_size` divided by |dma-buffer_size|.                                                                |
    +-------------------+----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

.. note::
    The different |Alveo|_ cards have different memory types.

    The following command, using option :option:`-g`, allows to identify the names of available memory types and associated memory tags on the card selected with card BDF ``<BDF>``:

    .. code-block:: bash

        $ xbtest -d <BDF> -g dma

For example:

  * **Single test**:

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 50, "target": "DDR" } ]

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 50, "target": "HBM" } ]

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 50, "target": "DDR[0]" } ]

      * .. code-block:: JSON

            "test_sequence": [ { "duration": 50, "target": "HBM[1]", "buffer_size": 128 } ]

  * **Multiple tests**:

      * .. code-block:: JSON

            "test_sequence": [
              { "duration": 50, "target": "DDR[0]" },
              { "duration": 20, "target": "DDR[1]" },
              { "duration": 10, "target": "DDR[2]" }
            ]

        .. note::
            If, in an xclbin, the memory tags ``DDR[0]`` and ``DDR[1]`` are available for the memory type named ``DDR``, then the sequence set to:

            .. code-block:: JSON

                "test_sequence": [ { "duration": 15, "target": "DDR[0]" }, { "duration": 15, "target": "DDR[1]" } ]

            is equivalent to the sequence:

            .. code-block:: JSON

                "test_sequence": [ { "duration": 15, "target": "DDR" } ]

----

.. _dma-parameter-check_bw:

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

  * :ref:`dma-parameter-hi_thresh_wr-rd`.
  * :ref:`dma-parameter-lo_thresh_wr-rd`.

----

.. _dma-parameter-stop_on_error:

=====================================================
``stop_on_error``
=====================================================

Optional;
Type           : boolean;
Possible values: ``false`` or ``true``;
Default        : ``false``.

By default, the write-read-check cycles are always executed during the entire test |dma-duration| even if errors occurred during a cycle.
By setting this member to ``true``, the |DMA| test case will stop in case of write / read transfer or data integrity error.

----

.. _dma-parameter-hi_thresh_wr-rd:
.. _dma-parameter-hi_thresh_wr:
.. _dma-parameter-hi_thresh_rd:

=====================================================
``hi_thresh_wr``, ``hi_thresh_rd``
=====================================================

Optional;
Type           : integer;
Possible values: from 1 to 2\ :sup:`32`\-1;
Default        : specified in the :ref:`ug-platform-definition`.

Overwrite high threshold of the write/read bandwidth (MB/s) specified in the :ref:`ug-platform-definition` for specified memory type.
After all bandwidth measurements made during the test |dma-duration| are complete, if the measured bandwidth is greater than this threshold, the test fails.

----

.. _dma-parameter-lo_thresh_wr-rd:
.. _dma-parameter-lo_thresh_wr:
.. _dma-parameter-lo_thresh_rd:

=====================================================
``lo_thresh_wr``, ``lo_thresh_rd``
=====================================================

Optional;
Type   : integer;
Range  : [1, 2\ :sup:`32`\-1];
Default: specified in the :ref:`ug-platform-definition`.

Overwrite low threshold of the DDR/HBM write/read bandwidth (MB/s) specified in the :ref:`ug-platform-definition` for specified memory type.
After all bandwidth measurements made during the test |dma-duration| are complete, if the measured bandwidth is lower than this threshold, the test fails.
Low threshold must be lower than high threshold.

----

.. _dma-parameter-total_size:

=====================================================
``total_size``
=====================================================

Optional;
Type           : integer;
Possible values: from minimum buffer size to memory size;
Default        : memory size.

Override the total amount of data (in MB) per transfer cycle for specified memory type.
When not specified, it defaults to the memory size.
This must be a multiple of the |dma-buffer_size| parameter for all tests in the :ref:`dma-parameter-test_sequence`.

----

********************************************************
Output files
********************************************************

All DMA measurements are stored in output CSV files which are generated in xbtest logging directory.
The values are stored in CSV type format with one column for each information type.

.. important::
    If the command line option :option:`-L` is used while calling the |Application software|, no output file is generated.

In the |DMA| test case, two different CSV files are used to store all test results.
They are named with the following convention:

  * ``dma_detail.csv``
  * ``dma_result.csv``

=====================================================
``dma_detail.csv`` output file
=====================================================

This file contains all intermediate bandwidth measurements for all memory types available on the card (for example: DDR/HBM).
There is one line of result for every write-read-check cycle of each test of the :ref:`dma-parameter-test_sequence`.
The following table summarizes the content of this file, where the following columns represent groups of columns present in the file for a platform
containing a memory type named DDR with the two tags DDR[0] and DDR[1] associated and
containing also a memory type named HBM with the 32 tags associated: HBM[0] to HBM[31]:

* **write results**: Group of columns for DMA write results.
* **read results**: Group of columns for DMA read results.

.. table:: Example: ``dma_detail.csv``

    +------+------------+------------------+----------+----------------+---------------+--------------+
    | Test | memory tag | buffer size (MB) | Cycle ID | Data integrity | write results | read results |
    +======+============+==================+==========+================+===============+==============+
    | 1    | DDR[0]     | 256              | 0        | OK             | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+
    | 1    | DDR[0]     | 256              | 1        | OK             | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+
    | ...  | ...        | ...              | ...      | ...            | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+
    | 2    | DDR[1]     | 256              | 0        | OK             | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+
    | 2    | DDR[1]     | 256              | 1        | OK             | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+
    | ...  | ...        | ...              | ...      | ...            | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+
    | 3    | HBM[0]     | 256              | 0        | OK             | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+
    | ...  | ...        | ...              | ...      | ...            | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+
    | 4    | HBM[1]     | 256              | 0        | OK             | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+
    | ...  | ...        | ...              | ...      | ...            | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+
    | 34   | HBM[31]    | 256              | 0        | OK             | ...           | ...          |
    +------+------------+------------------+----------+----------------+---------------+--------------+

Where:

  * **Test**: Index of current test within the :ref:`dma-parameter-test_sequence`. Index of first test is 1.
  * **memory tag**: Tested memory name.
  * **buffer size (MB)**: Size of buffers transferred during the test.
  * **Cycle ID**: Index of the write-read-check cycle: the number of cycles depends on test |dma-duration| and quantity of data transferred.
  * **Data integrity**: Data integrity result for the current write-read-check cycle.
  * **write results**: This group contains the following columns:

      * **live write BW (MBps)**: DMA write BW measurements for the current write-read-check cycle.
      * **minimum write BW (MBps)**: Minimum of DMA write BW measurements.
      * **average write BW (MBps)**: Average of DMA write BW measurements.
      * **maximum write BW (MBps)**: Maximum of DMA write BW measurements.

  * **read results**: This group contains the following columns:

      * **live read BW (MBps)**: DMA read BW measurements for the current write-read-check cycle.
      * **minimum read BW (MBps)**: Minimum of DMA read BW measurements.
      * **average read BW (MBps)**: Average of DMA read BW measurements.
      * **maximum read BW (MBps)**: Maximum of DMA read BW measurements.

=====================================================
``dma_result.csv`` output file
=====================================================

For each test of the :ref:`dma-parameter-test_sequence`, a new row containing the test configuration and results computed is present in this file.
The following table summarizes the content of this file, where the following columns represent groups of columns present in the file (see description below) for a platform
containing a memory type named DDR with the two tags DDR[0] and DDR[1] associated and
containing also a memory type named HBM with the 32 tags associated HBM[0] to HBM[31]:

  * **configuration**: Group of columns for DMA write/read configuration.
  * **write results**: Group of columns for DMA write results.
  * **read results**: Group of columns for DMA read results.

.. table:: Example: ``dma_result.csv``

    +------+------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | Test | memory tag | duration (s)  | configuration | Number of cycles | Data integrity | write results | read results |
    +======+============+===============+===============+==================+================+===============+==============+
    | 1    | DDR[0]     | 10            | ...           | ...              | OK             | ...           | ...          |
    +------+------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | 2    | DDR[1]     | 10            | ...           | ...              | OK             | ...           | ...          |
    +------+------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | 3    | HBM[0]     | 10            | ...           | ...              | OK             | ...           | ...          |
    +------+------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | 4    | HBM[1]     | 10            | ...           | ...              | OK             | ...           | ...          |
    +------+------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | ...  | ...        | ...           | ...           | ...              | ...            | ...           | ...          |
    +------+------------+---------------+---------------+------------------+----------------+---------------+--------------+
    | 34   | HBM[31]    | 10            | ...           | ...              | OK             | ...           | ...          |
    +------+------------+---------------+---------------+------------------+----------------+---------------+--------------+

Where:

  * **Test**: Index of current test within the :ref:`dma-parameter-test_sequence`. Index of first test is 1.
  * **memory tag**: Tested memory name.
  * **duration (s)**: Test duration.
  * **configuration**: This group contains the following columns:

      * **buffer size (MB)**: Size of buffers transferred during the test.
      * **number of buffers**: Quantity of buffers transferred in each write-read-check cycle.
      * **total size (MB)**: Total quantity of data transferred in each write-read-check cycle.

  * **Number of cycles**: Total number of write-read-check cycles performed: the number of cycles depends on test |dma-duration| and quantity of data transferred.
  * **Data integrity**: Data integrity result.
  * **write results**: This group contains the following columns:

      * **minimum write BW (MBps)**: Minimum of DMA write BW measurements.
      * **average write BW (MBps)**: Average of DMA write BW measurements.
      * **maximum write BW (MBps)**: Maximum of DMA write BW measurements.

  * **read results**: This group contains the following columns:

      * **minimum read BW (MBps)**: Minimum of DMA read BW measurements.
      * **average read BW (MBps)**: Average of DMA read BW measurements.
      * **maximum read BW (MBps)**: Maximum of DMA read BW measurements.

