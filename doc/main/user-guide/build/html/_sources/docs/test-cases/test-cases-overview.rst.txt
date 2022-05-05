
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _test-cases-overview:

##########################################################################
Test cases overview
##########################################################################

Different test cases can be run by xbtest depending on the deployment platform and the |xclbin| capabilities.
A failure in a test case does not stop other test cases.

Apart from the |Verify| test case, a test case is composed of, at minimum, a test sequence which contains the duration and some configuration parameters.

The following tables provides an overview of the supported test cases:

.. table:: Test cases overview

    +------------+--------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+
    | Test case  | Overview                                                                                                                       | Illustration                                       |
    +============+================================================================================================================================+====================================================+
    | |Verify|   | This test case:                                                                                                                | /                                                  |
    |            |                                                                                                                                |                                                    |
    |            |   * Detects and reports available CUs.                                                                                         |                                                    |
    |            |   * Checks compatibility.                                                                                                      |                                                    |
    |            |   * Displays platform definition.                                                                                              |                                                    |
    |            |   * Checks capabilities of all CUs.                                                                                            |                                                    |
    |            |   * Checks basic communication between the host and the CUs: read/write of a scratch register.                                 |                                                    |
    |            |                                                                                                                                |                                                    |
    +------------+--------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+
    | |DMA|      | This test case:                                                                                                                | .. figure:: ../diagram/test-case-dma.svg           |
    |            |                                                                                                                                |     :align: center                                 |
    |            |   * Checks data transfer between the host and the memories available on the card (for example: DDR/HBM).                       |                                                    |
    |            |   * Tests each memory individually.                                                                                            |     DMA test case                                  |
    |            |   * Uses counter for data integrity check.                                                                                     |                                                    |
    |            |   * Measures read and write bandwidths between the host and the memories available on the card (for example: DDR/HBM).         |                                                    |
    |            |                                                                                                                                |                                                    |
    |            | .. note::                                                                                                                      |                                                    |
    |            |     The |DMA| test case does not use any CUs, but it requires an |xclbin| with connection to the memory under test.            |                                                    |
    +------------+--------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+
    | |P2P CARD| | This test case:                                                                                                                | .. figure:: ../diagram/test-case-p2p-card.svg      |
    |            |                                                                                                                                |     :align: center                                 |
    |            |   * Checks data transfer between the memories available on two Alveo cards (for example: DDR/HBM).                             |                                                    |
    |            |   * Tests each memory individually.                                                                                            |     P2P CARD test case                             |
    |            |   * Uses counter for data integrity check.                                                                                     |                                                    |
    |            |   * Measures read and write bandwidths between the memories available on two Alveo cards (for example: DDR/HBM).               |                                                    |
    |            |                                                                                                                                |                                                    |
    |            | .. note::                                                                                                                      |                                                    |
    |            |     The P2P CARD test case does not use any CUs, but it requires an |xclbin| with connection to the memory under test.         |                                                    |
    +------------+--------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+
    | |P2P NVME| | This test case:                                                                                                                | .. figure:: ../diagram/test-case-p2p-nvme.svg      |
    |            |                                                                                                                                |     :align: center                                 |
    |            |   * Checks data transfer between a NVMe SSD and the memories available on an Alveo card (for example: DDR/HBM).                |                                                    |
    |            |   * Tests each memory individually.                                                                                            |     P2P NVME test case                             |
    |            |   * Uses counter for data integrity check.                                                                                     |                                                    |
    |            |   * Measures read and write bandwidths between a NVMe SSD and the memories available on an Alveo card (for example: DDR/HBM).  |                                                    |
    |            |                                                                                                                                |                                                    |
    |            | .. note::                                                                                                                      |                                                    |
    |            |     The P2P CARD test case does not use any CUs, but it requires an |xclbin| with connection to the memory under test.         |                                                    |
    +------------+--------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+
    | |Memory|   | This test case:                                                                                                                | .. figure:: ../diagram/test-case-memory.svg        |
    |            |                                                                                                                                |     :align: center                                 |
    |            |   * Checks data transfer between the CUs and:                                                                                  |                                                    |
    |            |                                                                                                                                |     Memory test case                               |
    |            |       * Memories available on the card (for example: DDR HBM).                                                                 |                                                    |
    |            |       * Memories available on the host via Slave Bridge.                                                                       |                                                    |
    |            |                                                                                                                                |                                                    |
    |            |   * Tests all memories separately with different a configuration for each memory type.                                         |                                                    |
    |            |   * Uses PRBS31 for data integrity check and linear addressing.                                                                |                                                    |
    |            |   * Measure read and write bandwidths and latencies.                                                                           |                                                    |
    |            |                                                                                                                                |                                                    |
    +------------+--------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+
    | |Power|    | This test case:                                                                                                                | /                                                  |
    |            |                                                                                                                                |                                                    |
    |            |   * Sets the power consumed by the card by controlling the toggle rate of the resources present in the CU.                     |                                                    |
    |            |                                                                                                                                |                                                    |
    |            | Power CU only exercises the logic of the |xclbin|. The maximum and minimum power depend on the following:                      |                                                    |
    |            |                                                                                                                                |                                                    |
    |            |   * Selected Alveo card.                                                                                                       |                                                    |
    |            |   * Platform used (see :ref:`ug-platform-definition`).                                                                         |                                                    |
    |            |   * Configuration of other tests running at the same time as the |Power| test case.                                            |                                                    |
    |            |                                                                                                                                |                                                    |
    +------------+--------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+
    | |GT MAC|   | This test case:                                                                                                                | .. figure:: ../diagram/test-case-gt-mac.svg        |
    |            |                                                                                                                                |     :align: center                                 |
    |            |   * Checks the GT transceiver of the Alveo card at 10 Gigabit Ethernet (10 GbE) and 25 Gigabit Ethernet (25 GbE) lane rates.   |                                                    |
    |            |   * Uses the Xilinx XXV Ethernet IP core (see |PG210|_).                                                                       |     GT MAC test case                               |
    |            |   * Includes packet generators, checkers and counters to verify that all expected packets are received error free.             |                                                    |
    |            |   * Supports configurable GT settings which allows the GT MAC CU to be connected to:                                           |                                                    |
    |            |                                                                                                                                |                                                    |
    |            |       1. A switch: optical or electrical cables.                                                                               |                                                    |
    |            |       2. Directly Itself: loopback module or cables.                                                                           |                                                    |
    |            |       3. A GT LPBK CU: optical or electrical cables.                                                                           |                                                    |
    |            |       4. Another GT MAC CU (present in the same |xclbin|): optical or electrical cables.                                       |                                                    |
    |            |                                                                                                                                |                                                    |
    |            |       .. note::                                                                                                                |                                                    |
    |            |            With the 3 first methods, the traffic is ultimately looped back to the GT MAC CU itself.                            |                                                    |
    |            |            With the last method, the traffic flows between GT MAC CU instances                                                 |                                                    |
    |            |                                                                                                                                |                                                    |
    +------------+--------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+
    | |GT PRBS|  | This test case:                                                                                                                | .. figure:: ../diagram/test-case-gt-prbs.svg       |
    |            |                                                                                                                                |     :align: center                                 |
    |            |   * Generates and checks 64/66b PRBS-31 data at 25GbE rate.                                                                    |                                                    |
    |            |                                                                                                                                |     GT PRBS test case                              |
    +------------+--------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+
    | |GT LPBK|  | This test case:                                                                                                                | .. figure:: ../diagram/test-case-gt-lpbk.svg       |
    |            |                                                                                                                                |     :align: center                                 |
    |            |   * Loops back incoming 25GbE traffic by performing a rate adaptation.                                                         |                                                    |
    |            |                                                                                                                                |     GT LPBK test case                              |
    |            | .. warning::                                                                                                                   |                                                    |
    |            |     This CU requires a 25GbE traffic source which could be GT MAC CU.                                                          |                                                    |
    |            |                                                                                                                                |                                                    |
    +------------+--------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+
