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

module memtest_reg_array #(
    parameter integer C_MAJOR_VERSION       = 0,    // Major version
    parameter integer C_MINOR_VERSION       = 0,    // Minor version
    parameter integer C_BUILD_VERSION       = 0,    // Build version
    parameter integer C_CLOCK0_FREQ         = 300,  // Frequency for clock0 (ap_clk)
    parameter integer C_CLOCK1_FREQ         = 500,  // Frequency for clock1 (ap_clk_2)
    parameter integer DEST_SYNC_FF          = 4,
    parameter integer C_BLOCK_ID            = 1,    // Block_ID (POWER = 0, MEMORY = 1)
    parameter integer C_MEM_KRNL_INST       = 0,    // Memory kernel instance
    parameter integer C_MEM_KRNL_CORE_IDX   = 0,    // M_AXI Port index
    parameter integer C_NUM_MAX_M_AXI       = 32,   // Maximum number of M_AXI ports (for memory kernel)
    parameter integer C_NUM_USED_M_AXI      = 1,    // Number of M_AXI ports
    parameter integer C_MEM_TYPE            = 0,    // 1 single-channel 2 multi-channel
    parameter integer C_USE_AXI_ID          = 0,    // 1 use axi id, 0 disable
    parameter integer C_M_AXI_DATA_WIDTH    = 0,
    parameter integer C_NUM_XFER_SIZE_WIDTH = 28,   // Width of the ctrl_xfer_cnt,
    parameter integer C_M_AXI_ADDR_WIDTH    = 64,
    parameter integer C_STAT_MEAS_SIZE      = 32,    // Max 32
    parameter integer C_STAT_TOTAL_SIZE     = 64,    // Max 64
    parameter integer C_STAT_INST_SIZE      = 32,    // Max 32
    parameter integer C_STAT_ERR_CNT_SIZE   = 8      // Max 32
) (
    input  wire                                 clk,
    input  wire                                 rst,

    input  wire                                 cs,
    input  wire                                 we,
    input  wire  [21:0]                         addr,
    input  wire  [31:0]                         wdata,
    output logic [31:0]                         rdata = '0,
    output logic                                cmd_cmplt = '0,

    input  wire                                 watchdog_alarm,

    output logic                                ctrl_stop_pulse = '0,
    output logic                                ctrl_update_cfg_pulse = '0,
    output logic [1:0]                          ctrl_test_mode = '0,

    output logic                                ctrl_reset = '0,
    output logic                                ctrl_clear_err_pulse = '0,

    output wire [63:0]                          ctrl_wr_start_addr,
    output wire [63:0]                          ctrl_rd_start_addr,

    output logic [8-1:0]                        ctrl_wr_burst_size = '0,
    output logic [8-1:0]                        ctrl_rd_burst_size = '0,

    output logic [C_NUM_XFER_SIZE_WIDTH-1:0]    ctrl_wr_num_xfer = '0,
    output logic [C_NUM_XFER_SIZE_WIDTH-1:0]    ctrl_rd_num_xfer = '0,

    output logic                                ctrl_wr_burst_req_rate_en = '0,
    output logic [31:0]                         ctrl_wr_burst_req_rate = '0,
    output logic                                ctrl_rd_burst_req_rate_en = '0,
    output logic [31:0]                         ctrl_rd_burst_req_rate = '0,

    output logic                                ctrl_wr_outstanding_en = '0,
    output logic [8:0]                          ctrl_wr_outstanding = '0,
    output logic                                ctrl_rd_outstanding_en = '0,
    output logic [8:0]                          ctrl_rd_outstanding = '0,

    output logic                                ctrl_axi_id_en = C_USE_AXI_ID[0],

    input  wire                                 stat_cfg_updated_pulse,

    input  wire                                 stat_toggle_1_sec,
    input  wire  [15:0]                         stat_timestamp_1_sec,

    input  wire                                 stat_gen_seed_err_latch,
    input  wire                                 stat_term_seed_err_latch,
    input  wire                                 stat_term_err_latch,
    input  wire [C_STAT_ERR_CNT_SIZE-1:0]       stat_term_err_cnt,

    input  wire [C_M_AXI_ADDR_WIDTH-1:0]        stat_axi_addr_ptr,

    input wire [31:0]                           stat_timestamp,

    input wire [C_STAT_TOTAL_SIZE-1:0]          stat_wr_burst_time_total,
    input wire [C_STAT_INST_SIZE-1:0]           stat_wr_burst_time_inst,
    input wire [C_STAT_MEAS_SIZE-1:0]           stat_wr_burst_time_min,
    input wire [C_STAT_MEAS_SIZE-1:0]           stat_wr_burst_time_max,

    input wire [C_STAT_TOTAL_SIZE-1:0]          stat_rd_burst_time_total,
    input wire [C_STAT_INST_SIZE-1:0]           stat_rd_burst_time_inst,
    input wire [C_STAT_MEAS_SIZE-1:0]           stat_rd_burst_time_min,
    input wire [C_STAT_MEAS_SIZE-1:0]           stat_rd_burst_time_max,

    input wire [C_STAT_TOTAL_SIZE-1:0]          stat_wr_burst_latency_total,
    input wire [C_STAT_INST_SIZE-1:0]           stat_wr_burst_latency_inst,
    input wire [C_STAT_MEAS_SIZE-1:0]           stat_wr_burst_latency_min,
    input wire [C_STAT_MEAS_SIZE-1:0]           stat_wr_burst_latency_max,

    input wire [C_STAT_TOTAL_SIZE-1:0]          stat_rd_burst_latency_total,
    input wire [C_STAT_INST_SIZE-1:0]           stat_rd_burst_latency_inst,
    input wire [C_STAT_MEAS_SIZE-1:0]           stat_rd_burst_latency_min,
    input wire [C_STAT_MEAS_SIZE-1:0]           stat_rd_burst_latency_max
);

