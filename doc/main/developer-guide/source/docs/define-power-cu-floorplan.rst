
.. include:: ../../../shared/links.rst
.. include:: share/links.rst
.. include:: share/include.rst

.. _define-power-cu-floorplan:

##########################################################################
Define power CU floorplan
##########################################################################

********************************************************
Overview
********************************************************

This page describes required input files for the power CU and provides some guidelines on how to define them.
The power CU will run typically at 500MHz and should reach the power target of your card.

The power CU is flexible enough to adapt to any FPGA and dynamic region shape but you must still define how much resources you want according to your power target.
The power CU high flexibility is achieved by:

  * Defining a floorplan: shape of the FPGA & power CU.
  * Defining resource usage: how much FF/DSP/RAMs you want to use within this floorplan.

The floorplan & utilization should allow your card to exceed the maximum power of your card.
The excess of power allows the check of the safety features of the card (clock throttle/shutdown & regulator shutdown).

.. important::
    Make sure your power CU is designed according to the maximum power you want to achieve:

      * Not too big: to have enough granulometric control of the toggle rate: to allow power & thermal qualification of your card/platform at precise levels
      * Not too small: you won't be able to test the limit & safety feature of the card.

********************************************************
General step
********************************************************

This chapter gives you a view of the required tasks and why:

  1. Get the FPGA logic available for the dynamic region.

       * It's the physical localization across FPGA die (and its various SLR if applicable) of all FF, DSP, BRAM, URAM available for any compute unit.
         Each platform is different so its dynamic region too.

         .. warning::
             This step must be re-done every time you change the shape (thus the resources) of the dynamic region.

  2. Define the utilization within this floorplan.

       * Per Clock Region (CR) of the FPGA, define the percentage of FF/DSP/BRAM/URAM allocated to the power CU.
       * Some general utilization guidelines are available.

  3. Refine resource usage by eventually disable some of them. This allows fine tuning (within the CR) of the resource.

       * You may want to forbid some specific areas due to e.g. congestion with other CUs or static region.

  4. Build and close timing.

       * The power CU itself should not be an issue to close timing but due to the high quantity of resource used, Vivado gives up some time to time too early on the other CU.

xbtest can generate template files for steps 1, 2 & 3. You just have to fill them according to your need.

The actual resources of the power CU are the result of the following equation:

.. math::

    ({dynamic\ region} - invalid) * utilization

.. note::
    To ease the definition of the utilization & invalid, it's possible to :ref:`visualize-power-cu-floorplan` without doing any synthesis or implementation.

********************************************************
Detailed steps
********************************************************

Three JSON files are used to define the entire floorplan of the power CU.
The following files should be defined in ``<xbtest_build>/xclbin_generate/cfg/<dev_platform>/pwr_cfg``, where:

  * |<xbtest_build> def|
  * |<dev_platform> def|

.. table:: Power floorplan JSON files

    +---------------------------+-------------------+-------------------------------------------------------------------------------------+-------------------------------------------------------------------+
    | File name                 | Required/optional | Description                                                                         | Note                                                              |
    +===========================+===================+=====================================================================================+===================================================================+
    | ``dynamic_geometry.json`` | Required          | Available primitives in platform dynamic region (see :ref:`dynamic_geometry-json`). | Automatically generated from a DCP with provided script.          |
    +---------------------------+-------------------+-------------------------------------------------------------------------------------+-------------------------------------------------------------------+
    | ``utilization.json``      | Required          | Power CUs sites utilization (see :ref:`utilization-json`).                          | Template automatically generated from a DCP with provided script. |
    +---------------------------+-------------------+-------------------------------------------------------------------------------------+-------------------------------------------------------------------+
    | ``invalid.json``          | Optional          | Invalid primitives to be excluded (see :ref:`invalid-json`).                        | Template automatically generated from a DCP with provided script. |
    +---------------------------+-------------------+-------------------------------------------------------------------------------------+-------------------------------------------------------------------+

In |xclbin_generate| workflow, these files are used to generate one power CU per SLR.
All the power CUs are then controlled together by xbtest SW.
For each power CU, the workflow generates:

  * One SV package defining quantity of resources.
  * One XDC file defining LOC and timing constraints.

      * As your power CU could contains millions of FF and 1000's of DSP/RAM, you have to LOC every single element to achieve timing closure.

=====================================================
Automatic generation of templates
=====================================================

See :ref:`initialize-power-floorplan-sources`

.. _power-floorplan-sources-definition:

=====================================================
Power floorplan sources definition
=====================================================

When a required power floorplan source file is not found at expected location, each selected power CU will be configured with a single SLICE and the workflow will stop |Vitis|_ after the OPT design phase and a DCP will be available in
``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project name>/u_ex/run/vpp_link/link/vivado/vpl/prj/prj.runs/impl_1/level0_wrapper_opt.dcp``

Where:

  * |<xbtest_build> def|
  * |<dev_platform> def|
  * |<project_name> def|

