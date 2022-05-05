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

`define PORT_AXI_PTR0(INDEX)                        \
    output logic [64-1:0] axi``INDEX``_ptr0 = 'h0,  \

module krnl_xbtest_control_s_axi #(
    parameter integer C_KRNL_MODE       = 0,    // Validation kernel mode (POWER = 0, MEMORY = 1)
    parameter integer C_NUM_USED_M_AXI  = 1,    // Number of used M_AXI ports 1..32 (enables M01_AXI .. M32_AXI for memory kernel)
    parameter integer C_ADDR_WIDTH      = 12,
    parameter integer C_DATA_WIDTH      = 32
) (
    input  wire                      aclk,
    input  wire                      areset,
    input  wire                      awvalid,
    output logic                     awready,
    input  wire [C_ADDR_WIDTH-1:0]   awaddr,
    input  wire                      wvalid,
    output logic                     wready,
    input  wire [C_DATA_WIDTH-1:0]   wdata,
    input  wire [C_DATA_WIDTH/8-1:0] wstrb,
    input  wire                      arvalid,
    output logic                     arready,
    input  wire [C_ADDR_WIDTH-1:0]   araddr,
    output logic                     rvalid,
    input  wire                      rready,
    output logic [C_DATA_WIDTH-1:0]  rdata,
    output wire [2-1:0]              rresp,
    output logic                     bvalid,
    input  wire                      bready,
    output wire [2-1:0]              bresp,

    `PORT_AXI_PTR0(00)
    `PORT_AXI_PTR0(01)
    `PORT_AXI_PTR0(02)
    `PORT_AXI_PTR0(03)
    `PORT_AXI_PTR0(04)
    `PORT_AXI_PTR0(05)
    `PORT_AXI_PTR0(06)
    `PORT_AXI_PTR0(07)
    `PORT_AXI_PTR0(08)
    `PORT_AXI_PTR0(09)
    `PORT_AXI_PTR0(10)
    `PORT_AXI_PTR0(11)
    `PORT_AXI_PTR0(12)
    `PORT_AXI_PTR0(13)
    `PORT_AXI_PTR0(14)
    `PORT_AXI_PTR0(15)
    `PORT_AXI_PTR0(16)
    `PORT_AXI_PTR0(17)
    `PORT_AXI_PTR0(18)
    `PORT_AXI_PTR0(19)
    `PORT_AXI_PTR0(20)
    `PORT_AXI_PTR0(21)
    `PORT_AXI_PTR0(22)
    `PORT_AXI_PTR0(23)
    `PORT_AXI_PTR0(24)
    `PORT_AXI_PTR0(25)
    `PORT_AXI_PTR0(26)
    `PORT_AXI_PTR0(27)
    `PORT_AXI_PTR0(28)
    `PORT_AXI_PTR0(29)
    `PORT_AXI_PTR0(30)
    `PORT_AXI_PTR0(31)
    `PORT_AXI_PTR0(32)

    output wire                      interrupt,
    output logic                     ap_start,
    input  wire                      ap_idle,
    input  wire                      ap_done,
    output logic [32-1:0]            scalar00   = 'h0,
    output logic [32-1:0]            scalar01   = 'h0,
    output logic [32-1:0]            scalar02   = 'h0,
    output logic [32-1:0]            scalar03   = 'h0
);

    //------------------------Address Info-------------------
    // 0x000 : Control signals
    //         bit 0  - ap_start (Read/Write/COH)
    //         bit 1  - ap_done (Read/COR)
    //         bit 2  - ap_idle (Read)
    //         others - reserved
    // 0x004 : Global Interrupt Enable Register
    //         bit 0  - Global Interrupt Enable (Read/Write)
    //         others - reserved
    // 0x008 : IP Interrupt Enable Register (Read/Write)
    //         bit 0  - Channel 0 (ap_done)
    //         others - reserved
    // 0x00c : IP Interrupt Status Register (Read/TOW)
    //         bit 0  - Channel 0 (ap_done)
    //         others - reserved
    // 0x010 : Data signal of scalar00
    //         bit 31~0 - scalar00[31:0] (Read/Write)
    // 0x014 : reserved
    // 0x018 : Data signal of scalar01
    //         bit 31~0 - scalar01[31:0] (Read/Write)
    // 0x01c : reserved
    // 0x020 : Data signal of scalar02
    //         bit 31~0 - scalar02[31:0] (Read/Write)
    // 0x024 : reserved
    // 0x028 : Data signal of scalar03
    //         bit 31~0 - scalar03[31:0] (Read/Write)
    // 0x02c : reserved
    // 0x030 : Data signal of axi00_ptr0
    //         bit 31~0 - axi00_ptr0[31:0] (Read/Write)
    // 0x034 : Data signal of axi00_ptr0
    //         bit 31~0 - axi00_ptr0[63:32] (Read/Write)
    // 0x038 : Data signal of axi01_ptr0
    //         bit 31~0 - axi01_ptr0[31:0] (Read/Write)
    // 0x03c : Data signal of axi01_ptr0
    //         bit 31~0 - axi01_ptr0[63:32] (Read/Write)
    // ...
    // 0x130 : Data signal of axi32_ptr0
    //         bit 31~0 - axi32_ptr0[31:0] (Read/Write)
    // 0x134 : Data signal of axi32_ptr0
    //         bit 31~0 - axi32_ptr0[63:32] (Read/Write)
    // (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

    localparam [C_ADDR_WIDTH-1:0]
        LP_ADDR_AP_CTRL         = 12'h000,
        LP_ADDR_GIE             = 12'h004,
        LP_ADDR_IER             = 12'h008,
        LP_ADDR_ISR             = 12'h00c,
        LP_ADDR_SCALAR00_0      = 12'h010,
        LP_ADDR_SCALAR01_0      = 12'h018,
        LP_ADDR_SCALAR02_0      = 12'h020,
        LP_ADDR_SCALAR03_0      = 12'h028,
        LP_ADDR_AXI00_PTR0_0    = 12'h030,
        LP_ADDR_AXI00_PTR0_1    = 12'h034,
        LP_ADDR_AXI01_PTR0_0    = 12'h038,
        LP_ADDR_AXI01_PTR0_1    = 12'h03c,
        LP_ADDR_AXI02_PTR0_0    = 12'h040,
        LP_ADDR_AXI02_PTR0_1    = 12'h044,
        LP_ADDR_AXI03_PTR0_0    = 12'h048,
        LP_ADDR_AXI03_PTR0_1    = 12'h04c,
        LP_ADDR_AXI04_PTR0_0    = 12'h050,
        LP_ADDR_AXI04_PTR0_1    = 12'h054,
        LP_ADDR_AXI05_PTR0_0    = 12'h058,
        LP_ADDR_AXI05_PTR0_1    = 12'h05c,
        LP_ADDR_AXI06_PTR0_0    = 12'h060,
        LP_ADDR_AXI06_PTR0_1    = 12'h064,
        LP_ADDR_AXI07_PTR0_0    = 12'h068,
        LP_ADDR_AXI07_PTR0_1    = 12'h06c,
        LP_ADDR_AXI08_PTR0_0    = 12'h070,
        LP_ADDR_AXI08_PTR0_1    = 12'h074,
        LP_ADDR_AXI09_PTR0_0    = 12'h078,
        LP_ADDR_AXI09_PTR0_1    = 12'h07c,
        LP_ADDR_AXI10_PTR0_0    = 12'h080,
        LP_ADDR_AXI10_PTR0_1    = 12'h084,
        LP_ADDR_AXI11_PTR0_0    = 12'h088,
        LP_ADDR_AXI11_PTR0_1    = 12'h08c,
        LP_ADDR_AXI12_PTR0_0    = 12'h090,
        LP_ADDR_AXI12_PTR0_1    = 12'h094,
        LP_ADDR_AXI13_PTR0_0    = 12'h098,
        LP_ADDR_AXI13_PTR0_1    = 12'h09c,
        LP_ADDR_AXI14_PTR0_0    = 12'h0a0,
        LP_ADDR_AXI14_PTR0_1    = 12'h0a4,
        LP_ADDR_AXI15_PTR0_0    = 12'h0a8,
        LP_ADDR_AXI15_PTR0_1    = 12'h0ac,
        LP_ADDR_AXI16_PTR0_0    = 12'h0b0,
        LP_ADDR_AXI16_PTR0_1    = 12'h0b4,
        LP_ADDR_AXI17_PTR0_0    = 12'h0b8,
        LP_ADDR_AXI17_PTR0_1    = 12'h0bc,
        LP_ADDR_AXI18_PTR0_0    = 12'h0c0,
        LP_ADDR_AXI18_PTR0_1    = 12'h0c4,
        LP_ADDR_AXI19_PTR0_0    = 12'h0c8,
        LP_ADDR_AXI19_PTR0_1    = 12'h0cc,
        LP_ADDR_AXI20_PTR0_0    = 12'h0d0,
        LP_ADDR_AXI20_PTR0_1    = 12'h0d4,
        LP_ADDR_AXI21_PTR0_0    = 12'h0d8,
        LP_ADDR_AXI21_PTR0_1    = 12'h0dc,
        LP_ADDR_AXI22_PTR0_0    = 12'h0e0,
        LP_ADDR_AXI22_PTR0_1    = 12'h0e4,
        LP_ADDR_AXI23_PTR0_0    = 12'h0e8,
        LP_ADDR_AXI23_PTR0_1    = 12'h0ec,
        LP_ADDR_AXI24_PTR0_0    = 12'h0f0,
        LP_ADDR_AXI24_PTR0_1    = 12'h0f4,
        LP_ADDR_AXI25_PTR0_0    = 12'h0f8,
        LP_ADDR_AXI25_PTR0_1    = 12'h0fc,
        LP_ADDR_AXI26_PTR0_0    = 12'h100,
        LP_ADDR_AXI26_PTR0_1    = 12'h104,
        LP_ADDR_AXI27_PTR0_0    = 12'h108,
        LP_ADDR_AXI27_PTR0_1    = 12'h10c,
        LP_ADDR_AXI28_PTR0_0    = 12'h110,
        LP_ADDR_AXI28_PTR0_1    = 12'h114,
        LP_ADDR_AXI29_PTR0_0    = 12'h118,
        LP_ADDR_AXI29_PTR0_1    = 12'h11c,
        LP_ADDR_AXI30_PTR0_0    = 12'h120,
        LP_ADDR_AXI30_PTR0_1    = 12'h124,
        LP_ADDR_AXI31_PTR0_0    = 12'h128,
        LP_ADDR_AXI31_PTR0_1    = 12'h12c,
        LP_ADDR_AXI32_PTR0_0    = 12'h130,
        LP_ADDR_AXI32_PTR0_1    = 12'h134;

    localparam integer LP_SM_WIDTH = 2;

    // Write State Machine
    localparam [LP_SM_WIDTH-1:0]
        SM_WRIDLE   = 2'd0,
        SM_WRDATA   = 2'd1,
        SM_WRRESP   = 2'd2,
        SM_WRRESET  = 2'd3;
    logic [LP_SM_WIDTH-1:0] wstate = SM_WRRESET;

    // Read State Machine
    localparam [LP_SM_WIDTH-1:0]
        SM_RDIDLE   = 2'd0,
        SM_RDDATA   = 2'd1,
        SM_RDRESET  = 2'd3;
    logic [LP_SM_WIDTH-1:0] rstate = SM_RDRESET;

    logic [C_ADDR_WIDTH-1:0]    waddr = 'h0;
    wire  [C_DATA_WIDTH-1:0]    wmask = { {8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}} };
    // internal registers
    logic                       ap_done_latch   = 1'b0;
    logic                       int_gie         = 1'b0;
    logic                       int_ier         = 1'b0;
    logic                       int_isr         = 1'b0;

    //------------------------AXI WRITE FSM------------------
    // awready = (wstate == SM_WRIDLE);
    // wready  = (wstate == SM_WRDATA);
    // bvalid  = (wstate == SM_WRRESP);
    assign bresp = 2'b00; // OKAY

    // wstate
    always_ff @(posedge aclk) begin
        case (wstate)
            SM_WRIDLE: begin
                if (awvalid) begin
                    awready <= 1'b0;
                    wready  <= 1'b1;
                    waddr   <= awaddr;
                    wstate  <= SM_WRDATA;
                end
            end
            SM_WRDATA: begin
                if (wvalid) begin
                    wready  <= 1'b0;
                    bvalid  <= 1'b1;
                    wstate  <= SM_WRRESP;
                end
            end
            SM_WRRESP: begin
                if (bready) begin
                    awready <= 1'b1;
                    bvalid  <= 1'b0;
                    wstate  <= SM_WRIDLE;
                end
            end
            default: begin // SM_WRRESET
                awready <= 1'b1;
                wready  <= 1'b0;
                bvalid  <= 1'b0;
                wstate  <= SM_WRIDLE;
            end
        endcase

        if (areset) begin
            awready <= 1'b0;
            wready  <= 1'b0;
            bvalid  <= 1'b0;
            wstate  <= SM_WRRESET;
        end
    end

    //------------------------AXI READ FSM-------------------
    // arready = (rstate == SM_RDIDLE);
    // rvalid  = (rstate == SM_RDDATA);
    assign rresp   = 2'b00;  // OKAY
    // rstate
    always_ff @(posedge aclk) begin
        case (rstate)
            SM_RDIDLE: begin
                if (arvalid) begin
                    arready <= 1'b0;
                    rvalid  <= 1'b1;
                    rstate  <= SM_RDDATA;
                end
            end
            SM_RDDATA: begin
                if (rready) begin
                    arready <= 1'b1;
                    rvalid  <= 1'b0;
                    rstate  <= SM_RDIDLE;
                end
            end
            // SM_RDRESET:
            default: begin
                arready <= 1'b1;
                rvalid  <= 1'b0;
                rstate  <= SM_RDIDLE;
            end
        endcase

        if (areset) begin
            arready <= 1'b0;
            rvalid  <= 1'b0;
            rstate  <= SM_RDRESET;
        end
    end

