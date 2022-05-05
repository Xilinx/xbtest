
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _build-rpm-and-deb-packages:

##########################################################################
Build RPM and DEB packages
##########################################################################

********************************************************
Overview
********************************************************

.. include:: share/note-iterative-pkg.rst

After following the steps specified in previous chapters, you can generate the RPM and DEB HW packages using the |rpm_generate| workflow.

A HW package is composed by:

  * **xclbin**: it contains various Compute Unit (CU). It's the CU which will test and check the performance of your platform in tandem with xbtest SW.
  * **Platform definition JSON file**: it describes to xbtest SW what your platform is capable of. 
    It also includes limits and settings to show case the highest performances of the platform.
  * ``test`` **folder**: it contains a series of pre-canned tests JSON.

      * You'll use them to characterize your platform (limits and performance settings).
      * These tests can be used by any user as template.

You must provide these files to the |rpm_generate| workflow using command line option :option:`--include_dir`.

  * Except for the pre-canned tests if you're using the default ones.

The workflow allows you to:

  * Name/version your package.
  * Create dependencies toward specific deployment platform (name & version).

********************************************************
Pre-requisites
********************************************************

You need to:

  * Copy the xclbin from the |xclbin_generate| workflow.
  * Copy the updated :ref:`platform-definition-JSON-file` (see :ref:`fill-platform-definition-json`).
  * Provide pre-canned tests if you're not using the default ones.

.. note::
    The instructions below are valid if you follow the default directory structure.

=====================================================
Copy xclbin and ``xbtest_pfm_def.json``
=====================================================

Once the xclbin is successfully generated, copy the xclbin from the |xclbin_generate| workflow (see :ref:`build-xclbin`).

  * |<xbtest_build> def|
  * |<dev_platform> def|
  * |<deploy_platform> def|
  * |<project_name> def|

Create the following directories:

.. code-block:: bash

    $ mkdir -p <xbtest_build>/rpm_generate/include/<deploy_platform>/xclbin
    $ mkdir -p <xbtest_build>/rpm_generate/include/<deploy_platform>/dcps

Copy platform definition JSON file:

.. code-block:: bash

    $ cp path/to/updated/xbtest_pfm_def.json \
         <xbtest_build>/rpm_generate/include/<deploy_platform>/xbtest_pfm_def.json

If you've updated any of the pre-canned tests:

.. code-block:: bash

    $ cp path/to/ALL/pre_canned_test.json \
       <xbtest_build>/rpm_generate/include/<deploy_platform>/test/pre_canned_test.json

.. caution::
    If you decide to modify in any manner any of the pre-canned test JSON files, you must include **all** needed tests when creating the packages (including the un-modified ones).

Copy xclbin:

.. code-block:: bash

    $ cp <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/<project_name>.xclbin \
         <xbtest_build>/rpm_generate/include/<deploy_platform>/xclbin/xbtest_stress.xclbin

Copy final DCP. For example:

.. code-block:: bash

    $ cp <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/vpp_link/link/vivado/vpl/prj/prj.runs/impl_1/level0_wrapper_postroute_physopt.dcp \
         <xbtest_build>/rpm_generate/include/<deploy_platform>/dcp/

.. tip::
    Copying DCP is optional but it is recommended to save it somewhere (as it may useful for any analysis of the xclbin).

    The DCP won't be included in the package.

********************************************************
``rpm_generate`` workflow input and output products
********************************************************

The required structure and file naming of the |rpm_generate| workflow input products and location of output products is detailed in following table:

  * |<xbtest_build> def|
  * |<deploy_name> def|
  * |<deploy_version> def|
  * |<deploy_platform> def|
  * |<pkg_release> def|

