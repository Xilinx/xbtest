
.. include:: ../../shared/links.rst
.. include:: docs/share/links.rst
.. include:: docs/share/include.rst


.. include:: ../../shared/dochub.rst


##########################################################################
Developer guide
##########################################################################

.. toctree::
   :caption: Content
   :maxdepth: 3
   :hidden:

   ./docs/expected-tasks.rst
   ./docs/quick-guide.rst
   ./docs/architecture-and-workflows.rst
   ./docs/environment-setup-and-workflows-initialization.rst
   ./docs/define-power-cu-floorplan.rst
   ./docs/configure-xclbin.rst
   ./docs/configure-vitis.rst
   ./docs/build-xclbin.rst
   ./docs/xclbin-timing-closure-tips.rst
   ./docs/select-pre-canned-tests.rst
   ./docs/fill-platform-definition-json.rst
   ./docs/build-rpm-and-deb-packages.rst
   ./docs/complete-checklist.rst

********************************************************
Overview
********************************************************

The developer guide describes the steps to generate xbtest HW package for a targeted platform.

Start by getting acquainted with expected tasks described in :ref:`expected-tasks` and make sure you have all :ref:`developer-guide-prerequisite`.

The :ref:`quick-guide` lists the commands to run to generate xbtest from scratch from your development platform.

Templates and examples are provided in this guide.

.. note::
    OEM, EMC, Power & Thermal Qualifications are the main users of xbtest.

.. _developer-guide-prerequisite:

********************************************************
Prerequisites
********************************************************

xbtest requires:

.. table:: xbtest prerequisites

    +---------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Prerequisite                          | Description                                                                                                                                                    |
    +=======================================+================================================================================================================================================================+
    | Development platform (XPFM or HW XSA) |   * Platform supports PLRAMs.                                                                                                                                  |
    |                                       |   * GT defined in platform metadata.                                                                                                                           |
    +---------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Vitis/Vivado versions                 |   * 2022.1                                                                                                                                                     |
    |                                       |   * GT MAC CU uses and requires license for |XXV|_.                                                                                                            |
    +---------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Deployment server (for testing)       |   * Install your |Alveo|_ card(s), |XRT|_ (required >= 2.13.307) as per their respective UG.                                                                   |
    |                                       |   * Validate your card(s):                                                                                                                                     |
    |                                       |                                                                                                                                                                |
    |                                       |     .. code-block:: bash                                                                                                                                       |
    |                                       |                                                                                                                                                                |
    |                                       |         $ xbutil validate                                                                                                                                      |
    |                                       |                                                                                                                                                                |
    +---------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Xilinx AI Engine license              | A license for the AIE compiler is required to successfully build the power CU with AIE.                                                                        |
    |                                       |                                                                                                                                                                |
    |                                       |   * If you have an AIE compiler license, set the environment variable ``XILINXD_LICENSE_FILE`` to include that license before building xbtest xclbin.          |
    |                                       |                                                                                                                                                                |
    |                                       |   * If you do not have an AIE compiler license, do not use AIE in the power CU by setting ``AIE_UTILIZATION`` to 0 in your ``utilization.json`` configuration. |
    |                                       |                                                                                                                                                                |
    +---------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------+

********************************************************
What's new in xbtestv6?
********************************************************

xbtestv6 new main features w.r.t xbtestv5 are:

.. table:: xbtestv6 new main features

    +-----------------+-------------------------------------------------------+
    | Item            | New features                                          |
    +=================+=======================================================+
    | Memory testcase |   * Multiple AXI thread IDs.                          |
    |                 |   * Maximum number of outstanding transactions.       |
    +-----------------+-------------------------------------------------------+
    | Power testcase  |   * AIE support.                                      |
    |                 |   * Throttle source: external/internal clock/macro.   |
    |                 |   * Floorplan format.                                 |
    +-----------------+-------------------------------------------------------+
    | GT testcase     |   * GT_MAC to GT_MAC loopback.                        |
    |                 |   * GT_PRBS CU.                                       |
    |                 |   * GT_LPBK CU.                                       |
    +-----------------+-------------------------------------------------------+
    | Ease of use     |   * Result visualization with Vitis Analyzer.         |
    |                 |   * HW/SW configuration.                              |
    +-----------------+-------------------------------------------------------+
    | Performances    |   * XRT API support.                                  |
    +-----------------+-------------------------------------------------------+
    | Build flow      |   * Python workflows.                                 |
    |                 |   * Automatic generation of all pre-canned tests.     |
    |                 |   * Automatic generation of templates. For example:   |
    |                 |                                                       |
    |                 |       * :ref:`platform-definition-JSON-file-template` |
    |                 |       * ``utilization_template.json``                 |
    |                 |       * ``invalid_template.json``                     |
    +-----------------+-------------------------------------------------------+


.. include:: ../../shared/other-versions.rst

