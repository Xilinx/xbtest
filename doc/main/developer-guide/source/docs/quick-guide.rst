
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _quick-guide:

##########################################################################
Quick guide
##########################################################################

This quick guide lists the commands needed to build xbtest xclbin and HW packages.
More information is provided in other sections of the developer guide.

.. contents::
    :depth: 1
    :local:

********************************************************
Definition
********************************************************

This document uses the following definitions:

  * |<xbtest_catalog> def|
  * |<xbtest_build> def|
  * |<dev_platform> def|
  * |<deploy_platform> def|
  * |<project_name> def|
  * |<pkg_release> def|

********************************************************
Get xbtest sources and packages
********************************************************

Get xbtest sources and packages (see :ref:`xbtest-sources`):

.. code-block:: bash

    git clone https://github.com/Xilinx/xbtest <xbtest_local_repo>

********************************************************
Set up your environment
********************************************************

Execute the following commands to set up the |Vitis|_ environment for building xbtest:

.. code-block:: bash

    $ source <Vitis_Installation_Path>/Vitis/<Vitis_Version>/settings64.csh

See :ref:`environment-setup` for more details on setting up build environment and dependencies.

********************************************************
Move to the ``xclbin_generate`` directory
********************************************************

Change to the following working directory:

.. code-block:: bash

    $ cd <xbtest_build>/xclbin_generate

********************************************************
Initialize ``xclbin_generate`` input products
********************************************************

Run the following command to generate the templates for required |xclbin_generate| input products:

.. code-block:: bash

    $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> \
                            --xpfm path/to/platform.xpfm \
                            --init

.. note::
    Add the option :option:`--use_lsf` to run on LSF if needed.
    You can also enable |--verbose| for more detailed output.

See :ref:`workflows-initialization` for more details.

********************************************************
Get ``xclbin_generate`` input products templates
********************************************************

Get the generated templates of |xclbin_generate| input products:

.. code-block:: bash

    $ cp -r ./output/<dev_platform>/init/u_ex/run/cfg_template \
            ./cfg/<dev_platform>

See :ref:`environment-setup-and-workflows-initialization` for more details.

********************************************************
Generate power floorplan templates
********************************************************

From a DCP of your platform, generates templated of power CU floorplan configuration:

.. code-block:: bash

    $ vivado -mode tcl \
             -source ../tcl/power/gen_dynamic_geometry.tcl \
             -tclargs ./output/<dev_platform>/init/u_ex/run/vpp_link/link/vivado/vpl/prj/prj.runs/impl_1/level0_wrapper_opt.dcp \
                      ./cfg/<dev_platform>/pwr_cfg \
                      <pblocks>

See :ref:`environment-setup-and-workflows-initialization` for more details.

********************************************************
Customize ``xclbin_generate`` input products
********************************************************

You need to customize the following required |xclbin_generate| workflow inputs according to your requirements:

.. code-block::

    <xbtest_build>/xclbin_generate/cfg/<dev_platform>/wizard_cfg.json
    <xbtest_build>/xclbin_generate/cfg/<dev_platform>/pwr_cfg/utilization.json

Optionally, you need can also to customize the following:

.. code-block::

    <xbtest_build>/xclbin_generate/cfg/<dev_platform>/pwr_cfg/invalid.json
    <xbtest_build>/xclbin_generate/cfg/<dev_platform>/vpp_cfg/vpp.ini
    <xbtest_build>/xclbin_generate/cfg/<dev_platform>/vpp_cfg/postsys_link.tcl
    <xbtest_build>/xclbin_generate/cfg/<dev_platform>/vpp_cfg/place_design_pre.tcl
    <xbtest_build>/xclbin_generate/cfg/<dev_platform>/vpp_cfg/route_design_pre.tcl

For more details, refer to

  - :ref:`define-power-cu-floorplan`
  - :ref:`configure-xclbin`
  - :ref:`configure-vitis`

********************************************************
Generate xclbin
********************************************************

Use the following command to generate an xbtest xclbin based on your configuration provided using option :option:`--config_dir`:

.. code-block:: bash

    $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> \
                            --xpfm path/to/platform.xpfm \
                            --config_dir ./cfg/<dev_platform> \
                            --project_name <project_name>