`define CASE_RD_AXI_PTR0(INDEX)                                       \
    LP_ADDR_AXI``INDEX``_PTR0_0: rdata <= axi``INDEX``_ptr0[0+:32];   \
    LP_ADDR_AXI``INDEX``_PTR0_1: rdata <= axi``INDEX``_ptr0[32+:32];

always_ff @(posedge aclk) begin
    if (arvalid & arready) begin
        rdata <= 'h0;
        case (araddr)
            LP_ADDR_AP_CTRL: begin
                rdata[0] <= ap_start;
                rdata[1] <= ap_done_latch;
                rdata[2] <= ap_idle;

                ap_done_latch <= 1'b0; // clear on read
            end
            LP_ADDR_GIE:        rdata[0] <= int_gie;
            LP_ADDR_IER:        rdata[0] <= int_ier;
            LP_ADDR_ISR:        rdata[0] <= int_isr;
            LP_ADDR_SCALAR00_0: rdata <= scalar00[0+:32];
            LP_ADDR_SCALAR01_0: rdata <= scalar01[0+:32];
            LP_ADDR_SCALAR02_0: rdata <= scalar02[0+:32];
            LP_ADDR_SCALAR03_0: rdata <= scalar03[0+:32];

            `CASE_RD_AXI_PTR0(00)
            `CASE_RD_AXI_PTR0(01)
            `CASE_RD_AXI_PTR0(02)
            `CASE_RD_AXI_PTR0(03)
            `CASE_RD_AXI_PTR0(04)
            `CASE_RD_AXI_PTR0(05)
            `CASE_RD_AXI_PTR0(06)
            `CASE_RD_AXI_PTR0(07)
            `CASE_RD_AXI_PTR0(08)
            `CASE_RD_AXI_PTR0(09)
            `CASE_RD_AXI_PTR0(10)
            `CASE_RD_AXI_PTR0(11)
            `CASE_RD_AXI_PTR0(12)
            `CASE_RD_AXI_PTR0(13)
            `CASE_RD_AXI_PTR0(14)
            `CASE_RD_AXI_PTR0(15)
            `CASE_RD_AXI_PTR0(16)
            `CASE_RD_AXI_PTR0(17)
            `CASE_RD_AXI_PTR0(18)
            `CASE_RD_AXI_PTR0(19)
            `CASE_RD_AXI_PTR0(20)
            `CASE_RD_AXI_PTR0(21)
            `CASE_RD_AXI_PTR0(22)
            `CASE_RD_AXI_PTR0(23)
            `CASE_RD_AXI_PTR0(24)
            `CASE_RD_AXI_PTR0(25)
            `CASE_RD_AXI_PTR0(26)
            `CASE_RD_AXI_PTR0(27)
            `CASE_RD_AXI_PTR0(28)
            `CASE_RD_AXI_PTR0(29)
            `CASE_RD_AXI_PTR0(30)
            `CASE_RD_AXI_PTR0(31)
            `CASE_RD_AXI_PTR0(32)

            default: rdata <= 'h0;
        endcase
    end

    if (ap_done) begin
        ap_done_latch <= 1'b1;
    end

    if (areset) begin
        ap_done_latch <= 1'b0;
    end
