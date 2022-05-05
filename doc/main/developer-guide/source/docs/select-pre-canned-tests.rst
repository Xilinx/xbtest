
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _select-pre-canned-tests:

##########################################################################
Select pre-canned tests
##########################################################################

********************************************************
Overview
********************************************************

Pre-canned test JSON files are various example of test JSON files provided to xbtest users in the xclbin RPM/DEB packages.

The content of pre-canned test JSON files depends on the features supported in the xclbin. Their definition is provided in the following section. Note:

  * All compute units present in xclbin must be referenced in pre-canned test when applicable. For example:

      * All on-board / host memories are included in the memory testcase when specified in pre-canned test definition.
      * All GT_MAC / GT_PRBS / GT_LPBK CUs are included in their respective GT testcase when specified in pre-canned test definition.
      * Pre-canned test ``dma`` is not included for NoDMA platforms.

  * Pre-canned test must always pass when run on any card/server.

.. warning::
    By default, you should not do anything as pre-canned test JSON files selection & content is automatically handled by the workflows.

This section also contains a description of the pre-canned test JSON files

  * Goal & targeted resources.
  * Test conditions.

********************************************************
Overwrite
********************************************************

Default pre-canned test JSON files are automatically generated based on the compute units selected in :ref:`wizard-configuration-json-file` (via ``cu_selection`` node) when generating an xclbin using |xclbin_generate| workflow.

They are automatically passed to the |rpm_generate| workflow using xclbin file as carrying vector (they are embedded in xclbin section ``USER_METADATA``).

If needed, you can overwrite the content and the quantity of pre-canned test JSON files packaged with you xclbin.

.. caution::
    If you decide to modify in any manner any of the pre-canned test JSON files, you have to include **all** needed tests when creating the packages (including the un-modified ones).

