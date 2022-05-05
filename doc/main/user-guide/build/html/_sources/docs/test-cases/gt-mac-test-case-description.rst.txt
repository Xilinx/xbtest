
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _gt-mac-test-case-description:

##########################################################################
GT MAC test case description
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2

The goal of this test case is to allow verification of GT transceivers on |Alveo|_ cards at 10GbE and 25GbE lane rates.
Each GT transceiver supports 4 lanes.

This compute unit (CU) instantiates the 10G/25G High Speed Ethernet Subsystem IP core and allows the core to be configured from a Test JSON file
(see |PG210|_).
GT MAC traffic is layer 2 type traffic:

  * Ethertype: 0x88b5, local traffic only.
  * Source and Destination MAC addresses are inserted.
  * No IP address is present as there is no layer 3.

In case of multiple CUs, the rate can be select individually per CU, but the selected rate applies to the 4 lanes of the CU.

The CU includes a packet generator, which allows a card with simple electrical or optical loopback cables to generate packets.
The CU also verify that the generated packets have been received back, error free. The packet generator can be configured for each lane individually.

The CU also includes a sets of packet counters, which counts, per lane, the quantity of packets and bytes transmitted and received with the expected source and destination MAC addresses.

.. figure:: ../diagram/gt_mac-block_diagram.svg
    :align: center

    GT MAC CU block diagram

.. _gt-mac-test-set-up:

********************************************************
GT test set up
********************************************************

GT testing can be achieved by using one of the following methods.

  * Loopback electrical or optical:

      * The use of a QSFP passive electrical loopback module. The module must be compliant to 100GbE (25GbE per lane) and have 0 dB insertion loss.
        This is the preferred method, the GTs having been validated using a QSFP28 module provided by MultiLane (|ML4002-28-C5|_).

        .. note::
            This module also has the capability of providing a QSFP temperature reading and a programmable power dissipation up to 5W. However, these are not required to pass the GT tests.

      * The use of a QSFP optical module with suitably connected fiber loopback. The module must be compatible with the traffic rate being tested.

        .. note::
            This is an active component the electrical interface between the GTs and the module will need to be validated to ensure optimum performance.

  * Connected to a switch

  * Connected to another GT MAC CU present on the same board

  * Connected to GT LPBK CU (see :ref:`gt-lpbk-test-case-description`).

  * The use of a protocol analyzer with a compatible electrical or optical interface.
    This is the most complex method of connection as not only will the interfaces require validation with the GTs, the RX and TX paths will be independent.
    The test JSON file needs to be modified to reflect that the RX and TX packet/byte counts might not be the same.

.. warning::
    The configuration of the |GT MAC| test case depends on the set up (see :ref:`gt-mac-test-json-members`).

=====================================================
Switch set up
=====================================================

xbtest has been validated with the following Cisco hardware:

  * |Switch Nexus 3232c|_
  * |Cables Cisco|_

      * **10/25GbE**: QSFP-100G-CU3M - 100GBASE-CR4 Passive Copper Cable, 3m.
      * **25GbE**: QSFP-100G-AOC3M - 100GBASE QSFP Active Optical Cable, 3m.

The following is the switch configuration:

  * **port 1 - 16**: 10GbE; no FEC.
  * **port 17 - 32**: 25GbE; clause 74 FEC.

The configuration can be obtained via the following command:

.. code-block:: bash

    $ interface breakout module 1 port 1-16 map 10g-4x
    $ interface breakout module 1 port 17-32 map 25g-4x

.. table:: Example of switch port configuration

    +--------------------------------------------------------------------+-------------------------------------------------------------------+
    | 10GbE Port 1                                                       | 25GbE Port 17                                                     |
    +====================================================================+===================================================================+
    |                                                                    |                                                                   |
    | * **Interface Ethernet1/1/1**:                                     | * **Interface Ethernet1/17/1**:                                   |
    |                                                                    |                                                                   |
    |   * Switchport.                                                    |   * Switchport.                                                   |
    |   * Switchport access VLAN 3000.                                   |   * Switchport access VLAN 3000.                                  |
    |   * Spanning-tree port type edge.                                  |   * Spanning-tree port type edge.                                 |
    |   * Spanning-tree bpduguard enable.                                |   * Spanning-tree bpduguard enable.                               |
    |   * MTU 9216.                                                      |   * MTU 9216.                                                     |
    |   * Speed 10000.                                                   |   * Speed 25000.                                                  |
    |   * Duplex full.                                                   |   * FEC FC-FEC                                                    |
    |   * No shutdown.                                                   |   * No shutdown.                                                  |
    |                                                                    |                                                                   |
    | * **Interface Ethernet1/1/2**: Identical to **Ethernet1/1/1**.     | * **Interface Ethernet1/17/2**: Identical to **Ethernet1/17/1**.  |
    | * **Interface Ethernet1/1/3**: Identical to **Ethernet1/1/1**.     | * **Interface Ethernet1/17/3**: Identical to **Ethernet1/17/1**.  |
    | * **Interface Ethernet1/1/4**: Identical to **Ethernet1/1/1**.     | * **Interface Ethernet1/17/4**: Identical to **Ethernet1/17/1**.  |
    |                                                                    |                                                                   |
    +--------------------------------------------------------------------+-------------------------------------------------------------------+

.. note::
    The switch port should be on their own VLAN to avoid traffic leak/broadcast.

=====================================================
Source MAC address
=====================================================

The source MAC addresses of the card can be obtained via the following command:

.. code-block:: bash

    xbutil examine --device <BDF> --report platform

The GT MAC CU uses all valid source MAC addresses (one per lane).
If multiple GT MAC CUs are present in the |xclbin|, they'll split all valid MAC addresses in a round robin manner over all lanes of all GT MAC CU's.

