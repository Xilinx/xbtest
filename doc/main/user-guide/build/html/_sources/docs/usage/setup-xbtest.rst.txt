
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _set-up-xbtest:

##########################################################################
Set up xbtest
##########################################################################

Before using xbtest, your card should be installed and operating correctly, including |XRT|_.
For installation instructions, see the following:

  * |XRT_DOC|_
  * |Alveo doc|_

.. important::
    Ensure you run xbtest from a folder where you have write permission.

Use the following commands to set up xbtest:

.. table:: Set Up xbtest

    +-------+-------------------------------------------+
    | Shell | Command                                   |
    +=======+===========================================+
    | csh   | .. code-block:: bash                      |
    |       |                                           |
    |       |     $ source /opt/xilinx/xbtest/setup.csh |
    |       |                                           |
    +-------+-------------------------------------------+
    | bash  | .. code-block:: bash                      |
    |       |                                           |
    |       |     $ source /opt/xilinx/xbtest/setup.sh  |
    |       |                                           |
    +-------+-------------------------------------------+

If xbtest was installed in a user specified location ``<target directory>`` (see :ref:`install-xbtest-to-another-location`), set up the environment by using the following command:

.. table:: Set Up xbtest From Another Location

    +-------+-------------------------------------------------------------+
    | Shell | Command                                                     |
    +=======+=============================================================+
    | csh   | .. code-block:: bash                                        |
    |       |                                                             |
    |       |     $ source <target directory>/opt/xilinx/xbtest/setup.csh |
    |       |                                                             |
    +-------+-------------------------------------------------------------+
    | bash  | .. code-block:: bash                                        |
    |       |                                                             |
    |       |     $ source <target directory>/opt/xilinx/xbtest/setup.sh  |
    |       |                                                             |
    +-------+-------------------------------------------------------------+

This script:

  * Sets the environment variable ``XILINX_XBTEST`` with the script location (``/opt/xilinx/xbtest/`` or ``<target directory>/opt/xilinx/xbtest/``).
  * Prepends the location of the xbtest executable (``/opt/xilinx/xbtest/bin/`` or ``<target directory>/opt/xilinx/xbtest/bin/``) to the ``PATH`` environment variable.

.. note::
    The |Common software| uses the environment variable ``XILINX_XBTEST`` for the installation location of |Test software| and |Platform specific libraries|.

    If ``XILINX_XBTEST`` is not set, then |Common software| reports an error:

    .. code-block:: bash

        FAILURE   :: GEN_070 :: GENERAL      :: Environment variable XILINX_XBTEST is not set. Please source the xbtest setup script.

If xbtest is installed and set up correctly, the following command displays the xbtest help instructions:

.. code-block:: bash

    $ xbtest -h

.. note::
    The installation directory is reported when using command line option :option:`-v` or :option:`-h`.
