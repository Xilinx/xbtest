// Copyright (C) 2022 Xilinx, Inc.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// default_nettype of none prevents implicit wire declaration.
`default_nettype none

`define MEMTEST_WRAPPER_AXI_PARAM(INDEX)                        \
    parameter integer C_M``INDEX``_AXI_THREAD_ID_WIDTH  = 2,    \
    parameter integer C_M``INDEX``_AXI_ADDR_WIDTH       = 64,   \
    parameter integer C_M``INDEX``_AXI_DATA_WIDTH       = 512,

`define MEMTEST_WRAPPER_AXI_PORT(INDEX)                                         \
    output wire [C_M``INDEX``_AXI_THREAD_ID_WIDTH-1:0]  m``INDEX``_axi_awid,    \
    output wire                                         m``INDEX``_axi_awvalid, \
    input  wire                                         m``INDEX``_axi_awready, \
    output wire [C_M``INDEX``_AXI_ADDR_WIDTH-1:0]       m``INDEX``_axi_awaddr,  \
    output wire [8-1:0]                                 m``INDEX``_axi_awlen,   \
    output wire                                         m``INDEX``_axi_wvalid,  \
    input  wire                                         m``INDEX``_axi_wready,  \
    output wire [C_M``INDEX``_AXI_DATA_WIDTH-1:0]       m``INDEX``_axi_wdata,   \
    output wire [C_M``INDEX``_AXI_DATA_WIDTH/8-1:0]     m``INDEX``_axi_wstrb,   \
    output wire                                         m``INDEX``_axi_wlast,   \
    input  wire [C_M``INDEX``_AXI_THREAD_ID_WIDTH-1:0]  m``INDEX``_axi_bid,     \
    input  wire                                         m``INDEX``_axi_bvalid,  \
    output wire                                         m``INDEX``_axi_bready,  \
                                                                                \
    output wire [C_M``INDEX``_AXI_THREAD_ID_WIDTH-1:0]  m``INDEX``_axi_arid,    \
    output wire                                         m``INDEX``_axi_arvalid, \
    input  wire                                         m``INDEX``_axi_arready, \
    output wire [C_M``INDEX``_AXI_ADDR_WIDTH-1:0]       m``INDEX``_axi_araddr,  \
    output wire [8-1:0]                                 m``INDEX``_axi_arlen,   \
    input  wire [C_M``INDEX``_AXI_THREAD_ID_WIDTH-1:0]  m``INDEX``_axi_rid,     \
    input  wire                                         m``INDEX``_axi_rvalid,  \
    output wire                                         m``INDEX``_axi_rready,  \
    input  wire [C_M``INDEX``_AXI_DATA_WIDTH-1:0]       m``INDEX``_axi_rdata,   \
    input  wire                                         m``INDEX``_axi_rlast,   \
    input  wire [C_M``INDEX``_AXI_ADDR_WIDTH-1:0]       axi``INDEX``_ptr0,

module memtest_wrapper #(
    parameter integer C_MAJOR_VERSION       = 2,    // Major version
    parameter integer C_MINOR_VERSION       = 0,    // Minor version
    parameter integer C_BUILD_VERSION       = 0,    // Build version
    parameter integer C_CLOCK0_FREQ         = 300,  // Frequency for clock0 (ap_clk)
    parameter integer C_CLOCK1_FREQ         = 500,  // Frequency for clock1 (ap_clk_2)
    parameter integer C_BLOCK_ID            = 1,    // Block_ID (POWER = 0, MEMORY = 1)
    parameter integer C_MEM_KRNL_INST       = 0,    // Memory kernel instance
    parameter integer C_NUM_MAX_M_AXI       = 32,   // Maximum number of M_AXI ports (for memory kernel)
    parameter integer C_NUM_USED_M_AXI      = 1,    // Number of used M_AXI ports 1..32 (enables M01_AXI .. M32_AXI for memory kernel)
    parameter integer C_MEM_TYPE            = 0,    // 1 single-channel 2 multi-channel
    parameter integer C_USE_AXI_ID          = 0,    // 1 use axi id, 0 disable
    parameter integer C_PLRAM_ADDR_WIDTH    = 64,
    parameter integer C_PLRAM_DATA_WIDTH    = 32,

    `MEMTEST_WRAPPER_AXI_PARAM(01)
    `MEMTEST_WRAPPER_AXI_PARAM(02)
    `MEMTEST_WRAPPER_AXI_PARAM(03)
    `MEMTEST_WRAPPER_AXI_PARAM(04)
    `MEMTEST_WRAPPER_AXI_PARAM(05)
    `MEMTEST_WRAPPER_AXI_PARAM(06)
    `MEMTEST_WRAPPER_AXI_PARAM(07)
    `MEMTEST_WRAPPER_AXI_PARAM(08)
    `MEMTEST_WRAPPER_AXI_PARAM(09)
    `MEMTEST_WRAPPER_AXI_PARAM(10)
    `MEMTEST_WRAPPER_AXI_PARAM(11)
    `MEMTEST_WRAPPER_AXI_PARAM(12)
    `MEMTEST_WRAPPER_AXI_PARAM(13)
    `MEMTEST_WRAPPER_AXI_PARAM(14)
    `MEMTEST_WRAPPER_AXI_PARAM(15)
    `MEMTEST_WRAPPER_AXI_PARAM(16)
    `MEMTEST_WRAPPER_AXI_PARAM(17)
    `MEMTEST_WRAPPER_AXI_PARAM(18)
    `MEMTEST_WRAPPER_AXI_PARAM(19)
    `MEMTEST_WRAPPER_AXI_PARAM(20)
    `MEMTEST_WRAPPER_AXI_PARAM(21)
    `MEMTEST_WRAPPER_AXI_PARAM(22)
    `MEMTEST_WRAPPER_AXI_PARAM(23)
    `MEMTEST_WRAPPER_AXI_PARAM(24)
    `MEMTEST_WRAPPER_AXI_PARAM(25)
    `MEMTEST_WRAPPER_AXI_PARAM(26)
    `MEMTEST_WRAPPER_AXI_PARAM(27)
    `MEMTEST_WRAPPER_AXI_PARAM(28)
    `MEMTEST_WRAPPER_AXI_PARAM(29)
    `MEMTEST_WRAPPER_AXI_PARAM(30)
    `MEMTEST_WRAPPER_AXI_PARAM(31)
    `MEMTEST_WRAPPER_AXI_PARAM(32)

    parameter integer DEST_SYNC_FF          = 4,
    parameter integer C_EXTRA_CHIPSCOPE     = 0

) (
    input   wire        ap_clk,
    input   wire        ap_clk_cont,
    input   wire        ap_rst,

    input  wire         watchdog_alarm_in,

    // AXI4 master interfaces
    `MEMTEST_WRAPPER_AXI_PORT(01)
    `MEMTEST_WRAPPER_AXI_PORT(02)
    `MEMTEST_WRAPPER_AXI_PORT(03)
    `MEMTEST_WRAPPER_AXI_PORT(04)
    `MEMTEST_WRAPPER_AXI_PORT(05)
    `MEMTEST_WRAPPER_AXI_PORT(06)
    `MEMTEST_WRAPPER_AXI_PORT(07)
    `MEMTEST_WRAPPER_AXI_PORT(08)
    `MEMTEST_WRAPPER_AXI_PORT(09)
    `MEMTEST_WRAPPER_AXI_PORT(10)
    `MEMTEST_WRAPPER_AXI_PORT(11)
    `MEMTEST_WRAPPER_AXI_PORT(12)
    `MEMTEST_WRAPPER_AXI_PORT(13)
    `MEMTEST_WRAPPER_AXI_PORT(14)
    `MEMTEST_WRAPPER_AXI_PORT(15)
    `MEMTEST_WRAPPER_AXI_PORT(16)
    `MEMTEST_WRAPPER_AXI_PORT(17)
    `MEMTEST_WRAPPER_AXI_PORT(18)
    `MEMTEST_WRAPPER_AXI_PORT(19)
    `MEMTEST_WRAPPER_AXI_PORT(20)
    `MEMTEST_WRAPPER_AXI_PORT(21)
    `MEMTEST_WRAPPER_AXI_PORT(22)
    `MEMTEST_WRAPPER_AXI_PORT(23)
    `MEMTEST_WRAPPER_AXI_PORT(24)
    `MEMTEST_WRAPPER_AXI_PORT(25)
    `MEMTEST_WRAPPER_AXI_PORT(26)
    `MEMTEST_WRAPPER_AXI_PORT(27)
    `MEMTEST_WRAPPER_AXI_PORT(28)
    `MEMTEST_WRAPPER_AXI_PORT(29)
    `MEMTEST_WRAPPER_AXI_PORT(30)
    `MEMTEST_WRAPPER_AXI_PORT(31)
    `MEMTEST_WRAPPER_AXI_PORT(32)

    output wire         plram_awvalid,
    input  wire         plram_awready,
    output wire [63:0]  plram_awaddr,
    output wire [7:0]   plram_awlen,
    output wire         plram_wvalid,
    input  wire         plram_wready,
    output wire [31:0]  plram_wdata,
    output wire [3:0]   plram_wstrb,
    output wire         plram_wlast,
    input  wire         plram_bvalid,
    output wire         plram_bready,
    output wire         plram_arvalid,
    input  wire         plram_arready,
    output wire [63:0]  plram_araddr,
    output wire [7:0]   plram_arlen,
    input  wire         plram_rvalid,
    output wire         plram_rready,
    input  wire [31:0]  plram_rdata,
    input  wire         plram_rlast,

    input  wire [C_PLRAM_ADDR_WIDTH-1:0]  axi00_ptr0,
    input  wire [32-1:0]                  scalar00,
    input  wire [32-1:0]                  scalar01,
    input  wire [32-1:0]                  scalar02,
    input  wire [32-1:0]                  scalar03,
    input  wire                           start_pulse,
    output wire                           done_pulse
);

    localparam integer SIM_DIVIDER
    // synthesis translate_off
                                    = 1000;
    localparam integer DUMMY_DIVIDER
    // synthesis translate_on
                                    = 1;

    wire         toggle_1_sec;

    wire         cs;
    wire         we;
    wire  [27:0] addr;
    wire  [31:0] wdata;
    logic [31:0] rdata;
    logic        cmd_cmplt;

    ///////////////////////////////////////////////////////////////////////////////
    // Memory CU host interface
    ///////////////////////////////////////////////////////////////////////////////

    memtest_config  # (
        .C_PLRAM_ADDR_WIDTH ( C_PLRAM_ADDR_WIDTH    ),
        .C_PLRAM_DATA_WIDTH ( C_PLRAM_DATA_WIDTH    ),
        .C_NUM_USED_M_AXI   ( C_NUM_USED_M_AXI      )
    ) u_memtest_config (
        .clk              ( ap_clk           ),
        .rst              ( ap_rst           ),

        .plram_awvalid    ( plram_awvalid    ),
        .plram_awready    ( plram_awready    ),
        .plram_awaddr     ( plram_awaddr     ),
        .plram_awlen      ( plram_awlen      ),
        .plram_wvalid     ( plram_wvalid     ),
        .plram_wready     ( plram_wready     ),
        .plram_wdata      ( plram_wdata      ),
        .plram_wstrb      ( plram_wstrb      ),
        .plram_wlast      ( plram_wlast      ),
        .plram_bvalid     ( plram_bvalid     ),
        .plram_bready     ( plram_bready     ),
        .plram_arvalid    ( plram_arvalid    ),
        .plram_arready    ( plram_arready    ),
        .plram_araddr     ( plram_araddr     ),
        .plram_arlen      ( plram_arlen      ),
        .plram_rvalid     ( plram_rvalid     ),
        .plram_rready     ( plram_rready     ),
        .plram_rdata      ( plram_rdata      ),
        .plram_rlast      ( plram_rlast      ),

        .axi00_ptr0       ( axi00_ptr0       ),
        .scalar00         ( scalar00         ),
        .scalar01         ( scalar01         ),
        .scalar02         ( scalar02         ),
        .scalar03         ( scalar03         ),
        .start_pulse      ( start_pulse      ),
        .done_pulse       ( done_pulse       ),

        .cs               ( cs               ),
        .wr_en            ( we               ),
        .addr             ( addr             ),
        .wdata            ( wdata            ),
        .rdata            ( rdata            ),
        .cmd_cmplt        ( cmd_cmplt        )
    );

    ///////////////////////////////////////////////////////////////////////////////
    // Manage proc interface
    ///////////////////////////////////////////////////////////////////////////////

    logic        cs_d = 'b0;
    logic        we_d = 'b0;
    logic [27:0] addr_d = 'b0;
    logic [31:0] wdata_d = 'b0;

    wire        sel_wrapper_bi_ctrl = addr[4];
    wire        sel_wrapper_cores   = addr[27];
    wire [4:0]  sel_core_idx        = addr[26:22];

    wire        sel_wrapper_bi_ctrl_d   = addr_d[4];
    wire        sel_wrapper_cores_d     = addr_d[27];
    wire [4:0]  sel_core_idx_d          = addr_d[26:22];

    logic       we_bi = 'b0;
    logic       we_ctrl_status = 'b0;
    wire [31:0] rdata_bi;
    wire [31:0] rdata_ctrl_status;

    logic [C_NUM_MAX_M_AXI:1]   cs_memtest = 'b0;
    wire  [31:0]                rdata_memtest [C_NUM_MAX_M_AXI:1];
    wire  [C_NUM_MAX_M_AXI:1]   cmd_cmplt_memtest;

    wire [C_NUM_USED_M_AXI:1] sel;
    wire [C_NUM_USED_M_AXI:1] sel_d;

    logic [31:0] rdata_v = 'b0;
    logic        cmd_cmplt_v = 'b0;

    wire [15: 0] Info_3 = 'h0;

    generate
        for (genvar INDEX = 0; INDEX < C_NUM_USED_M_AXI; INDEX++) begin
            assign sel[INDEX+1]     = (sel_core_idx     == INDEX) ? 1'b1 : 1'b0;
            assign sel_d[INDEX+1]   = (sel_core_idx_d   == INDEX) ? 1'b1 : 1'b0;
        end
    endgenerate

    always_ff @(posedge ap_clk) begin
        ///////////////////////////////////////////////////////////////////////////////
        // Stage 1
        ///////////////////////////////////////////////////////////////////////////////
        cs_d    <= cs;
        we_d    <= we;
        addr_d  <= addr;
        wdata_d <= wdata;

        we_bi           <= 1'b0;
        we_ctrl_status  <= 1'b0;

        cs_memtest  <= 'b0;

        if (cs) begin
            case (sel_wrapper_cores)
                'h0 : begin // wrapper build info
                    if (sel_wrapper_bi_ctrl) begin
                        we_ctrl_status <= we;
                    end else begin
                        we_bi          <= we;
                    end
                end
                default : begin // cores registers
                    for (int INDEX = 1; INDEX <= C_NUM_USED_M_AXI; INDEX++) begin
                        if (sel[INDEX] == 1'b1) begin
                            cs_memtest[INDEX] <= 1'b1;
                        end
                    end
                end
            endcase
        end

        ///////////////////////////////////////////////////////////////////////////////
        // Stage 2
        ///////////////////////////////////////////////////////////////////////////////

        rdata_v     = 'h0;
        cmd_cmplt_v = 1'b0;
        for (int INDEX = 1; INDEX <= C_NUM_USED_M_AXI; INDEX++) begin
            rdata_v     = rdata_v        | rdata_memtest[INDEX];
            cmd_cmplt_v = cmd_cmplt_v    | cmd_cmplt_memtest[INDEX];
        end

        rdata       <= rdata_v;
        cmd_cmplt   <= cmd_cmplt_v;

        if ((cs_d == 1'b1) && (sel_wrapper_cores_d == 1'b0)) begin
            if (sel_wrapper_bi_ctrl_d) begin
                rdata   <= rdata_ctrl_status;
            end else begin
                rdata   <= rdata_bi;
            end

            cmd_cmplt   <= 1'b1;
        end
    end

    ///////////////////////////////////////////////////////////////////////////////
    // build info instantiation
    ///////////////////////////////////////////////////////////////////////////////
    build_info_v4_0 #(
        .C_MAJOR_VERSION    ( C_MAJOR_VERSION       ),
        .C_MINOR_VERSION    ( C_MINOR_VERSION       ),
        .C_BUILD_VERSION    ( C_BUILD_VERSION       ),
        .C_BLOCK_ID         ( C_BLOCK_ID            )
    ) memtest_build_info (
        .Clk        ( ap_clk                                        ),
        .Rst        ( ap_rst                                        ),
        .Info_1     ( 16'b0                                         ),
        .Info_2     ( {C_MEM_KRNL_INST[7:0], 8'b0}                  ),
        .Info_3     ( Info_3                                        ),
        .Info_4     ( {C_NUM_MAX_M_AXI[7:0], C_NUM_USED_M_AXI[7:0]} ),
        .Info_5     ( {12'b0, C_USE_AXI_ID[1:0], C_MEM_TYPE[1:0]}   ),
        .Info_6     ( 16'h0                                         ),
        .Info_7     ( {7'h0, C_CLOCK0_FREQ[8:0]}                    ),
        .Info_8     ( {7'b0, C_CLOCK1_FREQ[8:0]}                    ),
        .We         ( we_bi                                         ),
        .Addr       ( addr_d[2:0]                                   ),
        .Data_In    ( wdata_d                                       ),
        .Data_Out   ( rdata_bi                                      )
    );

    common_ctrl_status #(
        .C_CLOCK_FREQ               ( C_CLOCK0_FREQ ),
        .DEST_SYNC_FF               ( DEST_SYNC_FF  ),
        .C_CLK_TROTTLE_DETECT_EN    ( 0             ),
        .C_WATCHDOG_ENABLE          ( 0             ),
        .C_EXT_TOGGLE_1_SEC         ( 0             )
    ) u_common_ctrl_status (
        .ap_clk         ( ap_clk            ),
        .ap_clk_cont    ( ap_clk_cont       ),
        .ap_rst         ( ap_rst            ),

        .ap_clk_2       ( 1'b0              ),
        .ap_clk_2_cont  ( 1'b0              ),
        .ap_rst_2       ( 1'b0              ),

        .toggle_1sec    ( 1'b0              ),
        .rst_watchdog   ( 1'b0              ),
        .watchdog_alarm (                   ),
        .We             ( we_ctrl_status    ),
        .Addr           ( addr_d[2:0]       ),
        .Data_In        ( wdata_d           ),
        .User_Status_1  ( 'h0               ),
        .Data_Out       ( rdata_ctrl_status )
    );

    ///////////////////////////////////////////////////////////////////////////////
    // Instantiate memtest IPs
    ///////////////////////////////////////////////////////////////////////////////

    timer #(
        .C_CLOCK_FREQ       ( C_CLOCK0_FREQ     ),
        .C_1_SEC_TIMER_EN   ( 1                 ),
        .DEST_SYNC_FF       ( DEST_SYNC_FF      ),
        .C_SIM_DIVIDER      ( SIM_DIVIDER       )
    ) u_timer (
        .clk_1              ( ap_clk_cont       ),
        .clk_2              ( ap_clk            ),

        .toggle_1_sec_1     (                   ),
        .toggle_1_sec_2     ( toggle_1_sec      ),

        .timer_rst          ( 1'b0              ),
        .timer_end_1        (                   ),
        .timer_end_2        (                   )
    );

    `define MEMTEST_TOP_INSTANCE(INDEX)                                             \
    generate                                                                        \
        if (INDEX <= C_NUM_USED_M_AXI) begin : genblk_memtest_top_``INDEX``         \
            memtest_top #(                                                          \
                .C_MAJOR_VERSION            ( C_MAJOR_VERSION                   ),  \
                .C_MINOR_VERSION            ( C_MINOR_VERSION                   ),  \
                .C_BUILD_VERSION            ( C_BUILD_VERSION                   ),  \
                .C_CLOCK0_FREQ              ( C_CLOCK0_FREQ                     ),  \
                .C_CLOCK1_FREQ              ( C_CLOCK1_FREQ                     ),  \
                .C_BLOCK_ID                 ( C_BLOCK_ID                        ),  \
                .C_MEM_KRNL_INST            ( C_MEM_KRNL_INST                   ),  \
                .C_MEM_KRNL_CORE_IDX        ( INDEX                             ),  \
                .C_NUM_MAX_M_AXI            ( C_NUM_MAX_M_AXI                   ),  \
                .C_NUM_USED_M_AXI           ( C_NUM_USED_M_AXI                  ),  \
                .C_MEM_TYPE                 ( C_MEM_TYPE                        ),  \
                .C_USE_AXI_ID               ( C_USE_AXI_ID                      ),  \
                .C_M_AXI_THREAD_ID_WIDTH    ( C_M``INDEX``_AXI_THREAD_ID_WIDTH  ),  \
                .C_M_AXI_ADDR_WIDTH         ( C_M``INDEX``_AXI_ADDR_WIDTH       ),  \
                .C_M_AXI_DATA_WIDTH         ( C_M``INDEX``_AXI_DATA_WIDTH       ),  \
                .C_NUM_PIPELINE             ( 2                                 ),  \
                .C_EXTRA_CHIPSCOPE          ( C_EXTRA_CHIPSCOPE                 )   \
            ) u_memtest_top_``INDEX`` (                                             \
                .ap_clk             ( ap_clk                        ),              \
                .ap_clk_cont        ( ap_clk_cont                   ),              \
                .ap_rst             ( ap_rst                        ),              \
                                                                                    \
                .m_axi_awid         ( m``INDEX``_axi_awid           ),              \
                .m_axi_awvalid      ( m``INDEX``_axi_awvalid        ),              \
                .m_axi_awready      ( m``INDEX``_axi_awready        ),              \
                .m_axi_awaddr       ( m``INDEX``_axi_awaddr         ),              \
                .m_axi_awlen        ( m``INDEX``_axi_awlen          ),              \
                .m_axi_wvalid       ( m``INDEX``_axi_wvalid         ),              \
                .m_axi_wready       ( m``INDEX``_axi_wready         ),              \
                .m_axi_wdata        ( m``INDEX``_axi_wdata          ),              \
                .m_axi_wstrb        ( m``INDEX``_axi_wstrb          ),              \
                .m_axi_wlast        ( m``INDEX``_axi_wlast          ),              \
                .m_axi_bid          ( m``INDEX``_axi_bid            ),              \
                .m_axi_bvalid       ( m``INDEX``_axi_bvalid         ),              \
                .m_axi_bready       ( m``INDEX``_axi_bready         ),              \
                                                                                    \
                .m_axi_arid         ( m``INDEX``_axi_arid           ),              \
                .m_axi_arvalid      ( m``INDEX``_axi_arvalid        ),              \
                .m_axi_arready      ( m``INDEX``_axi_arready        ),              \
                .m_axi_araddr       ( m``INDEX``_axi_araddr         ),              \
                .m_axi_arlen        ( m``INDEX``_axi_arlen          ),              \
                .m_axi_rid          ( m``INDEX``_axi_rid            ),              \
                .m_axi_rvalid       ( m``INDEX``_axi_rvalid         ),              \
                .m_axi_rready       ( m``INDEX``_axi_rready         ),              \
                .m_axi_rdata        ( m``INDEX``_axi_rdata          ),              \
                .m_axi_rlast        ( m``INDEX``_axi_rlast          ),              \
                                                                                    \
                .axi_addr_ptr       ( axi``INDEX``_ptr0             ),              \
                                                                                    \
                .toggle_1_sec       ( toggle_1_sec                  ),              \
                .watchdog_alarm     ( watchdog_alarm_in             ),              \
                                                                                    \
                .cs                 ( cs_memtest[INDEX]             ),              \
                .we                 ( we_d                          ),              \
                .addr               ( addr_d[21:0]                  ),              \
                .wdata              ( wdata_d                       ),              \
                .rdata              ( rdata_memtest[INDEX]          ),              \
                .cmd_cmplt          ( cmd_cmplt_memtest[INDEX]      )               \
            );                                                                      \
        end : genblk_memtest_top_``INDEX``                                          \
    endgenerate

    `MEMTEST_TOP_INSTANCE(01)
    `MEMTEST_TOP_INSTANCE(02)
    `MEMTEST_TOP_INSTANCE(03)
    `MEMTEST_TOP_INSTANCE(04)
    `MEMTEST_TOP_INSTANCE(05)
    `MEMTEST_TOP_INSTANCE(06)
    `MEMTEST_TOP_INSTANCE(07)
    `MEMTEST_TOP_INSTANCE(08)
    `MEMTEST_TOP_INSTANCE(09)
    `MEMTEST_TOP_INSTANCE(10)
    `MEMTEST_TOP_INSTANCE(11)
    `MEMTEST_TOP_INSTANCE(12)
    `MEMTEST_TOP_INSTANCE(13)
    `MEMTEST_TOP_INSTANCE(14)
    `MEMTEST_TOP_INSTANCE(15)
    `MEMTEST_TOP_INSTANCE(16)
    `MEMTEST_TOP_INSTANCE(17)
    `MEMTEST_TOP_INSTANCE(18)
    `MEMTEST_TOP_INSTANCE(19)
    `MEMTEST_TOP_INSTANCE(20)
    `MEMTEST_TOP_INSTANCE(21)
    `MEMTEST_TOP_INSTANCE(22)
    `MEMTEST_TOP_INSTANCE(23)
    `MEMTEST_TOP_INSTANCE(24)
    `MEMTEST_TOP_INSTANCE(25)
    `MEMTEST_TOP_INSTANCE(26)
    `MEMTEST_TOP_INSTANCE(27)
    `MEMTEST_TOP_INSTANCE(28)
    `MEMTEST_TOP_INSTANCE(29)
    `MEMTEST_TOP_INSTANCE(30)
    `MEMTEST_TOP_INSTANCE(31)
    `MEMTEST_TOP_INSTANCE(32)

endmodule: memtest_wrapper
`default_nettype wire