.. _utilization-json:

---------------------------------------------------
``utilization.json``
---------------------------------------------------

The site utilization of the power CUs must be defined.
The utilization is the percentage of valid sites: available sites in dynamic region after invalid site exclusion.
A utilization is defined for each site type and for each clock region.

Utilization guidelines are provided further down this page.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
``utilization.json`` - Definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ref:`utilization-json` contains the following nodes:

.. table:: ``utilization.json`` definition

    +---------------------+-------------------------------------------------------------------------------+-----------------------------------------------------------------------+
    | Node                | Description                                                                   | Format                                                                |
    +=====================+===============================================================================+=======================================================================+
    | ``PL_UTILIZATION``  | Utilization of PL sites is defined                                            | Dictionary                                                            |
    |                     | per clock region (``<CR X>``, ``<CR Y>``) and                                 |                                                                       |
    |                     | per site type,                                                                | .. code-block::                                                       |
    |                     | in percentage [0;100] of                                                      |                                                                       |
    |                     | (number of valid locations in dynamic geometry                                |     SLR_<SLR idx> : {                                                 |
    |                     | - number of invalid locations).                                               |       CR_Y_<CR_Y idx> : {                                             |
    |                     |                                                                               |         CR_X    : [ <list of CR_X idx> ],                             |
    |                     |                                                                               |         SLICE   : [ <list of SLICE utilizations for each CR_X idx> ], |
    |                     |                                                                               |         DSP     : [ <list of DSP utilizations for each CR_X idx> ],   |
    |                     |                                                                               |         BRAM    : [ <list of BRAM utilizations for each CR_X idx> ],  |
    |                     |                                                                               |         URAM    : [ <list of URAM utilizations for each CR_X idx> ]   |
    |                     |                                                                               |       }                                                               |
    |                     |                                                                               |     }                                                                 |
    |                     |                                                                               |                                                                       |
    +---------------------+-------------------------------------------------------------------------------+-----------------------------------------------------------------------+
    | ``AIE_UTILIZATION`` | Utilization of AIE sites is defined                                           | Dictionary                                                            |
    |                     | per SLR                                                                       |                                                                       |
    |                     | in percentage [0;100] of                                                      | .. code-block::                                                       |
    |                     | number of valid locations in dynamic geometry                                 |                                                                       |
    |                     |                                                                               |     SLR_<SLR idx> : <utilization>                                     |
    |                     |                                                                               |                                                                       |
    +---------------------+-------------------------------------------------------------------------------+-----------------------------------------------------------------------+

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
``utilization.json`` - Examples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following table provides example of :ref:`utilization-json` for some platforms:

.. table:: ``utilization.json`` example

    +---------------------------------------+-----------------------------------+---------------------------+
    | Platform                              | utilization_template.json         | utilization.json          |
    +=======================================+===================================+===========================+
    | xilinx_u55c_gen3x16_xdma_3_202210_1   | |u55c utilization_template.json|_ | |u55c utilization.json|_  |
    +---------------------------------------+-----------------------------------+---------------------------+
    | xilinx_u250_gen3x16_xdma_4_1_202210_1 | |u55c utilization_template.json|_ | |u250 utilization.json|_  |
    +---------------------------------------+-----------------------------------+---------------------------+
    | xilinx_u50lv_gen3x4_xdma_2_202010_1   | |u55c utilization_template.json|_ | |u50lv utilization.json|_ |
    +---------------------------------------+-----------------------------------+---------------------------+

.. _invalid-json:

---------------------------------------------------
``invalid.json``
---------------------------------------------------

Invalid sites are the primitives to be excluded from the power CUs.

Depending on the settings during the platform generation, routing of the static region is allowed bleed into the dynamic region.
Placing power CU logic next to the static region may impeach of both routing (congestion reported by Vivado).

It may necessary to disable some sites: e.g. close to static region or I/Os to ease P&R. Obviously invalid sites must be part of FPGA geometry.

.. tip::
    If there is no invalid site, do not create :ref:`invalid-json` file.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
``invalid.json`` - Definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ref:`invalid-json` contains the following nodes:

.. table:: ``invalid.json`` definition

    +----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------------+
    | Node           | Description                                                                                                                                            | Format                                                            |
    +================+========================================================================================================================================================+===================================================================+
    | ``PL_INVALID`` | Locations of sites not used in power CU floorplan (``PL_INVALID``) are defined per site type and per SLR ``<SLR idx>``.                                | Dictionary:                                                       |
    |                |                                                                                                                                                        |                                                                   |
    |                | Provide a single site (``<x0>``, ``<y0>``) or a site rectangle defined by bottom left (``<x1>``, ``<y1>``) and top right (``<x2>``, ``<y2>``) corners. | .. code-block::                                                   |
    |                |                                                                                                                                                        |                                                                   |
    |                | See ``dynamic_geometry`` for supported ``<site_type>``:                                                                                                |     SLR_<SLR idx> : [                                             |
    |                |                                                                                                                                                        |       { location: <site_type>_X<x0>Y<y0> },                       |
    |                |                                                                                                                                                        |       { location: <site_type>_X<x1>Y<y1>:<site_type>_X<x2>Y<y2> } |
    |                |                                                                                                                                                        |     ]                                                             |
    +----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------------+

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
``invalid.json`` - Examples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following table provides example of :ref:`invalid-json` for some platforms:

.. table:: ``invalid.json`` example

    +---------------------------------------+--------------------------------+-----------------------+
    | Platform                              | invalid_template.json          | invalid.json          |
    +=======================================+================================+=======================+
    | xilinx_u55c_gen3x16_xdma_3_202210_1   | |u55c invalid_template.json|_  | n/a                   |
    +---------------------------------------+--------------------------------+-----------------------+
    | xilinx_u250_gen3x16_xdma_4_1_202210_1 | |u250 invalid_template.json|_  | n/a                   |
    +---------------------------------------+--------------------------------+-----------------------+
    | xilinx_u50lv_gen3x4_xdma_2_202010_1   | |u50lv invalid_template.json|_ | |u50lv invalid.json|_ |
    +---------------------------------------+--------------------------------+-----------------------+

.. _dynamic_geometry-json:

---------------------------------------------------
``dynamic_geometry.json``
---------------------------------------------------

The valid sites (available primitives in platform dynamic region) which can be selected by xbtest to be used by the power CU must be contained in the dynamic region pblocks.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
``dynamic_geometry.json`` - Definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. important::
    Do not edit this file.

:ref:`dynamic_geometry-json` contains the following nodes:

.. table:: ``dynamic_geometry.json`` definition

    +-------------------------+-----------------------------------------------------------------------------------------------------+-------------------------------------+
    | Node                    | Description                                                                                         | Format                              |
    +=========================+=====================================================================================================+=====================================+
    | ``PART``                | The FPGA part of the DCP used to generate the dynamic geometry.                                     | String:                             |
    |                         |                                                                                                     |                                     |
    |                         |                                                                                                     | .. code-block::                     |
    |                         |                                                                                                     |                                     |
    |                         |                                                                                                     |     <part>                          |
    +-------------------------+-----------------------------------------------------------------------------------------------------+-------------------------------------+
    | ``PBLOCKS``             | The list of pblock names provided to generate the dynamic geometry.                                 | List of strings:                    |
    |                         |                                                                                                     |                                     |
    |                         |                                                                                                     | .. code-block::                     |
    |                         |                                                                                                     |                                     |
    |                         |                                                                                                     |     [ <pblock name> ]               |
    +-------------------------+-----------------------------------------------------------------------------------------------------+-------------------------------------+
    | ``SLR``                 | SLR definition: List of all SLR indexes ``<SLR index>`` in the FPGA.                                | List of integers:                   |
    |                         |                                                                                                     |                                     |
    |                         |                                                                                                     | .. code-block::                     |
    |                         |                                                                                                     |                                     |
    |                         |                                                                                                     |     [ <SLR index> ]                 |
    +-------------------------+-----------------------------------------------------------------------------------------------------+-------------------------------------+
    | ``CLOCK_REGIONS``       |  Clock Regions definition:                                                                          | Dictionary:                         |
    |                         |                                                                                                     |                                     |
    |                         |  List of all the Clock Region indexes (``<CR X>``, ``<CR Y>``) per SLR ``<SLR index>`` in the FPGA. | .. code-block::                     |
    |                         |                                                                                                     |                                     |
    |                         |                                                                                                     |     <SLR index> : {                 |
    |                         |                                                                                                     |       <CR Y> : [ <CR X> ]           |
    |                         |                                                                                                     |     }                               |
    +-------------------------+-----------------------------------------------------------------------------------------------------+-------------------------------------+
    | ``SITES_TYPES``         | Sites types ``<Site type>`` supported in PL:                                                        | Dictionary:                         |
    |                         |                                                                                                     |                                     |
    |                         | * **SLICE**: SLICE.                                                                                 | .. code-block::                     |
    |                         | * **DSP**: DSP48E2 or DSP.                                                                          |                                     |
    |                         | * **URAM**: URAM288.                                                                                |     <Site key> : <Site type>        |
    |                         | * **BRAM**: RAMB36.                                                                                 |                                     |
    +-------------------------+-----------------------------------------------------------------------------------------------------+-------------------------------------+
    | ``PL_DYNAMIC_GEOMETRY`` | PL sites definition:                                                                                | Dictionary:                         |
    |                         |                                                                                                     |                                     |
    |                         | List of all site ``<Site key>`` locations (``<Site X>``, ``<Site Y>``)                              | .. code-block::                     |
    |                         | found in pblocks per CR (``<CR X>``, ``<CR Y>``) per SLR ``<SLR index>``.                           |                                     |
    |                         |                                                                                                     |    <Site key> : {                   |
    |                         |                                                                                                     |       <SLR index> : {               |
    |                         |                                                                                                     |         <CR Y> : {                  |
    |                         |                                                                                                     |           <CR X> : {                |
    |                         |                                                                                                     |             <Site X> : [ <Site Y> ] |
    |                         |                                                                                                     |           }                         |
    |                         |                                                                                                     |         }                           |
    |                         |                                                                                                     |       }                             |
    |                         |                                                                                                     |    }                                |
    +-------------------------+-----------------------------------------------------------------------------------------------------+-------------------------------------+
    | ``AIE_GEOMETRY``        | AIE sites definition: List of all AIE locations (``<Site X>``, ``<Site Y>``)                        | Dictionary:                         |
    |                         | found per ``<SLR index>``.                                                                          |                                     |
    |                         |                                                                                                     | .. code-block::                     |
    |                         | Not present if AIE not supported.                                                                   |                                     |
    |                         |                                                                                                     |     <SLR index> : {                 |
    |                         |                                                                                                     |        <Site Y> : [ <Site X> ]      |
    |                         |                                                                                                     |     }                               |
    +-------------------------+-----------------------------------------------------------------------------------------------------+-------------------------------------+

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
``dynamic_geometry.json`` - Examples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following table provides example of :ref:`dynamic_geometry-json` for some platforms:

.. table:: ``dynamic_geometry.json`` example

    +---------------------------------------+--------------------------------+
    | Platform                              | dynamic_geometry.json          |
    +=======================================+================================+
    | xilinx_u55c_gen3x16_xdma_3_202210_1   | |u55c dynamic_geometry.json|_  |
    +---------------------------------------+--------------------------------+
    | xilinx_u250_gen3x16_xdma_4_1_202210_1 | |u250 dynamic_geometry.json|_  |
    +---------------------------------------+--------------------------------+
    | xilinx_u50lv_gen3x4_xdma_2_202010_1   | |u50lv dynamic_geometry.json|_ |
    +---------------------------------------+--------------------------------+

=====================================================
Power CU floorplanning tips
=====================================================

---------------------------------------------------
General
---------------------------------------------------

The power CU requires special attention when it comes to create its floorplan and how to use the available resources.

The actual resources of the power CU are the result of the following equation:

.. math::

    (dynamic\ region - invalid) * utilization

.. note::
    Any utilization defined for Clock Region which are part of the static region will be ignored.

As the dynamic region also contains the memory subsystem, you must leave room for it:

  * The power CU uses LOC constrains for every resource (FF, DSP, BRAM, URAM).
  * If the sites utilization is too high, Vivado placer will complain that it has not enough FF/DSP/RAMs.

In a nutshell, here is the procedure to get a quick rough initial floorplan:

.. table:: Get initial power floorplan

    +------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------+
    | Step                                                                                                                                                                   | Example                                                      |
    +========================================================================================================================================================================+==============================================================+
    | Run |xclbin_generate|:                                                                                                                                                 |                                                              |
    |                                                                                                                                                                        |                                                              |
    |   * Set power CU utilization set to 0%.                                                                                                                                |                                                              |
    |   * Select all required power, memory, GT CUs.                                                                                                                         |                                                              |
    +------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------+
    | Open final DCP in Vivado:                                                                                                                                              |                                                              |
    |                                                                                                                                                                        |                                                              |
    |   * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/vpp_link/link/vivado/vpl/prj/prj.runs/impl_1/level0_wrapper_postroute_physopt.dcp`` |                                                              |
    |                                                                                                                                                                        |                                                              |
    | Where:                                                                                                                                                                 |                                                              |
    |                                                                                                                                                                        |                                                              |
    |   * |<xbtest_build> def|                                                                                                                                               |                                                              |
    |   * |<dev_platform> def|                                                                                                                                               |                                                              |
    |   * |<project_name> def|                                                                                                                                               |                                                              |
    +------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------+
    | Find which clock region are occupied by the Memory-SubSystem (Mem-SS).                                                                                                 |                                                              |
    +------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------+
    | Find which clock region is occupied by the DDR calibration DSP:                                                                                                        | .. figure:: ./images/dsp-mem-ss-search.png                   |
    |                                                                                                                                                                        |     :align: center                                           |
    |   * Look for DSPs inside the Mem-SS (typically 2 DSPs per DDR).                                                                                                        |                                                              |
    |                                                                                                                                                                        |     Find mem-SS DSP                                          |
    +------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------+
    | If a column of macro (DSP, BRAM or URAM) is located next to the static region, mark it as invalid in :ref:`invalid-json`.                                              | For example, invalid a column of DSP (X=29) across all SLRs: |
    |                                                                                                                                                                        |                                                              |
    |                                                                                                                                                                        | .. code-block:: JSON                                         |
    |                                                                                                                                                                        |                                                              |
    |                                                                                                                                                                        |     {                                                        |
    |                                                                                                                                                                        |       "PL_INVALID" :                                         |
    |                                                                                                                                                                        |         "SLR_0": [                                           |
    |                                                                                                                                                                        |           { "location": "DSP48E2_X29Y0:DSP48E2_X29Y89" }     |
    |                                                                                                                                                                        |         ],                                                   |
    |                                                                                                                                                                        |         "SLR_1": [                                           |
    |                                                                                                                                                                        |           { "location": "DSP48E2_X29Y90:DSP48E2_X29Y185" }   |
    |                                                                                                                                                                        |         ],                                                   |
    |                                                                                                                                                                        |         "SLR_2": [                                           |
    |                                                                                                                                                                        |           { "location": "DSP48E2_X29Y186:DSP48E2_X29Y281" }  |
    |                                                                                                                                                                        |         ]                                                    |
    |                                                                                                                                                                        |     }                                                        |
    |                                                                                                                                                                        |                                                              |
    +------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------+
    |  Leave room for the Memory CU to grow:                                                                                                                                 |                                                              |
    |                                                                                                                                                                        |                                                              |
    |    * Mem-SS will grow as power, memory and GT kernel use PLRAM and require AXI connection to it.                                                                       |                                                              |
    |    * HBM-SS number of ports of memory CU depend on platform.                                                                                                           |                                                              |
    +------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------+
    | Define utilization per clock region: use these typical values:                                                                                                         | .. code-block::                                              |
    |                                                                                                                                                                        |                                                              |
    |   * **When the clock region is totally available for the power CU**:                                                                                                   |     "CR_Y_<cr_y>" : {                                        |
    |                                                                                                                                                                        |       "CR_X"  : [ <...>  <cr_x>   <...> ],                   |
    |       * SLICE = 95 %                                                                                                                                                   |       "SLICE" : [ <...>     95,   <...> ],                   |
    |       * DSP   = 100 %                                                                                                                                                  |       "DSP"   : [ <...>    100,   <...> ],                   |
    |       * BRAM  = 100 %                                                                                                                                                  |       "BRAM"  : [ <...>    100,   <...> ],                   |
    |       * URAM  = 100 %                                                                                                                                                  |       "URAM"  : [ <...>    100,   <...> ]                    |
    |                                                                                                                                                                        |     },                                                       |
    |   * **When the clock region is occupied by the Mem-SS or HBM-SS**,                                                                                                     |                                                              |
    |     don't be afraid of inserting column of DSP/URAM where the Mem/HBM-SS is located:                                                                                   | .. code-block::                                              |
    |                                                                                                                                                                        |                                                              |
    |       * SLICE = 0 %                                                                                                                                                    |     "CR_Y_<cr_y>" : {                                        |
    |       * DSP   = 100 %                                                                                                                                                  |       "CR_X"  : [ <...>  <cr_x>   <...> ],                   |
    |       * BRAM  = 0 %                                                                                                                                                    |       "SLICE" : [ <...>      0,   <...> ],                   |
    |       * URAM  = 100 %                                                                                                                                                  |       "DSP"   : [ <...>    100,   <...> ],                   |
    |                                                                                                                                                                        |       "BRAM"  : [ <...>      0,   <...> ],                   |
    |   * **When the clock region is occupied by DDR calibration DSP**, with only 50% of DSP,                                                                                |       "URAM"  : [ <...>    100,   <...> ]                    |
    |     You give enough freedom to Vivado to place the DDR calibration DSPs alongside the power CU DSP's,                                                                  |     },                                                       |
    |     without creating timing issue inside the calibration logic:                                                                                                        |                                                              |
    |                                                                                                                                                                        | .. code-block::                                              |
    |       * SLICE = 0 %                                                                                                                                                    |                                                              |
    |       * DSP   = 50 %                                                                                                                                                   |     "CR_Y_<cr_y>" : {                                        |
    |       * BRAM  = 0 %                                                                                                                                                    |       "CR_X"  : [ <...>  <cr_x>   <...> ],                   |
    |       * URAM  = 100 %                                                                                                                                                  |       "SLICE" : [ <...>      0,   <...> ],                   |
    |                                                                                                                                                                        |       "DSP"   : [ <...>     50,   <...> ],                   |
    |                                                                                                                                                                        |       "BRAM"  : [ <...>      0,   <...> ],                   |
    |                                                                                                                                                                        |       "URAM"  : [ <...>    100,   <...> ]                    |
    |                                                                                                                                                                        |     },                                                       |
    +------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------+
    | Refine utilization number according to timing closure (@ 500MHz) and the actual maximum power reached:                                                                 |                                                              |
    |                                                                                                                                                                        |                                                              |
    |   * Utilization goes from 0 to 100 (%), feel free to be imaginative.                                                                                                   |                                                              |
    |   * DSP are hungry beast, and they are easy to P&R, so try to use them as much as you can.                                                                             |                                                              |
    |   * FF requires lots of tool effort resulting in long P&R phase, avoid them as much as possible.                                                                       |                                                              |
    |                                                                                                                                                                        |                                                              |
    |       * Vivado converges faster when using DSP and RAM.                                                                                                                |                                                              |
    |                                                                                                                                                                        |                                                              |
    |   * So far the Mem/HBM-SS and GT CU don't use any URAM nor DSP, so it's why you can insert them everywhere across the dynamic region.                                  |                                                              |
    |   * Take extra care when trying to use BRAMs in clock region already occupied by the Mem-SS, you could end up with timing violation in the Mem-SS.                     |                                                              |
    |   * Reduce ``SLICE`` utilization in the clock region close to SLR boundaries when timing issue are related to SLR-crossing (check failing paths).                      |                                                              |
    |                                                                                                                                                                        |                                                              |
    |     .. note::                                                                                                                                                          |                                                              |
    |         u280 platforms are more prone to timing violation in Mem-SS from SLR2 to SLR0 (when the SLR is getting fuller,                                                 |                                                              |
    |         some logic of SLR1 ends being put in SLR2 but the SLR crossing logic is not updated accordingly).                                                              |                                                              |
    +------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------+


Try the display_pwr_fp mode (see :ref:`visualize-power-cu-floorplan`) to easily visualize the actual location of the power CU across all SLR based on you power floorplan JSON files.

Here is an example of ``xilinx_u280_xdma_201910_1`` floorplan:

.. figure:: ./images/xilinx-u280-xdma-201910-1-floorplan.png
    :align: center

    xilinx_u280_xdma_201910_1 Floorplan

.. table:: xilinx_u280_xdma_201910_1 floorplan legend

    +------------------+----------------------------------------------------------------------------+
    | Colour           | Description                                                                |
    +==================+============================================================================+
    | Orange and white | Power CU:                                                                  |
    |                  |                                                                            |
    |                  |   * In white the column of DSPs running across the entire dynamic region.  |
    |                  |   * Notice the 4 columns of URAM across the entire dynamic region.         |
    +------------------+----------------------------------------------------------------------------+
    | Yellow           | Static region.                                                             |
    +------------------+----------------------------------------------------------------------------+
    | Green            | DDR memory CU.                                                             |
    +------------------+----------------------------------------------------------------------------+
    | Dark Blue        | HBM memory CU (16 channels).                                               |
    +------------------+----------------------------------------------------------------------------+
    | Turquoise        | Mem-SS and HBM-SS.                                                         |
    +------------------+----------------------------------------------------------------------------+
    | Red rectangle    | Location of the DDR calibration DSP, so no power CU DSPs (white).          |
    +------------------+----------------------------------------------------------------------------+

.. note::

      * No DSP are used on the left side of the static region (no white column close to yellow static region).

          * Depending on the platform settings during its generation, routing of the static region is allowed bleed into the dynamic region.
          * Placing power CU logic next to the static region may impeach routing.

      * The top SLR doesn't contain any power CU FF or BRAM, so GT CUs could be added.

---------------------------------------------------
Power estimation
---------------------------------------------------

.. important::
    The power estimation described in this section is only valid for Virtex Ultrascale+ type of |Alveo|_ card.

The estimated power is computed as:


.. math::

    Estimated\ power = site\ usage * site\ power

Where:

  * The site usage is the number of sites used in the power floorplan.
  * The site power is an estimation of power consumption for 1 site.

    .. table:: Site power estimation

        +-----------+-----------------+
        | Site type | Site power (mW) |
        +===========+=================+
        | SLICE     | 1.39158324      |
        +-----------+-----------------+
        | DSP       | 10.96698108     |
        +-----------+-----------------+
        | BRAM      | 48.27586212     |
        +-----------+-----------------+
        | URAM      | 63.94736844     |
        +-----------+-----------------+

You can find the quantity of Slices, DSPs, BRAMs and URAMs used in the power CU per SLR within Vivado file ``runme.log``.
Look for ID ``[GEN_CONSTRAINTS-18]`` in ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project_name>/u_ex/run/vpp_link/link/vivado/vpl/runme.log``.

Where:

  * |<xbtest_build> def|
  * |<dev_platform> def|
  * |<project_name> def|

.. code-block:: bash
    :emphasize-lines: 1

    INFO: [GEN_POWER_FLOORPLAN-18] SLR0 utilization:
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      |   Resource |    Dynamic |  Available |      Usage |    Usage % |  Est Pwr W |
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      |      SLICE |      46735 |      45415 |      16220 |      35.72 |      22.57 |
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      |       BRAM |        684 |        684 |          0 |       0.00 |       0.00 |
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      |       URAM |        112 |        112 |        112 |     100.00 |       7.16 |
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      |        DSP |       1368 |       1368 |       1056 |      77.19 |      11.58 |
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      Total estimated power: 41.31 W

The ``display_pwr_fp`` flow gives you directly the total for the whole FPGA in ``wizard.log``, while you need to make this addition for all SLRs if you read Vitis ``runme.log``:

  * ``<xbtest_build>/xclbin_generate/output/<dev_platform>/<project name>/wizard.log``

.. code-block:: bash
    :emphasize-lines: 1

    INFO: [GEN_POWER_FLOORPLAN-18] Total utilization:
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      |   Resource |    Dynamic |  Available |      Usage |    Usage % |  Est Pwr W |
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      |      SLICE |     182175 |     182175 |      37615 |      20.65 |      52.34 |
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      |        DSP |      10634 |      10634 |       8678 |      81.61 |      95.17 |
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      |       BRAM |       2384 |       2384 |        912 |      38.26 |      44.03 |
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]      |       URAM |       1068 |       1068 |        940 |      88.01 |      60.11 |
    INFO: [GEN_POWER_FLOORPLAN-18]      -------------------------------------------------------------------------------
    INFO: [GEN_POWER_FLOORPLAN-18]  Total estimated power: 251.65 W

