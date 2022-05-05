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

module dsp_col #(
    parameter integer C_THROTTLE_MODE   = 1, // 1: clock throttling with BUFG, 0: throttle clock enable of sites FF input oscillator
    parameter integer N_DSP             = 4  // N_DSP max = 24
) (
    input wire clk, // throttle if C_THROTTLE_MODE = 1
    input wire reset,
    input wire enable, // SW
    input wire tog_en // throttle if C_THROTTLE_MODE = 0
);
    generate
        if (N_DSP > 0) begin

            (*dont_touch ="true"*) logic ff = 1'b0;
            always_ff @(posedge clk) begin
                if ((C_THROTTLE_MODE == 0) && (tog_en & enable)
                 || (C_THROTTLE_MODE == 1) && (enable)) begin
                    ff <= ~ff;
                end
            end

            for (genvar kk = 0; kk < N_DSP; kk++) begin : genblk_dsp48
                dsp48e2_top u_dsp48e2_top (
                    .clk            ( clk       ),
                    .data_b         ( {18{ff}}  ),
                    .data_a         ( {30{ff}}  ),
                    .data_c         ( {48{ff}}  ),
                    .data_d         ( {27{ff}}  ),
                    .ce             ( enable    )
                );
            end : genblk_dsp48
        end
    endgenerate

endmodule : dsp_col

//-----------------------------------------------------------