.. table:: ``rpm_generate`` workflow input and output products

    +-------------------------------------------------------+--------------------------------------------------------------------+--------------------------+-------------------+------------------------------------------------------------------------+
    | File/directory name                                                                                                                                   | Required/optional | Description                                                            |
    +-------------------------------------------------------+--------------------------------------------------------------------+--------------------------+                   +                                                                        +
    | Level 1                                               | Level 2                                                            | Level 3                  |                   |                                                                        |
    +=======================================================+====================================================================+==========================+===================+========================================================================+
    | **Input products**                                                                                                                                                                                                                                 |
    +-------------------------------------------------------+--------------------------------------------------------------------+--------------------------+-------------------+------------------------------------------------------------------------+
    | <xbtest_build>/rpm_generate/include/<deploy_platform> | xclbin                                                             | xbtest_stress.xclbin     | Required          | xclbin copied from |xclbin_generate| output products.                  |
    +-------------------------------------------------------+--------------------------------------------------------------------+--------------------------+-------------------+------------------------------------------------------------------------+
    |                                                       | xbtest_pfm_def.json                                                |                          | Required          | Platform definition JSON file updated after completing checklist.      |
    +                                                       +--------------------------------------------------------------------+--------------------------+-------------------+------------------------------------------------------------------------+
    |                                                       | test                                                               | dma.json                 | Optional          | Pre-canned tests JSON files.                                           |
    +                                                       +--------------------------------------------------------------------+--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | memory.json              | Optional          | .. important::                                                         |
    +                                                       +                                                                    +--------------------------+-------------------+     Do not include any tests if you're using default pre-canned tests. +
    |                                                       |                                                                    | memory_host.json         | Optional          |                                                                        |
    +                                                       +                                                                    +--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | power.json               | Optional          |                                                                        |
    +                                                       +                                                                    +--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | gt_mac.json              | Optional          |                                                                        |
    +                                                       +                                                                    +--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | switch_10gbe.json        | Optional          |                                                                        |
    +                                                       +                                                                    +--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | switch_25gbe.json        | Optional          |                                                                        |
    +                                                       +                                                                    +--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | gt_prbs.json             | Optional          |                                                                        |
    +                                                       +                                                                    +--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | gt_mac_lpbk.json         | Optional          |                                                                        |
    +                                                       +                                                                    +--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | gt_mac_port_to_port.json | Optional          |                                                                        |
    +                                                       +                                                                    +--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | stress.json              | Optional          |                                                                        |
    +                                                       +                                                                    +--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | verify.json              | Required          |                                                                        |
    +                                                       +                                                                    +--------------------------+-------------------+                                                                        +
    |                                                       |                                                                    | your_test.json           | Optional          |                                                                        |
    +-------------------------------------------------------+--------------------------------------------------------------------+--------------------------+-------------------+------------------------------------------------------------------------+
    | **Output products**                                                                                                                                                                                                                                |
    +-------------------------------------------------------+--------------------------------------------------------------------+--------------------------+-------------------+------------------------------------------------------------------------+
    | <xbtest_build>/rpm_generate                           | xbtest-<deploy_name>-<deploy_version>_6.0-<pkg_release>_all.deb    |                          | Required          | DEB package (Ubuntu).                                                  |
    +-------------------------------------------------------+--------------------------------------------------------------------+--------------------------+-------------------+------------------------------------------------------------------------+
    |                                                       | xbtest-<deploy_name>-<deploy_version>-6.0-<pkg_release>.noarch.rpm |                          | Required          | RPM package (CentOS/Red Hat/SUSE).                                     |
    +-------------------------------------------------------+--------------------------------------------------------------------+--------------------------+-------------------+------------------------------------------------------------------------+

The |rpm_generate| workflow generates the following packages when running on:

  * **CentOS/Red Hat/SUSE**: RPM package named xbtest-``<deploy_name>``\ -``<deploy_version>``\ -6.0-``<pkg_release>``\ .noarch.rpm
  * **Ubuntu**: DEB package named xbtest-``<deploy_name>``\ -``<deploy_version>``\ _6.0-``<pkg_release>``\ _all.deb

Where:

  * |<deploy_name> def|
  * |<deploy_version> def|
  * |<pkg_release> def|