----------------------------------------------------
Power limitations/considerations and general advises
----------------------------------------------------

Make sure you power CU is designed according to the maximum power you want to achieve (not too big, not too small).

  * The power CU should run at **75-80%** of toggle rate and still being capable of reaching the maximum power when the FPGA is cold and with server fan spinning at 100% (with 20C ambient air).

**75-80%** leaves margin for testing clock throttle and clock shut-down safety mechanism present in some shells (e.g. u50 subsystem 2.0).

Don't count on the general leakage of the device to reach the target power:

  * The maximum power should be reached even if the FPGA is cold (@35C).
  * TSMC improves continuously its processes and user may have to redesign the power CU if the leakage is reduced.
  * |XPE|_

.. _visualize-power-cu-floorplan:

=====================================================
Visualize power CU floorplan
=====================================================

---------------------------------------------------
Visualization overview
---------------------------------------------------

``xbtest_wizard`` allows the power CU floorplan visualization without synthesis and implementation.
It generates the power CU floorplan the same way as it is done during the power CU output products generation (during Vitis execution) and a Vivado project is generated, which allow to mark the site of the power CU floorplan with simple commands.

---------------------------------------------------
Pre-requisites
---------------------------------------------------

The following steps need to be completed before visualizing the power CU floorplan:

  * :ref:`define-power-cu-floorplan-setup`
  * :ref:`power-floorplan-sources-definition`


