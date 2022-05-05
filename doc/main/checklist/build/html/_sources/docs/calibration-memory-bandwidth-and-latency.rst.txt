
.. include:: ../../../shared/links.rst
.. include:: links.rst

.. _calibration-memory-bandwidth-and-latency:

##########################################################################
Calibration - Memory bandwidth and latency
##########################################################################

********************************************************
Goal
********************************************************

xbtest compares bandwidth and latency measurements against limits.
This section will help you to define these limits (``cu_bw`` & ``cu_latency``) and find the optimal point which gives best results (maximum bandwidth with minimal latency).

The latency of the memory will depend on the request filling level of the AXI infrastructure (and memory controller).

There is a tipping point from which incrementing the quantity of write/read outstanding transactions doesn't increase the bandwidth but does increase latency.
Above this point, the access requests are queued in the AXI infrastructure (& memory controller), simply waiting to be served by the memory (as the memory operates at maximum capacity/bandwidth).

  * Few requests results in low latency but in lower bandwidth.
  * Too many requests mean highest bandwidth but high latency too.

The quantity of write/read outstanding transactions of the memory CU can be controlled by xbtest SW.
Best settings will be incorporated in the platform definition JSON file (``cu_outstanding``) and used as default settings during test.

In this example, you can see that:

  * **x = 1, 2**: when the outstanding transaction is low, read latency is low.

      * Outstanding transaction has a limited effect on the bandwidth.
        It only reduces the BW if there are big gaps in-between requests (longer than the actual data burst duration).

  * **x = 1 -> 9**: the latency increases with the quantity of outstanding transaction.
  * **x > 9**: the latency maxes out when all AXI infrastructure is full.

.. figure:: ./images/read-bw-lat-vs-outstanding-reads.png
    :align: center

    Read BW (MBps) and latency (ns) vs outstanding reads

.. note::
    If the memory rate has been reduced drastically to avoid over-power, the outstanding control may have no influence on the latency as the bandwidth is so low that AXI infrastructure is never full.

    This calibration is still required to get the bandwidth limits (and fill the platform definition JSON file).

********************************************************
General steps
********************************************************

  1. Run the tests available to download.
     They all are memory tests with ramps of outstanding values (write & read outstanding requests are increasing gradually).
  2. Save your results in section :ref:`calibration-memory-bandwidth-and-latency-checklist` of your checklist and plot some graphs to easily find the optimal point.

       * Check where the memory reaches maximum bandwidth with the lowest latency.
       * Extract write/read bandwidths/latencies & outstanding settings.

  3. Fill your platform definition JSON file with these figures.

       * **FYI**: by default, any memory test uses the outstanding and the bandwidth/latency limits defined in platform definition JSON file.

=====================================================
Margin
=====================================================

  * **Outstanding**: Select accordingly BW and latency.
  * **Bandwidth/latency**: xbtest SW takes automatically 10% margin around ``average`` BW and latency defined in platform definition JSON file.

      * Alternatively, you can also define ``high``/``low`` thresholds (see corner case below).

Don't be afraid to round BW and latency threshold values.

Follow the steps below for all on-board memories present in your platform.

  * E.g. DDR, HBM, PS_DDR, PL_DDR.

********************************************************
Configuration corner cases
********************************************************

=====================================================
DMA thresholds configuration
=====================================================

DMA bandwidth high/low thresholds are automatically created based on PCIe speed of the card.

It can be overwritten if needed, for example, if the actual memory (or AXI infrastructure) BW is lower than PCIe capabilities.

Reduce speed for u25 PS_DDR:

.. code-block:: JSON

    "dma_bw": {
      "write": {
        "average": 3840
      },
      "read": {
        "average": 3840
      }
    }

Reduce low threshold:

.. code-block:: JSON

    "dma_bw": {
      "write": {
        "low": 8000
      },
      "read": {
        "low": 8000
      }
    }

=====================================================
P2P_NVME thresholds configuration
=====================================================

P2P_NVME bandwidth high/low thresholds are automatically created based on PCIe speed of the card.

It can be overwritten if needed, for example, if the actual memory (or AXI infrastructure) BW is lower than PCIe capabilities.

For example, reduce high threshold:

.. code-block:: JSON

    "p2p_nvme_bw": {
      "write": {
        "high": 8000
      },
      "read": {
        "high": 8000
      }
    }

=====================================================
P2P_CARD thresholds configuration
=====================================================

P2P_CARD bandwidth high/low thresholds are automatically created based on PCIe speed of the card.

It can be overwritten if needed, for example, if the actual memory (or AXI infrastructure) BW is lower than PCIe capabilities.

For example, reduce high threshold:

.. code-block:: JSON

    "p2p_card_bw": {
      "write": {
        "high": 8000
      },
      "read": {
        "high": 8000
      }
    }

=====================================================
Memory CU latency thresholds configuration
=====================================================

multi-channel memory (e.g. HBM, PS_DDR or Versal NOC DDR) may have more complex connection.
Some access points to the memory could be shared between CU and shell infrastructure (e.g. DMA engine).
E.g. Pseudo-channel ``HBM[12]`` is also used as PCIe hook point.

Therefore, latency might be bigger/lower for some memory CU channels.
In such case, you can't use a single ``average`` limit.
You need to fully define the range of the latency from best- and worst-case figures across all channels:

  * ``high``: 30% above highest latency across all channels.
  * ``low``: 30% below lower latency across all channels.

Example of definition of the memory CU latency high and low thresholds:

.. code-block:: JSON

    "cu_latency": {
      "only_wr": {
        "write": {
          "high": 156,
          "low" : 56
        }
      },
      "only_rd": {
        "read": {
          "high": 319,
          "low" : 138
        }
      },
      "simul_wr_rd": {
        "write": {
          "high": 156,
          "low" : 56
        },
        "read": {
          "high": 358,
          "low" : 154
        }
      }
    }

.. _host-memory-configuration:

=====================================================
Host memory configuration
=====================================================

Host memory doesn't require a calibration. You can used default value as it is accessed over PCIe and it's too much dependent on the server used.

  * It will be easier to use a test JSON file defining outstanding, with (or not) latency thresholds and enable their checks.

Fixed HOST memory settings can be used:

  * No ``cu_outstanding``.

      * It's impossible to define a value that will work for all servers.

  * ``cu_rate`` for memory test mode ``only_wr`` set to:

      * 50 % for platform with PCIe 3x16.
      * 12 % for 3x4 platform.

  * ``cu_bw`` based on the PCIe speed (see examples below):

      * ``high = 256 MBps * 2pcie_speed-1 * pcie_width``.
      * ``low = 25 % of high``.

  * Latency are using loose range.

