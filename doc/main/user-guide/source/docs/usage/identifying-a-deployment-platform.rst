
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

.. _identifying-a-deployment-platform:

##########################################################################
Identifying a deployment platform
##########################################################################

After having installed and set up XRT (see |XRT_DOC|_), use the following command to get the list of available platforms:

.. code-block:: bash

    $ xbutil examine

The command will output results like the following example.
The card BDF is the string value given in the square brackets ``[<BDF>]`` with the format ``<domain>:<bus>:<device>.<function>`` followed by deployment platform name.

.. code-block:: bash

    Devices present
    BDF             :  Shell                              Platform UUID                         Device ID       Device Ready*
    [0000:d8:00.1]  :  xilinx_u50lv_gen3x4_xdma_base_2    CA1BD561-0169-A52C-E463-B3300DF98172  user(inst=133)  Yes
    [0000:af:00.1]  :  xilinx_u50lv_gen3x4_xdma_base_2    CA1BD561-0169-A52C-E463-B3300DF98172  user(inst=132)  Yes
    [0000:86:00.1]  :  xilinx_u50lv_gen3x4_xdma_base_2    CA1BD561-0169-A52C-E463-B3300DF98172  user(inst=131)  Yes
    [0000:5e:00.1]  :  xilinx_u50lv_gen3x4_xdma_base_2    CA1BD561-0169-A52C-E463-B3300DF98172  user(inst=130)  Yes
    [0000:3b:00.1]  :  xilinx_u50lv_gen3x4_xdma_base_2    CA1BD561-0169-A52C-E463-B3300DF98172  user(inst=129)  Yes
    [0000:18:00.1]  :  xilinx_u50lv_gen3x4_xdma_base_2    CA1BD561-0169-A52C-E463-B3300DF98172  user(inst=128)  Yes

