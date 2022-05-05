
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _pre-canned-tests-description:

##########################################################################
Pre-canned tests description
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2

********************************************************
Overview
********************************************************

xbtest comes with a set of pre-canned tests which use one or more of the available |test cases|.

The pre-canned tests can be used as templates to create your own tests.

Use command line option :option:`-h` to list and locate the pre-canned test files.
Any pre-canned test requires xbtest to be set up correctly (see :ref:`set-up-xbtest`).

.. warning::
    The exact list and content of available pre-canned tests is specific to each platform.
    The ``test_sequence`` used by these various tests depends on the targeted platform.

.. important::
    For each platform, all pre-canned tests have been validated in DELL PowerEdge R740 server with its fans spinning at 100% in a 25°C room.

xbtest supports the following pre-canned tests described in next sections:

.. contents::
    :depth: 2
    :local:

.. note::
    The ``test_sequence`` listed in these various pre-canned sections is purely illustrative.
    Please refer to the actual pre-canned test of your platform for accurate parameter definitions.

----

********************************************************
``verify``
********************************************************

The ``verify`` pre-canned test checks the integrity of the |xclbin| (see :ref:`verify-test-case-description`).

----

********************************************************
``dma``
********************************************************

The ``dma`` pre-canned test performs a basic |DMA| test case of all memories available on the card (for example: DDR and/or HBM).
For more information about host <-> memory test capabilities, see :ref:`dma-test-case-description`.

In this test, the DMA bandwidths are only reported as information and are not checked against any thresholds.
The following are two examples of how a pre-canned ``test_sequence`` may look like.
Refer to the pre-canned test provided in the |Platform specific library| for accurate content.

.. code-block:: JSON

    "test_sequence": [
      { "duration": 10, "target": "HBM" },
      { "duration": 10, "target": "DDR" }
    ]

.. code-block:: JSON

    "test_sequence": [
      { "duration": 10, "target": "PL_DDR" },
      { "duration": 10, "target": "PS_DDR" }
    ]

----

********************************************************
``p2p_card``
********************************************************

The ``p2p_card`` pre-canned test performs a basic |P2P CARD| test case of all memories available on the source card (for example: DDR and/or HBM).
For more information about card <-> card test capabilities, see :ref:`p2p-card-test-case-description`.

In this test, the P2P bandwidths are only reported as information and are not checked against any thresholds.
Here is an example of how a pre-canned ``test_sequence`` may look like.
Refer to the pre-canned test provided in the |Platform specific library| for accurate content.

.. code-block:: JSON

    "test_sequence": [
      { "duration": 10, "source": "HBM" },
      { "duration": 10, "source": "DDR" }
    ]

----

********************************************************
``p2p_nvme``
********************************************************

The ``p2p_nvme`` pre-canned test performs a basic |P2P NVME| test case of all memories available on the card (for example: DDR and/or HBM) tested as source and then tested as target.

For NoDMA platform, memories available on card are only tested as target.

For more information about NVMe SSD <-> card test capabilities, see :ref:`p2p-nvme-test-case-description`.

In this test, the P2P bandwidths are only reported as information and are not checked against any thresholds.
Here is an example of how a pre-canned ``test_sequence`` may look like.
Refer to the pre-canned test provided in the |Platform specific library| for accurate content.

.. code-block:: JSON

    "test_sequence": [
      { "duration": 10, "source": "HBM" },
      { "duration": 10, "source": "DDR" },
      { "duration": 10, "target": "HBM" },
      { "duration": 10, "target": "DDR" }
    ]

----

********************************************************
``memory``
********************************************************

The ``memory`` pre-canned test performs a basic |Memory| test case of all memories available on the card (for example DDR or HBM).
See :ref:`memory-test-case-description` for more information about CU <-> memory test capabilities.
Here is an example of how a pre-canned ``test_sequence`` may look like.
Refer to the pre-canned test provided in the |Platform specific library| for accurate content.