.. _define-power-cu-floorplan-setup:

---------------------------------------------------
Setup
---------------------------------------------------

The following parameters need to be set to in :ref:`wizard-configuration-json-file`:

  * ``pwr_floorplan_dir``: Specify power floorplan source directory.
  * ``display_pwr_floorplan``: Set to ``true``.
  * ``cu_selection.power``: Specify all the power CU.

The following example shows the minimal required parameters:

.. code-block:: JSON

    {
      "xbtest_power_fp": {
        "build": {
          "pwr_floorplan_dir" : "../pwr_cfg",
          "display_pwr_floorplan" : true
        },
        "cu_selection" : {
          "power" : [0, 1, 2]
        }
      }
    }

Run |xclbin_generate| workflow using command line option :option:`--skip_xclbin_gen` to skip xclbin generation.
A Vivado project will be generated and then opened running a generated ``setup.tcl`` script using the following commands:

  1. Move to xclbin_generate directory:

     .. code-block:: bash

         $ cd <xbtest_build>/xclbin_generate

  2. Run xclbin_generate workflow:

     .. code-block:: bash

         $ python3 gen_xclbin.py --ip_catalog <xbtest_catalog> --skip_xclbin_gen --xpfm path/to/your/platform.xpfm --wizard_config_name xbtest_power_fp --config_dir path/to/your/config_dir --project_name prj_power_fp

  3. Open project:

     .. code-block:: bash

         $ vivado -source ./output/<dev_platform>/prj_power_fp/u_ex/run/display_pwr_fp/setup.tcl

Where:

  * |<xbtest_catalog> def|
  * |<xbtest_build> def|
  * |<dev_platform> def|

---------------------------------------------------
Visualize floorplan
---------------------------------------------------

Display the power CU resources in different colour depending on the type:

.. table:: Power CU visualization legend

    +-----------+--------+
    | Site type | Colour |
    +===========+========+
    | SLICE     | blue   |
    +-----------+--------+
    | DSP       | green  |
    +-----------+--------+
    | BRAM      | orange |
    +-----------+--------+
    | URAM      | yellow |
    +-----------+--------+

