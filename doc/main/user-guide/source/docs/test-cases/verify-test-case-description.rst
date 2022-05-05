
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _verify-test-case-description:

##########################################################################
Verify test case description
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2

The verify test case is always executed at the start of any test and is not configurable.

If any of the described checks fail, then none of the test cases are executed.
xbtest software automatically detects the compute units (CUs) present in the |xclbin|.
The verify test case cross-checks the contents of xclbin for the following:

  * Its compatibility with the |Application software|.
  * The content of the test JSON file.

********************************************************
Compute units verification
********************************************************

Once uniquely identified, each CU present in the |xclbin| is checked for:

  * Compatibility with application software version.
  * Basic communication where multiple read/write data transfers to each CU scratch register are performed.

********************************************************
Test JSON file verification
********************************************************

An initial sanity check of the test JSON file is performed when the application software starts.
All JSON members are checked for validity and compatibility (value type and range) with the application software and the platform definition JSON file.
This also includes a check of the ``test_sequence`` parameters for each test case.

  * If a test case is described in the test JSON file, but the |xclbin| does not contain the associated CU, then the verify test case fails.
  * If a test case is not described in the test JSON file, the associated CU will stay in its idle state, and it is not considered to be a verify test case failure.