module dsp48e2_top (
    input  wire        clk,
    input  wire [29:0] data_a,
    input  wire [17:0] data_b,
    input  wire [47:0] data_c,
    input  wire [26:0] data_d,
    input  wire        ce
 );

    (*dont_touch = "true"*) wire [29:0] wire_ACOUT;
    (*dont_touch = "true"*) wire [17:0] wire_BCOUT;
    (*dont_touch = "true"*) wire        wire_CARRYCASCOUT;
    (*dont_touch = "true"*) wire        wire_MULTSIGNOUT;
    (*dont_touch = "true"*) wire [47:0] wire_PCOUT;
    (*dont_touch = "true"*) wire [47:0] wire_P;
    (*dont_touch = "true"*) wire        wire_OVERFLOW;
    (*dont_touch = "true"*) wire        wire_PATTERNBDETECT;
    (*dont_touch = "true"*) wire        wire_PATTERNDETECT;
    (*dont_touch = "true"*) wire        wire_UNDERFLOW;
    (*dont_touch = "true"*) wire [3:0]  wire_CARRYOUT;
    (*dont_touch = "true"*) wire [7:0]  wire_XOROUT;

    // DSP48E2: 48-bit Multi-Functional Arithmetic Block
    // UltraScale
    // Xilinx HDL Language Template, version 2017.4
    DSP48E2 #(
        // Feature Control Attributes: Data Path Selection
        .AMULTSEL                   ( "AD"               ), // Selects A input to multiplier (A, AD)
        .A_INPUT                    ( "DIRECT"           ), // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
        .BMULTSEL                   ( "B"                ), // Selects B input to multiplier (AD, B)
        .B_INPUT                    ( "DIRECT"           ), // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
        .PREADDINSEL                ( "A"                ), // Selects input to pre-adder (A, B)
        .RND                        ( 48'h000000000000   ), // Rounding Constant
        .USE_MULT                   ( "MULTIPLY"         ), // Select multiplier usage (DYNAMIC, MULTIPLY, NONE)
        .USE_SIMD                   ( "ONE48"            ), // SIMD selection (FOUR12, ONE48, TWO24)
        .USE_WIDEXOR                ( "FALSE"            ), // Use the Wide XOR function (FALSE, TRUE)
        .XORSIMD                    ( "XOR24_48_96"      ), // Mode of operation for the Wide XOR (XOR12, XOR24_48_96)
        // Pattern Detector Attributes: Pattern Detection Configuration
        .AUTORESET_PATDET           ( "NO_RESET"         ), // NO_RESET, RESET_MATCH, RESET_NOT_MATCH
        .AUTORESET_PRIORITY         ( "RESET"            ), // Priority of AUTORESET vs. CEP (CEP, RESET).
        .MASK                       ( 48'h3fffffffffff   ), // 48-bit mask value for pattern detect (1=ignore)
        .PATTERN                    ( 48'h000000000000   ), // 48-bit pattern match for pattern detect
        .SEL_MASK                   ( "MASK"             ), // C, MASK, ROUNDING_MODE1, ROUNDING_MODE2
        .SEL_PATTERN                ( "PATTERN"          ), // Select pattern value (C, PATTERN)
        .USE_PATTERN_DETECT         ( "NO_PATDET"        ), // Enable pattern detect (NO_PATDET, PATDET)
        // Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
        .IS_ALUMODE_INVERTED        ( 4'b0000            ), // Optional inversion for ALUMODE
        .IS_CARRYIN_INVERTED        ( 1'b0               ), // Optional inversion for CARRYIN
        .IS_CLK_INVERTED            ( 1'b0               ), // Optional inversion for CLK
        .IS_INMODE_INVERTED         ( 5'b00000           ), // Optional inversion for INMODE
        .IS_OPMODE_INVERTED         ( 9'b000000000       ), // Optional inversion for OPMODE
        .IS_RSTALLCARRYIN_INVERTED  ( 1'b0               ), // Optional inversion for RSTALLCARRYIN
        .IS_RSTALUMODE_INVERTED     ( 1'b0               ), // Optional inversion for RSTALUMODE
        .IS_RSTA_INVERTED           ( 1'b0               ), // Optional inversion for RSTA
        .IS_RSTB_INVERTED           ( 1'b0               ), // Optional inversion for RSTB
        .IS_RSTCTRL_INVERTED        ( 1'b0               ), // Optional inversion for RSTCTRL
        .IS_RSTC_INVERTED           ( 1'b0               ), // Optional inversion for RSTC
        .IS_RSTD_INVERTED           ( 1'b0               ), // Optional inversion for RSTD
        .IS_RSTINMODE_INVERTED      ( 1'b0               ), // Optional inversion for RSTINMODE
        .IS_RSTM_INVERTED           ( 1'b0               ), // Optional inversion for RSTM
        .IS_RSTP_INVERTED           ( 1'b0               ), // Optional inversion for RSTP
        // Register Control Attributes: Pipeline Register Configuration
        .ACASCREG                   ( 2                  ), // Number of pipeline stages between A/ACIN and ACOUT (0-2)
        .ADREG                      ( 1                  ), // Pipeline stages for pre-adder (0-1)
        .ALUMODEREG                 ( 1                  ), // Pipeline stages for ALUMODE (0-1)
        .AREG                       ( 2                  ), // Pipeline stages for A (0-2)
        .BCASCREG                   ( 2                  ), // Number of pipeline stages between B/BCIN and BCOUT (0-2)
        .BREG                       ( 2                  ), // Pipeline stages for B (0-2)
        .CARRYINREG                 ( 1                  ), // Pipeline stages for CARRYIN (0-1)
        .CARRYINSELREG              ( 1                  ), // Pipeline stages for CARRYINSEL (0-1)
        .CREG                       ( 1                  ), // Pipeline stages for C (0-1)
        .DREG                       ( 1                  ), // Pipeline stages for D (0-1)
        .INMODEREG                  ( 1                  ), // Pipeline stages for INMODE (0-1)
        .MREG                       ( 1                  ), // Multiplier pipeline stages (0-1)
        .OPMODEREG                  ( 1                  ), // Pipeline stages for OPMODE (0-1)
        .PREG                       ( 1                  )  // Number of pipeline stages for P (0-1)
    ) DSP48E2_inst (
        // Cascade outputs: Cascade Ports
        .ACOUT          ( wire_ACOUT          ), // 30-bit output: A port cascade
        .BCOUT          ( wire_BCOUT          ), // 18-bit output: B cascade
        .CARRYCASCOUT   ( wire_CARRYCASCOUT   ), // 1-bit output: Cascade carry
        .MULTSIGNOUT    ( wire_MULTSIGNOUT    ), // 1-bit output: Multiplier sign cascade
        .PCOUT          ( wire_PCOUT          ), // 48-bit output: Cascade output
        // Control outputs: Control Inputs/Status Bits
        .OVERFLOW       ( wire_OVERFLOW       ), // 1-bit output: Overflow in add/acc
        .PATTERNBDETECT ( wire_PATTERNBDETECT ), // 1-bit output: Pattern bar detect
        .PATTERNDETECT  ( wire_PATTERNDETECT  ), // 1-bit output: Pattern detect
        .UNDERFLOW      ( wire_UNDERFLOW      ), // 1-bit output: Underflow in add/acc
        // Data outputs: Data Ports
        .CARRYOUT       ( wire_CARRYOUT       ), // 4-bit output: Carry
        .XOROUT         ( wire_XOROUT         ), // 8-bit output: XOR data
        .P              ( wire_P              ), // 48-bit output: Primary data
        // Cascade inputs: Cascade Ports
        .ACIN           ( 30'h0               ), // 30-bit input: A cascade data
        .BCIN           ( 18'h0               ), // 18-bit input: B cascade
        .CARRYCASCIN    ( 1'b0                ), // 1-bit input: Cascade carry
        .MULTSIGNIN     ( 1'b0                ), // 1-bit input: Multiplier sign cascade
        .PCIN           ( 48'h0               ), // 48-bit input: P cascade
        // Control inputs: Control Inputs/Status Bits
        .CLK            ( clk                 ), // 1-bit input: Clock
        .INMODE         ( 5'b00100            ), // 5-bit input: INMODE control  W=C, Z=C, Y = M, X = M = (A+D)*B
        .OPMODE         ( 9'b11_011_01_01     ), // 9-bit input: Operation mode  Z + W + X + Y + CIN
        .ALUMODE        ( 4'b0010             ), // 4-bit input: ALU control not (Z +W + X + Y + CIN) = -Z  -W - X - Y  - CIN - 1
        .CARRYINSEL     ( 3'b000              ), // 3-bit input: Carry select
        // Data inputs: Data Ports
        .A              ( data_a              ), // 30-bit input: A data
        .B              ( data_b              ), // 18-bit input: B data
        .C              ( data_c              ), // 48-bit input: C data
        .D              ( data_d              ), // 27-bit input: D data
        .CARRYIN        ( 1'b0                ), // 1-bit input: Carry-in
        // Reset/Clock Enable inputs: Reset/Clock Enable Inputs
        .CEA1           ( ce                  ), // 1-bit input: Clock enable for 1st stage AREG
        .CEA2           ( ce                  ), // 1-bit input: Clock enable for 2nd stage AREG
        .CEAD           ( ce                  ), // 1-bit input: Clock enable for ADREG
        .CEALUMODE      ( ce                  ), // 1-bit input: Clock enable for ALUMODE
        .CEB1           ( ce                  ), // 1-bit input: Clock enable for 1st stage BREG
        .CEB2           ( ce                  ), // 1-bit input: Clock enable for 2nd stage BREG
        .CEC            ( ce                  ), // 1-bit input: Clock enable for CREG
        .CECARRYIN      ( ce                  ), // 1-bit input: Clock enable for CARRYINREG
        .CECTRL         ( ce                  ), // 1-bit input: Clock enable for OPMODEREG and CARRYINSELREG
        .CED            ( ce                  ), // 1-bit input: Clock enable for DREG
        .CEINMODE       ( ce                  ), // 1-bit input: Clock enable for INMODEREG
        .CEM            ( ce                  ), // 1-bit input: Clock enable for MREG
        .CEP            ( ce                  ), // 1-bit input: Clock enable for PREG
        .RSTA           ( 1'b0                ), // 1-bit input: Reset for AREG
        .RSTALLCARRYIN  ( 1'b0                ), // 1-bit input: Reset for CARRYINREG
        .RSTALUMODE     ( 1'b0                ), // 1-bit input: Reset for ALUMODEREG
        .RSTB           ( 1'b0                ), // 1-bit input: Reset for BREG
        .RSTC           ( 1'b0                ), // 1-bit input: Reset for CREG
        .RSTCTRL        ( 1'b0                ), // 1-bit input: Reset for OPMODEREG and CARRYINSELREG
        .RSTD           ( 1'b0                ), // 1-bit input: Reset for DREG and ADREG
        .RSTINMODE      ( 1'b0                ), // 1-bit input: Reset for INMODEREG
        .RSTM           ( 1'b0                ), // 1-bit input: Reset for MREG
        .RSTP           ( 1'b0                )  // 1-bit input: Reset for PREG
    );

endmodule : dsp48e2_top
`default_nettype wire
