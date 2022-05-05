
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _test-specific-setup:

##########################################################################
Test specific set up
##########################################################################

The following sections describes set up procedures required only for specific tests.

.. _host-memory-set-up:

********************************************************
Host memory set up
********************************************************

Host memory tests (Slave bridge) and NoDMA platforms require the following set up procedure:

  1. Before loading xbtest |xclbin|, you must allocate the host memory with the following command.

     .. code-block:: bash

         $ sudo xbutil configure --device <BDF> --host-mem --size <size> ENABLE

     Where:

       * ``<BDF>``  is the card BDF (see :ref:`identifying-a-deployment-platform`)
       * ``<size>`` is the size of the host memory (for example ``1G``)

  2. Force a reload of xbtest xclbin and validate your card with the following command:

     .. code-block:: bash

         $ xbutil validate --device <BDF>

  3. Start xbtest test:

     .. code-block:: bash

         $ xbtest -d <BDF> -j path/to/my_tests.json

.. note::
    Steps 1 and 2 must be done after any server reboot, but they do not need to be redone in between each xbtest test.

.. important::
    NoDMA platforms require preallocation of host memory.

For more information on host memory size requirement and enabling hugepages, refer to |XRT_HM_DOC|_.

.. _p2p-tests-set-up:

********************************************************
P2P tests set up
********************************************************

P2P tests require the following set up procedure:

  1. You must enable P2P on your cards with the following command.

     .. code-block:: bash

         $ sudo xbutil configure --device <BDF> --p2p enable

     Where:

       * ``<BDF>``  is the card BDF (see :ref:`identifying-a-deployment-platform`)

  2. Warm reboot the host.
  3. Validate your card with the following command:

     .. code-block:: bash

         $ xbutil validate --device <BDF>

  4. Start xbtest test:

     .. code-block:: bash

         $ xbtest -d <BDF> -j path/to/my_tests.json

.. note::
    Steps 1 and 2 must be done after any server cold reboot, but they do not need to be redone in between each xbtest test.

.. note::
    XRT or xbtest reports error when P2P is not enabled. Check P2P is enabled with the following command:

    .. code-block:: bash

        $ xbutil examine --device <BDF> --report platform

For more information on P2P setup and requirements, refer to |XRT_P2P_DOC|_.