.. important::

    The |rpm_generate| workflow uses values provided with options :option:`--deploy_name` and :option:`--deploy_version` to add a dependency to the generated package.

    When installing the generated package on the deployment host, the deployment platform package named ``<deploy_name>`` and version equal to ``<deploy_version>`` must be already installed on the host.

    The option :option:`--dependency` allows to specify additional dependencies to the generated package.

.. note::
    The |rpm_generate| workflow uses the following command to detect the ID of the OS distribution:

    .. code-block:: bash

        $ lsb_release -is

    The supported values returned by this command are ``CentOS``, ``RedHatEnterprise``, ``SUSE`` and ``Ubuntu``.

********************************************************
``rpm_generate`` workflow command line options
********************************************************

The |rpm_generate| workflow supports the following command line options described in next sections.
You can always refer to the help of the workflow for a quick summary of the various options.
Each option can be specified fully or in short manner.

.. contents::
    :depth: 1
    :local:

----

=====================================================
-h, --help: Display help
=====================================================

.. option:: -h, --help

    Display |rpm_generate| workflow help message.

----

=====================================================
-V, --verbose: Enable verbosity
=====================================================

.. option:: -V, --verbose

    Turn on verbosity.

----

=====================================================
-n, --deploy_name: Define deployment platform name
=====================================================

.. option:: -n <name>, --deploy_name <name>

    Mandatory.
    Deployment platform name, e.g. ``xilinx-u50-gen3x4-xdma-base``.

----

========================================================
-m, --deploy_version: Define deployment platform version
========================================================

.. option:: -m <version>, --deploy_version <version>

    Mandatory.
    Deployment platform version, e.g. ``2``.

----

=====================================================
-i, --include_dir: Select include directory
=====================================================

.. option:: -i <dir>, --include_dir <dir>

    Include directory: location of files to be included in package (xclbin, :ref:`platform-definition-JSON-file` and pre-canned test JSON files).

    Default: ``./include/<deploy_name>-<deploy_version>``.

    .. important::
       If this directory does not contain any test folder, then you are using default pre-canned tests.

----

=====================================================
-r, --pkg_release: Provide package release
=====================================================

.. option:: -r <rel>, --pkg_release <rel>

    Package release. Default ``1``.

----

=====================================================
-D / –-dependency: Provide dependency
=====================================================

.. option:: -D <dep>, --dependency <dep>

    Provide additional dependencies to be added to the generated RPM/DEB package metadata. A version requirement can be specified with an operator.

    Dependencies must be specified with valid:

      * For CentOS / Red Hat: RPM SPEC file format (see directive ``Requires``).
      * For Ubuntu: DEB CONTROL file format (see tag ``Depends``).

    For example, you can specify a dependency with specific package (``xilinx-u50lv-gen3x4-xdma-base``), version (``2``) and release (``123456``) with the following command:

      * For CentOS / Red Hat:

        .. code-block:: bash

            $ python3 gen_rpm.py --dependency "xilinx-u50lv-gen3x4-xdma-base=2-123456" --deploy_name xilinx-u50lv-gen3x4-xdma-base --deploy_version 2

      * For Ubuntu:

        .. code-block:: bash

            $ python3 gen_rpm.py --dependency "xilinx-u50lv-gen3x4-xdma-base (= 2-123456)" --deploy_name xilinx-u50lv-gen3x4-xdma-base --deploy_version 2

    This option can be provided multiple times in the command line.

----

=====================================================
 -o, --output_dir: Provide output directory
=====================================================

.. option:: -o <dir>, --output_dir <dir>

    Path to the output directory. Default: ``./output/<date>_<time>/``.

----

=====================================================
-f, --force: Force an operation
=====================================================

.. option:: -f, --force

    Override output directory if already existing.

----

=====================================================
-v, --version: Display version
=====================================================

.. option:: -v, --version

    Display |rpm_generate| workflow version.

********************************************************
Run ``rpm_generate`` Workflow
********************************************************

|rpm_generate| is a python workflow to run with python3.