.. table:: Source MAC address round robin selection

    +-------------------+---------------+
    | MAC address index | GT/lane index |
    +===================+===============+
    | 0                 | GT[0] Lane 0  |
    +-------------------+---------------+
    | 1                 | GT[1] Lane 0  |
    +-------------------+---------------+
    | 2                 | GT[0] Lane 1  |
    +-------------------+---------------+
    | 3                 | GT[1] Lane 1  |
    +-------------------+---------------+
    | 4                 | GT[0] Lane 2  |
    +-------------------+---------------+
    | ...               | ...           |
    +-------------------+---------------+

If there are not enough valid MAC addresses, lanes will be disabled following the same round robin manner.
In the table above, if MAC address index 4 is the last one available, GT[0] lane 3 and GT[1] lanes 2/3 will be disabled.
It's possible to re-organize the MAC address distribution of the GT via the :ref:`gt-mac-parameter-source_addr` option.
Source MAC addresses are displayed with message ID ``ETH_031``.

=====================================================
Destination MAC address - Lane mapping
=====================================================

The destination MAC addresses are defined via the lane mapping.
By default, each lane is configured loop back to itself.
So, per lane, the destination MAC address is identical to the Source MAC address.
This default mapping is the one to use with loopback module as each lane is physically loopbacked to itself.
Destination MAC addresses are displayed with message ID ``ETH_031``.

When using a switch, lane traffic can't be loopback to itself, source and destination MAC addresses must be different.
xbtest only supports paired mapping lanes in order to compare RX status with TX status.

.. table:: Supported lane mapping

    +---------+-----------------+-----------+-----------+-----------+
    |         | Loopback module | Switch                            |
    + Source  +-----------------+-----------+-----------+-----------+
    |         | Default pairing | Pairing A | Pairing B | Pairing C |
    +=========+=================+===========+===========+===========+
    | Lane[0] | Lane[0]         | Lane[1]   | Lane[2]   | Lane[3]   |
    +---------+-----------------+-----------+-----------+-----------+
    | Lane[1] | Lane[1]         | Lane[0]   | Lane[3]   | Lane[2]   |
    +---------+-----------------+-----------+-----------+-----------+
    | Lane[2] | Lane[2]         | Lane[3]   | Lane[0]   | Lane[1]   |
    +---------+-----------------+-----------+-----------+-----------+
    | Lane[3] | Lane[3]         | Lane[2]   | Lane[1]   | Lane[0]   |
    +---------+-----------------+-----------+-----------+-----------+

The mapping is defined using :ref:`gt-mac-parameter-tx_mapping` option. Here is how the switch pairing A is configured in the test JSON file:

.. code-block:: JSON

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

.. caution::
    When connected to switch, the lane mapping must be defined in pair in order to be able to cross check RX and TX status counters.


Although destination addresses are automatically selected based on :ref:`gt-mac-parameter-tx_mapping`, it's possible to overwrite it with :ref:`gt-mac-parameter-dest_addr` member.

=====================================================
Lane enabling
=====================================================
For a lane to be used/enabled, it must have valid source and destination addresses:

* When the lane is looped back to itself, this means that only one valid address is required.
* When lanes are paired, both need to have a valid MAC Address, otherwise both will be disabled.
  So, if e.g. Lane[0] and Lane[3] are paired but only 1 lane gets a valid address, both lanes will be disabled.

You can overwrite lane MAC address via :ref:`gt-mac-parameter-source_addr` and :ref:`gt-mac-parameter-dest_addr`.

You can also disable a lane via :ref:`gt-mac-parameter-disable_lane`. If the disabled lane is paired, both lanes will be disabled.

.. note::
    When you get un-expected disabled lanes, check MAC address reported by xbtest and their lane attribution (alongside the lane pairing).

=====================================================
GT MAC CU to GT MAC CU connection
=====================================================

When the same |xclbin| contains 2 GT MAC CUs, they can be connected via cable (or optical fibre).
In this case, only one GT MAC CU must have its :ref:`gt-mac-parameter-test_sequence` defined, while the other one must use :ref:`gt-mac-parameter-mac_to_mac_connection` and point it to other one index.

See :ref:`gt-mac-gt-mac-interconnections` for usage example.

.. _gt-mac-gt-settings:

.. include:: ../shared/gt-settings.rst

********************************************************
Main test steps
********************************************************

A test is generally composed of four steps and a definition of the hardware environment (see :ref:`gt-mac-test-json-members`). The following are typical test steps:

  1. Configuration.
  2. Clear status.
  3. Run.
  4. Report/check status.


.. note::
    Under some circumstances the packet generator might not be able to send packets at the requested rate. This is most likely to occur when operating at 25GbE and with small packets (for example < 128-bytes packet). Reducing the number of active MACs and/or increasing the packet size should allow the maximum rate to be achieved (see :ref:`gt-mac-test-json-members`).

.. warning::

      * By default, after |xclbin| downloads, the GT MAC CU generates IDLE packets at 25GbE rate.
      * When the test sequence is over, the GT MAC CU continues to send traffic as per its last configuration.


========================================================
Test parameters
========================================================

The mandatory test configuration parameters are listed below.
For more information, see :ref:`gt-mac-test-json-members`.

  * |gt-mac-duration|: The duration of the test, measured in seconds.
  * |gt-mac-mode|: Mode of the compute unit.

.. _status:

********************************************************
Status
********************************************************

GT MAC CU provides 3 kind of status/counters:

  * A subset of the status registers from the 10G/25G High Speed Ethernet Subsystem IP core (see |PG210|_). Some status are reported as information (counter registers), others are checked against a null value (error register).
  * An indication that the quantity of bytes and packets transmitted is within a range based on the test |gt-mac-duration| and |gt-mac-mode| (lane rate), :ref:`gt-mac-parameter-utilisation`, and :ref:`gt-mac-parameter-packet_cfg` configurations.
  * A comparison between the quantity of packets and bytes sent by a lane and received by its destination lane. Per lane, the packet receiver checks the source and destination MAC address for each packet received. This is only enabled when :ref:`gt-mac-parameter-match_tx_rx` is set to ``true``.

