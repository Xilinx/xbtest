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

module uram_col #(
    parameter integer C_THROTTLE_MODE       = 1, // 1: clock throttling with BUFG, 0: throttle clock enable of sites FF input oscillator
    parameter integer N_URAM                = 0, // N_URAM max = 16
    parameter integer DISABLE_SIM_ASSERT    = 0
) (
    input wire clk, // throttle if C_THROTTLE_MODE = 1
    input wire reset,
    input wire enable, // SW
    input wire tog_en // throttle if C_THROTTLE_MODE = 0
);

    // Generate a column of oscillators need more than N_RAM
    localparam integer N_SLICE_COL = 2; // = max slice used within teh column
    localparam integer N_FF_SLICE  = 16; // = Number of bits per SLICE

    generate
        if (N_URAM > 0) begin
            (*dont_touch ="true"*) logic sleep = 1'b1;
            always_ff @(posedge clk) begin
                if (reset) begin
                    sleep <= 1'b1;
                end else begin
                    sleep <= ~enable;
                end
            end

            (*dont_touch ="true"*) logic ff = 1'b0;
            always_ff @(posedge clk) begin
                if ((C_THROTTLE_MODE == 0) && (tog_en & enable)
                 || (C_THROTTLE_MODE == 1) && (enable)) begin
                    ff <= ~ff;
                end
            end

            for (genvar kk = 0; kk < N_URAM; kk++) begin : genblk_uram288
                uram288_top #(
                    .DISABLE_SIM_ASSERT ( DISABLE_SIM_ASSERT )
                ) u_uram288_top (
                    .clk      ( clk         ),
                    .addr_a   ( {23{ff}}    ),
                    .addr_b   ( {23{ff}}    ),
                    .din_a    ( {72{ff}}    ),
                    .sleep    ( sleep       )
                );
            end : genblk_uram288
        end
    endgenerate

endmodule : uram_col

//-----------------------------------------------------------