You must run this workflow per OS you want to release an HW package for:

  * On CentOS/Red Hat/SUSE to generate the RPM package.
  * On Ubuntu to generate the DEB package.

Make sure you have completed the |checklist| which might require re-generating the RPM/DEB packages.

Use the following commands to generate the RPM/DEB:

  1. Move to |rpm_generate| sources directory:

     .. code-block:: bash

         $ cd <xbtest_build>/rpm_generate

  2. Generate RPM/DEB package either:

     * Using default option :option:`--include_dir`:

       .. code-block:: bash

           $ python3 gen_rpm.py --deploy_name <deploy_name> --deploy_version <deploy_version>

       For example, for u50:

       .. code-block:: bash

           $ python3 gen_rpm.py --deploy_name xilinx-u55c-gen3x16-xdma-base --deploy_version 3

       This command generates the following package when run on:

         * **CentOS/Red Hat/SUSE**: xbtest-xilinx-u55c-gen3x16-xdma-base-3-6.0-1.noarch.rpm
         * **Ubuntu**: xbtest-xilinx-u55c-gen3x16-xdma-base-3_6.0-1.deb

     * Providing option :option:`--include_dir`:

       .. code-block:: bash

           $ python3 gen_rpm.py --deploy_name <deploy_name> --deploy_version <deploy_version> --include_dir path/to/another/include/directory

     * Specifying a package release with option :option:`--pkg_release`:

       .. code-block:: bash

           $ python3 gen_rpm.py --pkg_release <pkg_release> --deploy_name <deploy_name> --deploy_version <deploy_version>

       For example, for u250 providing a package release:

       .. code-block:: bash

           $ python3 gen_rpm.py --pkg_release 123456 --deploy_name xilinx-u250-gen3x16-xdma-shell --deploy_version 4.1

       This command generates the following package when run on:

         * **CentOS/Red Hat/SUSE**: xbtest-xilinx-u250-gen3x16-xdma-shell-4.1-6.0-123456.noarch.rpm
         * **Ubuntu**: xbtest-xilinx-u250-gen3x16-xdma-shell-4.1_6.0-123456_all.deb

This workflow will create a run directory per RPM/DEB build: ``<xbtest_build>/rpm_generate/output/<date>_<time>``.
The generated output RPM/DEB packages will be moved to ``<xbtest_build>/rpm_generate`` directory.

At the end of the RPM/DEB generation, |rpm_generate| workflow output contains ``[GEN_RPM-40]`` message, like the following:

.. code-block:: bash
    :emphasize-lines: 8

    STATUS: [GEN_RPM-33] *** [2021-10-11, 11:18:02] Starting step: generate RPM package
    STATUS: [GEN_RPM-34] Executing: $ rpmbuild --verbose --define _topdir <xbtest_build>/rpm_generate/output/2021-10-11_11-18-02 -bb <xbtest_build>/rpm_generate/output/2021-10-11_11-18-02/SPECS/specfile.spec
    STATUS: [GEN_RPM-34] Log file: <xbtest_build>/rpm_generate/output/2021-10-11_11-18-02/rpmbuild.log
    STATUS: [GEN_RPM-35] ************************** End of step. Elapsed time: 0:00:08


    INFO: [GEN_RPM-39] Package generated successfully: <xbtest_build>/rpm_generate/output/2021-10-11_11-18-02/RPMS/noarch/xbtest-xilinx-u55c-gen3x16-xdma-base-3-6.0-1.noarch.rpm
    INFO: [GEN_RPM-40] Copy output package: <xbtest_build>/rpm_generate/xbtest-xilinx-u55c-gen3x16-xdma-base-3-6.0-1.noarch.rpm
    INFO: [GEN_RPM-8] --------------------------------------------------------------------------------------
    INFO: [GEN_RPM-8] [2021-10-11, 11:18:10] gen_rpm.py END. Total Elapsed Time: 0:00:27
    INFO: [GEN_RPM-8] ------------------------------------------------------------------------------------