=====================================================
Matching TX RX
=====================================================

The optional parameter :ref:`gt-mac-parameter-match_tx_rx` causes comparison between some registers of the 10G/25G High Speed Ethernet Subsystem IP core:

  * ``RX_TOTAL_GOOD_PACKETS`` with ``TX_TOTAL_PACKETS``.
  * ``RX_TOTAL_GOOD_BYTES`` with ``TX_TOTAL_BYTES``.

The packet receiver also compares the quantity of packets and bytes sent (``TX_TOTAL_PACKETS``, ``TX_TOTAL_BYTES``) with their respective received quantities when source and destination MAC addresses are matching. :ref:`gt-mac-parameter-tx_mapping` option defines which lane values are compared together.

In addition, if the ``RX_TOTAL_GOOD_PACKETS`` count is equal to 0, then an error message ID ``ETH_007`` is reported to inform that no good packets were received, and the test will fail.

=====================================================
MAC_STAT status registers description
=====================================================

Each time the ``check_status`` command is executed, the following registers are read from the MAC hardware for each active MAC lane.
All registers are stored in hardware using 48 bits and extended to 64 bits when read by software.

.. note::
    The 48-bit counters ``RX_TOTAL_BYTES``, ``RX_TOTAL_GOOD_BYTES`` and ``TX_TOTAL_BYTES`` could saturate after approximately 25 hours of maximum rate operation at 25GbE.

It is therefore recommended that the test |gt-mac-duration| does not exceed 24 hours between two ``check_status`` test |gt-mac-mode|.

In the table following table, the register type column represents how the register is verified:

  * **Check**: The content of the register must be null. Any other value will generate an error (message ID ``ETH_004``).
  * **Info**: The content of the register is displayed as information (no verification performed).

.. table:: ``MAC_STAT`` status description

    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | Register name                   | Register type | Description                                                                                                               |
    +=================================+===============+===========================================================================================================================+
    | ``CYCLE_COUNT``                 | Info          | Number of transceiver clock domain cycles (approximately 1.5625e8 / sec at 10GbE and 3.90612e8 / sec at 25GbE).           |
    |                                 |               |                                                                                                                           |
    |                                 |               | .. note::                                                                                                                 |
    |                                 |               |     A value of 0 means that clocks were not active during the test and other registers should be ignored.                 |
    |                                 |               |     Any non-zero result indicates the clocks were active.                                                                 |
    |                                 |               |                                                                                                                           |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``FEC_INC_CANT_CORRECT_COUNT``  | Check         | This count indicates how many uncorrected bit errors in the corresponding Clause 74 FEC Frame.                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``FEC_INC_CORRECT_COUNT``       | Check         | This count indicates how many corrected bit errors in the corresponding Clause 74 FEC Frame.                              |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_BAD_CODE``                 | Check         | This count indicates how many cycles the RX PCS receive state machine is in the RX_E state as defined by IEEE Std. 802.3. |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_BAD_FCS``                  | Check         | The value of this count indicates packets received with a bad FCS, but not a stomped FCS.                                 |
    |                                 |               | A stomped FCS is defined as the bitwise inverse of the expected good FCS.                                                 |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_BROADCAST``                | Info          | Increment for good broadcast packets.                                                                                     |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_ERROR``                    | Check         | This count indicates a mismatch occurred for the test pattern in the RX core.                                             |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_FRAGMENT``                 | Check         | Increment for packets shorter than ``stat_rx_min_packet_len`` with bad FCS.                                               |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_FRAMING_ERR``              | Check         | This count is used to keep track of sync header errors.                                                                   |
    |                                 |               | The ``stat_rx_framing_err`` output indicates how many sync header errors were received.                                   |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_INRANGEERR``               | Check         | Increment for packets with Length field error but with good FCS.                                                          |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_JABBER``                   | Check         | Increment for packets longer than ``ctl_rx_max_packet_len`` with bad FCS.                                                 |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_MULTICAST``                | Info          | Increment for good multicast packets.                                                                                     |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_OVERSIZE``                 | Check         | Increment for packets longer than ``ctl_rx_max_packet_len`` with good FCS.                                                |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_64_BYTES``          | Info          | Increment for good and bad packets received that contain 64 bytes.                                                        |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_65_127_BYTES``      | Info          | Increment for good and bad packets received that contain 65 to 127 bytes.                                                 |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_128_255_BYTES``     | Info          | Increment for good and bad packets received that contain 128 to 255 bytes.                                                |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_256_511_BYTES``     | Info          | Increment for good and bad packets received that contain 256 to 511 bytes.                                                |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_512_1023_BYTES``    | Info          | Increment for good and bad packets received that contain 512 to 1,023 bytes.                                              |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_1024_1518_BYTES``   | Info          | Increment for good and bad packets received that contain 1,024 to 1,518 bytes.                                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_1519_1522_BYTES``   | Info          | Increment for good and bad packets received that contain 1,519 to 1,522 bytes.                                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_1523_1548_BYTES``   | Info          | Increment for good and bad packets received that contain 1,523 to 1,548 bytes.                                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_1549_2047_BYTES``   | Info          | Increment for good and bad packets received that contain 1,549 to 2,047 bytes.                                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_2048_4095_BYTES``   | Info          | Increment for good and bad packets received that contain 2,048 to 4,095 bytes.                                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_4096_8191_BYTES``   | Info          | Increment for good and bad packets received that contain 4,096 to 8,191 bytes.                                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_8192_9215_BYTES``   | Info          | Increment for good and bad packets received that contain 8,192 to 9,215 bytes.                                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_BAD_FCS``           | Check         | Increment for packets between 64 and ``ctl_rx_max_packet_len`` bytes that have FCS errors.                                |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_LARGE``             | Info          | Increment for all packets that are more than 9,215 bytes long.                                                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PACKET_SMALL``             | Check         | Increment for all packets that are less than 64 bytes long.                                                               |
    |                                 |               | Packets that are less than 4 bytes are dropped.                                                                           |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_PAUSE``                    | Info          | Increment for 802.3x Ethernet MAC Pause packet with good FCS.                                                             |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_RSFEC_CORRECTED_CW_INC``   | Check         | This count will increment if the RS-FEC decoder detected and corrected a bit errors in the corresponding frame.           |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_RSFEC_ERR_COUNT0_INC``     | Check         | Increment for RS-FEC detected errors.                                                                                     |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_RSFEC_UNCORRECTED_CW_INC`` | Check         | This count will increment if the RS-FEC decoder detected uncorrectable bit errors in the corresponding frame.             |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_STOMPED_FCS``              | Check         | The value of this count indicates packets were received with a stomped FCS.                                               |
    |                                 |               | A stomped FCS is defined as the bitwise inverse of the expected good FCS.                                                 |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_TEST_PATTERN_MISMATCH``    | Check         | This count indicates how many mismatches occurred for the test pattern in the RX core.                                    |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_TOOLONG``                  | Check         | Increment for packets longer than ``ctl_rx_max_packet_len`` with good and bad FCS.                                        |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_TOTAL_BYTES``              | Info          | Increment for the total number of bytes received.                                                                         |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_TOTAL_GOOD_BYTES``         | Info          | Increment for the total number of good bytes received.                                                                    |
    |                                 |               | This value is only non-zero when a packet is received completely and contains no errors.                                  |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_TOTAL_GOOD_PACKETS``       | Info          | Increment for the total number of good packets received.                                                                  |
    |                                 |               | This value is only non-zero when a packet is received completely and contains no errors.                                  |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_TOTAL_PACKETS``            | Info          | Increment for the total number of packets received.                                                                       |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_TRUNCATED``                | Check         | This count indicates that the number of packets truncated due to their length exceeding ``ctl_rx_max_packet_len[14:0]``.  |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_UNDERSIZE``                | Check         | Increment for packets shorter than ``stat_rx_min_packet_len`` with good FCS.                                              |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_UNICAST``                  | Info          | Increment for good unicast packets.                                                                                       |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_USER_PAUSE``               | Info          | Increment for priority-based pause packets with good FCS.                                                                 |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``RX_VLAN``                     | Info          | Increment for good 802.1Q tagged VLAN packets.                                                                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``TX_TOTAL_BYTES``              | Info          | Increment for the total number of bytes transmitted by the packet generator.                                              |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+
    | ``TX_TOTAL_PACKETS``            | Info          | Increment for the total number of packets transmitted by the packet generator.                                            |
    +---------------------------------+---------------+---------------------------------------------------------------------------------------------------------------------------+

