
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _command-line-options:

##########################################################################
Command line options
##########################################################################

********************************************************
Command line options definition
********************************************************

xbtest supports the following command line options described in next sections:

.. contents::
    :depth: 1
    :local:

----

=====================================================
-v: Display version
=====================================================

.. option:: -v

    Display xbtest version [1]_. There are two version levels:

      * |Common software|:

        .. code-block:: bash

            $ xbtest -v

      * |Test software|: version for the selected platform (:option:`-d`).

        .. code-block:: bash

            $ xbtest -d <BDF> -v

----

=====================================================
-h: Display help
=====================================================

.. option:: -h

    Display help message and command line options available [1]_.
    There are two help levels:

      * |Common software|: Command line options and the list of all installed platforms supported by xbtest with their respective pre-canned tests.

        .. code-block:: bash

            $ xbtest -h

      * |Test software|: Command line options for the selected platform (:option:`-d`).

        .. code-block:: bash

            $ xbtest -d <BDF> -h

----

=====================================================
-d: Select card
=====================================================

.. option:: -d <BDF>

    Select the Alveo card identified by its ``<BDF>``.

    The command line:

      * Must start with an option :option:`-d`. Other options following will be applied for the same group of cards.
      * Cannot finish with an option :option:`-d`.

    Maximum number of times option :option:`-d` is present in command line is 100.

    See :ref:`identifying-a-deployment-platform` to find the ``<BDF>`` of the card installed in your system.

    .. code-block:: bash

        $ xbtest -d <BDF> -j path/to/my_tests.json

----

=====================================================
-g: Display guide
=====================================================

.. option:: -g <test case/task>

    Display a guide for the given ``<test case/task>`` [1]_.

    This guide includes JSON members description, test sequence definition with examples and basic test JSON file examples.

    To obtain the list of test cases available use the |Test software| command line option :option:`-h`.

    .. note::
        This option must be used with command line option :option:`-d`.

    .. code-block:: bash

        $ xbtest -d <BDF> -g <test case/task>

----

=====================================================
-j: Select test JSON
=====================================================

.. option:: -j path/to/my_tests.json

    Select test JSON file ``path/to/my_tests.json`` defining the test cases to run [2]_.

    See :ref:`test-json-file-structure` for more information on the definition of the test JSON file content.

    .. code-block:: bash

        $ xbtest -d <BDF> -j path/to/my_tests.json

----

=====================================================
-c: Select pre-canned test
=====================================================

.. option:: -c <pre-canned test>

    Select a pre-canned test ``<pre-canned test>`` to run [2]_.

    To obtain the list of pre-canned tests available and their location in the installation directory use the |Test software| command line option :option:`-h`.

    See :ref:`pre-canned-tests-description` for more information on the quantity and content of these platform specific tests.

    .. code-block:: bash

        $ xbtest -d <BDF> -c <pre-canned test>

----

=====================================================
-T: Select P2P target card
=====================================================

.. option:: -T <P2P target card BDF>

    Select the Alveo card, identified by its ``<BDF>``, used as P2P target in the |P2P CARD| test case.

    This option is used, the command line:

      * Must contain only one option :option:`-d` which selects the Alveo card used as P2P source.
      * Cannot contain option :option:`-N` which is used for the |P2P NVME| test case.

    See :ref:`identifying-a-deployment-platform` to find the ``<BDF>`` of the card installed in your system.

    .. code-block:: bash

        $ xbtest -d <P2P source card BDF> -T <P2P target card BDF> -j path/to/my_tests.json

----

=====================================================
-N: Select P2P NVMe path
=====================================================

.. option:: -N <P2P NVMe Path>

    Select the path to the NVMe SSD used in the |P2P NVME| test case.

    This option is used, the command line:

      * Must contain only one option :option:`-d` which selects the Alveo card used as P2P source or target.
      * Cannot contain option :option:`-T` which is used for the |P2P CARD| test case.

    .. code-block:: bash

        $ xbtest -d <BDF> -N <P2P NVMe Path> -j path/to/my_tests.json

    The P2P NVMe path can be for example:

      * A file path in a mounted file system:

        .. code-block:: bash

            $ xbtest -d <BDF> -N /mnt/nvme0n1p1/file.dat -j path/to/my_tests.json

      * A partition node:

        .. code-block:: bash

            $ xbtest -d <BDF> -N /dev/nvme0n1p1 -j path/to/my_tests.json

      * A device node:

        .. code-block:: bash

            $ xbtest -d <BDF> -N /dev/nvme0n1 -j path/to/my_tests.json