function [3:0] f_data_width_div;
    input integer C_M_AXI_DATA_WIDTH;

    case (C_M_AXI_DATA_WIDTH)
        512 : begin
                f_data_width_div = 'h1;
            end
        256 : begin
                f_data_width_div = 'h2;
            end
        128 : begin
                f_data_width_div = 'h4;
            end
        64 : begin
                f_data_width_div = 'h8;
            end
        default: begin
                f_data_width_div = 'h0;
        end
    endcase

endfunction


wire [19:0] addr_core_reg   = addr[19:0];
wire        sel_core_reg    = addr[21];
wire        sel_core_stat   = addr[20];
wire        sel_bi_ctrl     = addr[4];

wire        we_bi           = (~sel_core_reg & ~sel_bi_ctrl) ? cs & we : 'b0;
wire        we_ctrl_status  = (~sel_core_reg &  sel_bi_ctrl) ? cs & we : 'b0;
wire [31:0] rdata_bi;
wire [31:0] rdata_ctrl_status;

wire [15: 0] Info_3 = {12'b0, f_data_width_div(C_M_AXI_DATA_WIDTH) };


//########################################
//### build info instantiation
//########################################
build_info_v4_0 #(
    .C_MAJOR_VERSION    ( C_MAJOR_VERSION       ),
    .C_MINOR_VERSION    ( C_MINOR_VERSION       ),
    .C_BUILD_VERSION    ( C_BUILD_VERSION       ),
    .C_BLOCK_ID         ( C_BLOCK_ID            )
) u_build_info (
    .Clk        ( clk                                           ),
    .Rst        ( rst                                           ),
    .Info_1     ( 16'b0                                         ), // Info 1 reserved for future use
    .Info_2     ( {C_MEM_KRNL_INST[7:0], 8'b0}                  ),
    .Info_3     ( Info_3                                        ),
    .Info_4     ( {C_NUM_MAX_M_AXI[7:0], C_NUM_USED_M_AXI[7:0]} ),
    .Info_5     ( {12'b0, C_USE_AXI_ID[1:0], C_MEM_TYPE[1:0]}   ),
    .Info_6     ( {8'b0, C_MEM_KRNL_CORE_IDX[7:0]}              ),
    .Info_7     ( {7'b0, C_CLOCK0_FREQ[8:0]}                    ),
    .Info_8     ( {7'b0, C_CLOCK1_FREQ[8:0]}                    ),
    .We         ( we_bi                                         ),
    .Addr       ( addr[2:0]                                     ),
    .Data_In    ( wdata                                         ),
    .Data_Out   ( rdata_bi                                      )
);


common_ctrl_status #(
    .C_CLOCK_FREQ               ( C_CLOCK0_FREQ ),
    .DEST_SYNC_FF               ( DEST_SYNC_FF  ),
    .C_CLK_TROTTLE_DETECT_EN    ( 0             ),
    .C_WATCHDOG_ENABLE          ( 0             ),
    .C_EXT_TOGGLE_1_SEC         ( 0             )
) u_common_ctrl_status (
    .ap_clk         ( clk               ),
    .ap_clk_cont    ( 1'b0              ),
    .ap_rst         ( rst               ),

    .ap_clk_2       ( 1'b0              ),
    .ap_clk_2_cont  ( 1'b0              ),
    .ap_rst_2       ( 1'b0              ),

    .toggle_1sec    ( 1'b0              ),
    .rst_watchdog   ( 1'b0              ),
    .watchdog_alarm (                   ),

    .We             ( we_ctrl_status    ),
    .Addr           ( addr[2:0]         ),
    .Data_In        ( wdata             ),
    .User_Status_1  ( 32'b0             ),
    .Data_Out       ( rdata_ctrl_status )
);

//########################################
//### Registers
//########################################

logic           stat_cfg_updated_latch = '0;
logic [31:0]    ctrl_wr_start_addr_lsb = '0;
logic [31:0]    ctrl_wr_start_addr_msb = '0;

logic [31:0]    ctrl_rd_start_addr_lsb = '0;
logic [31:0]    ctrl_rd_start_addr_msb = '0;

// there is a false path on the watchdog alarm input
wire   watchdog_alarm_cdc;
(*dont_touch ="true"*) logic watchdog_alarm_d = '0;

xpm_cdc_single #(
    .DEST_SYNC_FF   ( DEST_SYNC_FF  ),
    .INIT_SYNC_FF   ( 0             ),
    .SRC_INPUT_REG  ( 0             ),
    .SIM_ASSERT_CHK ( 0             )
)
xpm_cdc_watchdog (
    .src_clk  ( 'b0         ),
    .src_in   ( watchdog_alarm      ),
    .dest_out ( watchdog_alarm_cdc  ),
    .dest_clk ( clk                 )
);

always_ff @(posedge clk) begin

    ctrl_stop_pulse         <= '0;
    ctrl_update_cfg_pulse   <= '0;
    ctrl_clear_err_pulse    <= '0;

    rdata                   <= '0;
    cmd_cmplt               <= cs;

    watchdog_alarm_d <= watchdog_alarm_cdc;

    if (watchdog_alarm_cdc != watchdog_alarm_d) begin

        ctrl_stop_pulse <= 1'b1; // stop the memory CU channel

    end
    if (stat_cfg_updated_pulse) begin

        stat_cfg_updated_latch <= 1'b1;

    end

    if (cs) begin

        case (sel_core_reg)
            'h0 : begin
                if (sel_bi_ctrl) begin                                      //  0x10 -> 0x1F = common ctrl and status
                    rdata <= rdata_ctrl_status;
                end else begin                                              //  0x8 -> 0xF  = Unused
                    rdata <= rdata_bi;                                      //  0x0 -> 0x7  = build info
                end
            end
            default : begin
                case (sel_core_stat)
                    'h0 : begin // ctrl reg
                        case (addr_core_reg[3:0]) // 0x200000 -> 0x2FFFFF = Core control registers
                            'h00 : begin     // 0x200000
                                if (we) begin
                                    ctrl_stop_pulse             <= wdata[0];
                                    ctrl_update_cfg_pulse       <= wdata[1];
                                    if (wdata[1] | wdata[0]) begin
                                        stat_cfg_updated_latch <= 1'b0; // clear status just before we update config or stop CU as SW will detect its asserted in both case
                                    end
                                    ctrl_test_mode              <= wdata[5:4];
                                    ctrl_reset                  <= wdata[8];
                                    ctrl_clear_err_pulse        <= wdata[12];
                                    ctrl_wr_burst_req_rate_en   <= wdata[16];
                                    ctrl_rd_burst_req_rate_en   <= wdata[17];
                                    ctrl_wr_outstanding_en      <= wdata[18];
                                    ctrl_rd_outstanding_en      <= wdata[19];
                                    if (C_USE_AXI_ID == 1) begin
                                        ctrl_axi_id_en          <= wdata[20];
                                    end
                                end
                                rdata[5:4]  <= ctrl_test_mode;
                                rdata[8]    <= ctrl_reset;
                                rdata[16]   <= ctrl_wr_burst_req_rate_en;
                                rdata[17]   <= ctrl_rd_burst_req_rate_en;
                                rdata[18]   <= ctrl_wr_outstanding_en;
                                rdata[19]   <= ctrl_rd_outstanding_en;
                                if (C_USE_AXI_ID == 1) begin
                                    rdata[20]   <= ctrl_axi_id_en;
                                end
                            end
                            'h01 : begin     // 0x200001
                                if (we) begin
                                    ctrl_wr_start_addr_lsb <= wdata;
                                end
                                rdata <= ctrl_wr_start_addr_lsb;
                            end
                            'h02 : begin     // 0x200002
                                if (we) begin
                                    ctrl_wr_start_addr_msb <= wdata;
                                end
                                rdata <= ctrl_wr_start_addr_msb;
                            end
                            'h03 : begin     // 0x200003
                                if (we) begin
                                    ctrl_rd_start_addr_lsb <= wdata;
                                end
                                rdata <= ctrl_rd_start_addr_lsb;
                            end
                            'h04 : begin     // 0x200004
                                if (we) begin
                                    ctrl_rd_start_addr_msb <= wdata;
                                end
                                rdata <= ctrl_rd_start_addr_msb;
                            end
                            'h05 : begin     // 0x200005
                                if (we) begin
                                    ctrl_wr_burst_size  <= wdata[8-1:0];
                                end
                                rdata[8-1:0] <= ctrl_wr_burst_size;
                            end
                            'h06 : begin     // 0x200006
                                if (we) begin
                                    ctrl_rd_burst_size  <= wdata[8-1:0];
                                end
                                rdata[8-1:0] <= ctrl_rd_burst_size;
                            end
                            'h07 : begin     // 0x200007
                                if (we) begin
                                    ctrl_wr_num_xfer <= wdata[C_NUM_XFER_SIZE_WIDTH-1:0];
                                end
                                rdata[C_NUM_XFER_SIZE_WIDTH-1:0] <= ctrl_wr_num_xfer;
                            end
                            'h08 : begin     // 0x200008
                                if (we) begin
                                    ctrl_rd_num_xfer <= wdata[C_NUM_XFER_SIZE_WIDTH-1:0];
                                end
                                rdata[C_NUM_XFER_SIZE_WIDTH-1:0] <= ctrl_rd_num_xfer;
                            end

                            'h09 : begin     // 0x200009
                                if (we) begin
                                    ctrl_wr_burst_req_rate <= wdata;
                                end
                                rdata <= ctrl_wr_burst_req_rate;
                            end
                            'h0A : begin     // 0x20000A
                                if (we) begin
                                    ctrl_rd_burst_req_rate <= wdata;
                                end
                                rdata <= ctrl_rd_burst_req_rate;
                            end
                            'h0B : begin // 0x20000B
                                if (we) begin
                                    ctrl_wr_outstanding <= wdata[24:16];
                                    ctrl_rd_outstanding <= wdata[8:0];
                                end
                                rdata[24:16] <= ctrl_wr_outstanding;
                                rdata[8:0]   <= ctrl_rd_outstanding;
                            end
                            /*
                            'h0C : begin // 0x20000C
                            end
                            ...
                            'hFFFFF : begin // 0x2FFFFF
                            end
                            */
                            default : $display("Illegal address");
                        endcase
                    end
                    default : begin // stat reg
                        case (addr_core_reg[4:0]) // 0x300000 -> 0x3FFFFF = Core status registers
                            'h00 : begin     // 0x300000
                                rdata[0]        <= stat_cfg_updated_latch;
                                rdata[1]        <= stat_term_err_latch;
                                rdata[2]        <= stat_gen_seed_err_latch;
                                rdata[3]        <= stat_term_seed_err_latch;
                                rdata[15]       <= stat_toggle_1_sec;
                                rdata[31:16]    <= stat_timestamp_1_sec;
                            end
                            'h01 : begin     // 0x300001
                                rdata[C_STAT_ERR_CNT_SIZE-1:0] <= stat_term_err_cnt;
                            end
                            'h02 : begin     // 0x300002
                                rdata <= stat_axi_addr_ptr[31:0];
                            end
                            'h03 : begin     // 0x300003
                                rdata <= stat_axi_addr_ptr[63:32];
                            end

                            'h04 : begin     // 0x300004
                                if (C_STAT_TOTAL_SIZE >= 32) begin
                                    rdata                           <= stat_wr_burst_time_total[31:0];
                                end else begin
                                    rdata[C_STAT_TOTAL_SIZE-1:0]    <= stat_wr_burst_time_total;
                                end
                            end
                            'h05 : begin     // 0x300005
                                rdata <= stat_wr_burst_time_total[63:32];
                            end
                            'h06 : begin     // 0x300006
                                rdata[C_STAT_INST_SIZE-1:0] <= stat_wr_burst_time_inst;
                            end
                            'h07 : begin     // 0x300007
                                rdata[C_STAT_MEAS_SIZE-1:0] <= stat_wr_burst_time_min;
                            end
                            'h08 : begin     // 0x200008
                                rdata[C_STAT_MEAS_SIZE-1:0] <= stat_wr_burst_time_max;
                            end

                            'h09 : begin     // 0x300009
                                if (C_STAT_TOTAL_SIZE >= 32) begin
                                    rdata                           <= stat_rd_burst_time_total[31:0];
                                end else begin
                                    rdata[C_STAT_TOTAL_SIZE-1:0]    <= stat_rd_burst_time_total;
                                end
                            end
                            'h0A : begin     // 0x30000A
                                if (C_STAT_TOTAL_SIZE >= 32) begin
                                    rdata[C_STAT_TOTAL_SIZE-32-1:0] <= stat_rd_burst_time_total[C_STAT_TOTAL_SIZE-1:32];
                                end
                            end
                            'h0B : begin     // 0x30000B
                                rdata[C_STAT_INST_SIZE-1:0] <= stat_rd_burst_time_inst;
                            end
                            'h0C : begin     // 0x30000C
                                rdata[C_STAT_MEAS_SIZE-1:0] <= stat_rd_burst_time_min;
                            end
                            'h0D : begin     // 0x30000D
                                rdata[C_STAT_MEAS_SIZE-1:0] <= stat_rd_burst_time_max;
                            end

                            'h0E : begin     // 0x30000E
                                if (C_STAT_TOTAL_SIZE >= 32) begin
                                    rdata                           <= stat_wr_burst_latency_total[31:0];
                                end else begin
                                    rdata[C_STAT_TOTAL_SIZE-1:0]    <= stat_wr_burst_latency_total;
                                end
                            end
                            'h0F : begin     // 0x30000F
                                if (C_STAT_TOTAL_SIZE >= 32) begin
                                    rdata[C_STAT_TOTAL_SIZE-32-1:0] <= stat_wr_burst_latency_total[C_STAT_TOTAL_SIZE-1:32];
                                end
                            end
                            'h10 : begin     // 0x300010
                                rdata[C_STAT_INST_SIZE-1:0] <= stat_wr_burst_latency_inst;
                            end
                            'h11 : begin     // 0x300011
                                rdata[C_STAT_MEAS_SIZE-1:0] <= stat_wr_burst_latency_min;
                            end
                            'h12 : begin     // 0x300012
                                rdata[C_STAT_MEAS_SIZE-1:0] <= stat_wr_burst_latency_max;
                            end

                            'h13 : begin     // 0x300013
                                if (C_STAT_TOTAL_SIZE >= 32) begin
                                    rdata                           <= stat_rd_burst_latency_total[31:0];
                                end else begin
                                    rdata[C_STAT_TOTAL_SIZE-1:0]    <= stat_rd_burst_latency_total;
                                end
                            end
                            'h14 : begin     // 0x300014
                                if (C_STAT_TOTAL_SIZE >= 32) begin
                                    rdata[C_STAT_TOTAL_SIZE-32-1:0] <= stat_rd_burst_latency_total[C_STAT_TOTAL_SIZE-1:32];
                                end
                            end
                            'h15 : begin     // 0x300015
                                rdata[C_STAT_INST_SIZE-1:0] <= stat_rd_burst_latency_inst;
                            end
                            'h16 : begin     // 0x300016
                                rdata[C_STAT_MEAS_SIZE-1:0] <= stat_rd_burst_latency_min;
                            end
                            'h17 : begin     // 0x300017
                                rdata[C_STAT_MEAS_SIZE-1:0] <= stat_rd_burst_latency_max;
                            end

                            'h18 : begin     // 0x300018
                                rdata <= stat_timestamp;
                            end

                            /*
                            'h19 : begin     // 0x300019
                            end
                            ...
                            'hFFFFF : begin     // 0x3FFFFF
                            end
                            */
                            default : $display("Illegal address");
                        endcase
                    end
                endcase
            end
        endcase

    end

    if (rst) begin

        ctrl_update_cfg_pulse       <= '0;
        ctrl_reset                  <= '0;
        stat_cfg_updated_latch      <= '0;
        cmd_cmplt                   <= '0;

    end
end

assign ctrl_wr_start_addr = { ctrl_wr_start_addr_msb, ctrl_wr_start_addr_lsb };
assign ctrl_rd_start_addr = { ctrl_rd_start_addr_msb, ctrl_rd_start_addr_lsb };

endmodule : memtest_reg_array
`default_nettype wire