.. _gt-mac-test-json-members:

********************************************************
GT MAC test JSON members
********************************************************

Following are examples of |GT MAC| test cases.
Some test JSON members can be overwritten for each lane using the test JSON member ``lane_config`` which child members are lane indexes.

----

=====================================================
Electrical/optical loopback example
=====================================================

.. note::
    The default TX/RX lane mapping is used with loopback module.

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
    }

----

=====================================================
Switch example
=====================================================

.. note::
    Lane pairing must be used when connected to a switch.

Here is an example of 2 GT CUs:

  * GT[0] is connected to a 10GbE port with a fixed packet size of 1024 bytes.
  * GT[1] is a 25GbE with the default ``sweep`` packet size.

.. code-block:: JSON

    "gt_mac": {
      "0": {
        "global_config": {
          "match_tx_rx": true,
          "packet_cfg": "1024",
          "test_sequence" : [
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
      },
      "1": {
        "global_config": {
          "match_tx_rx": true,
          "test_sequence": [
            { "duration":  1, "mode": "conf_25gbe_c74_fec" },
            { "duration":  1, "mode": "clear_status"       },
            { "duration": 60, "mode": "run"                },
            { "duration":  1, "mode": "check_status"       }
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

.. _gt-mac-gt-mac-interconnections:

=====================================================
GT MAC to GT MAC connection example
=====================================================

Here is an example of GT MAC interconnection. Both CU must be in the same |xclbin|. gt_mac[1] is connected linked to gt_mac[0] via :ref:`gt-mac-parameter-mac_to_mac_connection`.

In this example:

  * To avoid some lanes being automatically disabled by the SW (as there are not enough MAC address available), :ref:`gt-mac-parameter-source_addr-test_address` is used for :ref:`gt-mac-parameter-source_addr`.
  * :ref:`gt-mac-parameter-match_tx_rx` is used, meaning that at the top of checking that sending and receiving traffic is errorless, each GT MAC CU lane will also verify that it receives the expected quantity of packets and bytes based on the traffic definition and lane mapping of the other GT MAC CU lane.

.. note::
    only one test_sequence is defined

.. code-block:: JSON

    "gt_mac": {
      "0": {
        "global_config": {
          "match_tx_rx": true,
          "test_sequence" : [
            {"duration": 1, "mode": "conf_25gbe_c74_fec" },
            {"duration": 1, "mode": "clear_status"       },
            {"duration": 10, "mode": "run"               },
            {"duration": 1, "mode": "check_status"       },

            {"duration": 1, "mode": "conf_10gbe_no_fec"  },
            {"duration": 1, "mode": "clear_status"       },
            {"duration": 10, "mode": "run"               },
            {"duration": 1, "mode": "check_status"       }
          ]
        },
        "lane_config": {
          "0": {
            "tx_mapping" : 0
          },
          "1": {
            "tx_mapping" : 1,
            "source_addr": "test_address"
          },
          "2": {
            "tx_mapping" : 2,
            "source_addr": "test_address"
          },
          "3": {
            "tx_mapping" : 3,
            "source_addr": "test_address"
          }
        }
      },
      "1": {
        "global_config": {
          "mac_to_mac_connection": 0
        },
        "lane_config": {
          "1": {
            "source_addr": "test_address"
          },
          "2": {
            "source_addr": "test_address"
          },
          "3": {
            "source_addr": "test_address"
          }
        }
      }
    }

Cross connection even works through a switch. The traffic is sent to a different GT (thus different mac address), so even with default tx_mapping (lane 0 to lane 0, as per example above), the traffic will be flow (as the switch will see different source and destination addresses).

You can still change the default lane pairing configuration. Compared to pre-canned switch test, you're not limited to the 3 pairing A/B/C. As you target another GT, you can freely pair lanes.

.. code-block:: JSON

    "lane_config": {
        "0": {
            "tx_mapping" : 1
        },
        "1": {
            "tx_mapping" : 3
        },
        "2": {
            "tx_mapping" : 0
        },
        "3": {
            "tx_mapping" : 2
        }
    }

----

=====================================================
Definition
=====================================================

The following table shows all members available for this test case.
More details are provided for each member in the subsequent sections.

.. table:: GT MAC Test JSON members

    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | Member                                            | Lane override | Mandatory / optional | Description                                                   |
    +===================================================+===============+======================+===============================================================+
    | :ref:`gt-mac-parameter-test_sequence`             | No            | Mandatory            | Describes the sequence of tests to perform.                   |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-tx_mapping`                | Only          | Optional             | Specify lane mapping. It defines:                             |
    |                                                   |               |                      |                                                               |
    |                                                   |               |                      | * Destination MAC address.                                    |
    |                                                   |               |                      | * TX lane index which will be checked against RX status.      |
    |                                                   |               |                      |                                                               |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-disable_lane`              | Only          | Optional             | Disable a lane.                                               |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-source_addr`               | Only          | Optional             | Overwrite default source MAC address - lane mapping.          |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-dest_addr`                 | Only          | Optional             | Overwrite default destination MAC address.                    |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-utilisation`               | Yes           | Optional             | Transmit utilisation.                                         |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-traffic_type`              | Yes           | Optional             | Define the content of the payload area of the packets.        |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-packet_cfg`                | Yes           | Optional             | Define the packet length.                                     |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-match_tx_rx`               | Yes           | Optional             | Enable RX and TX packet count match when loopback is present. |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-mac_to_mac_connection`     | Yes           | Optional             | Enable GT MAC CUs connections.                                |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-gt_settings`               | No            | Optional             | Selects the GT default configuration.                         |
    |                                                   |               |                      | See |GT MAC JSON Member|.                                     |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-gt_tx_diffctrl`            | Yes           | Optional             | Select the Driver Swing Control.                              |
    |                                                   |               |                      | See |GT MAC JSON Member|.                                     |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-gt_tx_pre_emph`            | Yes           | Optional             | Select Transmitter pre-cursor TX pre-emphasis control.        |
    |                                                   |               |                      | See |GT MAC JSON Member|.                                     |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-gt_tx_post_emph`           | Yes           | Optional             | Select Transmitter post-cursor TX pre-emphasis control.       |
    |                                                   |               |                      | See |GT MAC JSON Member|.                                     |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-gt_tx_polarity`            | Yes           | Optional             | Select TX Polarity.                                           |
    |                                                   |               |                      | See |GT MAC JSON Member|.                                     |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+
    | :ref:`gt-mac-parameter-gt_rx_use_lpm`             | Yes           | Optional             | Select RX Equalizer.                                          |
    |                                                   |               |                      | See |GT MAC JSON Member|.                                     |
    +---------------------------------------------------+---------------+----------------------+---------------------------------------------------------------+

----

.. _gt-mac-parameter-test_sequence:

=====================================================
``test_sequence``
=====================================================

Mandatory. Describes the sequence of tests to perform.
Tests are performed serially, and a failure in one test does not stop the sequence (the next test will be launched).
There is no limitation to the length of the test sequence.

This field contains a list of tests, each test being defined by an object of key–value parameters pairs: ``[ {}, {}, {} ]``.

The following table defines the parameters supported in the GT MAC test sequence:

.. _gt-mac-parameter-test_sequence-duration:
.. _gt-mac-parameter-test_sequence-mode:

.. table:: GT MAC test sequence parameters

    +-------------------+----------------------+------------------------------------------------------------------+
    | Member            | Mandatory / optional | Description                                                      |
    +===================+======================+==================================================================+
    | ``duration``      | Mandatory            | The duration of the test in seconds; Range [1, 2\ :sup:`32`\-1]. |
    +-------------------+----------------------+------------------------------------------------------------------+
    | ``mode``          | Mandatory            | Mode of the compute unit. See the following table.               |
    +-------------------+----------------------+------------------------------------------------------------------+

.. table:: ``mode`` possible values

    +------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Possible value   | Description                                                                                                                                                |
    +==================+============================================================================================================================================================+
    | ``conf_<mode>``  | Apply the settings specified in the configuration parameters to the MAC hardware.                                                                          |
    |                  | Part of the configuration process is to issue a reset to the MAC hardware,                                                                                 |
    |                  | so the ``conf_<mode>`` operation will always result in the Ethernet link dropping and restarting,                                                          |
    |                  | even if the configuration is identical to the previous test.                                                                                               |
    |                  |                                                                                                                                                            |
    |                  | Configurations are available for various lane rates and Forward Error Correction (FEC) modes:                                                              |
    |                  |                                                                                                                                                            |
    |                  |   * **Lane rates**:                                                                                                                                        |
    |                  |                                                                                                                                                            |
    |                  |       * **10GbE**: 10.3125 Gb/s.                                                                                                                           |
    |                  |       * **25GbE**: 25.78125 Gb/s.                                                                                                                          |
    |                  |                                                                                                                                                            |
    |                  |   * **FEC modes**:                                                                                                                                         |
    |                  |                                                                                                                                                            |
    |                  |       * **none**: Disables FEC and uses 66-b words with 2-bit sync headers.                                                                                |
    |                  |       * **clause_74**: Enables the FEC specified in IEEE 802.3 Clause 74.                                                                                  |
    |                  |         It can be used for both 10GbE and 25GbE lane rates.                                                                                                |
    |                  |       * **rs_fec**: Enables the FEC specified in IEEE 802.3by Clause 91.                                                                                   |
    |                  |         It can only be used in 25GbE mode.                                                                                                                 |
    |                  |                                                                                                                                                            |
    |                  | Possible values of ``conf_<mode>`` are:                                                                                                                    |
    |                  |                                                                                                                                                            |
    |                  |   * ``conf_10gbe_no_fec``: Lane rate: **10GbE**, FEC mode: **none**.                                                                                       |
    |                  |   * ``conf_10gbe_c74_fec``: Lane rate: **10GbE**, FEC mode: **clause_74**.                                                                                 |
    |                  |   * ``conf_25gbe_no_fec`` : Lane rate: **25GbE**, FEC mode: **none**.                                                                                      |
    |                  |   * ``conf_25gbe_c74_fec``: Lane rate: **25GbE**, FEC mode: **clause_74**.                                                                                 |
    |                  |   * ``conf_25gbe_rs_fec``: Lane rate: **25GbE**, FEC mode: **rs_fec**.                                                                                     |
    |                  |                                                                                                                                                            |
    |                  | .. warning::                                                                                                                                               |
    |                  |     Most of the |xclbin| don't include the **rs_fec**, as it takes a lot of resources.                                                                     |
    |                  |     The SW detects the presence of the **rs_fec** and will let you aware if it's not supported.                                                            |
    |                  |                                                                                                                                                            |
    |                  | .. warning::                                                                                                                                               |
    |                  |     The switch only supports ``conf_10gbe_no_fec`` or ``conf_25gbe_c74_fec``                                                                               |
    |                  |     (see :ref:`gt-mac-test-set-up`)                                                                                                                        |
    |                  |                                                                                                                                                            |
    +------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``clear_status`` | Read and clear the MAC status registers, but ignore the values returned in the counters.                                                                   |
    |                  | It is intended to be used after a ``conf_<mode>`` operation to clear the status errors caused by the link dropping and restarting.                         |
    +------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``run``          | Enable the packet generator.                                                                                                                               |
    |                  | Any test sequence entry without a run will disable the packet generator.                                                                                   |
    |                  | If the final :ref:`gt-mac-parameter-test_sequence` entry contains a ``run`` then packet generation will continue after execution of xbtest has terminated. |
    +------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``check_status`` | Read the MAC status registers, and for any MAC instances that have not been disabled (:ref:`gt-mac-parameter-disable_lane`)                                |
    |                  | Check for any counter values that indicate an error has occurred, or the received number of packets indicates a fault on the link.                         |
    |                  | If an error is detected the overall test will be flagged as a fail.                                                                                        |
    +------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | ``<dir>_rst``    | Initiate a reset of the MAC TX and/or RX path.                                                                                                             |
    |                  | Possible values of ``<dir>_rst`` are:                                                                                                                      |
    |                  |                                                                                                                                                            |
    |                  |   * ``tx_rst``: MAC TX reset.                                                                                                                              |
    |                  |   * ``rx_rst``: MAC RX reset.                                                                                                                              |
    |                  |   * ``tx_rx_rst``: MAC TX followed by MAC RX reset 10ms after.                                                                                             |
    |                  |                                                                                                                                                            |
    +------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------+

An example of a :ref:`gt-mac-parameter-test_sequence` is:

.. code-block:: JSON

    "test_sequence": [
      { "duration":  1, "mode": "conf_10gbe_no_fec" },
      { "duration":  1, "mode": "clear_status"      },
      { "duration": 60, "mode": "run"               },
      { "duration":  1, "mode": "check_status"      }
    ]

This will:

* Apply the configuration to the MACs, reset them and wait for 1 second.
* Wait for 1 second then clear the status registers.
* Start the packet generators for any active MACs and wait for 60 seconds.
* Wait for 1 second before reading the status registers and check the results. Then, clear the status registers, stop the packet generator and exit.

----

.. _gt-mac-parameter-tx_mapping:

=====================================================
``tx_mapping``
=====================================================

Optional;
Type           : integer;
Possible values: 0 to 3;
Default        : ``n`` where ``n`` represents the lane index within the ``lane_config`` (so the default is equivalent to a lane loopback to itself).

Specifies the lane index of the ``n``\ :sup:`th` TX which will be checked against RX status.

This configuration can only be applied individually to one or more of the four lanes connected to the individual transceivers at the ``lane_config`` level.

----

.. _gt-mac-parameter-disable_lane:

=====================================================
``disable_lane``
=====================================================

Optional;
Type           : boolean;
Possible values: ``true`` or ``false``;
Default        : ``false``

This configuration can only be applied individually to one or more of the four lanes connected to the individual transceivers at the ``lane_config`` level.

  * When ``false``, the packet generator of the selected lane will be enabled, and receiver statistics will be gathered and used to determine the overall pass/fail result of the test.
  * When ``true``, no packets are generated by the selected lane, and receiver statistics from that instance are ignored.

----

.. _gt-mac-parameter-source_addr:

=====================================================
``source_addr``
=====================================================

Optional;
Type           : string;
Possible values: ``board_mac_addr_<i>`` where ``<i>`` represents the index of an available board MAC address.

This configuration can only be applied individually to one or more of the four lanes connected to the individual transceivers at the ``lane_config`` level.

This option allows the overwrite of the default round robin MAC address vs. lane mapping.

All available MAC addresses are listed in ``summary.log`` (or in ``xbtest.log``) file via the message ID ``ETH_036``:

.. code-block:: bash

    INFO :: ETH_030 :: GT_MAC[0] :: Board MAC address list:
    INFO :: ETH_036 :: GT_MAC[0] :: -board_mac_addr_0: 00:0A:35:06:9F:D2
    INFO :: ETH_036 :: GT_MAC[0] :: -board_mac_addr_1: 00:0A:35:06:9F:D3
    INFO :: ETH_036 :: GT_MAC[0] :: -board_mac_addr_2: 00:0A:35:06:9F:D4
    INFO :: ETH_036 :: GT_MAC[0] :: -board_mac_addr_3: 00:0A:35:06:9F:D5


In this case, there are 4 addresses listed, so the possible values for :ref:`gt-mac-parameter-source_addr` are ``board_mac_addr_0/1/2/3``.

.. tip::
    Using ``board_mac_addr_<i>`` addresses keeps the test generic across different cards as the actual value of the address is not used in the test JSON file.

Other values of :ref:`gt-mac-parameter-source_addr` are supported:

  * :ref:`gt-mac-parameter-source_addr-test_address`: Source MAC address set to a test address.
  * :ref:`gt-mac-parameter-source_addr-alveo_random_address`: Randomly generated Alveo compatible source MAC address.

There is no mechanism to insert any MAC address (spoofing protection).
These modes allow to re-enable a lane normally disabled to due missing or invalid MAC addresses.

----

.. _gt-mac-parameter-source_addr-test_address:

---------------------------------------------------
``test_address``
---------------------------------------------------

When setting :ref:`gt-mac-parameter-source_addr` to ``test_address``, the source MAC address is always ``06-bbcc-dd-ee-<X><Y>`` where:

  * ``<X>`` represents the index of the GT. Possible values: from 0 to ``n``, where ``n`` is the number of GT defined in the :ref:`ug-platform-definition`.
  * ``<Y>`` represents the index of the lane. Possible values: from 0 to 3.

In the ``test_address`` mode, the MAC addresses are fixed whatever the card is.
The address only depends on the GT and the lane used.
If multiple instances of xbtest are running simultaneously with ``test_address``, the switch will detect multiple lanes with identical MAC addresses and won't be able to route the traffic correctly.

As the addresses are predictable, it may help to debug traffic issues at the switch.

.. note::
    MAC addresses beginning with ``02``, ``06``, ``0A`` or ``0E`` are locally administered.

----

.. _gt-mac-parameter-source_addr-alveo_random_address:

---------------------------------------------------
``alveo_random_address``
---------------------------------------------------

Alveo cards MAC addresses are taken from 2 pools of addresses when setting :ref:`gt-mac-parameter-source_addr` to ``alveo_random_address``:

  1. ``00-0A-35-xx-xx-xx``
  2. ``00-5d-03-xx-xx-xx``

In this mode, xbtest creates randomly, at runtime, an address from the first pool (``00-0A-35-xx-xx-xx``).
Each xbtest run will result in different addresses.
This mode allows to run multiple cards/lanes without having to worry about conflicting MAC addresses.
This overcomes the limitation of the :ref:`gt-mac-parameter-source_addr-test_address` mode.

----

.. _gt-mac-parameter-dest_addr:

=====================================================
``dest_addr``
=====================================================

Optional;
Type           : string;
Possible values: ``board_mac_addr_<i>`` where ``<i>`` represents the index of an available board MAC address, or any valid six-octet value (for example: ``01:0A:BC:DE:F0:20``).

This configuration can only be applied individually to one or more of the four lanes connected to the individual transceivers at the ``lane_config`` level.

Although the destination address is automatically selected defining :ref:`gt-mac-parameter-tx_mapping`,
it is possible to overwrite the selection and use another board address or any valid MAC address.

All available MAC addresses are listed in ``summary.log`` (or in ``xbtest.log``) file via the message ID ``ETH_036``:

.. code-block:: bash

    INFO :: ETH_030 :: GT_MAC[0] :: Board MAC address list:
    INFO :: ETH_036 :: GT_MAC[0] :: -board_mac_addr_0: 00:0A:35:06:9F:D2
    INFO :: ETH_036 :: GT_MAC[0] :: -board_mac_addr_1: 00:0A:35:06:9F:D3
    INFO :: ETH_036 :: GT_MAC[0] :: -board_mac_addr_2: 00:0A:35:06:9F:D4
    INFO :: ETH_036 :: GT_MAC[0] :: -board_mac_addr_3: 00:0A:35:06:9F:D5

In this case, there are 4 addresses listed, so the possible values for :ref:`gt-mac-parameter-dest_addr` are ``board_mac_addr_0/1/2/3``.

.. tip::
    Using ``board_mac_addr_<i>`` addresses keeps the test generic across different cards as the actual value of the address is not used in the test JSON file.

The :ref:`gt-mac-parameter-dest_addr` overwrite also supports any valid MAC address.
The address must be composed of 6 octets separated by columns ":".
Only hexadecimal characters are supported. For example: ``01:0A:BC:DE:F0:20``.

When setting :ref:`gt-mac-parameter-dest_addr` to :ref:`gt-mac-parameter-source_addr-test_address`, the destination MAC address is always ``06-bbcc-dd-ee-<X><Y>`` where:

  * ``<X>`` represents the index of the GT. Possible values: from 0 to 1.
  * ``<Y>`` represents the index of the lane. Possible values: from 0 to 3.

In this mode, the MAC addresses are fixed whatever the card is.
The address only depends on the GT and the lane used. If multiple instances of xbtest are running simultaneously with :ref:`gt-mac-parameter-source_addr-test_address`,
the switch will detect multiple lanes with identical MAC addresses and it won't be able to route the traffic correctly.

As the addresses are predictable, it may help to debug traffic issues at the switch.

----

.. _gt-mac-parameter-utilisation:

=====================================================
``utilisation``
=====================================================

Optional;
Type           : integer;
Possible values: from ``0`` to ``100``;
Default        : ``50``.

This sets the transmit utilisation of the link in the range ``0`` to ``100`` (percent).
The parameter is used to set the approximate link utilisation for the packet generator, by adjusting the delay between packets.

  * Setting the utilisation to ``100`` causes packets to be generated at the maximum achievable rate.
  * Setting the utilisation to ``0`` disables the packet generator completely.

.. caution::
    Never use a :ref:`gt-mac-parameter-utilisation` of ``100`` when connected to the switch.
    The switch also sends some maintenance packets which will take priority over any traffic, resulting in lost packets.

----

.. _gt-mac-parameter-traffic_type:

=====================================================
``traffic_type``
=====================================================

Optional;
Type           : string;
Possible values: ``0x00``, ``0xff``, ``count`` or ``pattern``;
Default        : ``count``.

The test packets produced by the traffic generator consist of a statically configured destination address (48 bits), source address (48 bits) and ethertype (16 bits) followed by a payload area and a CRC (32 bits).

The content of the payload area is controlled by this parameter:

  * ``0x00``: The whole payload area will be filled with bytes of value ``0x00``.
  * ``count``: The payload area will be filled with a byte count sequence.
    The byte following Ethertype will be ``0x00``, the next ``0x01``, with each successive byte incrementing to ``0xff`` and rolling over to ``0x00`` and repeating to the end of the payload area.
  * ``pattern``: The payload area will be filled with the pattern (``0x00``, ``0x55``, ``0xaa``, ``0xff``) repeating for the number of bytes in the payload area.
  * ``0xff``: The whole payload area will be filled with bytes of value ``0xff``.

----

.. _gt-mac-parameter-packet_cfg:

=====================================================
``packet_cfg``
=====================================================

Optional;
Type           : string;
Possible values: ``sweep`` or value from ``64`` to ``1535`` or from ``9000`` to ``10000``;
Default        : ``sweep``.

  * When ``sweep`` is used, a sequence of 1455 packets will be generated continuously with sizes between 64 and 1518 bytes.

If a single numeric value is used (in the range 64 to 1535 or in the range 9000 to 10000) is supplied, then all generated packets shall be this size.

.. warning::

      * Only even values are supported for packet sizes between 9000 and 10000 (jumbo frame).
      * The switch only supports jumbo frames up to 9216 bytes (see :ref:`gt-mac-test-set-up`).

.. note::
    Note that the receive MTU is adjusted to match the configured transmit packet size.

    If the transmit size is:

      * Lower than or equal to 1518, then the receive MTU is set to 1518.
      * Greater than 1518 but lower than or equal to 9600, then the receive MTU is set to 9600.
      * Greater than 9600, then the receive MTU is set to 10000.

----

.. _gt-mac-parameter-match_tx_rx:

=====================================================
``match_tx_rx``
=====================================================

Optional;
Type           : boolean;
Possible values: ``true`` or ``false``;
Default        : ``false``.

Specifies if RX is checked against TX.

If the transmit and receive interfaces of each active MAC instance are is looped back,
then the transmitted packet and byte counts are expected to exactly match the equivalent received good packet and byte counters.

  * Setting this parameter to ``true`` enables this comparison to be made and included in the overall pass/fail assessment of the link.

When set to ``false``, the comparison of TX and RX counters is not included in the overall pass/fail assessment of the link.

----

.. _gt-mac-parameter-mac_to_mac_connection:

=====================================================
``mac_to_mac_connection``
=====================================================

Optional;
Type: integer;
Possible values: from ``0`` to ``31``;

Enable GT MAC cross connections. Contains the index of the GT MAC CU to which is connected the CU.

See :ref:`gt-mac-gt-mac-interconnections` for syntax example.

----

.. _gt-mac-parameter-gt_settings-JSON-members:

.. include:: ../shared/gt-settings-JSON-members.rst

More info can be found here: |GT MAC Settings|.
Further details on each of settings can be found in |UG578|_.

----

.. _gt-mac-parameter-gt_settings:

.. include:: ../shared/gt-parameter-gt_settings.rst

----

.. _gt-mac-parameter-gt_tx_diffctrl:

.. include:: ../shared/gt-parameter-gt_tx_diffctrl.rst

----

.. _gt-mac-parameter-gt_tx_pre_emph:

.. include:: ../shared/gt-parameter-gt_tx_pre_emph.rst

----

.. _gt-mac-parameter-gt_tx_post_emph:

.. include:: ../shared/gt-parameter-gt_tx_post_emph.rst

----

.. _gt-mac-parameter-gt_tx_polarity:

.. include:: ../shared/gt-parameter-gt_tx_polarity.rst

----

.. _gt-mac-parameter-gt_rx_use_lpm:

.. include:: ../shared/gt-parameter-gt_rx_use_lpm.rst

----

********************************************************
Output files
********************************************************

All GT measurements are stored in an output CSV file generated in xbtest logging directory.
The values are stored in CSV type format with one column for each information type.

.. important::
    If the command line option :option:`-L` is used while calling the |Application software|, no output file is generated.

For each GT MAC CU, one file is generated per lane with the suffix/extension ``_gt<gt_cu_index>_<lane_index>.csv`` where:

  * ``<gt_cu_index>`` is the index of the GT MAC CU.
  * ``<lane_index>`` is the index of the lane.

For each test of the :ref:`gt-mac-parameter-test_sequence`, a new row containing the test results and status is present in this file.
All columns present in the file are defined as:

  * **Overall result**: Set to ``FAIL`` as soon as one test fails, otherwise set to ``PASS``.
  * **Test result**: Set to ``FAIL`` if the current test fails, otherwise set to ``PASS``.
  * **Status**: This group of columns is composed of one column for each status registers (see :ref:`status`).
