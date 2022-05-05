
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

##########################################################################
Installation
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2

xbtest is delivered as various archive files that contain the installation packages (RPM and DEB).
For each deployment platform, a different archive file is provided for each supported OS.
Each archive file provided contains:

  * |Application software|:

      * |Common software|: Select, configure, and launch the |Test software| based on the platform under test.
      * |Test software|: Actual software running the tests.

  * |Platform specific library|: Platform-specific files.

For links to xbtest application software and platform specific library archive files, go to :ref:`alveo-data-center-accelerator-card-compatibility`.

********************************************************
Dependencies
********************************************************

Dependencies are part of the xbtest RPM or DEB packages.

The following figure describes the dependencies between each xbtest package and with XRT and deployment platform:

.. figure:: ../diagram/packages-dependencies.svg
    :align: center

    Packages dependencies

.. important::
    Although the OS package manager will resolve the dependencies between the xbtest packages, xbtest requires a correctly installed and operating card.
    For instructions on how to install |XRT|_ and the deployment platform, refer to the |Alveo doc|_.

The |Application software| also depends on the ``json-glib-1.0`` and ``ncurses`` packages.
These two dependencies  will be resolved by the OS package manager (for example, ``yum`` or ``apt``).

.. caution::
    Different major version of xbtest cannot be installed simultaneously (for example v4 with v5).
    Before you can install a new version of xbtest, you must remove other versions of xbtest.

.. _install-xbtest:

********************************************************
Install xbtest
********************************************************

xbtest is delivered as various archive files containing the RPM or DEB packages to be installed, which are available in :ref:`alveo-data-center-accelerator-card-compatibility`.
This section explains how to identify and install the xbtest RPM or DEB packages using your OS package manager.

The high-level installation steps are first listed, and then specific details are outlined in the following section:

  1. Identify your OS and deployment platform.
  2. Get xbtest |Application software| and |Platform specific library| archive files compatible with your setup.
  3. Install xbtest application software RPM or DEB packages compatible with your setup.


     The application software packages are only installed once for all target platforms in the following order:

       1. |Common software|, named ``xbtest-common``.
       2. |Test software|, named ``xbtest-sw-6``.

  4. Install the |Platform specific library| RPM or DEB package compatible with your setup.

     You can install multiple |Platform specific library| packages (based on what is available on your system).

.. _step-identify-OS-deploy:

=====================================================
Step 1: Identify your OS and deployment platform
=====================================================

xbtest application software RPM and DEB packages depend on OS version and system architecture.

.. _step-identify-system-architecture:

-------------------------------------------------
Step 1.1: Identify your system architecture
-------------------------------------------------

Identify compatible xbtest package ``<architecture>`` which is returned by the command given in the following table:

.. table:: Identify xbtest package architecture

    +-------------------+---------------------------------+----------------------+
    | OS                | Command                         | Output               |
    +===================+=================================+======================+
    | Red Hat / CentOS  | .. code-block:: bash            | .. code-block:: bash |
    |                   |                                 |                      |
    |                   |     $ uname -p                  |     x86_64           |
    |                   |                                 |                      |
    +-------------------+---------------------------------+----------------------+
    | Ubuntu            | .. code-block:: bash            | .. code-block:: bash |
    |                   |                                 |                      |
    |                   |     $ dpkg --print-architecture |     amd64            |
    |                   |                                 |                      |
    +-------------------+---------------------------------+----------------------+

.. _step-identify-os-release:

-------------------------------------------------
Step 1.2: Identify your OS release
-------------------------------------------------

Identify compatible xbtest package ``<OS_release>`` depending on your distribution.
The following table gives two examples of xbtest package ``<OS_release>``:

.. table:: Identify xbtest package OS release

    +------------------+---------------------------+
    | OS               | xbtest package OS release |
    +==================+===========================+
    | Red Hat / CentOS | 8.x                       |
    +------------------+---------------------------+
    | Ubuntu           | 18.04                     |
    +------------------+---------------------------+


You can check the OS release of your distribution by running the command:

.. code-block:: bash

    $ lsb_release -rs

.. _step-identify-deployment-platform:

-------------------------------------------------
Step 1.3: Identify your deployment platform
-------------------------------------------------

Identify your deployment platform package name and version.
For example, if you are targeting a U50 LV card, run the command given in the following table based on your OS:

.. table:: Identify your deployment platform

    +-------------------+---------------------------------------+-----------------------------------------------------------------------+
    | OS                | Command                               | Output                                                                |
    +===================+=======================================+=======================================================================+
    | Red Hat / CentOS  | .. code-block:: bash                  | .. code-block:: bash                                                  |
    |                   |                                       |                                                                       |
    |                   |     $ yum list | grep 'xilinx-u50lv*' |     xilinx-u50lv-gen3x4-xdma-base.noarch 2-2902115 installed          |
    |                   |                                       |                                                                       |
    +-------------------+---------------------------------------+-----------------------------------------------------------------------+
    | Ubuntu            | .. code-block:: bash                  | .. code-block:: bash                                                  |
    |                   |                                       |                                                                       |
    |                   |     $ apt list | grep 'xilinx-u50lv*' |     xilinx-u50lv-gen3x4-xdma-base/now 2-2902115 all [installed,local] |
    |                   |                                       |                                                                       |
    +-------------------+---------------------------------------+-----------------------------------------------------------------------+