.. table:: Host memory settings

    +-----------------------------------------------------------+---------------------------------------------------------------+
    | 3x16 & 4x8 PCIe                                           | 3x4 PCIe                                                      |
    +===========================================================+===============================================================+
    | .. code-block:: JSON                                      | .. code-block:: JSON                                          |
    |    :emphasize-lines: 7, 14, 15, 20, 21, 26, 27, 30, 31    |    :emphasize-lines: 7, 14, 15, 20, 21, 26, 27, 30, 31        |
    |                                                           |                                                               |
    |     "memory" : {                                          |     "memory": {                                               |
    |       "0" : {                                             |       "0": {                                                  |
    |         "name" : "HOST",                                  |         "name": "HOST",                                       |
    |         "cu_rate": {                                      |         "cu_rate": {                                          |
    |           "only_wr": {                                    |           "only_wr": {                                        |
    |             "write": {                                    |             "write": {                                        |
    |               "nominal" : 50                              |               "nominal" : 12                                  |
    |             }                                             |             }                                                 |
    |           }                                               |           }                                                   |
    |         },                                                |         },                                                    |
    |         "cu_bw": {                                        |         "cu_bw": {                                            |
    |           "only_wr": {                                    |           "only_wr": {                                        |
    |             "write": {                                    |             "write": {                                        |
    |               "high": 16000,                              |               "high": 4000,                                   |
    |               "low" : 4000                                |               "low" : 1000                                    |
    |             }                                             |             }                                                 |
    |           },                                              |           },                                                  |
    |           "only_rd": {                                    |           "only_rd": {                                        |
    |             "read": {                                     |             "read": {                                         |
    |               "high": 16000,                              |               "high": 4000,                                   |
    |               "low" : 4000                                |               "low" : 1000                                    |
    |             }                                             |             }                                                 |
    |           },                                              |           },                                                  |
    |           "simul_wr_rd": {                                |           "simul_wr_rd": {                                    |
    |             "write": {                                    |             "write": {                                        |
    |               "high": 16000,                              |               "high": 4000,                                   |
    |               "low" : 4000                                |               "low" : 1000                                    |
    |             },                                            |             },                                                |
    |             "read": {                                     |             "read": {                                         |
    |               "high": 16000,                              |               "high": 4000,                                   |
    |               "low" : 4000                                |               "low" : 1000                                    |
    |             }                                             |             }                                                 |
    |           }                                               |           }                                                   |
    |         },                                                |         },                                                    |
    |         "cu_latency": {                                   |         "cu_latency": {                                       |
    |           "only_wr": {                                    |           "only_wr": {                                        |
    |             "write": {                                    |             "write": {                                        |
    |               "high": 6000,                               |               "high": 6000,                                   |
    |               "low" : 1                                   |               "low" : 1                                       |
    |             }                                             |             }                                                 |
    |           },                                              |           },                                                  |
    |           "only_rd": {                                    |           "only_rd": {                                        |
    |             "read": {                                     |             "read": {                                         |
    |               "high": 6000,                               |               "high": 6000,                                   |
    |               "low" : 1                                   |               "low" : 1                                       |
    |             }                                             |             }                                                 |
    |           },                                              |           },                                                  |
    |           "simul_wr_rd": {                                |           "simul_wr_rd": {                                    |
    |             "write": {                                    |             "write": {                                        |
    |               "high": 6000,                               |               "high": 6000,                                   |
    |               "low" : 1                                   |               "low" : 1                                       |
    |             },                                            |             },                                                |
    |             "read": {                                     |             "read": {                                         |
    |               "high": 6000,                               |               "high": 6000,                                   |
    |               "low" : 1                                   |               "low" : 1                                       |
    |             }                                             |             }                                                 |
    |           }                                               |           }                                                   |
    |         }                                                 |         }                                                     |
    |       }                                                   |       }                                                       |
    |     }                                                     |     }                                                         |
    +-----------------------------------------------------------+---------------------------------------------------------------+

********************************************************
Memory ``simultaneous_wr_rd`` QoS
********************************************************

The memory Quality of Service (QoS) can also be controlled by the rate.
You can define rate to balance read and write bandwidth during simultaneous access.

During ``simultaneous_wr_rd`` access, the read and write BW may be identical but it's not simple relationship from the ``only_wr`` or ``only_rd`` measurements.
It's recommended to always define the simultaneous bandwidth.

