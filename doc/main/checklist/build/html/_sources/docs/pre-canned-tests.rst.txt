
.. include:: ../../../shared/links.rst
.. include:: links.rst

.. _pre-canned-tests:

##########################################################################
Pre-canned tests
##########################################################################

********************************************************
Goal
********************************************************

This section gathers the results of the pre-canned tests.

They should all pass once the platform definition has been updated.

.. note::
    The first initial run of pre-canned tests will report errors as the platform definition template contains standard thresholds (which you'll update while filling the checklist).

    If a default pre-canned test is failing, and it's because a nominal setting is wrong, then you should update the setting in platform definition JSON file.

********************************************************
TO-DO
********************************************************

  1. Run all pre-canned tests and save the results in section :ref:`pre-canned-tests-checklist` of your checklist.
  2. Fill some extra information about the results and test environments.

********************************************************
Detailed steps
********************************************************

.. important::
    It's highly recommended to track any modifications and/or result out of expected range.
    Please fill a problem report and add their tracking number in the :ref:`checklist-questionnaire`.

=====================================================
System information
=====================================================

Indicated the following system information in section :ref:`system-information-checklist`:

.. table::

    +-----------------------------------+-----------------------------------------------------------------------------------------------------------------------+
    | System information                                                                                                                                        |
    +===================================+=======================================================================================================================+
    | OS                                | Indicate in what type of host (OS name & release) the pre-canned tests were run.                                      |
    |                                   |                                                                                                                       |
    |                                   | .. code-block:: bash                                                                                                  |
    |                                   |                                                                                                                       |
    |                                   |     $ lsb_release -a                                                                                                  |
    +-----------------------------------+-----------------------------------------------------------------------------------------------------------------------+
    | Architecture                      | Architecture of host the pre-canned tests were run.                                                                   |
    |                                   |                                                                                                                       |
    |                                   | .. code-block:: bash                                                                                                  |
    |                                   |                                                                                                                       |
    |                                   |     $ uname -m                                                                                                        |
    +-----------------------------------+-----------------------------------------------------------------------------------------------------------------------+
    | Server type                       | Server type of host the pre-canned tests were run.                                                                    |
    |                                   |                                                                                                                       |
    |                                   | .. code-block:: bash                                                                                                  |
    |                                   |                                                                                                                       |
    |                                   |     $ xbutil examine --device <bdf> --report host --format json --force --output /dev/stdout | grep model             |
    +-----------------------------------+-----------------------------------------------------------------------------------------------------------------------+
    | AUX cable                         | Indicate if AUX cable was used when the pre-canned tests were run.                                                    |
    +-----------------------------------+-----------------------------------------------------------------------------------------------------------------------+
    | Card S/N                          | Serial number of the card used when the pre-canned tests were run.                                                    |
    |                                   |                                                                                                                       |
    |                                   | .. code-block:: bash                                                                                                  |
    |                                   |                                                                                                                       |
    |                                   |     $ xbutil examine --device <bdf> --report platform --format json --force --output /dev/stdout | grep serial_number |
    +-----------------------------------+-----------------------------------------------------------------------------------------------------------------------+
    | XRT version                       | Version of |XRT|_ installed on host the pre-canned tests were run.                                                    |
    |                                   |                                                                                                                       |
    |                                   | .. code-block:: bash                                                                                                  |
    |                                   |                                                                                                                       |
    |                                   |     $ xbutil --version | grep "Version"                                                                               |
    +-----------------------------------+-----------------------------------------------------------------------------------------------------------------------+
    | Measured download time            | Indicate the download time reported in xbtest output (in seconds).                                                    |
    |                                   |                                                                                                                       |
    |                                   | Make sure to reload the xclbin before.                                                                                |
    |                                   |                                                                                                                       |
    |                                   |   * First load another xclbin, e.g. ``verify.xclbin``                                                                 |
    |                                   |                                                                                                                       |
    |                                   |     .. code-block:: bash                                                                                              |
    |                                   |                                                                                                                       |
    |                                   |         $ xbutil validate --run quick --device <bdf>                                                                  |
    |                                   |                                                                                                                       |
    |                                   |   * Then load xbtest xclbin                                                                                           |
    |                                   |                                                                                                                       |
    |                                   |     .. code-block:: bash                                                                                              |
    |                                   |                                                                                                                       |
    |                                   |         $ xbtest -F -b -2 -d <bdf> -c verify -l pre_canned_verify                                                     |
    |                                   |                                                                                                                       |
    |                                   |   * Report here the message with ID ``ITF_084`` extracted from ``xbtest.log`` file                                    |
    |                                   |                                                                                                                       |
    |                                   |     .. code-block:: bash                                                                                              |
    |                                   |                                                                                                                       |
    |                                   |         $ cat pre_canned_verify/xbtest.log | grep ITF_084                                                             |
    +-----------------------------------+-----------------------------------------------------------------------------------------------------------------------+

=====================================================
Pre-canned test modifications
=====================================================

Indicate in section :ref:`pre-canned-tests-modifications-checklist` if you have modified the provided pre-canned test templates with settings for example to increase performance.
Justify why you could not insert the settings within the platform definition.

.. note::
    By modifying the platform definition, you make your update available for all tests by default.

=====================================================
``dma`` pre-canned test
=====================================================

Identify CPU affinity:

.. code-block:: bash

    $ xbutil examine --device <BDF> --report all | grep "CPU Affinity"

Use pre-canned dma test with CPU affinity:

  1. Run xbtest:

     .. code-block:: bash

         $ taskset -c 0,2,4,6,8,10 xbtest -F -d <bdf> -c dma -l dma

  2. Zip the log directory and attach it to this checklist:

     .. code-block:: bash

         $ zip -r dma.zip dma

Add your results to section :ref:`dma_pre-canned-test-checklist` of your checklist.

For each on-board memory, report average BW results for 1 memory bank. For example:

  * **For DDR**: report ``DDR[0]`` average BW results.
  * **For HBM**: report ``HBM[0]`` average BW results.

Result is indicated in xbtest message ``DMA_018``.

Remove/add table rows per on-board memory type (e.g. HBM, DDR, PS_DDR, PL_DDR).

.. note::
    For PCIe 3x16 board, write and read bandwidths should be above 10000 MBps. For PCIe 3x4, they should be above 2500 MBps.

=====================================================
``p2p_card`` pre-canned test
=====================================================

Check P2P is enabled on your source and target cards:

.. code-block:: bash

    $ xbutil examine --device <source card bdf> | grep P2P
    $ xbutil examine --device <target card bdf> | grep P2P

If P2P is not already enabled, run the following command to enable P2P and then warm reboot the host:

.. code-block:: bash

    $ sudo xbutil configure --device <source card bdf> --p2p enable
    $ sudo xbutil configure --device <target card bdf> --p2p enable
    $ sudo reboot now

Use ``p2p_card`` pre-canned test specifying which card is source and which card is target:

  1. Run xbtest:

     .. code-block:: bash

         $ xbtest -F -d <source card bdf> -T <target card bdf> -c p2p_card -l p2p_card

  2. Zip the log directory and attach it to this checklist:

     .. code-block:: bash

         $ zip -r p2p_card.zip p2p_card

Add your results to section :ref:`p2p_card_pre-canned-test-checklist` of your checklist.

For each on-board memory, report average BW results for 1 memory bank. For example:

  * **For DDR**: report ``DDR[0]`` average BW results.
  * **For HBM**: report ``HBM[0]`` average BW results.

Result is indicated in xbtest message ``P2P_018``.

Remove/add table rows per on-board memory type (e.g. HBM, DDR, PS_DDR, PL_DDR).

=====================================================
``p2p_nvme`` pre-canned test
=====================================================

Check P2P is enabled on your card:

.. code-block:: bash

    $ xbutil examine --device <bdf> | grep P2P

If P2P is not already enabled, run the following command to enable P2P and then warm reboot the host:

.. code-block:: bash

    $ sudo xbutil configure --device <bdf> --p2p enable
    $ sudo reboot now

Create a file with write/read permissions in a mounted partition of the NVMe SSD. For example:

.. code-block:: bash

    $ touch /mnt/nvme0n1p1/file.out; chmod a+w /mnt/nvme0n1p1/file.out

Use pre-canned p2p_nvme test with NVMe file path:

  1. Run xbtest:

     .. code-block:: bash

         $ xbtest -F -d <bdf> -N /mnt/nvme0n1p1/file.out -c p2p_nvme -l p2p_nvme

  2. Zip the log directory and attach it to this checklist:

     .. code-block:: bash

         $ zip -r p2p_nvme.zip p2p_nvme

Add your results to section :ref:`p2p_nvme_pre-canned-test-checklist` of your checklist.

For each on-board memory, report average BW results for 1 memory bank. For example:

  * **For DDR**: report ``DDR[0]`` average BW results.
  * **For HBM**: report ``HBM[0]`` average BW results.

Report the results on applicable each card modes:

  * **source**: The card is used as P2P source (its DMA engine is used to initiates P2P transactions).

      * Not applicable for NoDMA platforms.

  * **target**: The card is used as P2P target.

Result is indicated in xbtest message ``P2P_018``.

Remove/add table rows per on-board memory type (e.g. HBM, DDR, PS_DDR, PL_DDR).

=====================================================
``memory`` pre-canned test
=====================================================

Use pre-canned memory test:

  1. Run xbtest:

     .. code-block:: bash

         $ xbtest -F -d <bdf> -c memory -l memory

  2. Zip the log directory and attach it to this checklist:

     .. code-block:: bash

         $ zip -r memory.zip memory

Add your results to section :ref:`memory_pre-canned-test-checklist` of your checklist.

BW and latency results are indicated in xbtest message ``MEM_040``.

  * For single-channel memory CU(s):  Report results for **one** memory bank only.

      * E.g. ``DDR[0]``.

  * For multi-channel memory CU(s): Report **combined** results:

      * E.g. ``INFO :: MEM_040 :: MEMORY :: HBM :: combined | all | 65233.170 | 65038.179 | 148.3 | 208.3 | OK``

Make sure to look at the correct ``test_mode``: ``alternate_wr_rd`` / ``only_wr`` / ``only_rd`` or ``simultaneous_wr_rd``.

Remove/add table per on-board memory type (e.g. HBM, DDR, PS_DDR, PL_DDR).

=====================================================
``memory_host`` pre-canned test
=====================================================

If the platform supports host memory, use ``memory_host`` pre-canned test:

  1. Enable 1G of host memory:

     .. code-block:: bash

         $ sudo xbutil configure --device <BDF> --host-mem -s 1G enable

  2. Run xbtest:

     .. code-block:: bash

         $ xbtest -F -d <bdf> -c memory_host -l memory_host

  3. Zip the log directory and attach it to this checklist:

     .. code-block:: bash

         $ zip -r memory_host.zip memory_host

Add your results to section :ref:`memory_host_pre-canned-test-checklist` of your checklist.

BW and latency results are indicated in xbtest message ``MEM_040``.

Report results for **one** memory bank only.

  * E.g. ``HOST[0]``.

Make sure to look at the correct ``test_mode``: ``alternate_wr_rd`` / ``only_wr`` / ``only_rd`` or ``simultaneous_wr_rd``.

=====================================================
Others pre-canned tests
=====================================================

They should all pass.