From the output of these commands, the deployment package can be identified:

  * Name is ``xilinx-u50lv-gen3x4-xdma-base``
  * Version is ``2``

=====================================================
Step 2: Get compatible archives
=====================================================

Download xbtest application archive file available in :ref:`alveo-data-center-accelerator-card-compatibility` compatible with your OS and deployment platform.

Extract xbtest application software and platform specific library RPM or DEB packages from the archive file.

=====================================================
Step 3: Install software packages
=====================================================

Install first the |Common software| and then the |Test software|.
The following table gives two examples of commands based on architecture and OS release:

.. table:: Install xbtest software packages

    +-----------------------+--------------+------------------------------------------------------------------+
    | Distribution          | Architecture | Command                                                          |
    +=======================+==============+==================================================================+
    | Red Hat / CentOS 8.x  | ``x86_64``   | .. code-block:: bash                                             |
    |                       |              |                                                                  |
    |                       |              |     $ sudo yum install xbtest-common-2.0-3522770.x86_64_8.x.rpm  |
    |                       |              |     $ sudo yum install xbtest-sw-6-0-3522770.x86_64_8.x.rpm      |
    |                       |              |                                                                  |
    +-----------------------+--------------+------------------------------------------------------------------+
    | Ubuntu 18.04          | ``amd64``    | .. code-block:: bash                                             |
    |                       |              |                                                                  |
    |                       |              |     $ sudo apt install xbtest-common_2.0-3522770_amd64_18.04.deb |
    |                       |              |     $ sudo apt install xbtest-sw-6_0-3522770_amd64_18.04.deb     |
    |                       |              |                                                                  |
    +-----------------------+--------------+------------------------------------------------------------------+

.. note::
    The application software packages are named with the suffix ``<architecture>``\ _\ ``<OS_release>``\ .\ ``<extension>`` where:

      * ``<architecture>`` is the system architecture identified in :ref:`step-identify-system-architecture`.
      * ``<OS_release>`` is the OS release identified in :ref:`step-identify-os-release`.
      * ``<extension>`` is the package extension (``deb`` or ``rpm``).

=====================================================
Step 4: Install platform specific library package
=====================================================

|Platform specific library| packages do not depend on OS release and architecture.

Install platform specific library DEB or RPM package.

The following table gives the installation command for the deployment platform identified in :ref:`step-identify-deployment-platform`:

.. table:: Install xbtest platform library packages

    +------------------+--------------------------------------------------------------------------------------+
    | OS               | Command                                                                              |
    +==================+======================================================================================+
    | Red Hat / CentOS | .. code-block:: bash                                                                 |
    |                  |                                                                                      |
    |                  |     $ sudo yum install xbtest-xilinx-u50lv-gen3x4-xdma-base-2-6.0-1234567.noarch.rpm |
    |                  |                                                                                      |
    +------------------+--------------------------------------------------------------------------------------+
    | Ubuntu           | .. code-block:: bash                                                                 |
    |                  |                                                                                      |
    |                  |     $ sudo apt install xbtest-xilinx-u50lv-gen3x4-xdma-base-2_6.0-1234567_all.deb    |
    |                  |                                                                                      |
    +------------------+--------------------------------------------------------------------------------------+

.. note::
    The platform specific library packages are named:

      * **Red Hat / CentOS**: xbtest-``<deploy_name>``\ -``<deploy_version>``\ -6.0-``<pkg_release>``\ .noarch.rpm.
      * **Ubuntu**: xbtest-``<deploy_name>``\ -``<deploy_version>``\ _6.0-``<pkg_release>``\ _all.deb.

    Where:

      * ``<deploy_name>`` is the deployment platform name identified in :ref:`step-identify-deployment-platform` (e.g. ``xilinx-u50lv-gen3x4-xdma-base``).
      * ``<deploy_version>`` is the deployment platform version identified in :ref:`step-identify-deployment-platform` (e.g. ``2``).
      * ``<pkg_release>`` is the xbtest package release version (e.g. ``1234567``).

.. _installed-content:

********************************************************
Installed content
********************************************************

After xbtest |Application software| packages installation, two executable files are present:

  * |Common software|: ``/opt/xilinx/xbtest/bin/xbtest``
  * |Test software|: ``/opt/xilinx/xbtest/6/bin/xbtest``

.. important::
    To ensure that the correct executable is used, the xbtest environment must be set up before running xbtest.
    Refer to :ref:`set-up-xbtest`, which also describes how to run a quick check of the installation.

After the |Platform specific library| installation, the following content is present:

  * One hardware application file (``xbtest_stress.xclbin``) containing specific compute units (GT MAC, GT PRBS, GT LPBK, memory, power and verify).
  * A set of pre-canned test JSON files, for example: ``verify``, ``dma``, ``p2p_card``, ``p2p_nvme``, ``memory``, ``gt_mac``, ``power`` and ``stress``.
  * Platform definition (``xbtest_pfm_def.json``) and configuration JSON files.