.. note::
    Add the option :option:`--use_lsf` to run on LSF if needed.

    Option :option:`--xpfm` can specify a ``.xpfm`` or a ``.xsa`` file.
    It can be also be a ``.rpm`` package (if running on CentOS/Red Hat/SUSE) or a ``.deb`` package (if running on Ubuntu).

    You can also enable |--verbose| for more detailed output.

See :ref:`build-xclbin` for more details.

********************************************************
Move to the ``rpm_generate`` directory
********************************************************

Change to the following working directory:

.. code-block:: bash

    $ cd <xbtest_build>/rpm_generate/

********************************************************
Initialize ``rpm_generate`` input products
********************************************************

Create the following directories:

.. code-block:: bash

    $ mkdir -p <xbtest_build>/rpm_generate/include/<deploy_platform>/dcps
    $ mkdir -p <xbtest_build>/rpm_generate/include/<deploy_platform>/xclbin

Copy platform definition JSON file:

.. code-block:: bash

    $ cp -r <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/sw/xbtest_pfm_def_template.json \
            <xbtest_build>/rpm_generate/include/<deploy_platform>/xbtest_pfm_def.json

Copy xclbin:

.. code-block:: bash

    $ cp <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/<project_name>.xclbin \
         <xbtest_build>/rpm_generate/include/<deploy_platform>/xclbin/xbtest_stress.xclbin

Copy final DCP. For example:

.. code-block:: bash

    $ cp <xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/vpp_link/link/vivado/vpl/prj/prj.runs/impl_1/level0_wrapper_postroute_physopt.dcp \
         <xbtest_build>/rpm_generate/include/<deploy_platform>/dcps

.. note::
    If optional post-route physical design optimization was not enabled, copy the routed DCP ``level0_wrapper_routed.dcp``.

See :ref:`build-rpm-and-deb-packages` for more details.

********************************************************
Customize platform definition JSON file
********************************************************

While you complete your |checklist|, you will customize the platform definition JSON file ``<xbtest_build>/rpm_generate/include/<deploy_platform>/xbtest_pfm_def.json``.

********************************************************
Generate RPM/DEB packages
********************************************************

Run the following command on CentOS/Red Hat/SUSE to generate RPM package and then on Ubuntu to generate DEB package.

.. code-block:: bash

    $ python3 gen_rpm.py --deploy_name <deploy_name> \
                         --deploy_version <deploy_version> \
                         --include_dir <xbtest_build>/rpm_generate/include/<deploy_platform> \
                         --pkg_release <pkg_release>

For example, if you build the RPM/DEB on LSF, you can use the following commands:

  * For the RPM package:

    .. code-block:: bash

        $ echo "#\!/bin/bash \
        source path/to/opt/xilinx/xrt/setup.sh \
        python3 gen_rpm.py --deploy_name <deploy_name> --deploy_version <deploy_version> --include_dir <xbtest_build>/rpm_generate/include/<deploy_platform> --pkg_release <pkg_release> \
        " | tee -a ./build_rpm.sh
        $ chmod a+x ./build_rpm.sh
        $ bsub -I -R "select[ (osdistro=rhel || osdistro=centos) && (osver == ws8 || osver == cent8) ]" -q short "./build_rpm.sh"

  * For the DEB package:

    .. code-block:: bash

        $ echo "#\!/bin/bash \
        source path/to/opt/xilinx/xrt/setup.sh \
        python3 gen_rpm.py --deploy_name <deploy_name> --deploy_version <deploy_version> --include_dir <xbtest_build>/rpm_generate/include/<deploy_platform> --pkg_release <pkg_release> \
        " | tee -a ./build_deb.sh
        $ chmod a+x ./build_deb.sh
        $ bsub -I -R "select[(osdistro == ubuntu) && (ostype == ubuntu2004)]" -q short "./build_deb.sh"

.. note::
    In the commands above, update according to you environment:

      * Path to XRT script ``path/to/opt/xilinx/xrt/setup.sh``.
      * ``bsub`` command line options.
      * |rpm_generate| workflow options :option:`--deploy_name`, :option:`--deploy_version`, :option:`--include_dir` and :option:`--pkg_release`.

See :ref:`build-rpm-and-deb-packages` for more details.

