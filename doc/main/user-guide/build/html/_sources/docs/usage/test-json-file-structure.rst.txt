
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _test-json-file-structure:

##########################################################################
Test JSON file structure
##########################################################################

.. caution::
    Test JSON files from previous versions of xbtest are not compatible with this version.
    Contact |Xilinx Support|_ for information on how to convert a |Test JSON file| from previous xbtest version.

********************************************************
Test environment members
********************************************************

The test JSON file allows to provide various schemas defining the configuration of the tasks and the |test cases| to be run.

.. table:: Test environment members

    +---------------+--------------------+---------------------------------------------------------------------------------------------------+
    | Member        | Mandatory/optional | Description                                                                                       |
    +===============+====================+===================================================================================================+
    | ``comment``   | Optional           | If necessary, to detail your test, use comments at any level in the |Test JSON file|.             |
    +---------------+--------------------+---------------------------------------------------------------------------------------------------+
    | ``testcases`` | Optional           | Defines each of the |test cases| to be executed, which are performed in parallel.                 |
    |               |                    | Define which test is performed. Because test cases run in parallel, you can define 0, 1, or more. |
    |               |                    | When not defined in the test JSON file, a test case is not run.                                   |
    |               |                    | The |Verify| test case is always performed even if no test cases are specified.                   |
    |               |                    |                                                                                                   |
    |               |                    | The following ``testcases`` nodes are supported:                                                  |
    |               |                    |                                                                                                   |
    |               |                    |   * ``dma``: |DMA| test case.                                                                     |
    |               |                    |   * ``p2p_card``: |P2P CARD| test case.                                                           |
    |               |                    |   * ``p2p_nvme``: |P2P NVME| test case.                                                           |
    |               |                    |   * ``memory``: |Memory| test case.                                                               |
    |               |                    |   * ``power``: |Power| test case.                                                                 |
    |               |                    |   * ``gt_mac``: |GT MAC| test case.                                                               |
    |               |                    |   * ``gt_prbs``: |GT PRBS| test case.                                                             |
    |               |                    |   * ``gt_lpbk``: |GT LPBK| test case.                                                             |
    |               |                    |                                                                                                   |
    +---------------+--------------------+---------------------------------------------------------------------------------------------------+
    | ``tasks``     | Optional           | Defines parameters of each |task|.                                                                |
    |               |                    | Note that tasks are performed in parallel with each of the |test cases|.                          |
    |               |                    |                                                                                                   |
    |               |                    | The following ``tasks`` nodes are supported:                                                      |
    |               |                    |                                                                                                   |
    |               |                    |   * ``device_mgmt``: |Device Management| task.                                                    |
    |               |                    |                                                                                                   |
    +---------------+--------------------+---------------------------------------------------------------------------------------------------+

The test JSON file has the following properties:

  * If the same member is repeated throughout your file, only the last value is used.
  * Comments can be added or removed anywhere in test JSON file using member ``comment``.

Test cases are executed in parallel with exception of:

  * |Verify|: Executed prior to any tests, as a preliminary check.
  * |DMA|, |P2P CARD| and |P2P NVME|: These test cases are executed prior to all other listed tests:

      * |Memory|
      * |Power|
      * |GT MAC|
      * |GT PRBS|
      * |GT LPBK|

********************************************************
Test JSON file example
********************************************************

The following is a test JSON file example.

.. code-block:: JSON

    {
      "comment": "This is an example of test JSON file",
      "comment": "You can use this example as template for your own tests",
      "comment": "Use comment to detail your test if necessary (you can also remove these lines)",
      "testcases": {
        "dma": {
          "global_config": {
            "comment": "Use comment to detail your test if necessary",
            "test_sequence": [
              { "duration": 10, "target": "DDR" },
              { "duration": 10, "target": "HBM" }
            ]
          }
        },
        "p2p_card": {
          "global_config": {
            "comment": "Use comment to detail your test if necessary",
            "test_sequence": [
              { "duration": 10, "source": "DDR" },
              { "duration": 10, "source": "HBM" }
            ]
          }
        },
        "p2p_nvme": {
          "global_config": {
            "comment": "Use comment to detail your test if necessary",
            "test_sequence": [
              { "duration": 10, "source": "DDR" },
              { "duration": 10, "source": "HBM" },
              { "duration": 10, "target": "DDR" },
              { "duration": 10, "target": "HBM" }
            ]
          }
        },
        "power": {
          "comment": "Use comment to detail your test if necessary",
          "global_config": {
            "test_sequence": [
              { "duration":  60, "toggle_rate": 15 },
              { "duration": 120, "toggle_rate": 50 }
            ]
          }
        },
        "memory": {
          "DDR": {
            "comment": "Use comment to detail your test if necessary",
            "global_config": {
              "test_sequence": [
                { "duration": 60, "mode": "alternate_wr_rd" }
              ]
            }
          },
          "HBM": {
            "global_config": {
              "comment": "Use comment to detail your test if necessary",
              "test_sequence": [
                { "duration": 60, "mode": "alternate_wr_rd" }
              ]
            }
          }
        },
        "gt_mac": {
          "comment": "Use comment to detail your test if necessary",
          "0": {
            "global_config": {
              "test_sequence": [
                { "duration":  1, "mode": "conf_10gbe_no_fec" },
                { "duration":  1, "mode": "clear_status"       },
                { "duration": 10, "mode": "run"                },
                { "duration":  1, "mode": "check_status"       }
              ]
            }
          },
          "1": {
            "global_config": {
              "test_sequence": [
                { "duration":  1, "mode": "conf_25gbe_c74_fec"  },
                { "duration":  1, "mode": "clear_status"        },
                { "duration": 10, "mode": "run"                 },
                { "duration":  1, "mode": "check_status"        }
              ]
            }
          }
        }
      }
    }