.. table:: ``simultaneous_wr_rd`` QoS

    +-----------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+
    | DDR QoS                                                                           | HBM QoS                                                                                   | Host QoS                                                                                  |
    +===================================================================================+===========================================================================================+===========================================================================================+
    | The current DDR controller is balancing write and read BW                         | HBM sub-system & controller currently balance access to reduce latency.                   | The memory CU is sending traffic to the host over the Slave bridge.                       |
    | when read and write access are performed simultaneously.                          | This results in a higher write bandwidth which could be rectified                         | The current Slave bridge implementation doesn't include any QoS.                          |
    |                                                                                   | by using a reduce write rate. It's not mandatory.                                         | Knowing that PCIe write are posted, this results in a write-bias bandwidth.               |
    | DDRs are faster to read than to write, resulting in a write BW quite lower.       |                                                                                           |                                                                                           |
    | So even if ``simultaneous_wr_rd`` bandwidths are identical                        | In this example, with a ``cu_rate`` of 33 for both read and write                         | Rate can be used to balance read/write access. In this case, selects a rate of 45 %.      |
    | can't not simply be extracted from the ``only_wr/rd`` values.                     | you'll achieve the highest total bandwidth (12GB/s) with evenly distributed write/read.   | It's not recommended as Host tests are heavily depending on the PCIe architecture         |
    |                                                                                   |                                                                                           | of the server.                                                                            |
    | .. code-block:: JSON                                                              | If you use default ``cu_rate`` (100%), you'll have to define individual                   |                                                                                           |
    |                                                                                   | simultaneous write and read bandwidths.                                                   |                                                                                           |
    |     "cu_bw": {                                                                    |                                                                                           | **For host memory, do not define rate for QoS purpose.**                                  |
    |       "only_wr": {                                                                | .. warning::                                                                              | Let the user select the best rate according to his test environment.                      |
    |         "write": {                                                                |    Selected rate should be compliant with the previous rate calibration                   |                                                                                           |
    |           "average": 15200                                                        |    (see :ref:`calibration-memory-cu-power`)                                               | .. figure:: ./images/host-simultaneous-qos.png                                            |
    |         }                                                                         |                                                                                           |    :align: center                                                                         |
    |       },                                                                          | .. figure:: ./images/hbm-simultaneous-qos.png                                             |                                                                                           |
    |       "only_rd": {                                                                |       :align: center                                                                      |    u55c host memory BW vs. memory CU rate                                                 |
    |         "read": {                                                                 |                                                                                           |                                                                                           |
    |           "average": 17200                                                        |       u55c HBM BW vs. memory CU rate                                                      |                                                                                           |
    |         }                                                                         |                                                                                           |                                                                                           |
    |       },                                                                          | .. table:: CU rate and BW limits QoS                                                      |                                                                                           |
    |       "simul_wr_rd": {                                                            |                                                                                           |                                                                                           |
    |         "write": {                                                                |    +---------------------------------+---------------------------------+                  |                                                                                           |
    |           "average": 8500                                                         |    | QoS rate used:                  | No QoS rate used:               |                  |                                                                                           |
    |         },                                                                        |    | Even ``simul_wr_rd`` BW         | Asymmetrical ``simul_wr_rd`` BW |                  |                                                                                           |
    |         "read": {                                                                 |    +=================================+=================================+                  |                                                                                           |
    |           "average": 8500                                                         |    | .. code-block:: JSON            | .. code-block:: JSON            |                  |                                                                                           |
    |         }                                                                         |    |     :emphasize-lines: 24, 27    |     :emphasize-lines: 14, 17    |                  |                                                                                           |
    |       }                                                                           |    |                                 |                                 |                  |                                                                                           |
    |     }                                                                             |    |     "cu_rate": {                |     "cu_bw": {                  |                  |                                                                                           |
    |                                                                                   |    |       "simul_wr_rd": {          |       "only_wr": {              |                  |                                                                                           |
    |                                                                                   |    |         "write": {              |         "write": {              |                  |                                                                                           |
    |                                                                                   |    |           "nominal" : 33        |           "average": 12300      |                  |                                                                                           |
    |                                                                                   |    |         },                      |         }                       |                  |                                                                                           |
    |                                                                                   |    |         "read": {               |       },                        |                  |                                                                                           |
    |                                                                                   |    |           "nominal" : 33        |       "only_rd": {              |                  |                                                                                           |
    |                                                                                   |    |         }                       |         "read": {               |                  |                                                                                           |
    |                                                                                   |    |       }                         |           "average": 12300      |                  |                                                                                           |
    |                                                                                   |    |     },                          |         }                       |                  |                                                                                           |
    |                                                                                   |    |     "cu_bw": {                  |       },                        |                  |                                                                                           |
    |                                                                                   |    |       "only_wr": {              |       "simul_wr_rd": {          |                  |                                                                                           |
    |                                                                                   |    |         "write": {              |         "write": {              |                  |                                                                                           |
    |                                                                                   |    |           "average": 12300      |           "average": 7800       |                  |                                                                                           |
    |                                                                                   |    |         }                       |         },                      |                  |                                                                                           |
    |                                                                                   |    |       },                        |         "read": {               |                  |                                                                                           |
    |                                                                                   |    |       "only_rd": {              |           "average": 4500       |                  |                                                                                           |
    |                                                                                   |    |         "read": {               |         }                       |                  |                                                                                           |
    |                                                                                   |    |           "average": 12300      |       }                         |                  |                                                                                           |
    |                                                                                   |    |         }                       |     }                           |                  |                                                                                           |
    |                                                                                   |    |       },                        |                                 |                  |                                                                                           |
    |                                                                                   |    |       "simul_wr_rd": {          |                                 |                  |                                                                                           |
    |                                                                                   |    |         "write": {              |                                 |                  |                                                                                           |
    |                                                                                   |    |           "average": 6000       |                                 |                  |                                                                                           |
    |                                                                                   |    |         },                      |                                 |                  |                                                                                           |
    |                                                                                   |    |         "read": {               |                                 |                  |                                                                                           |
    |                                                                                   |    |           "average": 6000       |                                 |                  |                                                                                           |
    |                                                                                   |    |         }                       |                                 |                  |                                                                                           |
    |                                                                                   |    |       }                         |                                 |                  |                                                                                           |
    |                                                                                   |    |     }                           |                                 |                  |                                                                                           |
    |                                                                                   |    +---------------------------------+---------------------------------+                  |                                                                                           |
    |                                                                                   |                                                                                           |                                                                                           |
    |                                                                                   |                                                                                           |                                                                                           |
    +-----------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+