.. table:: Power CU visualization commands

    +----------------------------------------+---------------------------------------+------------------------------------------------------------------------------------------------+------------------------------------------------------+
    | Command                                | Syntax                                | Usage                                                                                          | Example                                              |
    +========================================+=======================================+================================================================================================+======================================================+
    | Report the utilization of the power CU | .. code-block::                       | ``<resource>``: (Optional) Defines the resources to be displayed e.g. all, SLICE or DSP.       | Use command ``unmark_objects`` to reset the display: |
    |                                        |                                       |                                                                                                |                                                      |
    |                                        |     display_pwr_fp <resource>         |                                                                                                | .. code-block::                                      |
    |                                        |                                       |                                                                                                |                                                      |
    |                                        |                                       |                                                                                                |     display_pwr_fp all                               |
    |                                        |                                       |                                                                                                |     display_pwr_fp all                               |
    |                                        |                                       |                                                                                                |     unmark_objects                                   |
    |                                        |                                       |                                                                                                |     display_pwr_fp SLICE                             |
    |                                        |                                       |                                                                                                |     unmark_objects                                   |
    |                                        |                                       |                                                                                                |     display_pwr_fp DSP                               |
    +----------------------------------------+---------------------------------------+------------------------------------------------------------------------------------------------+------------------------------------------------------+
    | Report the utilization of the power CU | .. code-block::                       |   * ``<resource>``\ : (Optional) Defines the resource to be displayed e.g. all, SLICE or DSP.  | .. code-block::                                      |
    |                                        |                                       |   * ``<area>``\ : (Optional) Defines the area to be reported:                                  |                                                      |
    |                                        |  report_utilization <resource> <area> |                                                                                                |     report_utilization  all    SLR                   |
    |                                        |                                       |       * ``SLR``: The utilization will be reported per SLR.                                     |     report_utilization  SLICE  SLR                   |
    |                                        |                                       |       * ``CR``: The utilization will be reported per Clock Region.                             |     report_utilization  DSP    CR                    |
    |                                        |                                       |                                                                                                |                                                      |
    +----------------------------------------+---------------------------------------+------------------------------------------------------------------------------------------------+------------------------------------------------------+

.. table:: ``display_pwr_fp`` output examples

    +----------------------------------------+---------------------------------------+-----------------------------------------------+
    | Command                                | Description                           | Output                                        |
    +========================================+=======================================+===============================================+
    | .. code-block::                        | Display all sites types               | .. figure:: ./images/display-pwr-fp-all.png   |
    |                                        |                                       |     :align: center                            |
    |     display_pwr_fp all                 |                                       |                                               |
    |                                        |                                       |     display_pwr_fp all                        |
    +----------------------------------------+---------------------------------------+-----------------------------------------------+
    | .. code-block::                        | Display SLICE sites                   | .. figure:: ./images/display-pwr-fp-slice.png |
    |                                        |                                       |     :align: center                            |
    |     display_pwr_fp SLICE               |                                       |                                               |
    |                                        |                                       |     display_pwr_fp SLICE                      |
    +----------------------------------------+---------------------------------------+-----------------------------------------------+
    | .. code-block::                        | Display DSP sites                     | .. figure:: ./images/display-pwr-fp-dsp.png   |
    |                                        |                                       |     :align: center                            |
    |     display_pwr_fp DSP                 |                                       |                                               |
    |                                        |                                       |     display_pwr_fp DSP                        |
    +----------------------------------------+---------------------------------------+-----------------------------------------------+

---------------------------------------------------
FPGA part
---------------------------------------------------

The FPGA part must be set in the platform XPFM file (provided via command line option :option:`--xpfm` to |xclbin_generate| workflow).

|xclbin_generate| workflow expects the value of the FPGA part to be defined in:

  * ``hardwarePlatforms.hardwarePlatform.board.part``

Alternatively, the FPGA part can be overwritten using ``fpga_part`` parameter in :ref:`wizard-configuration-json-file`.
For example, set u50 board part:

.. code-block:: JSON

    {
      "xbtest_power_fp": {
        "platform": {
          "fpga_part" : "xcu50-fsvh2104-2L-e"
        }
        "build": {
          "pwr_floorplan_dir" : "../pwr_cfg",
          "display_pwr_floorplan" : true
        },
        "cu_selection" : {
          "power" : [0]
        }
      }
    }

---------------------------------------------------
Other outputs
---------------------------------------------------

In the build directory, the following other outputs can be found, relatively to the directory ``<xbtest_build>/xclbin_generate/output/<dev_platform>/prj_power_fp/u_ex/run/display_pwr_fp``.

Where:

  * |<xbtest_build> def|
  * |<dev_platform> def|

.. table:: Other outputs

    +--------------------------------------------------------------------+---------------------------------------------------------------+
    | Description                                                        | File location                                                 |
    +====================================================================+===============================================================+
    | Site utilization (total and per SLR)                               | ``output/gen_constraints.log``                                |
    +--------------------------------------------------------------------+---------------------------------------------------------------+
    | All XDC constraints (caution, huge file)                           | ``output/sdx_loc.tcl``                                        |
    +--------------------------------------------------------------------+---------------------------------------------------------------+
    | The SV packages defining the number of resources to be synthesized | ``output/powertest_param_slr<slr>.sv``                        |
    +--------------------------------------------------------------------+---------------------------------------------------------------+
    | TCL scripts to mark sites in the output Vivado project             | ``debug/mark_<slr>_CR_X<cr_x>Y<cr_y>_<site_type>_actual.dbg`` |
    +--------------------------------------------------------------------+---------------------------------------------------------------+

