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

module bram_col #(
    parameter integer C_THROTTLE_MODE       = 1, // 1: clock throttling with BUFG, 0: throttle clock enable of sites FF input oscillator
    parameter integer N_BRAM                = 0, // N_BRAM max = 12
    parameter integer DISABLE_SIM_ASSERT    = 0
) (
    input wire clk,    // throttle if C_THROTTLE_MODE = 1
    input wire reset,
    input wire enable, // SW
    input wire tog_en  // throttle if C_THROTTLE_MODE = 0
);
    // Generate a column of oscillators need more than N_BRAM
    localparam integer N_SLICE_COL = 2; // = max slice used within teh column
    localparam integer N_FF_SLICE  = 16; // = Number of bits per SLICE

    generate
        if (N_BRAM > 0) begin

            (*dont_touch ="true"*) logic sleep = 1'b1;
            // pipeline enable for replication
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

            for (genvar kk = 0; kk < N_BRAM; kk++) begin : genblk_ramb36e2
                ramb36e2_top #(
                    .DISABLE_SIM_ASSERT ( DISABLE_SIM_ASSERT )
                ) u_ramb36e2_top (
                    .clk     ( clk      ),
                    .rdaddr  ( {15{ff}} ),
                    .wraddr  ( {15{ff}} ),
                    .din     ( {64{ff}} ),
                    .dinp    ( { 8{ff}} ),
                    .sleep   ( sleep    )
                );
            end : genblk_ramb36e2
        end
    endgenerate
endmodule : bram_col

//-----------------------------------------------------------

