
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _ug-platform-definition:

##########################################################################
Platform definition
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2
   
The same Test software is used for all supported platforms.
It is automatically configured at runtime based on the targeted platform using:

  * Platform definition JSON file.
  * |xclbin|.
  * |XRT Device APIs|_.

As part of this platform specific customization, the supported parameters a user can specify in the test JSON file are computed.
For example, no |GT MAC| test case can be run if there is no GT defined for the platform under test.

.. tip::
    All platform definition parameters are displayed in ``xbtest.log`` (as information with the header ``XBT_SW_CFG``).

********************************************************
Platform definition JSON file
********************************************************

xbtest uses a platform definition JSON file specific to each deployment platform.
It specifies characteristics, default settings, limits and pass/fail criteria of xbtest for a platform.
It defines for example:

  * Maximum expected |xclbin| download time.
  * Power and temperature sources definition.
  * Default GT settings.
  * Default bandwidth thresholds of |DMA|, |P2P CARD| and |P2P NVME| test cases.
  * Default bandwidth and latency thresholds of the |Memory| test case.
  * Nominal buffer size and total size for |DMA|, |P2P CARD| and |P2P NVME| test cases.
  * Nominal rate, burst size and maximum number of outstanding transactions for the |Memory| test case.

Other settings are set with default values internally within the ``Test`` software.

The platform definition JSON file is part of the platform library package (see :ref:`installed-content`) and the specification of its content and structure of is beyond the scope of this document.

********************************************************
xclbin metadata
********************************************************

xbtest uses different metadata extracted from the |xclbin| sections:

  * ``IP_LAYOUT``: CU indexes in the IP layout.
  * ``CONNECTIVITY``: Memory indexes associated with each AXI interface for all CUs.
  * ``MEM_TOPOLOGY``: Enabled memory tags and indexes.
  * ``USER_METADATA``: Build information and configurations:

      * GT connections and locations.
      * Interface UUID of targeted platform.
      * CU names, modes, connectivity, locations.
      * Clock frequencies.

********************************************************
XRT device APIs metadata
********************************************************

xbtest uses different metadata extracted from the |XRT Device APIs|_ output before and/or after the |xclbin| is downloaded:

  * ``xrt::info::device::name``: Development platform name.
  * ``xrt::info::device::offline``: Check if the device is not offline before querying any other device information.
  * ``xrt::info::device::interface_uuid``: Interface UUID.
  * ``xrt::info::device::nodma``: Platform is NoDMA
  * ``xrt::info::device::platform``: Platform information such as P2P status, expected and actual SC version, MAC addresses.
  * ``xrt::info::device::host``: Host information such as XRT version and build date.
  * ``xrt::info::device::pcie_info``: PCIe information including expected and actual PCIe speed/width.
  * ``xrt::info::device::dynamic_regions``: Information about xclbin. Only reported as information.
  * ``xrt::info::device::memory``: Sizes of each enabled (on-board and host) memory.

xbtest also uses the |XRT Device APIs|_ to read sensor values:

  * ``xrt::info::device::electrical``: Electrical and power sensors.
  * ``xrt::info::device::thermal``: Thermal sensors.
  * ``xrt::info::device::mechanical``: Mechanical sensors.

xbtest has two kinds of behaviours depending on the device information being queried in case it is not able to get the requested device information:

  * **Sensor reading**: A critical warning is reported when a query failed.
    When three consecutive queries have failed, xbtest reports one error and stops reporting critical warnings.
    In any cases, xbtest does not halt for any sensor reading failure.
  * **Other metadata**: Query is re-initiated every second (3 times maximum).
    If they all fail xbtest halts and reports a failure.