.. code-block:: JSON

    "test_sequence": [
      { "duration": 20, "mode": "alternate_wr_rd"    },
      { "duration": 20, "mode": "only_wr"            },
      { "duration": 20, "mode": "only_rd"            },
      { "duration": 20, "mode": "simultaneous_wr_rd" }
    ]

----

********************************************************
``memory_host`` (Slave bridge)
********************************************************

The host memory must be enabled before running the ``memory_host`` pre-canned test (see :ref:`host-memory-set-up`).

The ``memory_host`` pre-canned test performs a basic |Memory| test case of the allocated host memory.
See :ref:`memory-test-case-description` for more information about CU <-> memory test capabilities.
Here is an example of how a pre-canned ``test_sequence`` may look like.
Refer to the pre-canned test provided in the |Platform specific library| for accurate content.

.. code-block:: JSON

    "test_sequence": [
      { "duration": 20, "mode": "alternate_wr_rd"    },
      { "duration": 20, "mode": "only_wr"            },
      { "duration": 20, "mode": "only_rd"            },
      { "duration": 20, "mode": "simultaneous_wr_rd" }
    ]

.. note::
    In the ``memory_host`` pre-canned test, write and read bandwidths are not compared against any thresholds.
    Bandwidths are only reported as information.

----

********************************************************
``power``
********************************************************

The ``power`` pre-canned test performs a basic |Power| test case (see :ref:`power-test-case-description`).
Here is an example of how a pre-canned ``test_sequence`` may look like.
Refer to the pre-canned test provided in the |Platform specific library| for accurate content.

.. code-block:: JSON

    "test_sequence": [
      { "duration": 100, "toggle_rate": 10 },
      { "duration": 100, "toggle_rate": 20 },
      { "duration": 100, "toggle_rate": 30 },
      { "duration": 100, "toggle_rate": 40 }
    ]

----

********************************************************
GT
********************************************************

Each GT pre-canned test requires a different set up (see :ref:`gt-mac-test-set-up`).

=====================================================
``gt_mac``
=====================================================

The ``gt_mac`` pre-canned test uses the QSFP passive electrical loopback module.
All the GT_MAC CUs present in |xclbin| are referenced in this pre-canned test.

Here is an example of how a pre-canned ``test_sequence`` may look like.
Refer to the pre-canned test provided in the |Platform specific library| for accurate content.

.. code-block:: JSON

    "test_sequence": [
      { "duration":  1, "mode": "conf_25gbe_rs_fec"  },
      { "duration":  1, "mode": "clear_status"       },
      { "duration": 10, "mode": "run"                },
      { "duration":  1, "mode": "check_status"       },

      { "duration":  1, "mode": "conf_10gbe_c74_fec" },
      { "duration":  1, "mode": "clear_status"       },
      { "duration": 10, "mode": "run"                },
      { "duration":  1, "mode": "check_status"       }
    ]

.. note::
    The usage of QSFP passive electrical loopback module allows 10/25GbE rate update during the test.

----

=====================================================
``switch``
=====================================================

The ``switch`` pre-canned tests require to be connected to a 10GbE or 25GbE switch port.
See :ref:`gt-mac-test-case-description` for supported test sequence, lane mapping, switch and cables.

These pre-canned tests perform basic tests at 10GbE or 25GbE rate while the GT is connected to a 10 or 25GbE switch port.
The traffic is looped back by the switch.
All the GT_MAC CUs present in |xclbin| are referenced in these pre-canned tests.
One pre-canned test is provided per lane rate:

  * **10GbE**: ``switch_10gbe``.
  * **25GbE**: ``switch_25gbe``.

Here is an example of how a pre-canned ``test_sequence`` may look like.
Refer to the pre-canned test provided in the |Platform specific library| for accurate content.