end

//------------------------Register logic-----------------
assign interrupt = int_gie & (|int_isr);

// Generate axi00_ptr0 (INDEX == 0) for all kernel modes
// Generate other axi*_ptr0 for memory kernel (C_KRNL_MODE = 1) depending on number of m_axi ports used  C_NUM_USED_M_AXI
`define CASE_WR_AXI_PTR0(INDEX)                                                                                         \
    LP_ADDR_AXI``INDEX``_PTR0_0: begin                                                                                  \
        if ((INDEX == 0) || ((C_KRNL_MODE == 1) && (INDEX <= C_NUM_USED_M_AXI))) begin                                  \
            axi``INDEX``_ptr0[0+:32]    <= (wdata[0+:32] & wmask[0+:32]) | (axi``INDEX``_ptr0[0+:32] & ~wmask[0+:32]);  \
        end                                                                                                             \
    end                                                                                                                 \
    LP_ADDR_AXI``INDEX``_PTR0_1: begin                                                                                  \
        if ((INDEX == 0) || ((C_KRNL_MODE == 1) && (INDEX <= C_NUM_USED_M_AXI))) begin                                  \
            axi``INDEX``_ptr0[32+:32]   <= (wdata[0+:32] & wmask[0+:32]) | (axi``INDEX``_ptr0[32+:32] & ~wmask[0+:32]); \
        end                                                                                                             \
    end

always_ff @(posedge aclk) begin
    // ap_start
    if (ap_done) begin
        ap_start <= 1'b0;
    end

    // scalar00
    if (wvalid & wready) begin
        case (waddr)
            LP_ADDR_AP_CTRL: begin
                 if (wstrb[0] & wdata[0]) begin
                    ap_start <= 1'b1;
                end
            end
            LP_ADDR_GIE: begin
                 if (wstrb[0]) begin
                    int_gie <= wdata[0];
                end
            end
            LP_ADDR_IER: begin
                 if (wstrb[0]) begin
                    int_ier <= wdata[0];
                end
            end
            LP_ADDR_ISR: begin
                 if (wstrb[0]) begin
                    int_isr <= int_isr ^ wdata[0];
                end
            end
            LP_ADDR_SCALAR00_0: begin
                scalar00[0+:32] <= (wdata[0+:32] & wmask[0+:32]) | (scalar00[0+:32] & ~wmask[0+:32]);
            end
            LP_ADDR_SCALAR01_0: begin
                scalar01[0+:32] <= (wdata[0+:32] & wmask[0+:32]) | (scalar01[0+:32] & ~wmask[0+:32]);
            end
            LP_ADDR_SCALAR02_0: begin
                scalar02[0+:32] <= (wdata[0+:32] & wmask[0+:32]) | (scalar02[0+:32] & ~wmask[0+:32]);
            end
            LP_ADDR_SCALAR03_0: begin
                scalar03[0+:32] <= (wdata[0+:32] & wmask[0+:32]) | (scalar03[0+:32] & ~wmask[0+:32]);
            end
            `CASE_WR_AXI_PTR0(00)
            `CASE_WR_AXI_PTR0(01)
            `CASE_WR_AXI_PTR0(02)
            `CASE_WR_AXI_PTR0(03)
            `CASE_WR_AXI_PTR0(04)
            `CASE_WR_AXI_PTR0(05)
            `CASE_WR_AXI_PTR0(06)
            `CASE_WR_AXI_PTR0(07)
            `CASE_WR_AXI_PTR0(08)
            `CASE_WR_AXI_PTR0(09)
            `CASE_WR_AXI_PTR0(10)
            `CASE_WR_AXI_PTR0(11)
            `CASE_WR_AXI_PTR0(12)
            `CASE_WR_AXI_PTR0(13)
            `CASE_WR_AXI_PTR0(14)
            `CASE_WR_AXI_PTR0(15)
            `CASE_WR_AXI_PTR0(16)
            `CASE_WR_AXI_PTR0(17)
            `CASE_WR_AXI_PTR0(18)
            `CASE_WR_AXI_PTR0(19)
            `CASE_WR_AXI_PTR0(20)
            `CASE_WR_AXI_PTR0(21)
            `CASE_WR_AXI_PTR0(22)
            `CASE_WR_AXI_PTR0(23)
            `CASE_WR_AXI_PTR0(24)
            `CASE_WR_AXI_PTR0(25)
            `CASE_WR_AXI_PTR0(26)
            `CASE_WR_AXI_PTR0(27)
            `CASE_WR_AXI_PTR0(28)
            `CASE_WR_AXI_PTR0(29)
            `CASE_WR_AXI_PTR0(30)
            `CASE_WR_AXI_PTR0(31)
            `CASE_WR_AXI_PTR0(32)
            default : $display("Illegal address");
        endcase
    end

    // int_isr
    if (int_ier & ap_done) begin
        int_isr <= 1'b1;
    end

    if (areset) begin
        ap_start    <= 1'b0;
        int_gie     <= 1'b0;
        int_ier     <= 1'b0;
        int_isr     <= 1'b0;
    end
end

endmodule: krnl_xbtest_control_s_axi
`default_nettype wire