.. caution::
    These files are specific to each deployment platform. Do not edit them.

Various platform libraries can be installed and used simultaneously.
The following shows an example of some installed files and directory structure for two platforms, ``<Platform_A>`` and ``<Platform_B>``.

.. code-block:: bash

    /opt/xilinx/xbtest/
    ├── compatibility.json
    ├── README.md
    ├── setup.csh
    ├── setup.sh
    ├── license/
    ├── bin/
    │   └── xbtest*
    ├── 6/
    │   └── config.json
    │   └── README.md
    │   └── license/
    │   └── bin/
    │      └── xbtest*
    └── lib/
        ├── <Platform_A>/
        │   ├── config.json
        │   ├── README.md
        │   ├── xbtest_pfm_def.json
        │   ├── license/
        │   ├── xclbin/
        │   │   └── xbtest_stress.xclbin
        │   └── test/
        │       └── verify, dma, memory, power, stress.json
        └── <Platform_B>/
            ├── config.json
            ├── README.md
            ├── xbtest_pfm_def.json
            ├── license/
            ├── xclbin/
            │   └── xbtest_stress.xclbin
            └── test/
                └── verify, dma, p2p_card, p2p_nvme, gt_mac, switch, memory_host, memory, power, stress.json


Where:

.. code-block:: bash

    *: identifies an executable file
    /: identifies a folder

.. note::
    The folder ``test/`` contains the pre-canned test JSON files.
    The quantity and content of the pre-canned test JSON files depend on the deployment platform.

The |Common software| scans and checks all |Platform specific libraries| at start-up.
A library is ignored when it is not installed correctly.
For example, if:

  * Expected file does not exists.
  * JSON file syntax is invalid or content is not as expected.
  * |Test software| compatible with platform specific library (matching major version) is not installed.

When targeting a card for which the library is not correct, the |Common software| reports that the platform specific library is not found.

.. note::
    Invalid libraries are reported when using command line option :option:`-v` or :option:`-h`.

********************************************************
Removal
********************************************************

To fully remove xbtest run the command given in the following table based on your OS:

.. table:: xbtest packages removal

    +------------------+---------------------------------+
    | OS               | Command                         |
    +==================+=================================+
    | Red Hat / CentOS | .. code-block:: bash            |
    |                  |                                 |
    |                  |     $ sudo yum remove 'xbtest*' |
    |                  |                                 |
    +------------------+---------------------------------+
    | Ubuntu           | .. code-block:: bash            |
    |                  |                                 |
    |                  |     $ sudo apt remove 'xbtest*' |
    |                  |                                 |
    +------------------+---------------------------------+

.. caution::
    This will remove xbtest for all platforms.

.. _install-xbtest-to-another-location:

********************************************************
Install xbtest to another location
********************************************************

Different |Vitis|_ platforms could require different versions of xbtest but different versions of the same xbtest packages cannot be installed simultaneously with the OS package manager (for example, ``yum`` or ``apt``).

To install xbtest to a user specified location ``<target directory>``, use the following commands for each xbtest RPM or DEB package ``<xbtest pkg.rpm/deb>``:
This will extract xbtest package content to the installation directory ``<target directory>/opt/xilinx/xbtest/``.

.. warning::
    The directory structure ``opt/xilinx/xbtest`` must be preserved.

.. table:: Extract xbtest packages

    +------------------+--------------------------------------------------------------------+
    | OS               | Command                                                            |
    +==================+====================================================================+
    | Red Hat / CentOS | .. code-block:: bash                                               |
    |                  |                                                                    |
    |                  |     $ cd <target directory>; rpm2cpio <xbtest pkg.rpm> | cpio -idv |
    |                  |                                                                    |
    +------------------+--------------------------------------------------------------------+
    | Ubuntu           | .. code-block:: bash                                               |
    |                  |                                                                    |
    |                  |     $ dpkg -x <xbtest pkg.deb> <target directory>                  |
    |                  |                                                                    |
    +------------------+--------------------------------------------------------------------+

.. warning::
    RPM or DEB package dependencies are not checked with these commands.

Make sure that the dependency requirements of each xbtest packages ``<xbtest pkg.rpm/deb>`` are satisfied using the following commands:

.. table:: Check dependencies

    +------------------+------------------------------------+
    | OS               | Command                            |
    +==================+====================================+
    | Red Hat / CentOS | .. code-block:: bash               |
    |                  |                                    |
    |                  |     $ yum deplist <xbtest pkg.rpm> |
    |                  |                                    |
    |                  | or                                 |
    |                  |                                    |
    |                  | .. code-block:: bash               |
    |                  |                                    |
    |                  |     $ rpm -qpR <xbtest pkg.rpm>    |
    |                  |                                    |
    +------------------+------------------------------------+
    | Ubuntu           | .. code-block:: bash               |
    |                  |                                    |
    |                  |     $ dpkg-deb -I <xbtest pkg.deb> |
    |                  |                                    |
    +------------------+------------------------------------+
