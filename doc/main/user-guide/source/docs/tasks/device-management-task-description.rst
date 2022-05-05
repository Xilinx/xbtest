
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _device-management-task-description:

##########################################################################
Device management task description
##########################################################################

.. contents:: Table of contents
   :local:
   :depth: 2
   
The goal of the |Device Management| task is to:

  * Read, monitor and record the sensor values:

      * Sensor values are read every second via the |XRT Device APIs|_.
      * Measurements can be checked against provided thresholds. A Critical Warning is only issue once if the value goes out of range throughout the entire test.
      * Measurements are recorded in an output CSV file when enabled.

  * Configure the HW watchdog (disable or extend it). When the watchdog reaches its duration, it stops all CU present in the |xclbin|.
    Xbtest SW resets the HW watchdog on a regular basis (half the HW duration).

By default, the following sensors are monitored (this list can be amended by other sensors defined in :ref:`ug-platform-definition`).

  * FPGA fan speed.
  * FPGA temperature.
  * Board power.
  * 3v3_pex: power, current and voltage.
  * 12v_pex: power, current and voltage.
  * Vccint: power, current and voltage.
  * 12v_aux: power, current and voltage (when auxiliary power cable is present).

You can use this task to monitor other sensors or change the behaviour of sensor warnings (threshold or severity).

.. note::
    This task is always running and does not require any parameters.
    So, there is no need to include it inside your test JSON file unless you want to modify the default behaviour.
    For more information, see :ref:`device-management-test-json-members`.


.. _sensor-source-definition:

********************************************************
Sensor source definition
********************************************************

A sensor source is defined by a type and an ID.

The following table presents the different types of sensor that can monitored by xbtest and for each type, the ID of the sources monitored by default:

.. table:: Sensor Source Definition

    +-------------------+--------------------------------------------------------------------------------------------+-----------------------+-------------------------------------------------------------------------------------------------+
    | Sensor type       | Description                                                                                | Default sensor IDs    | Identify supported sensor IDs                                                                   |
    +===================+============================================================================================+=======================+=================================================================================================+
    | ``mechanical``    | Mechanical sensors on and surrounding the device.                                          | ``fpga_fan_1``        | ``mechanical`` sensor source IDs are defined like those found when using the following command: |
    |                   |                                                                                            |                       |                                                                                                 |
    |                   | Typically, mechanical measurements are fan speed recorded in Revolutions Per Minute (RPM). |                       | .. code-block:: bash                                                                            |
    |                   |                                                                                            |                       |                                                                                                 |
    |                   |                                                                                            |                       |     $ xbutil examine --device <BDF> --report mechanical --format JSON --output <filename>       |
    |                   |                                                                                            |                       |                                                                                                 |
    +-------------------+--------------------------------------------------------------------------------------------+-----------------------+-------------------------------------------------------------------------------------------------+
    | ``thermal``       | Thermal sensors present on the device.                                                     | ``fpga0``             | ``thermal`` sensor source IDs are defined like those found when using the following command:    |
    |                   |                                                                                            |                       |                                                                                                 |
    |                   | Typically, thermal measurements are temperatures recorded in degree Celsius.               |                       | .. code-block:: bash                                                                            |
    |                   |                                                                                            |                       |                                                                                                 |
    |                   |                                                                                            |                       |    $ xbutil examine --device <BDF> --report thermal --format JSON --output <filename>           |
    |                   |                                                                                            |                       |                                                                                                 |
    +-------------------+--------------------------------------------------------------------------------------------+-----------------------+-------------------------------------------------------------------------------------------------+
    | ``electrical``    | Electrical and power sensors present on the device.                                        | ``12v_pex``,          | ``electrical`` sensor source IDs are defined like those found when using the following command: |
    |                   |                                                                                            | ``12v_aux``,          |                                                                                                 |
    |                   | Typically, electrical measurements are currents recorded in mA, voltages recorded in mV    | ``3v3_pex``,          | .. code-block:: bash                                                                            |
    |                   | and power recorded in W.                                                                   | ``vccint``,           |                                                                                                 |
    |                   |                                                                                            | ``power_consumption`` |     $ xbutil examine --device <BDF> --report electrical --format JSON --output <filename>       |
    |                   |                                                                                            |                       |                                                                                                 |
    +-------------------+--------------------------------------------------------------------------------------------+-----------------------+-------------------------------------------------------------------------------------------------+

Refer to the |Alveo doc|_ for more information on the sensors.

The sources monitored by default are defined in the |Platform definition JSON file| (see :ref:`ug-platform-definition`).
Other sources can be monitored when specified using :ref:`device-management-parameter-sensor` parameter.

The supported sources are also reported depending on targeted platform using the following command:

.. code-block:: bash

    $ xbtest -d <BDF> -g device_mgmt

.. _device-management-test-json-members:

********************************************************
Device management test JSON members
********************************************************