----

=====================================================
-D: Select card configuration JSON
=====================================================

.. option:: -D path/to/card_cfg.json

    Provide a card configuration JSON file ``path/to/card_cfg.json``.

    This file can be used, instead of the command line, to select cards, test JSON files and pre-canned tests.

    This option can be provided only once and cannot be combined with the -d, -c, -j options.

    See :ref:`card-configuration-JSON-file` section for more information on the parameters supported in this file. 

    .. code-block:: bash

        $ xbtest -D path/to/card_cfg.json

----

=====================================================
-l: Select logging directory
=====================================================

.. option:: -l path/to/log_dir

    Define the name of a directory ``path/to/log_dir`` in which all log files will be stored, for example output files of any test case will be stored [3]_.

    When not specified, logging directory is still generated with a default name.

    If the provided directory already exists, then the command line option :option:`-f` must be provided to override the directory: all contents of the directory will be removed.

    See :ref:`result-directory` section for more information on the different directories and files generated by xbtest.

    .. code-block:: bash

        $ xbtest -l path/to/log_dir -d <BDF> -j path/to/my_tests.json

----

=====================================================
-L: Disable logging directory
=====================================================

.. option:: -L

    Disable logging directory generation in which all output files of any test case will be stored [3]_.

    No message displayed during the execution will be stored.

    .. code-block:: bash

        $ xbtest -L -d <BDF> -j path/to/my_tests.json

----

=====================================================
 -m: Display message information
=====================================================

.. option:: -m <message ID>

    Display message information for the given ``<message ID>``: severity, details or resolution (when applicable) [1]_.

    .. code-block:: bash

        $ xbtest -d <BDF> -m <message ID>

----

=====================================================
-F: Disable dynamic display
=====================================================

.. option:: -F

    Disable the dynamic display mode.

    When not provided, xbtest defaults to the dynamic display mode.

    See :ref:`display-modes` section for more information on the messages displayed by xbtest in the console.

    .. code-block:: bash

        $ xbtest -F -d <BDF> -j path/to/my_tests.json

----

=====================================================
-f: Force an operation
=====================================================

.. option:: -f

    When possible, force an operation.

    This can be used to override an already existing logging directory provided with option :option:`-l`: all contents of the directory will be removed.

    .. code-block:: bash

        $ xbtest -f -l <PathTo/LogDirToOverride> -d <BDF> -j path/to/my_tests.json

----

=====================================================
-b: Select verbosity
=====================================================

.. option:: -b <verbosity level>

    Select the verbosity level ``<verbosity level>``;

    Possible values: ``-1`` or ``-2``.

    This enables display of extra messages with ``DESIGNER`` or ``DEBUG`` severity (see :ref:`understanding-xbtest-messages`).

    .. code-block:: bash

        $ xbtest -b <verbosity level> -d <BDF> -j path/to/my_tests.json

    The following table describes these two other severities:

    .. table:: Extra verbosity level

        +--------------+-------+--------------------------------------------------------------------------------------------------+
        | Verbosity    | Value | Details                                                                                          |
        +==============+=======+==================================================================================================+
        | ``DEBUG``    | -1    | Intermediate results/measurements/test steps.                                                    |
        |              |       | The handiest one to debug a tricky situation and have more information about the ongoing test.   |
        +--------------+-------+--------------------------------------------------------------------------------------------------+
        | ``DESIGNER`` | -2    | Lowest level message used for example during OpenCL calls.                                       |
        |              |       | To be used only in very rare occasion, for example if the board/SW hangs.                        |
        +--------------+-------+--------------------------------------------------------------------------------------------------+

    These ``DEBUG`` and ``DESIGNER`` messages are not supported by command line option :option:`-m`.

    There are no details, nor resolution available.
    There are no rules about their content or even their accuracy (the best way to understand them is to have access to the SW source code to follow their generation).

----

=====================================================
-t: Select timestamp
=====================================================