You can use the default pre-canned test JSON files as template. They are written by |xclbin_generate| workflow in ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/sw/test/*.json``

  * |<xbtest_build> def|
  * |<dev_platform> def|
  * |<project_name> def|

After updating the files, include them in the |rpm_generate| workflow include directory ``<xbtest_build>/rpm_generate/include/<deploy_platform>/test``

  * See :ref:`build-rpm-and-deb-packages`
  * |<xbtest_build> def|
  * |<deploy_platform> def|

.. note::
    If at least one pre-canned test is overwritten:

      * The |rpm_generate| workflow ignores all pre-canned test embedded in the xclbin.
      * All pre-canned test JSON files (modified or not) must be included in ``<xbtest_build>/rpm_generate/include/<deploy_platform>/test``.

    The ``verify.json`` file is required and does not need to be updated: this is the only pre-canned test applicable for any xclbin as it does not depend on xclbin capabilities.

    Please update ``comment`` nodes in the pre-canned test JSON files according to your modifications.

    Keep formatting as in example provided below:

      * Indentation.
      * Tab = 2 blank spaces.

********************************************************
Pre-canned test description
********************************************************

Here is a description of all automatically generated pre-canned tests.

=====================================================
``verify.json``
=====================================================

This pre-canned test is used to run only a verify testcase.

File is always included for any xclbin.

Do not edit.

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ]
    }

=====================================================
``dma.json``
=====================================================

This pre-canned test only includes a DMA testcase:

  * Only the on-board memories shall be targeted.
  * All memory banks are tested for 10 seconds.
  * All the on-board memories present in xclbin are referenced.

File not included if:

  * xclbin does not support memory CU connected to on-board memory.
  * Platform is NoDMA.

Add/remove test iteration in ``test_sequence``:

.. code-block:: JSON

    {"duration": 5, "target": "<name>"}

For example, if HBM and DDR are supported, define:

.. code-block:: JSON

    {"duration": 10, "target": "DDR"},
    {"duration": 10, "target": "HBM"}

If memory CUs connected to HBM and DDR present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "dma": {
          "global_config": {
            "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
            "test_sequence": [
              {
                "duration": 10,
                "target": "DDR"
              },
              {
                "duration": 10,
                "target": "HBM"
              }
            ]
          }
        }
      }
    }

=====================================================
``p2p_nvme.json``
=====================================================

This pre-canned test only includes a P2P_NVME testcase:

  * Only the on-board memories shall be targeted.
  * All memory banks are tested as P2P source and as P2P target for 10 seconds.
  * All the on-board memories present in xclbin are referenced.
  * For NoDMA platforms, memory banks are only tested as P2P target.

File not included if:

  * xclbin does not support memory CU connected to on-board memory.
  * Platform does not support P2P.

Add/remove test iteration in ``test_sequence``:

.. code-block:: JSON

    {"duration": 5, "source": "<name>"},
    {"duration": 5, "target": "<name>"}

For example, if HBM and DDR are supported and if the platform is not NoDMA, define:

.. code-block:: JSON

    {"duration": 10, "source": "DDR"},
    {"duration": 10, "source": "HBM"},
    {"duration": 10, "target": "DDR"},
    {"duration": 10, "target": "HBM"}

If memory CUs connected to HBM and DDR present in xclbin and if the platform is not NoDMA:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "p2p_nvme": {
          "global_config": {
            "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
            "test_sequence": [
              {
                "duration": 10,
                "source": "DDR"
              },
              {
                "duration": 10,
                "source": "HBM"
              },
              {
                "duration": 10,
                "target": "DDR"
              },
              {
                "duration": 10,
                "target": "HBM"
              }
            ]
          }
        }
      }
    }

=====================================================
``p2p_card.json``
=====================================================

This pre-canned test only includes a P2P_CARD testcase:

  * Only the on-board memories shall be targeted.
  * All memory banks are tested as P2P source with default P2P target for 10 seconds.
  * All the on-board memories present in xclbin are referenced.

File not included if:

  * xclbin does not support memory CU connected to on-board memory.
  * Platform does not support P2P.
  * Platform is NoDMA.

Add/remove test iteration in ``test_sequence``:

.. code-block:: JSON

    {"duration": 5, "source": "<name>"}

For example, if HBM and DDR are supported, define:

.. code-block:: JSON

    {"duration": 10, "source": "DDR"},
    {"duration": 10, "source": "HBM"}

If memory CUs connected to HBM and DDR present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "p2p_card": {
          "global_config": {
            "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
            "test_sequence": [
              {
                "duration": 10,
                "source": "DDR"
              },
              {
                "duration": 10,
                "source": "HBM"
              }
            ]
          }
        }
      }
    }

=====================================================
``memory.json``
=====================================================

This pre-canned test only includes a memory testcase:

  * Only the on-board memories shall be targeted.
  * All supported values of ``test_sequence[].mode`` in memory testcase are tested for 20 seconds.
  * All the on-board memories present in xclbin are referenced.

File not included if:

  * xclbin does not support memory CU connected to on-board memory.

Add/remove ``testcases.memory.<name>`` node.

For example, if HBM and DDR are supported, define:

  * ``testcases.memory.HBM``
  * ``testcases.memory.DDR``

If memory CUs connected to HBM and DDR present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "memory": {
          "DDR": {
            "global_config": {
              "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
              "test_sequence": [
                {
                  "duration": 20,
                  "mode": "alternate_wr_rd"
                },
                {
                  "duration": 20,
                  "mode": "only_wr"
                },
                {
                  "duration": 20,
                  "mode": "only_rd"
                },
                {
                  "duration": 20,
                  "mode": "simultaneous_wr_rd"
                }
              ]
            }
          },
          "HBM": {
            "global_config": {
              "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
              "test_sequence": [
                {
                  "duration": 20,
                  "mode": "alternate_wr_rd"
                },
                {
                  "duration": 20,
                  "mode": "only_wr"
                },
                {
                  "duration": 20,
                  "mode": "only_rd"
                },
                {
                  "duration": 20,
                  "mode": "simultaneous_wr_rd"
                }
              ]
            }
          }
        }
      }
    }

=====================================================
``memory_host.json``
=====================================================

Same as memory pre-canned test but for **host** memory instead of **on-board** memory.

File not included if:

  * xclbin does not support memory CU connected to host memory.

If memory CUs connected to HOST present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "memory": {
          "HOST": {
            "global_config": {
              "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
              "test_sequence": [
                {
                  "duration": 20,
                  "mode": "alternate_wr_rd"
                },
                {
                  "duration": 20,
                  "mode": "only_wr"
                },
                {
                  "duration": 20,
                  "mode": "only_rd"
                },
                {
                  "duration": 20,
                  "mode": "simultaneous_wr_rd"
                }
              ]
            }
          }
        }
      }
    }

=====================================================
``power.json``
=====================================================

This pre-canned test only includes a power testcase:

  * Ramp of 4 steps of 100 seconds from 5 % to 20 % toggle rates.

File not included if:

  * xclbin does not support any power CU.

Do not edit.

If power CUs present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "power": {
          "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
          "global_config": {
            "test_sequence": [
              {
                "duration": 100,
                "toggle_rate": 5
              },
              {
                "duration": 100,
                "toggle_rate": 10
              },
              {
                "duration": 100,
                "toggle_rate": 15
              },
              {
                "duration": 100,
                "toggle_rate": 20
              }
            ]
          }
        }
      }
    }

=====================================================
``gt_mac.json``
=====================================================

This pre-canned test only includes a GT_MAC testcase:

  * Run with 25 GbE traffic then switched to 10 GbE traffic.
  * All the GT_MAC CUs present in xclbin are referenced.

File not included if:

  * xclbin does not support any GT_MAC CU.

Add/remove ``testcases.gt_mac.<gt index>`` nodes.

For example, if GT_MAC[0] and GT_MAC[1] are supported, define:

  * ``testcases.gt_mac.0``
  * ``testcases.gt_mac.1``

If 2 GT_MAC CUs present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "gt_mac": {
          "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
          "0": {
            "global_config": {
              "match_tx_rx": true,
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_25gbe_c74_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 10,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                },
                {
                  "duration": 1,
                  "mode": "conf_10gbe_c74_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 10,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                }
              ]
            }
          },
          "1": {
            "global_config": {
              "match_tx_rx": true,
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_25gbe_c74_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 10,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                },
                {
                  "duration": 1,
                  "mode": "conf_10gbe_c74_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 10,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                }
              ]
            }
          }
        }
      }
    }

=====================================================
``switch_10gbe.json``
=====================================================

This pre-canned test only includes a GT_MAC testcase:

  * The switch configuration is used.

      * To check that GT_MAC CUs can generate and receive valid 10GbE traffic when connected to a switch.
      * The traffic is loopbacked by the switch.

  * All the GT_MAC CUs present in xclbin are referenced.

File not included if:

  * xclbin does not support any GT_MAC CU.

xbtest has been validated with the following equipment:

  * |Switch Nexus 3232c|_
  * |Cables Cisco|_

      * QSFP-100G-CU3M - 100GBASE-CR4 Passive Copper Cable, 3m (10/25GbE Only).
      * QSFP-100G-AOC3M - 100GBASE QSFP Active Optical Cable, 3m (25GbE Only).

Add/remove ``testcases.gt_mac.<gt index>`` nodes.

For example, if GT_MAC[0] and GT_MAC[1] are supported, define:

  * ``testcases.gt_mac.0``
  * ``testcases.gt_mac.1``

If 2 GT_MAC CUs present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "gt_mac": {
          "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
          "0": {
            "global_config": {
              "match_tx_rx": true,
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_10gbe_no_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 60,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                }
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
          },
          "1": {
            "global_config": {
              "match_tx_rx": true,
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_10gbe_no_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 60,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                }
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
      }
    }

=====================================================
``switch_25gbe.json``
=====================================================

Same as switch_10gbe pre-canned test but for 25gbe instead of 10gbe.

GT_MAC CU configured with ``conf_25gbe_c74_fec`` instead of ``conf_10gbe_no_fec``.

File not included if:

  * xclbin does not support any GT_MAC CU.

If 2 GT_MAC CUs present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "gt_mac": {
          "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
          "0": {
            "global_config": {
              "match_tx_rx": true,
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_25gbe_c74_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 60,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                }
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
          },
          "1": {
            "global_config": {
              "match_tx_rx": true,
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_25gbe_c74_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 60,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                }
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
      }
    }

=====================================================
``gt_mac_lpbk.json``
=====================================================

This pre-canned test only includes GT_MAC and GT_LPBK testcases:

  * GT_MAC CUs are connected to GT_LPBK CUs with 25GbE traffic without FEC.
  * The GT MAC CU generates the traffic and it's loopback by the GT_LPBK CU.
  * All the GT_MAC and GT_LPBK CUs present in xclbin are referenced.

File not included if:

  * xclbin does not support any GT_MAC or any GT_LPBK CU.

xbtest has been validated with the following equipment:

  * |Cables Cisco|_

      * QSFP-100G-CU3M - 100GBASE-CR4 Passive Copper Cable, 3m (10/25GbE Only).
      * QSFP-100G-AOC3M - 100GBASE QSFP Active Optical Cable, 3m (25GbE Only).

Add/remove ``testcases.gt_mac.<gt index>`` and ``testcases.gt_lpbk.<gt index>`` nodes.

For example, if GT_MAC[0] and GT_LPBK[1] are supported, define:

  * ``testcases.gt_mac.0``
  * ``testcases.gt_lpbk.1``

If 1 GT_MAC CU and 1 GT_LPBK CU present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "gt_mac": {
          "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
          "0": {
            "global_config": {
              "match_tx_rx": true,
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_25gbe_no_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 60,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                }
              ]
            }
          }
        },
        "gt_lpbk": {
          "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
          "1": {
            "global_config": {
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_25gbe_no_fec"
                }
              ]
            }
          }
        }
      }
    }

=====================================================
``gt_mac_port_to_port.json``
=====================================================

This pre-canned test only includes GT_MAC testcases:

  * GT_MAC CUs are connected to other GT_MAC CUs.
  * Each GT MAC CU generates the traffic and it's checked by other GT_MAC CU.
  * Maximum number of pairs of GT_MAC CUs present in xclbin are referenced.

File not included if:

  * xclbin does not support >= 2 GT_MAC CUs.

xbtest has been validated with the following equipment:

  * |Cables Cisco|_

      * QSFP-100G-CU3M - 100GBASE-CR4 Passive Copper Cable, 3m (10/25GbE Only).
      * QSFP-100G-AOC3M - 100GBASE QSFP Active Optical Cable, 3m (25GbE Only).

Add/remove/update nodes ``testcases.gt_mac.<gt idx>`` to create port map using ``mac_to_mac_connection`` node (see example JSON file).

For example, if xclbin contains:

  * 2 GT_MAC CUs, define 1 pair

      * GT[0] <=> GT[1]

  * 3 GT_MAC CUs, define 1 pair

      * GT[0] <=> GT[1]
      * GT[2] not referenced

  * 4 GT_MAC CUs, define 2 pairs

      * GT[0] <=> GT[1]
      * GT[2] <=> GT[3]

  * 5 GT_MAC CUs, define 2 pairs

      * GT[0] <=> GT[1]
      * GT[2] <=> GT[3]
      * GT[4] not referenced

  * etc

If 2 GT_MAC CUs present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "gt_mac": {
          "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
          "0": {
            "global_config": {
              "match_tx_rx": true,
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_25gbe_c74_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 60,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                }
              ]
            }
          },
          "1": {
            "global_config": {
              "mac_to_mac_connection": 0
            }
          }
        }
      }
    }

=====================================================
``gt_prbs.json``
=====================================================

If 1 GT_PRBS CU present in xclbin:

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "gt_prbs": {
          "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
          "0": {
            "global_config": {
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_25gbe"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 30,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "read_status"
                }
              ]
            }
          }
        }
      }
    }

=====================================================
``stress.json``
=====================================================

This pre-canned test combines memory, power, GT_MAC and GT_PRBS testcases:

  * **Duration**: longer (typically 300 seconds).
  * **Power testcase** : toggle rate set to 10%.
  * **Memory testcase**: ``alternate_wr_rd`` mode.
  * **GT_MAC testcase**: switch settings at 25GbE (similar as ``switch_25gbe.json``).
  * **GT_PRBS testcase**.

File not included if:

  * xclbin does not support any memory CU connected to on-board memory, any power and GT_MAC CUs.

Add/remove ``testcases.power``, on-board memory ``testcases.memory.<name>`` and ``testcases.gt_mac.<gt index>`` nodes.

For example, if power / HBM and DDR / GT_MAC[0] and GT_PRBS[1] are supported, define:

  * ``testcases.power``
  * ``testcases.memory.HBM``
  * ``testcases.memory.DDR``
  * ``testcases.gt_mac.0``
  * ``testcases.gt_prbs.1``

.. code-block:: JSON

    {
      "comment": [
        "This is an example of test JSON file",
        "You can use this example as template for your own tests",
        "Please refer to the User Guide for how to define or add/remove testcases",
        "Comments can be added or removed anywhere in test JSON file"
      ],
      "testcases": {
        "power": {
          "comment": "Update toggle rate according to your test environment)",
          "global_config": {
            "test_sequence": [
              {
                "duration": 300,
                "toggle_rate": 10
              }
            ]
          }
        },
        "memory": {
          "DDR": {
            "global_config": {
              "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
              "test_sequence": [
                {
                  "duration": 300,
                  "mode": "alternate_wr_rd"
                }
              ]
            }
          },
          "HBM": {
            "global_config": {
              "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
              "test_sequence": [
                {
                  "duration": 300,
                  "mode": "alternate_wr_rd"
                }
              ]
            }
          }
        },
        "gt_prbs": {
          "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
          "1": {
            "global_config": {
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_25gbe"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 300,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                }
              ]
            }
          }
        },
        "gt_mac": {
          "comment": "Use comment to detail your test if necessary (you can also remove this comment)",
          "0": {
            "global_config": {
              "match_tx_rx": true,
              "test_sequence": [
                {
                  "duration": 1,
                  "mode": "conf_25gbe_c74_fec"
                },
                {
                  "duration": 1,
                  "mode": "clear_status"
                },
                {
                  "duration": 300,
                  "mode": "run"
                },
                {
                  "duration": 1,
                  "mode": "check_status"
                }
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
      }
    }