The following is an example of a device management task parameter definition:

.. code-block:: JSON

    "tasks": {
        "device_mgmt": {
            "sensor" : [
                {
                    "id"   : "12v_pex",
                    "type" : "electrical",
                    "warning_threshold" : {
                        "min": 1.0,
                        "max": 65.0
                    },
                    "error_threshold" : {
                        "min": 0.1,
                        "max": 70.0
                    },
                    "abort_threshold" : {
                        "min": 0.0,
                        "max": 75.0
                    }
                }
            ],
            "watchdog_duration": 32
        }
    }

----

=====================================================
Definition
=====================================================

The following table shows all members available for this task.
More details are provided for each member in the subsequent sections.

.. table:: Device management task members

    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    | Member                                                                                                                                       | JSON format | Mandatory/optional                                                     | Description                                   |
    +====================================================+=============================================================+===========================+=============+========================================================================+===============================================+
    | :ref:`device-management-parameter-sensor`          |                                                             |                           | List        | Optional                                                               | List of sensors definitions.                  |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    | :ref:`device-management-parameter-sensor-type`              |                           | Value       | Mandatory                                                              | Sensor type.                                  |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    |                                                    |                                                             |                           |             |   * If :ref:`device-management-parameter-sensor` provided              |                                               |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    | :ref:`device-management-parameter-sensor-id`                |                           | Value       | Mandatory                                                              | Sensor ID.                                    |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    |                                                    |                                                             |                           |             |   * If :ref:`device-management-parameter-sensor` provided              |                                               |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    | :ref:`device-management-parameter-sensor-warning_threshold` |                           | Object      | Optional                                                               | Warning limits.                               |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    |                                                             | |device_mgmt-warning-min| | Value       | Mandatory                                                              | Minimum warning limit.                        |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    |                                                    |                                                             |                           |             |   * If :ref:`device-management-parameter-sensor-warning_threshold`     |                                               |
    |                                                    |                                                             |                           |             |     provided                                                           |                                               |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    |                                                             | |device_mgmt-warning-max| | Value       | Mandatory                                                              | Maximum warning limit.                        |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    |                                                    |                                                             |                           |             |   * If :ref:`device-management-parameter-sensor-warning_threshold`     |                                               |
    |                                                    |                                                             |                           |             |     provided                                                           |                                               |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    | :ref:`device-management-parameter-sensor-error_threshold`   |                           | Object      | Optional                                                               | Error limits.                                 |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    |                                                             | |device_mgmt-error-min|   | Value       | Mandatory                                                              | Minimum error limit.                          |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    |                                                    |                                                             |                           |             |   * If :ref:`device-management-parameter-sensor-error_threshold`       |                                               |
    |                                                    |                                                             |                           |             |     provided                                                           |                                               |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    |                                                             | |device_mgmt-error-max|   | Value       | Mandatory                                                              | Maximum error limit.                          |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    |                                                    |                                                             |                           |             |   * If :ref:`device-management-parameter-sensor-error_threshold`       |                                               |
    |                                                    |                                                             |                           |             |     provided                                                           |                                               |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    | :ref:`device-management-parameter-sensor-abort_threshold`   |                           | Object      | Optional                                                               | Abort limits.                                 |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    |                                                             | |device_mgmt-abort-min|   | Value       | Mandatory                                                              | Minimum abort limit.                          |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    |                                                    |                                                             |                           |             |   * If :ref:`device-management-parameter-sensor-abort_threshold`       |                                               |
    |                                                    |                                                             |                           |             |     provided                                                           |                                               |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    |                                                    |                                                             | |device_mgmt-abort-max|   | Value       | Mandatory                                                              | Maximum abort limit.                          |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    |                                                    |                                                             |                           |             |   * If :ref:`device-management-parameter-sensor-abort_threshold`       |                                               |
    |                                                    |                                                             |                           |             |     provided                                                           |                                               |
    |                                                    |                                                             |                           |             |                                                                        |                                               |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    | :ref:`device-management-parameter-use_output_file` |                                                             |                           | Value       | Optional                                                               | Store in a file all measurements of the task. |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+
    | :ref:`device-management-parameter-watchdog`        |                                                             |                           | Value       | Optional                                                               | Control Watchdog behaviour.                   |
    +----------------------------------------------------+-------------------------------------------------------------+---------------------------+-------------+------------------------------------------------------------------------+-----------------------------------------------+

----

.. _device-management-parameter-sensor:

=====================================================
``sensor``
=====================================================

Optional;
Type: List of objects.

Define list of sensors definitions (JSON objects). Override existing sensor definition or define new sensor sources.

----

.. _device-management-parameter-sensor-type:

---------------------------------------------------
``type``
---------------------------------------------------

Mandatory if :ref:`device-management-parameter-sensor` was provided;
Type           : string;
Possible values: ``mechanical``, ``thermal`` or ``electrical``;

