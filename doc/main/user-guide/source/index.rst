
.. include:: ../../shared/links.rst
.. include:: ./docs/shared/include.rst


.. include:: ../../shared/dochub.rst


##########################################################################
User guide
##########################################################################

.. toctree::
   :maxdepth: 3
   :caption: Introduction
   :hidden:

   ./docs/introduction/overview.rst
   ./docs/introduction/installation.rst
   Download <https://www.xilinx.com/products/acceleration-solutions/xbtest.html>

.. toctree::
   :maxdepth: 3
   :caption: Usage
   :hidden:

   ./docs/usage/setup-xbtest.rst
   ./docs/usage/use-cases.rst
   ./docs/usage/identifying-a-deployment-platform.rst
   ./docs/usage/test-specific-setup.rst
   ./docs/usage/command-line-options.rst
   ./docs/usage/result.rst
   ./docs/usage/test-json-file-structure.rst

.. toctree::
   :maxdepth: 3
   :caption: Pre-canned tests
   :hidden:

   ./docs/pre-canned-tests/pre-canned-tests-description.rst

.. toctree::
   :maxdepth: 3
   :caption: Test cases
   :hidden:

   Overview <./docs/test-cases/test-cases-overview.rst>
   Verify <./docs/test-cases/verify-test-case-description.rst>
   DMA <./docs/test-cases/dma-test-case-description.rst>
   P2P CARD <./docs/test-cases/p2p-card-test-case-description.rst>
   P2P NVME <./docs/test-cases/p2p-nvme-test-case-description.rst>
   Memory <./docs/test-cases/memory-test-case-description.rst>
   Power <./docs/test-cases/power-test-case-description.rst>
   GT <./docs/test-cases/gt-test-case-description.rst>

.. toctree::
   :maxdepth: 3
   :caption: Tasks
   :hidden:

   Overview <./docs/tasks/tasks-overview.rst>
   Device management <./docs/tasks/device-management-task-description.rst>

.. toctree::
   :maxdepth: 3
   :caption: Platform definition
   :hidden:

   ./docs/platform-definition/platform-definition.rst

xbtest application can be used to validate that the |Alveo|_ card hardware is operating correctly within the host server environment.
The application monitors system health and validates the functionality of the essential hardware and software components of the platform.

xbtest can be configured to run the following tests:

  * Host can communicate with:

      * **On-board memories**: DMA.
      * **Compute units (CUs)**: Validate the CUs.

  * Host can control PCIe® peer-to-peer communication (P2P) data transfer between:

      * Two Alveo cards.
      * One Alveo card and one NVMe SSD.

  * Dissipate a programmable amount of power.
  * Check the GT transceivers at 10GbE and 25GbE lane rates.
  * Verify that CUs can communicate at the required rate with:

      * **On-board memories**: For example, DDR or HBM.
      * **Host memory**: If the slave bridge feature is available in your card (refer to the |Alveo doc|_).

.. important::
    Prior to using xbtest, your Alveo card hardware and software must be installed (refer to the |Alveo doc|_).

.. _alveo-data-center-accelerator-card-compatibility:

********************************************************
Alveo data center accelerator card compatibility
********************************************************

xbtest supports the Alveo cards with compatible |XRT|_ and target platforms.
The specific Alveo cards and deployment platforms compatible with xbtest are listed in |xbtest_downloads|_.

For Alveo card documentation, refer to the |Alveo doc|_.

********************************************************
What's new
********************************************************

xbtest v6 major updates compared to v5 are:

  * Multi-card support: user interface and configuration.
  * Visualisation of results using Vitis Analyser.
  * Sensor queries via |XRT Device APIs|_ for performance increase.
  * Memory Quality of Service (QoS): support AXI thread ID and AXI outstanding transaction configuration.
  * Extended GT test features:

      * Support for GT_MAC to GT_MAC connection.
      * New CU: GT_PRBS and GT_LPBK.

  * Support AIE contribution for power dissipation.
  * Support PCIe® peer-to-peer communication (P2P).
  * Support NoDMA platforms.
  * New test sequence JSON file definition for ease of use.
  
  
  
.. include:: ../../shared/other-versions.rst