module ramb36e2_top #(
    parameter integer DISABLE_SIM_ASSERT = 0
) (
    input  wire         clk,
    input  wire [14:0]  rdaddr,
    input  wire [14:0]  wraddr,
    input  wire [63:0]  din,
    input  wire [7:0]   dinp,
    input  wire         sleep
 );

    (*dont_touch = "true"*) wire [63:0] wire_DOUT;
    (*dont_touch = "true"*) wire [7:0]  wire_DOUTP;
    (*dont_touch = "true"*) wire [31:0] wire_CASDOUTB;
    (*dont_touch = "true"*) wire [3:0]  wire_CASDOUTPB;
    (*dont_touch = "true"*) wire [31:0] wire_CASDOUTA;
    (*dont_touch = "true"*) wire [3:0]  wire_CASDOUTPA;
    (*dont_touch = "true"*) wire        wire_CASOUTDBITERR;
    (*dont_touch = "true"*) wire        wire_CASOUTSBITERR;
    (*dont_touch = "true"*) wire        wire_DBITERR;
    (*dont_touch = "true"*) wire [7:0]  wire_ECCPARITY;
    (*dont_touch = "true"*) wire [8:0]  wire_RDADDRECC;
    (*dont_touch = "true"*) wire        wire_SBITERR;

    // Use this to suppress warning in simulation, don't care in RTL
    wire  dummy;
    generate
        if (DISABLE_SIM_ASSERT == 1) begin
            wire  dummy_comb = (~sleep);
            logic dummy_seq = 1'b0;
            logic dummy_seq_d = 1'b0;
            always_ff @(posedge clk) begin
                dummy_seq   <= dummy_comb;
                dummy_seq_d <= dummy_seq;
            end
            assign  dummy = dummy_comb & dummy_seq & dummy_seq_d; // Apply for some cycles
        end else begin
            assign  dummy = 1'b1;
        end
    endgenerate

    // RAMB36E2: 36K-bit Configurable Synchronous Block RAM
    //           Virtex UltraScale+
    //           SDP 72
    // Xilinx HDL Language Template, version 2018.2

    RAMB36E2 #(
        .CASCADE_ORDER_A            ("NONE"     ), // "FIRST", "MIDDLE", "LAST", "NONE"
        .CASCADE_ORDER_B            ("NONE"     ), // "FIRST", "MIDDLE", "LAST", "NONE"
        .CLOCK_DOMAINS              ("COMMON"   ), // "COMMON", "INDEPENDENT"
        .DOB_REG                    (1          ), // Optional output register (0, 1)
        .SIM_COLLISION_CHECK        ("NONE"     ), // Collision check: "ALL", "GENERATE_X_ONLY", "NONE", "WARNING_ONLY"
        .DOA_REG                    (1          ), // Optional output register (0, 1)
        .ENADDRENA                  ("FALSE"    ), // Address enable pin enable, "TRUE", "FALSE"
        .ENADDRENB                  ("FALSE"    ), // Address enable pin enable, "TRUE", "FALSE"
        .EN_ECC_PIPE                ("FALSE"    ), // ECC pipeline register, "TRUE"/"FALSE"
        .EN_ECC_READ                ("FALSE"    ), // Enable ECC decoder, "TRUE"/"FALSE"
        .EN_ECC_WRITE               ("FALSE"    ), // Enable ECC encoder, "TRUE"/"FALSE"
        .IS_CLKARDCLK_INVERTED      (1'b0       ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
        .IS_CLKBWRCLK_INVERTED      (1'b1       ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
        .IS_ENARDEN_INVERTED        (1'b0       ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
        .IS_ENBWREN_INVERTED        (1'b0       ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
        .IS_RSTRAMARSTRAM_INVERTED  (1'b0       ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
        .IS_RSTRAMB_INVERTED        (1'b0       ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
        .IS_RSTREGARSTREG_INVERTED  (1'b0       ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
        .IS_RSTREGB_INVERTED        (1'b0       ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
        .RDADDRCHANGEA              ("FALSE"    ), // Disable memory access when output value does not change ("TRUE", "FALSE")
        .RDADDRCHANGEB              ("FALSE"    ), // Disable memory access when output value does not change ("TRUE", "FALSE")
        .READ_WIDTH_A               (72         ), // Read width per port
        .WRITE_WIDTH_B              (72         ), // write width per port
        .RSTREG_PRIORITY_A          ("RSTREG"   ), // Reset or enable priority ("RSTREG", "REGCE")
        .RSTREG_PRIORITY_B          ("RSTREG"   ), // Reset or enable priority ("RSTREG", "REGCE")
        .SLEEP_ASYNC                ("FALSE"    ), // Sleep Async: Sleep function asynchronous or synchronous ("TRUE", "FALSE")
        .WRITE_MODE_A               ("NO_CHANGE"), // WriteMode: "WRITE_FIRST", "NO_CHANGE", "READ_FIRST"
        .WRITE_MODE_B               ("NO_CHANGE")  // WriteMode: "WRITE_FIRST", "NO_CHANGE", "READ_FIRST"
    ) RAMB36E2_inst (
        .CASDOUTB           (wire_CASDOUTB      ), // 32-bit output: Port B cascade output data
        .CASDOUTPB          (wire_CASDOUTPB     ), // 4-bit  output: Port B cascade output parity data
        .CASDOUTA           (wire_CASDOUTA      ), // 32-bit output: Port A cascade output data
        .CASDOUTPA          (wire_CASDOUTPA     ), // 4-bit  output: Port A cascade output parity data
        .CASOUTDBITERR      (wire_CASOUTDBITERR ), // 1-bit  output: DBITERR cascade output
        .CASOUTSBITERR      (wire_CASOUTSBITERR ), // 1-bit  output: SBITERR cascade output
        .DBITERR            (wire_DBITERR       ), // 1-bit  output: Double bit error status
        .ECCPARITY          (wire_ECCPARITY     ), // 8-bit  output: Generated error correction parity
        .RDADDRECC          (wire_RDADDRECC     ), // 9-bit  output: ECC Read Address
        .SBITERR            (wire_SBITERR       ), // 1-bit  output: Single bit error status
        .DOUTADOUT          (wire_DOUT[31:0]    ), // 32-bit output: Port A ata/LSB data
        .DOUTPADOUTP        (wire_DOUTP[3:0]    ), // 4-bit  output: Port A parity/LSB parity
        .DOUTBDOUT          (wire_DOUT[63:32]   ), // 32-bit output: Port B data/MSB data
        .DOUTPBDOUTP        (wire_DOUTP[7:4]    ), // 4-bit  output: Port B parity/MSB parity
        .CASDIMUXA          (1'b0               ), // 1-bit  input: Port A input data (0=DINA, 1=CASDINA)
        .CASDIMUXB          (1'b0               ), // 1-bit  input: Port B input data (0=DINB, 1=CASDINB)
        .CASDINA            (32'b0              ), // 32-bit input: Port A cascade input data
        .CASDINB            (32'b0              ), // 32-bit input: Port B cascade input data
        .CASDINPA           ({4{1'b0}}          ), // 4-bit  input: Port A cascade input parity data
        .CASDINPB           ({4{1'b0}}          ), // 4-bit  input: Port B cascade input parity data
        .CASDOMUXA          (1'b0               ), // 1-bit  input: Port A unregistered data (0=BRAM data, 1=CASDINA)
        .CASDOMUXB          (1'b0               ), // 1-bit  input: Port B unregistered data (0=BRAM data, 1=CASDINB)
        .CASDOMUXEN_A       (1'b0               ), // 1-bit  input: Port A unregistered output data enable
        .CASDOMUXEN_B       (1'b0               ), // 1-bit  input: Port B unregistered output data enable
        .CASINDBITERR       (1'b0               ), // 1-bit  input: DBITERR cascade input
        .CASINSBITERR       (1'b0               ), // 1-bit  input: SBITERR cascade input
        .CASOREGIMUXA       (1'b0               ), // 1-bit  input: Port A registered data (0=BRAM data, 1=CASDINA)
        .CASOREGIMUXB       (1'b0               ), // 1-bit  input: Port B registered data (0=BRAM data, 1=CASDINB)
        .CASOREGIMUXEN_A    (dummy              ), // 1-bit  input: Port A registered output data enable
        .CASOREGIMUXEN_B    (dummy              ), // 1-bit  input: Port B registered output data enable
        .ECCPIPECE          (dummy              ), // 1-bit  input: ECC Pipeline Register Enable
        .INJECTDBITERR      (1'b0               ), // 1-bit  input: Inject a double bit error
        .INJECTSBITERR      (1'b0               ), // 1-bit  input: Inject a single bit error
        .SLEEP              (sleep              ), // 1-bit  input: Sleep Mode
        .ADDRENA            (dummy              ), // 1-bit  input: Active-High A/Read port address enable
        .ADDRENB            (dummy              ), // 1-bit  input: Active-High B/Write port address enable
        .REGCEB             (dummy              ), // 1-bit  input: Port B register enable
        .REGCEAREGCE        (dummy              ), // 1-bit  input: Port A register enable/Register enable
        .CLKARDCLK          (clk                ), // 1-bit  input: A/Read port clock
        .CLKBWRCLK          (clk                ), // 1-bit  input: B/Write port clock
        .RSTRAMARSTRAM      (1'b0               ), // 1-bit  input: Port A set/reset
        .RSTRAMB            (1'b0               ), // 1-bit  input: Port B set/reset
        .RSTREGARSTREG      (1'b0               ), // 1-bit  input: Port A register set/reset
        .RSTREGB            (1'b0               ), // 1-bit  input: Port B register set/reset
        .ENBWREN            (dummy              ), // 1-bit  input: Port B enable/Write enable
        .ENARDEN            (dummy              ), // 1-bit  input: Port A enable/Read enable
        .WEA                ({4{dummy}}         ), // 4-bit input: Port A byte-wide write enable. When used as SDP memory, this port is not used.
        .WEBWE              ({8{dummy}}         ), // 8-bit  input: Port B write enable/Write enable. In SDP mode, this is the byte-wide write enable.
        .ADDRARDADDR        (rdaddr             ), // 9-bit input: A/Read port address
        .ADDRBWRADDR        (wraddr             ), // 9-bit input: B/Write port address
        .DINADIN            (din[31:0]          ), // 64-bit input: Port B data/MSB data
        .DINPADINP          (dinp[3:0]          ), // 8-bit  input: Port B parity/MSB parity
        .DINBDIN            (din[63:32]         ), // 64-bit input: Port B data/MSB data
        .DINPBDINP          (dinp[7:4]          )  // 8-bit  input: Port B parity/MSB parity
    );
endmodule : ramb36e2_top
`default_nettype wire