.. option:: -t <timestamp>

    Select the timestamp mode ``<timestamp>``;

    Possible values: ``none``, ``absolute`` and ``differential``.

    Defaults to none when not specified.

    .. code-block:: bash

        $ xbtest -t <timestamp> -d <BDF> -j path/to/my_tests.json

    The following table described the supported timestamp modes.

    .. table:: Timestamp modes

        +------------------+------------------------------------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------+
        | Mode             | Details                                                                                                                            | Example                                                                   |
        +==================+====================================================================================================================================+===========================================================================+
        | ``none``         | By default, no timestamp is used in the log messages.                                                                              | .. code-block:: bash                                                      |
        |                  |                                                                                                                                    |                                                                           |
        |                  |                                                                                                                                    |     STATUS :: CMN_032 :: POWER :: Start Test 1: [300, 49]                 |
        |                  |                                                                                                                                    |                                                                           |
        +------------------+------------------------------------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------+
        | ``absolute``     | The absolute elapsed wall-clock time since some arbitrary, fixed point in the past (typically since reboot of the server).         | .. code-block:: bash                                                      |
        |                  | This is handy to link ``dmesg`` file with ``xbtest.log`` file as it uses the same format (second with 6 decimal digits precision). |                                                                           |
        |                  |                                                                                                                                    |     [263445.141868] STATUS :: CMN_032 :: POWER :: Start Test 1: [300, 49] |
        |                  |                                                                                                                                    |                                                                           |
        +------------------+------------------------------------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------+
        | ``differential`` | Elapsed time since the previous message displayed.                                                                                 | .. code-block:: bash                                                      |
        |                  |                                                                                                                                    |                                                                           |
        |                  |                                                                                                                                    |     [+0.000076] STATUS :: CMN_032 :: POWER :: Start Test 1: [300, 49]     |
        |                  |                                                                                                                                    |                                                                           |
        +------------------+------------------------------------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------+

    .. warning::
        This will slow down the software as each message requests a timestamp to the OS (clock monotonic).
        The slow down shouldn't be noticeable if only 1 xbtest instance is running or if the processors are not heavily loaded.
        With multi-cards or CPU stress test running, the behaviour of xbtest cannot be guaranteed.

----

=====================================================
-x & -e: Select xclbin and platform definition JSON
=====================================================

.. option:: -x <xclbin>

    Select the |xclbin| ``<xclbin>``.

.. option:: -e <platform definition>

    Select the |Platform definition JSON file| ``<platform definition>``.

Command line options :option:`-x` and :option:`-e` can only be used when calling the |Test software| ``path/to/opt/xilinx/xbtest/6/bin/xbtest`` directly.

As describe elsewhere, xbtest is composed of two executables, both called xbtest, but they are totally different in term of functionalities:

  * |Common software|: When following the normal setup/usage process, this is called by the user (see :ref:`set-up-xbtest`).
  * |Test software|: Target platform-specific software.

|Common software| provides all necessary options to the |Test software|.
In case of patch (or debug software/workaround) it's possible to bypass |Common software| and directly call directly the |Test software|.
|Test software| (xbtest) requires at least options :option:`-d`, :option:`-j` (this could be a pre-canned test), :option:`-x` and :option:`-e`.

Most of the other command line options can be passed directly to the |Test software|.
User can bypass |Common software| and directly call the |Test software| so their current setup is unaffected.
The following command is an example of usage:

.. code-block:: bash

    $ path/to/opt/xilinx/xbtest/6/bin/xbtest -x <xclbin> -e <platform definition> -d <BDF> -j path/to/my_tests.json

This is useful for example in case of:

  * Temporary software patch.
  * Tactical patch (specially created |xclbin|).
  * Having different versions of |Test software| installed (see :ref:`install-xbtest-to-another-location`).
    In this case you don't install the other version of the package, but you extract the executable and call it directly.

.. note::

    This is only applicable when running a single test on a single card.

----

==============================================================
-X & -E: Select P2P target xclbin and platform definition JSON
==============================================================

.. option:: -X <xclbin>

    Select the |xclbin| ``<xclbin>`` of the P2P target card selected with :option:`-T` option.

.. option:: -E <platform definition>

    Select the |Platform definition JSON file| ``<platform definition>`` of the P2P target card selected with :option:`-T` option.

Like :option:`-x` and :option:`-E` options, these options can only be used when calling the |Test software| ``path/to/opt/xilinx/xbtest/6/bin/xbtest`` directly.

|Common software| provides all necessary options to the |Test software|.

----