.. code-block:: JSON

    "gt_mac": {
      "0": {
        "global_config": {
          "match_tx_rx": true,
          "test_sequence": [
            { "duration":  1, "mode": "conf_10gbe_no_fec" },
            { "duration":  1, "mode": "clear_status"      },
            { "duration": 60, "mode": "run"               },
            { "duration":  1, "mode": "check_status"      }
          ]
        },
        "lane_config": {
          "0": {
            "tx_mapping": 1
          },
          "1": {
            "tx_mapping": 0
          },
          "2": {
            "tx_mapping": 3
          },
          "3": {
            "tx_mapping": 2
          }
        }
      }
    }

----

=====================================================
``gt_mac_lpbk``
=====================================================

The ``gt_mac_lpbk`` pre-canned test requires a 25GbE capable connection between the 2 CU (GT MAC and GT LPBK).
The 2 CUs are directly connected to each other.
See :ref:`gt-mac-test-case-description` for supported test sequence, lane mapping, switch and cables.

This pre-canned test performs a basic test at 25GbE rate (without FEC).
The traffic is generated GT MAC and to looped back by via the GT LPBK.

.. code-block:: JSON

    "gt_mac": {
      "0": {
        "global_config": {
          "match_tx_rx": true,
          "test_sequence": [
            { "duration":  1, "mode": "conf_25gbe_no_fec" },
            { "duration":  1, "mode": "clear_status"      },
            { "duration": 60, "mode": "run"               },
            { "duration":  1, "mode": "check_status"      }
          ]
        }
      }
    },
    "gt_lpbk": {
      "1": {
        "global_config": {
          "test_sequence": [
            { "duration": 1, "mode": "conf_25gbe_no_fec" }
          ]
        }
      }
    }

----

=====================================================
``gt_mac_port_to_port``
=====================================================

The ``gt_mac_port_to_port`` pre-canned test requires a 10GbE or 25GbE capable connection between the 2 GT MAC CUs.
The 2 CU are directly connected to each other.
See :ref:`gt-mac-test-case-description` for supported test sequence, lane mapping, switch and cables.

This pre-canned test performs basic tests at 10GbE and 25GbE rate.
The traffic is generated by each GT MAC CU and terminated by the other one.

.. code-block:: JSON

    "gt_mac": {
      "0": {
        "global_config": {
          "match_tx_rx": true,
          "test_sequence": [
            { "duration":  1, "mode": "conf_25gbe_c74_fec"  },
            { "duration":  1, "mode": "clear_status"        },
            { "duration": 30, "mode": "run"                 },
            { "duration":  1, "mode": "check_status"        },

            { "duration":  1, "mode": "conf_10gbe_c74_fec" },
            { "duration":  1, "mode": "clear_status"       },
            { "duration": 30, "mode": "run"                },
            { "duration":  1, "mode": "check_status"       }
          ]
        }
      },
      "1": {
        "global_config": {
          "mac_to_mac_connection": 0
        }
      }
    }

----

=====================================================
``gt_prbs``
=====================================================

The ``gt_prbs`` pre-canned test requires a 25GbE capable loopback connection.
See :ref:`gt-mac-test-case-description` for supported test sequence, lane mapping, switch and cables.

This pre-canned test performs a basic test at 25GbE rate.
64/66B PRBS 31 is generated and checked.

.. code-block:: JSON

    "gt_prbs": {
      "0": {
        "global_config": {
            "test_sequence": [
            { "duration":  1, "mode": "conf_25gbe"   },
            { "duration":  1, "mode": "clear_status" },
            { "duration": 30, "mode": "run"          },
            { "duration":  1, "mode": "read_status"  }
          ]
        }
      }
    }


----

********************************************************
``stress``
********************************************************

The ``stress`` pre-canned test requires GTs to be connected to a 25GbE switch port (see :ref:`gt-mac-test-set-up`).

This pre-canned test combines multiple pre-canned tests:

  * ``verify``
  * ``switch_25gbe``
  * ``memory``
  * ``power``

Refer to the pre-canned test provided in the |Platform specific library| for accurate content.

.. important::
    If the GTs are not connected to a 25GbE switch port, this pre-canned test will fail.

