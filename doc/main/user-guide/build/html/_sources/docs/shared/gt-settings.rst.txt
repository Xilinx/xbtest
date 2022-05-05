
.. |UG_578| replace:: UltraScale Architecture GTY Transceivers User Guide (UG578)
.. _UG_578: https://www.xilinx.com/support/documentation/user_guides/ug578-ultrascale-gty-transceivers.pdf

********************************************************
GT settings
********************************************************

As there are multiple ways to connect to the GTs, two default configurations have been defined:

  * ``module``: For loopback module and active optical cable.
    Loopback module is an electrical track from TX to RX. It's the shortest path you can get between Tx and Rx (and still going out of the FPGA).
    An active optical cable terminates the electrical TX track at the optic module input.
    It also has the electric RX track from the optic module output.
    Resulting in electrical track length twice the size compared to the loopback module. From experience, it has no major impact and GT settings can be common for these 2 types (loopback module or active optical cable).
  * ``cable``: For copper cable.

The selection is made using the ``gt_settings`` member, by default ``module`` settings are selected.

Each mode defines values for the following GT transceiver settings (see |UG_578|_):

  * ``tx_differential_swing_control``
  * ``tx_pre_emphasis``
  * ``tx_post_emphasis``
  * ``gt_tx_polarity``
  * ``gt_loopback``
  * ``rx_equaliser``

The actual values are defined in the platform definition JSON file and are also displayed in the ``xbtest.log`` file with message ID ``CMN_021``.
It's possible to overwrite these settings for all lanes (included into ``global_config``) or selectively for some lanes (part of ``lane_config``).

.. warning::
    When connected to switch, using a wrong setting for one single lane might result in traffic interruption on all lanes.
    The switch might try to reset its whole module because it sees that a link is down.