********************************************************
TO-DO
********************************************************

For all on-board memory types (e.g. HBM, DDR, PS_DDR, PL_DDR):

  * Follow :ref:`bw-and-lat-detailed-steps` section.
  * Use the example provided as reference.
  * Add your results to section :ref:`calibration-memory-bandwidth-and-latency-checklist` of your checklist.

.. warning::
    Host memory doesn't require any calibration; use the recommended settings, see :ref:`host-memory-configuration`.

.. _bw-and-lat-detailed-steps:

********************************************************
Detailed steps
********************************************************

Nominal read rates, maximum number of outstanding transactions, BW thresholds and latency thresholds must be defined in the platform definition JSON file.
xbtest SW can still run with the default values present in the platform definition JSON file template.

Follow the calibration steps to optimize and characterize your memory and to be able to fill the platform definition JSON file.
To ease your task, test JSON files have been provided for the most common types of memory (DDR and HBM).
If your memory is not one of them, you'll need to update the test JSON files accordingly.

.. table:: Detailed calibration steps

    +----------+-----------------------------------------------------------------------------------------------------------------------------------+
    | Step     | Description                                                                                                                       |
    +==========+===================================================================================================================================+
    | Step 1   | Find the value of the maximum number of outstanding transactions providing the best latency and BW performances.                  |
    |          | For each on-board memory type:                                                                                                    |
    |          |                                                                                                                                   |
    |          |   1. Run the **three** test JSON files below.                                                                                     |
    |          |                                                                                                                                   |
    |          |        * Each of them contains a ramp of ``oustanding_wr/rd`` for a different test mode                                           |
    |          |          (``simultaneous_wr_rd``, ``only_rd``, ``only_wr``).                                                                      |
    |          |                                                                                                                                   |
    |          |          .. note::                                                                                                                |
    |          |             For ``simultaneous_wr_rd``, you need to check the QoS and run rate test.                                              |
    |          |                                                                                                                                   |
    |          |        * For other memory types, update with memory name being calibrated. E.g. ``testcases.memory.HBM``.                         |
    |          |        * **Important prerequisite**:                                                                                              |
    |          |                                                                                                                                   |
    |          |          * You should limit the rate in platform definition JSON file                                                             |
    |          |            to stay **below the critical power threshold** (see :ref:`calibration-memory-cu-power`).                               |
    |          |                                                                                                                                   |
    |          |   2. From each of the three runs, identify which maximum number of outstanding writes/reads                                       |
    |          |      gives the best write/read latency and BW performances.                                                                       |
    +----------+-----------------------------------------------------------------------------------------------------------------------------------+
    | Step 1.a | For QoS of ``simultaneous_wr_rd``, run the ``simultaneous_wr_rd_rate_ramp`` test for each on-board memory:                        |
    |          |                                                                                                                                   |
    |          | .. important::                                                                                                                    |
    |          |    If you've already reduced the rates due to power restriction (:ref:`calibration-memory-cu-power`),                             |
    |          |    you must skip this Step 1.a and you can re-use the results.                                                                    |
    |          |                                                                                                                                   |
    |          | .. code-block:: bash                                                                                                              |
    |          |                                                                                                                                   |
    |          |     $ xbtest -F -d <bdf> -j simultaneous_wr_rd_qos_rate_ramp_ddr.json -l simultaneous_wr_rd_qos_rate_ramp_ddr                     |
    |          |     $ xbtest -F -d <bdf> -j simultaneous_wr_rd_qos_rate_ramp_hbm.json -l simultaneous_wr_rd_qos_rate_ramp_hbm                     |
    |          |                                                                                                                                   |
    |          | Here is the test file:                                                                                                            |
    |          |                                                                                                                                   |
    |          |   * For DDR: :download:`simultaneous_wr_rd_qos_rate_ramp_ddr.json <./data/simultaneous_wr_rd_qos_rate_ramp_ddr.json>`             |
    |          |   * For HBM: :download:`simultaneous_wr_rd_qos_rate_ramp_hbm.json <./data/simultaneous_wr_rd_qos_rate_ramp_hbm.json>`             |
    |          |                                                                                                                                   |
    |          | Zip the log directory and attach it to this checklist:                                                                            |
    |          |                                                                                                                                   |
    |          | .. code-block:: bash                                                                                                              |
    |          |                                                                                                                                   |
    |          |     $ zip -r simultaneous_wr_rd_qos_rate_ramp_ddr.zip simultaneous_wr_rd_qos_rate_ramp_ddr                                        |
    |          |     $ zip -r simultaneous_wr_rd_qos_rate_ramp_hbm.zip simultaneous_wr_rd_qos_rate_ramp_hbm                                        |
    +----------+-----------------------------------------------------------------------------------------------------------------------------------+
    | Step 1.b | Set ``cu_rate`` for ``simul_wr_rd`` in platform definition JSON file.                                                             |
    |          | Select rates which provide balanced write/read BW.                                                                                |
    |          |                                                                                                                                   |
    |          | It could be that the write and read bandwidths stay similar throughout the entire ramp (typically with DDR),                      |
    |          | in this case, you don't define any ``cu_rate`` / ``simul_wr_rd``.                                                                 |
    |          |                                                                                                                                   |
    |          | .. important::                                                                                                                    |
    |          |    If you've already reduced the rates due to power restriction (:ref:`calibration-memory-cu-power`),                             |
    |          |    make sure that you select rates below the maximum supported.                                                                   |
    |          |                                                                                                                                   |
    +----------+-----------------------------------------------------------------------------------------------------------------------------------+
    | Step 1.c | Now that QoS is achieved, you can run the ``simultaneous_wr_rd_outstanding_ramp`` test                                            |
    |          | for each on-board memory:                                                                                                         |
    |          |                                                                                                                                   |
    |          | .. code-block:: bash                                                                                                              |
    |          |                                                                                                                                   |
    |          |     $ xbtest -F -d <bdf> -j simultaneous_wr_rd_outstanding_ramp_ddr.json -l simultaneous_wr_rd_outstanding_ramp_ddr               |
    |          |     $ xbtest -F -d <bdf> -j simultaneous_wr_rd_outstanding_ramp_hbm.json -l simultaneous_wr_rd_outstanding_ramp_hbm               |
    |          |                                                                                                                                   |
    |          | Here is the test file:                                                                                                            |
    |          |                                                                                                                                   |
    |          |   * For DDR: :download:`simultaneous_wr_rd_outstanding_ramp_ddr.json <./data/simultaneous_wr_rd_outstanding_ramp_ddr.json>`       |
    |          |   * For HBM: :download:`simultaneous_wr_rd_outstanding_ramp_hbm.json <./data/simultaneous_wr_rd_outstanding_ramp_hbm.json>`       |
    |          |                                                                                                                                   |
    |          | Zip the log directory and attach it to this checklist:                                                                            |
    |          |                                                                                                                                   |
    |          | .. code-block:: bash                                                                                                              |
    |          |                                                                                                                                   |
    |          |     $ zip -r simultaneous_wr_rd_outstanding_ramp_ddr.zip simultaneous_wr_rd_outstanding_ramp_ddr                                  |
    |          |     $ zip -r simultaneous_wr_rd_outstanding_ramp_hbm.zip simultaneous_wr_rd_outstanding_ramp_hbm                                  |
    +----------+-----------------------------------------------------------------------------------------------------------------------------------+
    | Step 1.b | For test mode: ``only_rd``, run the ``only_rd_outstanding_ramp`` test for each on-board memory:                                   |
    |          |                                                                                                                                   |
    |          | .. code-block:: bash                                                                                                              |
    |          |                                                                                                                                   |
    |          |     $ xbtest -F -d <bdf> -j only_rd_outstanding_ramp_ddr.json -l only_rd_outstanding_ramp_ddr                                     |
    |          |     $ xbtest -F -d <bdf> -j only_rd_outstanding_ramp_hbm.json -l only_rd_outstanding_ramp_hbm                                     |
    |          |                                                                                                                                   |
    |          | Here is the test file:                                                                                                            |
    |          |                                                                                                                                   |
    |          |   * For DDR: :download:`only_rd_outstanding_ramp_ddr.json <./data/only_rd_outstanding_ramp_ddr.json>`                             |
    |          |   * For HBM: :download:`only_rd_outstanding_ramp_hbm.json <./data/only_rd_outstanding_ramp_hbm.json>`                             |
    |          |                                                                                                                                   |
    |          | Zip the log directory and attach it to this checklist:                                                                            |
    |          |                                                                                                                                   |
    |          | .. code-block:: bash                                                                                                              |
    |          |                                                                                                                                   |
    |          |     $ zip -r only_rd_outstanding_ramp_ddr.zip only_rd_outstanding_ramp_ddr                                                        |
    |          |     $ zip -r only_rd_outstanding_ramp_hbm.zip only_rd_outstanding_ramp_hbm                                                        |
    +----------+-----------------------------------------------------------------------------------------------------------------------------------+
    | Step 1.c | For test mode: ``only_wr``, run the ``only_wr_outstanding_ramp`` test for each on-board memory:                                   |
    |          |                                                                                                                                   |
    |          | .. code-block:: bash                                                                                                              |
    |          |                                                                                                                                   |
    |          |     $ xbtest -F -d <bdf> -j only_wr_outstanding_ramp_ddr.json -l only_wr_outstanding_ramp_ddr                                     |
    |          |     $ xbtest -F -d <bdf> -j only_wr_outstanding_ramp_hbm.json -l only_wr_outstanding_ramp_hbm                                     |
    |          |                                                                                                                                   |
    |          | Here is the test file:                                                                                                            |
    |          |                                                                                                                                   |
    |          |   * For DDR: :download:`only_wr_outstanding_ramp_ddr.json <./data/only_wr_outstanding_ramp_ddr.json>`                             |
    |          |   * For HBM: :download:`only_wr_outstanding_ramp_hbm.json <./data/only_wr_outstanding_ramp_hbm.json>`                             |
    |          |                                                                                                                                   |
    |          | Zip the log directory and attach it to this checklist:                                                                            |
    |          |                                                                                                                                   |
    |          | .. code-block:: bash                                                                                                              |
    |          |                                                                                                                                   |
    |          |     $ zip -r only_wr_outstanding_ramp_ddr.zip only_wr_outstanding_ramp_ddr                                                        |
    |          |     $ zip -r only_wr_outstanding_ramp_hbm.zip only_wr_outstanding_ramp_hbm                                                        |
    +----------+-----------------------------------------------------------------------------------------------------------------------------------+
    | Step 2   | Report memory CU calibration results (multi-channel: for 1 channel only, single-channel for 1 CU only):                           |
    |          | BW and latency graphs and run directory ZIP files in :ref:`calibration-memory-bandwidth-and-latency-checklist` section.           |
    |          |                                                                                                                                   |
    |          | Determine nominal ``cu_outstanding`` (see template section).                                                                      |
    |          |                                                                                                                                   |
    |          |  * For ``only_wr`` and ``only_rd``, it should be relatively straight-forward to find an outstanding value                         |
    |          |    for which the bandwidth has plateaued with the lowest latency.                                                                 |
    |          |  * For ``simul_wr_rd``, the QoS (and the rate reduction) may have potentially disabled the effect of controlling                  |
    |          |    the outstanding transaction. The rate is low enough that the AXI infrastructure is saturated.                                  |
    |          |    You'll notice it when the BW stays constant (+/- 1%) across the whole range of outstanding.                                    |
    |          |    In such case, you don't need to define any ``simul_wr_rd`` outstanding writes/reads.                                           |
    |          |                                                                                                                                   |
    |          | Note BW and latency measured with this setting as you'll use them to fill the platform definition JSON file.                      |
    +----------+-----------------------------------------------------------------------------------------------------------------------------------+
    | Step 3   | Set ``cu_outstanding`` in your platform definition JSON file.                                                                     |
    |          | Use the maximum number of outstanding writes/reads (found in step 2) as nominal value                                             |
    |          | in platform definition JSON file for the memory being calibrated.                                                                 |
    +----------+-----------------------------------------------------------------------------------------------------------------------------------+
    | Step 4   | Set ``cu_bw`` in your platform definition JSON file.                                                                              |
    |          | Based on the write/read BW measurements using the nominal value of maximum number of outstanding writes/reads,                    |
    |          | define thresholds for ``only_wr``, for ``only_rd`` and for ``simultaneous_wr_rd`` test modes.                                     |
    +----------+-----------------------------------------------------------------------------------------------------------------------------------+
    | Step 5   | Set ``cu_latency`` in your platform definition JSON file.                                                                         |
    |          | Same procedure as BW thresholds but for latency thresholds.                                                                       |
    +----------+-----------------------------------------------------------------------------------------------------------------------------------+


