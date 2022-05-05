
.. include:: ../../shared/links.rst
.. include:: docs/links.rst


.. include:: ../../shared/dochub.rst


##########################################################################
Checklist
##########################################################################

********************************************************
Goal
********************************************************

The goals of the checklist are to:

  * Verify that your xbtest xclbin will work on your |Alveo|_ platform.
  * Customize xbtest for your platform. 
    xbtest SW is generic and works with all platforms and thus requires being customized.
    This is done via a **platform definition JSON file** (this file is loaded by xbtest SW at execution).

The generation of the xclbin produces 2 sets of templates:

  * **Platform definition JSON file**: ``xbtest_pfm_def_template.json``. See |fill-platform-definition-json0|_.
  * **Pre-canned tests**: ``test/*.json``.  See |select-pre-canned-tests|_.

By doing this checklist, you will fill along your **platform definition JSON file** which will be used to particularize xbtest SW to your platform.
You'll be also required to run the pre-canned tests.

.. important::
    The first initial run of pre-canned tests will report errors as the platform definition template contains standard thresholds (which you'll update while filling the checklist).

    If a default pre-canned test is failing, and it's because a nominal setting is wrong.
    Then you should update the setting in platform definition JSON file.
    It's an iterative process.

You should complete a new checklist for each xbtest package delivery.

********************************************************
Prerequisite
********************************************************

Some tests are run while completing your checklist.

  * These tests shall ideally be run on a DELL PowerEdge R740 or R7525 server set with 100% fan speed.
  * If other cards are present in the server, they shall not be used.
  * Released version of |XRT|_ compatible with xbtest shall be used.

********************************************************
Steps
********************************************************

Follow the checklist instructions:

.. toctree::
   :maxdepth: 1
   :caption: Checklist instructions

   ./docs/requirement-platform-high-level-features.rst
   ./docs/calibration-power-cu.rst
   ./docs/calibration-memory-cu-power.rst
   ./docs/calibration-memory-bandwidth-and-latency.rst
   ./docs/platform-definition-json-file.rst
   ./docs/pre-canned-tests.rst

These instructions will guide you to complete your checklist by filling the following template (All ``<TBC>`` will be replaced).

.. toctree::
   :maxdepth: 1
   :caption: Checklist template

   Checklist template <./docs/template/checklist.rst>

Refer to the following examples of checklist filled for various platforms:

.. toctree::
   :maxdepth: 1
   :caption: Checklist examples

   xilinx-u50lv-gen3x4-xdma-base-2 <docs/xilinx-u50lv-gen3x4-xdma-base-2/checklist.rst>
   xilinx-u55c-gen3x16-xdma-base-3 <docs/xilinx-u55c-gen3x16-xdma-base-3/checklist.rst>
   xilinx-u250-gen3x16-xdma-shell-4.1 <docs/xilinx-u250-gen3x16-xdma-shell-4.1/checklist.rst>


.. include:: ../../shared/other-versions.rst

