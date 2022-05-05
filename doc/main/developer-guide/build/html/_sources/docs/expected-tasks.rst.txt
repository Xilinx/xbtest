
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _expected-tasks:

##########################################################################
Expected tasks
##########################################################################

********************************************************
Overview
********************************************************

From xbtest team, you've received HW sources (+ examples & templates).
With these sources, you'll be able to create your own xbtest HW packages.

A HW package is composed by:

  * **xclbin**: It contains various compute units (CUs).
    The CUs test and check the performance of your platform in tandem with xbtest host application (SW).
  * **Platform definition JSON file**: It describes what your platform is capable of and is consumed by xbtest SW.
    It also includes limits and settings to show case the highest performances of the platform.
  * ``test`` **folder**: It contains a series of pre-canned test JSON files.

      * You'll use them to characterize your platform (limits and performance settings).
      * These tests can be used by any user as template.

After generating your xclbin, you will have to fill a |checklist|.
It's during its filling that you will gather all information required by the platform definition JSON file.

  * If the performances are not as expected (bandwidth, power reached), you may need to update the xclbin configuration.

This following diagram describes the expected tasks involved in the delivery of xbtest HW packages:

.. figure:: ./diagram/expected-tasks.svg
    :align: center

    Expected tasks

********************************************************
Description
********************************************************

Here are more details about the required tasks and where you can find information to execute them:

  * General information about CUs and build flows: :ref:`architecture-and-workflow`
  * Environment setup: :ref:`environment-setup-and-workflows-initialization`

.. table:: Expected tasks

    +---+--------------------------------------+------------------------+----------------------------------------------------------------------------------------------------------------+----------------------------+
    | # | Task                                 | Actor                  | Description                                                                                                    | Milestone                  |
    +===+======================================+========================+================================================================================================================+============================+
    | 1 |  Provide:                            | **xbtest team**        | Documentation includes:                                                                                        | **xbtest sources release** |
    |   |                                      |                        |                                                                                                                |                            |
    |   |    * Documentation.                  |                        |   * |xbtest UG|_.                                                                                              |                            |
    |   |    * HW sources.                     |                        |   * |xbtest DevG|_ (this documentation).                                                                       |                            |
    |   |    * Templates & examples.           |                        |   * |xbtest CHKL|_.                                                                                            |                            |
    |   |    * xbtest host application.        |                        |                                                                                                                |                            |
    |   |                                      |                        | HW sources includes (see :ref:`xbtest-sources`):                                                               |                            |
    |   |                                      |                        |                                                                                                                |                            |
    |   |                                      |                        |   * RTL sources.                                                                                               |                            |
    |   |                                      |                        |   * Workflows necessary to build xclbin and RPM/DEB packages.                                                  |                            |
    |   |                                      |                        |                                                                                                                |                            |
    |   |                                      |                        | Templates and examples provided for any required workflow input:                                               |                            |
    |   |                                      |                        |                                                                                                                |                            |
    |   |                                      |                        |   * Full u55c, u250 and u50lv examples provided.                                                               |                            |
    |   |                                      |                        |                                                                                                                |                            |
    |   |                                      |                        | Host application (pre-compiled): ``xbtest-sw-6`` and ``xbtest-common`` RPM/DEB packages.                       |                            |
    +---+--------------------------------------+------------------------+----------------------------------------------------------------------------------------------------------------+----------------------------+
    | 2 | :ref:`define-power-cu-floorplan`     | **xbtest developer**   | Based on your platform metadata (PLRAM, GT, SLR, memories), you can select which CU you want to include.       |                            |
    |   | and                                  |                        | Some CUs require careful configuration.                                                                        |                            |
    |   | :ref:`configure-xclbin`              |                        | Updates may be required after |checklist| is completed.                                                        |                            |
    +---+--------------------------------------+------------------------+----------------------------------------------------------------------------------------------------------------+----------------------------+
    | 3 | :ref:`build-xclbin`                  | **xbtest developer**   | xclbin generation (see also :ref:`xclbin-timing-closure-tips`).                                                |                            |
    +---+--------------------------------------+------------------------+----------------------------------------------------------------------------------------------------------------+----------------------------+
    | 4 | :ref:`select-pre-canned-tests`       | **xbtest developer**   | Automatically created based on xclbin content.                                                                 |                            |
    +---+--------------------------------------+------------------------+----------------------------------------------------------------------------------------------------------------+----------------------------+
    | 5 | :ref:`fill-platform-definition-json` | **xbtest developer**   | Basic template available.                                                                                      |                            |
    |   |                                      |                        | Update is required during |checklist| completion.                                                              |                            |
    +---+--------------------------------------+------------------------+----------------------------------------------------------------------------------------------------------------+----------------------------+
    | 6 | :ref:`build-rpm-and-deb-packages`    | **xbtest developer**   | Package include xclbin, pre-canned tests JSON, and platform definition JSON files.                             |                            |
    +---+--------------------------------------+------------------------+----------------------------------------------------------------------------------------------------------------+----------------------------+
    | 7 | :ref:`complete-checklist`            | **xbtest developer**   | Calibration and basic tests defined in a checklist to be completed for xclbin verification,                    | **xbtest RPM/DEB release** |
    |   |                                      |                        | Update platform definition JSON files and generate RPM/DEB with it after checklist completion.                 |                            |
    +---+--------------------------------------+------------------------+----------------------------------------------------------------------------------------------------------------+----------------------------+
    | 8 | Run xbtest                           | **xbtest user**        | Run xbtest, create test JSON files based on pre-canned tests.                                                  |                            |
    +---+--------------------------------------+------------------------+----------------------------------------------------------------------------------------------------------------+----------------------------+