********************************************************
Results and analysis
********************************************************

.. _bw-and-lat-graph:

=====================================================
Graph
=====================================================

For each test run, add the following graphs to section :ref:`calibration-memory-bandwidth-and-latency-checklist` of your checklist.

Find the memory log file:

  * For single-channel: ``<log_dir>/memory_<tag>_result.csv``, e.g. ``simultaneous_wr_rd_outstanding/memory_ddr[0]_result.csv``.
  * For multi-channel: ``<log_dir>/memory_<tag>_ch_0_result.csv``, e.g. ``simultaneous_wr_rd_outstanding/memory_hbm[0]_ch_0_result.csv``.
  * For PS_DDR, need to look at all channels and combined results: ``<log_dir>/memory_DDR[1]_ch_<id>_result.csv``.

      * E.g. ``simultaneous_wr_rd_outstanding/memory_PS_DDR_mc_summary.csv``.
      * E.g. ``simultaneous_wr_rd_outstanding/memory_PS_DDR_mc_summary.csv``.

Then:

  * Open it in Excel.

  * For ``simultaneous_wr_rd_rate_ramp`` runs:

    * Remove first rows where ``test_mode`` = ``only_wr`` as it contains results coming from the initialization of the memory (prior the actual readings).
    * Create graph (2-D line) with ``average total write+read BW (MBps)``, ``average write BW (MBps)`` and ``average read BW (MBps)``.

        * Use data of ``read rate (%)`` column for horizontal axis.
        * Set chart title to: **BW vs CU rate for <memory_type> <test_mode>**.
        * Set axis titles with data units.

    * Create graph (2-D line) with ``write burst latency (ns)``.

        * Use data of ``read rate (%)`` column for horizontal axis.
        * Set chart title to: **Write latency vs CU rate for <memory_type> <test_mode>**.
        * Set axis titles with data units.

    * Create similar graph but with ``read burst latency (ns)``.

  * For ``simultaneous_wr_rd_outstanding_ramp`` and ``only_rd_outstanding_ramp`` runs:

    * remove first rows where ``test_mode`` = ``only_wr``. as it contains results coming from the initialization of the memory (prior the actual readings).
    * Create graph (2-D line) with ``average read BW (MBps)`` and ``average read burst latency (ns)``.

        * Use data of ``outstanding reads`` column for horizontal axis.

            * Note outstanding set to 0 corresponds to a maximum number of outstanding transactions not limited.

        * Use primary vertical axis for bandwidth.
        * Use secondary vertical axis for latency.
        * Set chart title to: **Read BW & latency vs outstanding reads for <memory_type> <test_mode>**.
        * Set axis titles with data units.

    * Create similar graph but with ``average write BW (MBps)`` and ``average write burst latency (ns)``.

Include these graphs to your :ref:`checklist-results`.

=====================================================
Results
=====================================================

Add your results to section :ref:`calibration-memory-bandwidth-and-latency-checklist` of your checklist.