----

.. _device-management-parameter-sensor-id:

---------------------------------------------------
``id``
---------------------------------------------------

Mandatory if :ref:`device-management-parameter-sensor` was provided;
Type           : string;
Possible values: depend on targeted platform;

ID of the sensor source to monitor. See :ref:`sensor-source-definition` for more information on the supported sensor sources.

----

.. _device-management-parameter-sensor-warning_threshold:

---------------------------------------------------
``warning_threshold``
---------------------------------------------------

Optional;
Type: Object.

Warning limits: if measurement is out of range, a critical warning is displayed (once), the |test cases| are not stopped and global result is pass.

.. _device-management-parameter-sensor-warning_threshold-min:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``warning_threshold.min``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Optional;
Type           : double;
Possible values: any double value provided as |device_mgmt-warning-max| > |device_mgmt-warning-min|.

Minimum warning limit.

----

.. _device-management-parameter-sensor-warning_threshold-max:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``warning_threshold.max``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Optional;
Type           : double;
Possible values: any double value provided as |device_mgmt-warning-max| > |device_mgmt-warning-min|.

Maximum warning limit.

----

.. _device-management-parameter-sensor-error_threshold:

---------------------------------------------------
``error_threshold``
---------------------------------------------------

Optional;
Type: Object.

Error limits: if measurement is out of range, an error is displayed (once), the |test cases| are not stopped and global result is failure.

----

.. _device-management-parameter-sensor-error_threshold-min:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``error_threshold.min``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Optional;
Type           : double;
Possible values: any double value provided as |device_mgmt-error-max| > |device_mgmt-error-min|.

Minimum error limit.

----

.. _device-management-parameter-sensor-error_threshold-max:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``error_threshold.max``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Optional;
Type           : double;
Possible values: any double value provided as |device_mgmt-error-max| > |device_mgmt-error-min|.

Maximum error limit.

----

.. _device-management-parameter-sensor-abort_threshold:

---------------------------------------------------
``abort_threshold``
---------------------------------------------------

Optional;
Type: Object.

Abort limits: if measurement is out of range, a failure is displayed (once), all |test cases| are stopped and global result is failure.

.. _device-management-parameter-sensor-abort_threshold-min:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``abort_threshold.min``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Optional;
Type           : double;
Possible values: any double value provided as |device_mgmt-abort-max| > |device_mgmt-abort-min|.

Minimum abort limit.

----

.. _device-management-parameter-sensor-abort_threshold-max:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``abort_threshold.max``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Optional;
Type           : double;
Possible values: any double value provided as |device_mgmt-abort-max| > |device_mgmt-abort-min|.

Maximum abort limit.

----

.. _device-management-parameter-use_output_file:

=====================================================
``use_output_file``
=====================================================

Optional;
Type           : boolean;
Possible values: ``true`` or ``false``.

By default, when not specified, the output CSV file is only generated if any :ref:`device-management-parameter-sensor` parameter is specified.

Based on :ref:`device-management-parameter-use_output_file` parameters:

  * When set to ``true``, the output CSV file is generated.
  * When set to ``false``, the output CSV file is not generated.

The |Device Management| can store all measurements in an output CSV file (see :ref:`device-management-output_file`).

----

.. _device-management-parameter-watchdog:

=====================================================
``watchdog_duration``
=====================================================

Optional;
Type           : integer;
Possible values: ``0`` (disable),  ``16`` (default), ``32``, ``64`` and ``128``.

Controls the HW watchdog duration.

----

.. _device-management-output_file:

********************************************************
Output files
********************************************************

All sensor measurements are stored in output CSV file named ``sensor.csv`` which is generated in xbtest logging directory.
The values are stored in CSV type format with one column for each information type. By default, this file is not generated.

.. important::
    If the command line option :option:`-L` is used while calling the |Application software|, no output file is generated.

A new line is written in this file every second.
At a minimum, the following values are recorded:

  * **time (s)**: Timestamp of the measurement.
  * **measurement ID**: Measurement identifier. ID of first measurement is 1.
  * **measurement valid**: Set to ``OK`` if the ``Test`` software was able to successfully gets power and temperature measurements via the |XRT Device APIs|_, otherwise set to ``KO``.
  * **sensor reading duration (s)**: Duration in seconds of the |XRT Device APIs|_ commands execution.
    This value is rounded, for example a value of 0 means that the XRT Device APIs commands took less than 1 second.
  * **Mechanical measurements**: Group of one or more columns recording measurements for each mechanical sensor source monitored by xbtest.
  * **Thermal measurements**: Group of one or more columns recording measurements for each thermal sensor source monitored by xbtest.
  * **Electrical measurements**: Group of one or more columns recording detailed measurements for each electrical sensor source monitored by xbtest.

See :ref:`sensor-source-definition` for more information on the sensor sources monitored by xbtest.
