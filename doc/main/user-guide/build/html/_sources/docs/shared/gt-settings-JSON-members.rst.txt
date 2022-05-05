
=====================================================
GT settings test JSON members
=====================================================

For the 3 types of GT test cases, the GT settings can be defined in a similar manner

* For the 4 lanes simultaneously: part of the ``global_config``

    * Select one of the pre-defined configurations (``gt_settings``). 
      The various configurations are stored in the platform definition file (see :ref:`ug-platform-definition`).
    * Overwrite any settings of the selected configuration.

* For each lane individually: overwrite any settings of the selected configuration. Part of the ``lane_config``

If required, these settings are simply added to your test JSON file within your test case definition.
Here is an example with global selection, but it also includes global and per-lane specific overwrites.

.. code-block:: JSON

    "gt_mac / gt_prbs / gt_lpbk": {
      "0": {
        "global_config": {
          "gt_settings": "module",
          "gt_rx_use_lpm": true
        },
        "lane_config": {
          "0": {
            "gt_rx_use_lpm": false,
            "gt_tx_diffctrl": 11
          },
          "1": {
            "gt_tx_main_cursor": 80
          },
          "2": {
            "gt_tx_pre_emph": 2,
          },
          "3": {
            "gt_tx_post_emph": 3,
          }
        }
      }
    }