module uram288_top  #(
    parameter integer DISABLE_SIM_ASSERT = 0
) (
    input  wire         clk,
    input  wire [22:0]  addr_a,
    input  wire [22:0]  addr_b,
    input  wire [71:0]  din_a,
    input  wire         sleep
 );

    (*dont_touch = "true"*) wire [22:0] wire_CAS_OUT_ADDR_A;
    (*dont_touch = "true"*) wire [22:0] wire_CAS_OUT_ADDR_B;
    (*dont_touch = "true"*) wire [8:0]  wire_CAS_OUT_BWE_A;
    (*dont_touch = "true"*) wire [8:0]  wire_CAS_OUT_BWE_B;
    (*dont_touch = "true"*) wire        wire_CAS_OUT_DBITERR_A;
    (*dont_touch = "true"*) wire        wire_CAS_OUT_DBITERR_B;
    (*dont_touch = "true"*) wire [71:0] wire_CAS_OUT_DIN_A;
    (*dont_touch = "true"*) wire [71:0] wire_CAS_OUT_DIN_B;
    (*dont_touch = "true"*) wire [71:0] wire_CAS_OUT_DOUT_A;
    (*dont_touch = "true"*) wire [71:0] wire_CAS_OUT_DOUT_B;
    (*dont_touch = "true"*) wire        wire_CAS_OUT_EN_A;
    (*dont_touch = "true"*) wire        wire_CAS_OUT_EN_B;
    (*dont_touch = "true"*) wire        wire_CAS_OUT_RDACCESS_A;
    (*dont_touch = "true"*) wire        wire_CAS_OUT_RDACCESS_B;
    (*dont_touch = "true"*) wire        wire_CAS_OUT_RDB_WR_A;
    (*dont_touch = "true"*) wire        wire_CAS_OUT_RDB_WR_B;
    (*dont_touch = "true"*) wire        wire_CAS_OUT_SBITERR_A;
    (*dont_touch = "true"*) wire        wire_CAS_OUT_SBITERR_B;
    (*dont_touch = "true"*) wire        wire_DBITERR_A;
    (*dont_touch = "true"*) wire        wire_DBITERR_B;
    (*dont_touch = "true"*) wire [71:0] wire_DOUT_A;
    (*dont_touch = "true"*) wire [71:0] wire_DOUT_B;
    (*dont_touch = "true"*) wire        wire_RDACCESS_A;
    (*dont_touch = "true"*) wire        wire_RDACCESS_B;
    (*dont_touch = "true"*) wire        wire_SBITERR_A;
    (*dont_touch = "true"*) wire        wire_SBITERR_B;

    // Use this to suppress warning in simulation, don't care in RTL
    wire  dummy;

    generate
        if (DISABLE_SIM_ASSERT == 1) begin
            wire  dummy_comb = (~sleep);
            logic dummy_seq, dummy_seq_d;
            always_ff @(posedge clk) begin
                dummy_seq <= dummy_comb;
                dummy_seq_d <= dummy_seq;
            end
            assign  dummy =  dummy_comb & dummy_seq & dummy_seq_d; // Apply for some cycles
        end else begin
            assign  dummy =  1'b1;
        end
    endgenerate

    // URAM288: 288K-bit High-Density Memory Building Block
    //          Virtex UltraScale+
    // Xilinx HDL Language Template, version 2018.2

    URAM288 #(
        .AUTO_SLEEP_LATENCY       ( 8                      ), // Latency requirement to enter sleep mode
        .AVG_CONS_INACTIVE_CYCLES ( 10                     ), // Average consecutive inactive cycles when is SLEEP mode for power estimation
        .BWE_MODE_A               ( "PARITY_INDEPENDENT"   ), // Port A Byte write control
        .BWE_MODE_B               ( "PARITY_INDEPENDENT"   ), // Port B Byte write control
        .CASCADE_ORDER_A          ( "NONE"                 ), // Port A position in cascade chain
        .CASCADE_ORDER_B          ( "NONE"                 ), // Port B position in cascade chain
        .EN_AUTO_SLEEP_MODE       ( "FALSE"                ), // Enable to automatically enter sleep mode
        .EN_ECC_RD_A              ( "FALSE"                ), // Port A ECC encoder
        .EN_ECC_RD_B              ( "FALSE"                ), // Port B ECC encoder
        .EN_ECC_WR_A              ( "FALSE"                ), // Port A ECC decoder
        .EN_ECC_WR_B              ( "FALSE"                ), // Port B ECC decoder
        .IREG_PRE_A               ( "FALSE"                ), // Optional Port A input pipeline registers
        .IREG_PRE_B               ( "FALSE"                ), // Optional Port B input pipeline registers
        .IS_CLK_INVERTED          ( 1'b0                   ), // Optional inverter for clk
        .IS_EN_A_INVERTED         ( 1'b0                   ), // Optional inverter for Port A enable
        .IS_EN_B_INVERTED         ( 1'b0                   ), // Optional inverter for Port B enable
        .IS_RDB_WR_A_INVERTED     ( 1'b0                   ), // Optional inverter for Port A read/write select
        .IS_RDB_WR_B_INVERTED     ( 1'b0                   ), // Optional inverter for Port B read/write select
        .IS_RST_A_INVERTED        ( 1'b0                   ), // Optional inverter for Port A reset
        .IS_RST_B_INVERTED        ( 1'b0                   ), // Optional inverter for Port B reset
        .OREG_A                   ( "FALSE"                ), // Optional Port A output pipeline registers
        .OREG_B                   ( "FALSE"                ), // Optional Port B output pipeline registers
        .OREG_ECC_A               ( "FALSE"                ), // Port A ECC decoder output
        .OREG_ECC_B               ( "FALSE"                ), // Port B output ECC decoder
        .REG_CAS_A                ( "FALSE"                ), // Optional Port A cascade register
        .REG_CAS_B                ( "FALSE"                ), // Optional Port B cascade register
        .RST_MODE_A               ( "SYNC"                 ), // Port A reset mode
        .RST_MODE_B               ( "SYNC"                 ), // Port B reset mode
        .SELF_ADDR_A              ( 11'h000                ), // Port A self-address value
        .SELF_ADDR_B              ( 11'h000                ), // Port B self-address value
        .SELF_MASK_A              ( 11'h7ff                ), // Port A self-address mask
        .SELF_MASK_B              ( 11'h7ff                ), // Port B self-address mask
        .USE_EXT_CE_A             ( "FALSE"                ), // Enable Port A external CE inputs for output registers
        .USE_EXT_CE_B             ( "FALSE"                )  // Enable Port B external CE inputs for output registers
    ) URAM288_inst (
        .CAS_OUT_ADDR_A       ( wire_CAS_OUT_ADDR_A    ), // 23-bit output: Port A cascade output address
        .CAS_OUT_ADDR_B       ( wire_CAS_OUT_ADDR_B    ), // 23-bit output: Port B cascade output address
        .CAS_OUT_BWE_A        ( wire_CAS_OUT_BWE_A     ), // 9-bit  output: Port A cascade Byte-write enable output
        .CAS_OUT_BWE_B        ( wire_CAS_OUT_BWE_B     ), // 9-bit  output: Port B cascade Byte-write enable output
        .CAS_OUT_DBITERR_A    ( wire_CAS_OUT_DBITERR_A ), // 1-bit  output: Port A cascade double-bit error flag output
        .CAS_OUT_DBITERR_B    ( wire_CAS_OUT_DBITERR_B ), // 1-bit  output: Port B cascade double-bit error flag output
        .CAS_OUT_DIN_A        ( wire_CAS_OUT_DIN_A     ), // 72-bit output: Port A cascade output write mode data
        .CAS_OUT_DIN_B        ( wire_CAS_OUT_DIN_B     ), // 72-bit output: Port B cascade output write mode data
        .CAS_OUT_DOUT_A       ( wire_CAS_OUT_DOUT_A    ), // 72-bit output: Port A cascade output read mode data
        .CAS_OUT_DOUT_B       ( wire_CAS_OUT_DOUT_B    ), // 72-bit output: Port B cascade output read mode data
        .CAS_OUT_EN_A         ( wire_CAS_OUT_EN_A      ), // 1-bit  output: Port A cascade output enable
        .CAS_OUT_EN_B         ( wire_CAS_OUT_EN_B      ), // 1-bit  output: Port B cascade output enable
        .CAS_OUT_RDACCESS_A   ( wire_CAS_OUT_RDACCESS_A), // 1-bit  output: Port A cascade read status output
        .CAS_OUT_RDACCESS_B   ( wire_CAS_OUT_RDACCESS_B), // 1-bit  output: Port B cascade read status output
        .CAS_OUT_RDB_WR_A     ( wire_CAS_OUT_RDB_WR_A  ), // 1-bit  output: Port A cascade read/write select output
        .CAS_OUT_RDB_WR_B     ( wire_CAS_OUT_RDB_WR_B  ), // 1-bit  output: Port B cascade read/write select output
        .CAS_OUT_SBITERR_A    ( wire_CAS_OUT_SBITERR_A ), // 1-bit  output: Port A cascade single-bit error flag output
        .CAS_OUT_SBITERR_B    ( wire_CAS_OUT_SBITERR_B ), // 1-bit  output: Port B cascade single-bit error flag output
        .DBITERR_A            ( wire_DBITERR_A         ), // 1-bit  output: Port A double-bit error flag status
        .DBITERR_B            ( wire_DBITERR_B         ), // 1-bit  output: Port B double-bit error flag status
        .DOUT_A               ( wire_DOUT_A            ), // 72-bit output: Port A read data output
        .DOUT_B               ( wire_DOUT_B            ), // 72-bit output: Port B read data output
        .RDACCESS_A           ( wire_RDACCESS_A        ), // 1-bit  output: Port A read status
        .RDACCESS_B           ( wire_RDACCESS_B        ), // 1-bit  output: Port B read status
        .SBITERR_A            ( wire_SBITERR_A         ), // 1-bit  output: Port A single-bit error flag status
        .SBITERR_B            ( wire_SBITERR_B         ), // 1-bit  output: Port B single-bit error flag status
        .ADDR_A               ( addr_a                 ), // 23-bit input: Port A address
        .ADDR_B               ( addr_b                 ), // 23-bit input: Port B address
        .BWE_A                ( {9{dummy}}             ), // 9-bit  input: Port A Byte-write enable
        .BWE_B                ( {9{1'b0}}              ), // 9-bit  input: Port B Byte-write enable
        .CAS_IN_ADDR_A        ( {72{1'b0}}             ), // 23-bit input: Port A cascade input address
        .CAS_IN_ADDR_B        ( {72{1'b0}}             ), // 23-bit input: Port B cascade input address
        .CAS_IN_BWE_A         ( {9{1'b0}}              ), // 9-bit  input: Port A cascade Byte-write enable input
        .CAS_IN_BWE_B         ( {9{1'b0}}              ), // 9-bit  input: Port B cascade Byte-write enable input
        .CAS_IN_DBITERR_A     ( 1'b0                   ), // 1-bit  input: Port A cascade double-bit error flag input
        .CAS_IN_DBITERR_B     ( 1'b0                   ), // 1-bit  input: Port B cascade double-bit error flag input
        .CAS_IN_DIN_A         ( {72{1'b0}}             ), // 72-bit input: Port A cascade input write mode data
        .CAS_IN_DIN_B         ( {72{1'b0}}             ), // 72-bit input: Port B cascade input write mode data
        .CAS_IN_DOUT_A        ( {72{1'b0}}             ), // 72-bit input: Port A cascade input read mode data
        .CAS_IN_DOUT_B        ( {72{1'b0}}             ), // 72-bit input: Port B cascade input read mode data
        .CAS_IN_EN_A          ( 1'b0                   ), // 1-bit  input: Port A cascade enable input
        .CAS_IN_EN_B          ( 1'b0                   ), // 1-bit  input: Port B cascade enable input
        .CAS_IN_RDACCESS_A    ( 1'b0                   ), // 1-bit  input: Port A cascade read status input
        .CAS_IN_RDACCESS_B    ( 1'b0                   ), // 1-bit  input: Port B cascade read status input
        .CAS_IN_RDB_WR_A      ( 1'b0                   ), // 1-bit  input: Port A cascade read/write select input
        .CAS_IN_RDB_WR_B      ( 1'b0                   ), // 1-bit  input: Port B cascade read/write select input
        .CAS_IN_SBITERR_A     ( 1'b0                   ), // 1-bit  input: Port A cascade single-bit error flag input
        .CAS_IN_SBITERR_B     ( 1'b0                   ), // 1-bit  input: Port B cascade single-bit error flag input
        .CLK                  ( clk                    ), // 1-bit  input: Clock source
        .DIN_A                ( din_a                  ), // 72-bit input: Port A write data input
        .DIN_B                ( {72{1'b0}}             ), // 72-bit input: Port B write data input
        .EN_A                 ( dummy                  ), // 1-bit  input: Port A enable
        .EN_B                 ( dummy                  ), // 1-bit  input: Port B enable
        .INJECT_DBITERR_A     ( 1'b0                   ), // 1-bit  input: Port A double-bit error injection
        .INJECT_DBITERR_B     ( 1'b0                   ), // 1-bit  input: Port B double-bit error injection
        .INJECT_SBITERR_A     ( 1'b0                   ), // 1-bit  input: Port A single-bit error injection
        .INJECT_SBITERR_B     ( 1'b0                   ), // 1-bit  input: Port B single-bit error injection
        .OREG_CE_A            ( dummy                  ), // 1-bit  input: Port A output register clock enable
        .OREG_CE_B            ( dummy                  ), // 1-bit  input: Port B output register clock enable
        .OREG_ECC_CE_A        ( dummy                  ), // 1-bit  input: Port A ECC decoder output register clock enable
        .OREG_ECC_CE_B        ( dummy                  ), // 1-bit  input: Port B ECC decoder output register clock enable
        .RDB_WR_A             ( dummy                  ), // 1-bit  input: Port A read/write select
        .RDB_WR_B             ( 1'b0                   ), // 1-bit  input: Port B read/write select
        .RST_A                ( 1'b0                   ), // 1-bit  input: Port A asynchronous or synchronous reset for  output registers
        .RST_B                ( 1'b0                   ), // 1-bit  input: Port B asynchronous or synchronous reset for output registers
        .SLEEP                ( sleep                  )  // 1-bit  input: Dynamic power gating control
    );

endmodule : uram288_top
`default_nettype wire
