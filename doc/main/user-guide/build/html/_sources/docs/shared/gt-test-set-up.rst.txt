
.. |ML4002_28_C5| replace:: ML4002-28-C5
.. _ML4002_28_C5: https://multilaneinc.com/product/ml4002-28-8w/

********************************************************
GT test set up
********************************************************

GT testing can be achieved by using one of the following methods:

  * The use of a QSFP passive electrical loopback module.
    The module must be compliant to 100GbE (25GbE per lane) and have 0 dB insertion loss.
    This is the preferred method, the GTs having been validated using a QSFP28 module provided by MultiLane (|ML4002_28_C5|_).

    .. note::
        This module also has the capability of providing a QSFP temperature reading and a programmable power dissipation up to 5W.
        However, these are not required to pass the GT tests.

  * The use of a QSFP optical module with suitably connected fiber loopback.
    The module must be compatible with the traffic rate being tested.

    .. note::
        This is an active component the electrical interface between the GTs and the module will need to be validated to ensure optimum performance.