.. note::
    .. [1] Prevents any test being launched.
    .. [2] The maximum number of tests (number of times options :option:`-c` and :option:`-j` are present in command line) for each card configuration is 999.
    .. [3] :option:`-l` and :option:`-L` cannot be combined.

----

********************************************************
Command line options examples
********************************************************

=====================================================
Running single test on a single card
=====================================================

The following example shows how to run only one test, Test JSON files (:option:`-j`) or pre-canned test (:option:`-c`), on a single card.

.. code-block:: bash

    $ xbtest -d 0000:5e:00.1 -j path/to/my_tests.json

or

.. code-block:: bash

    $ xbtest -d 0000:5e:00.1 -c verify

=====================================================
Running multiple tests on a single card
=====================================================

Test JSON files (:option:`-j`) and pre-canned test (:option:`-c`) options can be mixed.

Each test provided is run one after the other for the specified BDF.

An error in one test on one card does not stop any other tests. 

For example:

.. code-block:: bash

    $ xbtest -d 0000:5e:00.1 -c verify -c dma -j path/to/my_tests.json

=====================================================
Same tests on multiple cards
=====================================================

Different cards can be targeted simultaneously.

Each test provided is run one after the other for all selected cards.

For example:

.. code-block:: bash

    $ xbtest -d 0000:5e:00.1 -d 0000:d9:00.1 -d 0000:86:00.1 -c dma -j path/to/my_tests.json -c memory -j path/to/another_test.json -b -1

In this example, the card configurations for all cards (0000:5e:00.1 & 0000:d9:00.1 & 0000:86:00.1) are:

  * Test 1: pre-canned ``dma``
  * Test 2: ``path/to/my_tests.json``
  * Test 3: pre-canned ``memory``
  * Test 4: ``path/to/another_test.json``
  * ``-b -1`` for all tests

=====================================================
Running different tests on different cards
=====================================================

The tests run can differs between each card.

.. code-block:: bash

    $ xbtest -d 0000:5e:00.1 -d 0000:d9:00.1 -c dma -j path/to/my_tests.json -c memory -b -1 \
             -d 0000:86:00.1                 -j path/to/my_card_specific_test.json

In this example, the card configurations are:

  * 0000:5e:00.1 & 0000:d9:00.1:

      * Test 1: pre-canned ``dma``
      * Test 2: ``path/to/my_tests.json``
      * Test 3: pre-canned ``memory``
      * ``-b -1`` is used for all tests

  * 0000:86:00.1:

      * Test 1: ``path/to/my_card_specific_test.json``

.. _card-configuration-JSON-file:

********************************************************
Card configuration JSON file
********************************************************

Instead of using the command line directly, the card configuration JSON file is used to define:

  * List of BDF.
  * List of tests:

      * Test JSON file or pre-canned test.
      * Possibly add other options for each test individually.

  * Possibly overwrite tests definition per BDF.
  * Comments supported at any level of the JSON file.

The card configuration JSON file is selected using command line option :option:`-D`:

.. code-block:: bash

    $ xbtest -D card_config.json

=====================================================
Card configuration JSON definition
=====================================================

The following table defines the parameters supported in the card configuration JSON file:

.. table:: Card configuration JSON file parameter definition

    +----------------+-----------+-----------------+----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Node name                                                           | Node type    | Example                           | Command line equivalent  | Mandatory/optional                  | Default                 | Description                                                                                                                                                  |
    +----------------+-----------+-----------------+----------------------+              +                                   +                          +                                     +                         +                                                                                                                                                              +
    | Level 0        | Level 1   | Level 2         | Level 3              |              |                                   |                          |                                     |                         |                                                                                                                                                              |
    +================+===========+=================+======================+==============+===================================+==========================+=====================================+=========================+==============================================================================================================================================================+
    | global_config  | args      |                 |                      | string       | "-b -1"                           | -b -1                    | Optional                            |                         | Specify the other command line options to be passed to xbtest SW for all cards.                                                                              |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |                                                                                                                                                              |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |   * These options and options defined in command line must be different.                                                                                     |
    +                +-----------+-----------------+----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                | cards     |                 |                      | List<string> | ["0000:86:00.1",                  | -d 0000:86:00.1          | Mandatory                           |                         | List of card BDFs.                                                                                                                                           |
    |                |           |                 |                      |              | "0000:5e:00.1"]                   | -d 0000:5e:00.1          |                                     |                         |                                                                                                                                                              |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |   * Maximum number of cards in this list is 100.                                                                                                             |
    +                +-----------+-----------------+----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                | tests     |                 |                      | List<object> |                                   |                          | Mandatory                           |                         | List of objects. Each object defines a test.                                                                                                                 |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |                                                                                                                                                              |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |   * Tests are run in the same order as specified in the list.                                                                                                |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |   * Maximum number of tests in this list is 999.                                                                                                             |
    +                +           +-----------------+----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                |           | args            |                      | string       | "-b -1"                           | -b -1                    | Optional                            | global_config.args      | Overwrites ``global_config.args`` for this test, for all cards.                                                                                              |
    +                +           +-----------------+----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                |           | test_json       |                      | string       | "path/to/my_tests.json"           | -j path/to/my_tests.json | Mandatory                           |                         | Test JSON file.                                                                                                                                              |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |                                                                                                                                                              |
    |                |           |                 |                      |              |                                   |                          |   * when ``pre_canned`` not defined |                         |                                                                                                                                                              |
    +                +           +-----------------+----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                |           | pre_canned      |                      | string       | "stress"                          | -c stress                | Optional                            |                         | Pre-canned test.                                                                                                                                             |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |                                                                                                                                                              |
    |                |           |                 |                      |              |                                   |                          |   * when ``test_json`` not defined  |                         |                                                                                                                                                              |
    +----------------+-----------+-----------------+----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | card_config    | ``<BDF>`` |                 |                      | object       |                                   |                          | Optional                            |                         | Overwrite for card identified by ``<BDF>``                                                                                                                   |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |                                                                                                                                                              |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |   * Valid ``<BDF>`` nodes are values provided in ``global_config.cards`` list.                                                                               |
    +                +           +-----------------+----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                |           | args            |                      | string       | "-b -1"                           | -b -1                    | Optional                            | global_config.args      | Overwrites ``global_config.args`` for all tests for card identified by ``<BDF>``.                                                                            |
    +                +           +-----------------+----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                |           | tests           |                      | List<object> |                                   |                          | Mandatory                           | gloabal_config.tests    | Overwrites ``global_config.tests`` for card identified by ``<BDF>``.                                                                                         |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |                                                                                                                                                              |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |   * Number of tests in ``card_config.<BDF>.tests`` does not necessarily equal number of tests in ``global_config.tests`` and can be different for each card. |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |   * Maximum number of tests in this list is 999.                                                                                                             |
    +                +           +                 +----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                |           |                 | args                 | string       | "-b -1"                           | -b -1                    | Optional                            | card_config.<BDF>.args  | Overwrites ``card_config.<BDF>.args`` for this test.                                                                                                         |
    +                +           +                 +----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                |           |                 | test_json            | string       | "path/to/my_tests.json"           | -j path/to/my_tests.json | Mandatory                           |                         | Test JSON file for card identified by ``<BDF>``.                                                                                                             |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |                                                                                                                                                              |
    |                |           |                 |                      |              |                                   |                          |   * when ``pre_canned`` not defined |                         |                                                                                                                                                              |
    +                +           +                 +----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                |           |                 | pre_canned           | string       | "stress"                          | -c stress                | Optional                            |                         | Pre-canned test for card identified by ``<BDF>``.                                                                                                            |
    |                |           |                 |                      |              |                                   |                          |                                     |                         |                                                                                                                                                              |
    |                |           |                 |                      |              |                                   |                          |   * when ``test_json`` not defined  |                         |                                                                                                                                                              |
    +----------------+-----------+-----------------+----------------------+--------------+-----------------------------------+--------------------------+-------------------------------------+-------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+

=====================================================
Card configuration JSON examples
=====================================================

.. code-block:: JSON

    {
        "comment": "First define all tests and all targeted cards",
        "global_config": {
            "args" : "-b -1",
            "cards": ["0000:86:00.1", "0000:5e:00.1", "0000:d9:00.1"],
            "tests": [
                {   "pre_canned": "verify"                                  },
                {   "test_json" : "path/to/my_tests.json",  "args": "-b -2" }
            ]
        },
        "comment": "Then override tests for some cards if needed",
        "card_config": {
            "0000:5e:00.1": {
                "tests": [
                    {   "pre_canned": "power", "args": "-b 0"     },
                    {   "test_json" : "path/to/another_test.json" },
                ]
            }
        }
    }