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

module PRBS31_Gen_Term #(
    parameter integer C_USE_AXI_ID          = 0,    // 1 use axi id, 0 disable
    parameter integer C_ID_WIDTH            = 1,
    parameter integer C_DATA_WIDTH          = 512,  // 512, 256, 128
    parameter integer C_STAT_ERR_CNT_SIZE   = 8    // Max 32
)(
    input  wire                             clk,
    input  wire                             rst,

    input  wire  [C_ID_WIDTH-1:0]           Gen_ID_In,
    input  wire                             Gen_Valid_In,
    input  wire                             Gen_Last_In,
    output logic                            Gen_Ready_Out = '0,

    input  wire                             m_axi_wready,
    output wire [C_ID_WIDTH-1:0]            axi_wid,
    output wire                             m_axi_wvalid,
    output wire [C_DATA_WIDTH-1:0]          m_axi_wdata,
    output wire                             m_axi_wlast,

    input  wire  [C_DATA_WIDTH-1:0]         Term_Data_In,
    input  wire  [C_ID_WIDTH-1:0]           Term_ID_In,
    input  wire                             Term_Valid_In,

    input  wire                             ctrl_clear_err_pulse,
    input  wire                             suppress_error,

    output logic                            stat_gen_seed_err_latch = '0,
    output logic                            stat_term_seed_err_latch = '0,
    output logic                            stat_term_err_latch = '0,
    output logic [C_STAT_ERR_CNT_SIZE-1:0]  stat_term_err_cnt = '0
);


localparam integer C_NUM_ID             = 2**(C_ID_WIDTH);
localparam integer C_DATA_WIDTH_BYTES   = C_DATA_WIDTH/8;

////////////////////////////////////////////////////////////
// PRBS types
////////////////////////////////////////////////////////////
localparam logic [30:0] C_RST_PRBS_SEED = 31'hffffffff;
localparam logic [30:0] C_PRBS31_POLY = 31'h48000000;

typedef    logic [30:0] PRBS_Data_Type [C_DATA_WIDTH-1:0];

function PRBS_Data_Type fn_Init_Poly_2_Data ( input integer fn_DATA_WIDTH );
    PRBS_Data_Type  Res;
    logic [30:0]    Poly_var;
    // For each bit in the input CRC, calculate the output CRC bits that it affects
    for (int n = 0; n < 31; n++) begin
        // Initialise the CRC from this bit
        Poly_var    = '0;
        Poly_var[n] =  1'b1;
        // Loop for each data bit
        for (int m = fn_DATA_WIDTH-1; m > -1; m--) begin
            Poly_var   = {Poly_var[29:0], ^(Poly_var & C_PRBS31_POLY)};
            Res[m][n]  = Poly_var[0];
        end
    end
    return Res;
endfunction

localparam PRBS_Data_Type  C_PRBS_CHECK  = fn_Init_Poly_2_Data(C_DATA_WIDTH);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// GENERATION
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef struct {
    logic                       rd_en;
    logic                       valid;
    logic                       last;
    logic [C_ID_WIDTH-1:0]      id;
} Gen_Pipe_Type;

Gen_Pipe_Type C_RST_GEN_PIPE = '{
    rd_en  : '0,
    valid  : '0,
    last   : '0,
    id     : '0
};
localparam integer GEN_PIPE_SIZE = 3;
Gen_Pipe_Type gen_pipe [0:GEN_PIPE_SIZE-1] = '{default:C_RST_GEN_PIPE};

logic [30:0]                        Gen_PRBS_Seed_var;
logic [30:0]                        Gen_PRBS_Seed_out = C_RST_PRBS_SEED;
logic [30:0]                        Gen_PRBS_Seed_RAM [0:C_NUM_ID-1] = '{default:C_RST_PRBS_SEED};

logic [C_DATA_WIDTH-1:0]            Gen_Data_var;
logic [C_DATA_WIDTH-1:0]            Term_Data_var;

localparam integer C_GEN_FIFO_DEPTH = 16;
localparam integer C_GEN_FIFO_PTR_SIZE = $clog2(C_GEN_FIFO_DEPTH)+1;

logic [C_DATA_WIDTH+C_ID_WIDTH+1-1:0]   Gen_FIFO_Data_In_var;
logic [C_DATA_WIDTH+C_ID_WIDTH+1-1:0]   Gen_FIFO [0:C_GEN_FIFO_DEPTH-1] = '{default:0};
logic [C_GEN_FIFO_PTR_SIZE-1:0]         Gen_FIFO_Ptr = '{C_GEN_FIFO_PTR_SIZE{1'b1}};
wire                                    Gen_FIFO_Rd_En;
wire                                    Gen_FIFO_Empty;

// Debug
logic  dbg_Gen_Seed_Err = '0;

////////////////////////////////////////////////////////////
// Generation pipeline
////////////////////////////////////////////////////////////

always_ff @(posedge clk) begin

    // drive the pipeline
    gen_pipe[1:GEN_PIPE_SIZE-1] <= gen_pipe[0:GEN_PIPE_SIZE-2];

    ////////////////////////////////////////////////////////////
    // Stage 0 - if a new channel is read
    ////////////////////////////////////////////////////////////

    gen_pipe[0].rd_en   <= '0;
    gen_pipe[0].valid   <= Gen_Valid_In;
    gen_pipe[0].last    <= Gen_Last_In;

    if (C_USE_AXI_ID == 1) begin

        if (Gen_Valid_In) begin

            gen_pipe[0].id   <= Gen_ID_In;

            if (gen_pipe[0].id != Gen_ID_In) begin

                gen_pipe[0].rd_en <= 1'b1;

            end

        end

    end

    ////////////////////////////////////////////////////////////
    // Stage 1 - seed
    ////////////////////////////////////////////////////////////

    for (int k = 30; k > -1; k--) begin

        Gen_PRBS_Seed_var[k] = ^(C_PRBS_CHECK[k] & Gen_PRBS_Seed_out); // compute next seed

    end

    if (gen_pipe[0].rd_en) begin

        Gen_PRBS_Seed_out <= Gen_PRBS_Seed_RAM[gen_pipe[0].id];

    end else if (gen_pipe[1].valid) begin

        Gen_PRBS_Seed_out <= Gen_PRBS_Seed_var;

    end

    if (gen_pipe[1].valid) begin

        Gen_PRBS_Seed_RAM[gen_pipe[1].id] <= Gen_PRBS_Seed_var;

    end

    //  Gen seed error
    if (ctrl_clear_err_pulse) begin

        stat_gen_seed_err_latch  <= 1'b0;

    end

    dbg_Gen_Seed_Err <= 1'b0;

    if (Gen_PRBS_Seed_out == '0) begin

        dbg_Gen_Seed_Err        <= 1'b1;
        stat_gen_seed_err_latch <= 1'b1;

    end


    ////////////////////////////////////////////////////////////
    // Stage 2 - FIFO write
    ////////////////////////////////////////////////////////////

    Gen_Data_var = '0;

    for (int k = C_DATA_WIDTH-1; k >= 0; k--) begin

        Gen_Data_var[k] = ^(C_PRBS_CHECK[k] & Gen_PRBS_Seed_out); // use current seed to create data

    end

    Gen_FIFO_Data_In_var = {gen_pipe[1].last, gen_pipe[1].id, Gen_Data_var};

    if (gen_pipe[1].valid) begin

        Gen_FIFO <= {Gen_FIFO_Data_In_var, Gen_FIFO[0:C_GEN_FIFO_DEPTH-2]};

        if (~Gen_FIFO_Rd_En) begin

            Gen_FIFO_Ptr    <= Gen_FIFO_Ptr + 1;

        end

    end else if (Gen_FIFO_Rd_En) begin

        Gen_FIFO_Ptr  <= Gen_FIFO_Ptr - 1;

    end

    ////////////////////////////////////////////////////////////
    // Stage 3 - Stop AXI controller when FIFO half full
    ////////////////////////////////////////////////////////////

    Gen_Ready_Out <= 1'b1;

    if (Gen_FIFO_Ptr[$high(Gen_FIFO_Ptr):$high(Gen_FIFO_Ptr)-1] == 2'b01) begin

        Gen_Ready_Out <= 1'b0;

    end

    // Sync reset
    if (rst) begin

        for (int k = 0; k < GEN_PIPE_SIZE; k++) begin

            gen_pipe[k].valid <= 1'b0;
            gen_pipe[k].rd_en <= 1'b0;

        end

        // Reset seeds to generate same data between two runs
        Gen_PRBS_Seed_out       <= C_RST_PRBS_SEED;
        Gen_PRBS_Seed_RAM       <= '{default:C_RST_PRBS_SEED};

        Gen_FIFO_Ptr            <= '{C_GEN_FIFO_PTR_SIZE{1'b1}};
        Gen_Ready_Out           <= 1'b1;

        stat_gen_seed_err_latch <= '0;

    end
end

// Combinatorial output to reduce utilization
assign Gen_FIFO_Empty = Gen_FIFO_Ptr[$high(Gen_FIFO_Ptr)];
assign Gen_FIFO_Rd_En = m_axi_wready & ~Gen_FIFO_Empty;
assign m_axi_wvalid   = Gen_FIFO_Rd_En;
assign {m_axi_wlast, axi_wid, m_axi_wdata} = Gen_FIFO[Gen_FIFO_Ptr[C_GEN_FIFO_PTR_SIZE-2:0]];


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TERMINATION
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam integer C_TERM_WIDTH = 512; // put back everything on 512 as the code designed for that width
localparam integer C_TERM_WIDTH_BYTES   = C_TERM_WIDTH/8;

typedef struct {
    logic                       rd_en;
    logic                       valid;
    logic [C_ID_WIDTH-1:0]      id;
    logic [C_TERM_WIDTH-1:0]    data;
    logic                       suppress_error;
    logic [C_TERM_WIDTH-1:0]    error;
} Term_Pipe_Type;

Term_Pipe_Type C_RST_TERM_PIPE = '{
    rd_en           : '0,
    valid           : '0,
    id              : '0,
    data            : '0,
    suppress_error  : '0,
    error           : '0
};
localparam integer C_TERM_PIPE_SIZE = 7;
Term_Pipe_Type term_pipe [0:C_TERM_PIPE_SIZE-1] = '{default:C_RST_TERM_PIPE};

wire [C_TERM_WIDTH-1:0]     Term_Data_In_ext;

wire                        Term_Valid_1;
wire [C_DATA_WIDTH-1:0]     Term_Data_1;
wire [C_TERM_WIDTH-1:0]     Term_Data_1_ext;
wire [C_ID_WIDTH-1:0]       Term_ID_1;

logic [30:0]                Term_PRBS_Seed_var;
logic [30:0]                Term_PRBS_Seed_out = C_RST_PRBS_SEED;
logic [30:0]                Term_PRBS_Seed_RAM [0:C_NUM_ID-1] = '{default:C_RST_PRBS_SEED};
logic [30:0]                Term_PRBS_Seed = C_RST_PRBS_SEED;
logic [30:0]                Term_PRBS_Seed_d = C_RST_PRBS_SEED;

logic [C_DATA_WIDTH-1:0]    Expected_Data;
wire  [C_TERM_WIDTH-1:0]    Expected_Data_ext;

localparam integer C_DIV_STAGE_1 = 3; // As this is set to 3, suppress_error with reset 33 bits instead of 32 ...
localparam integer C_DIV_STAGE_2 = 6;
localparam integer C_DIV_STAGE_3 = 6;
logic [C_TERM_WIDTH-1:0] Term_Error_3_var, Term_Error_4_var, Term_Error_5_var, Term_Error_6_var;

// Debug
logic        dbg_Term_Err               = '0;
logic        dbg_Term_Seed_Err          = '0;

// Avoid the extra stage for read_en that we do not need in single ID mode
generate
    if (C_USE_AXI_ID == 1) begin

        assign Term_Data_1  = term_pipe[1].data[C_TERM_WIDTH-1:C_TERM_WIDTH-C_DATA_WIDTH];
        assign Term_Valid_1 = term_pipe[1].valid;
        assign Term_ID_1    = term_pipe[1].id;

    end else begin

        assign Term_Data_1  = Term_Data_In;
        assign Term_Valid_1 = Term_Valid_In;
        assign Term_ID_1    = Term_ID_In;

    end
endgenerate


generate
    // assign the upper bit of a 512 vector with the data and fill the LSB with zero for logic optimisation
    // only support 512/256/128/64b
    assign Term_Data_In_ext = (C_DATA_WIDTH == 512 ) ?  Term_Data_In
                            : (C_DATA_WIDTH == 256 ) ? {Term_Data_In, 256'b0 }
                            : (C_DATA_WIDTH == 128 ) ? {Term_Data_In, 384'b0 }
                            : (C_DATA_WIDTH == 64  ) ? {Term_Data_In, 448'b0 }
                            : 'h0;
    assign Term_Data_1_ext = (C_DATA_WIDTH == 512 ) ?  Term_Data_1
                           : (C_DATA_WIDTH == 256 ) ? {Term_Data_1, 256'b0 }
                           : (C_DATA_WIDTH == 128 ) ? {Term_Data_1, 384'b0 }
                           : (C_DATA_WIDTH == 64  ) ? {Term_Data_1, 448'b0 }
                           : 'h0;
    assign Expected_Data_ext = (C_DATA_WIDTH == 512 ) ?  Expected_Data
                             : (C_DATA_WIDTH == 256 ) ? {Expected_Data, 256'b0 }
                             : (C_DATA_WIDTH == 128 ) ? {Expected_Data, 384'b0 }
                             : (C_DATA_WIDTH == 64  ) ? {Expected_Data, 448'b0 }
                             : 'h0;
endgenerate

////////////////////////////////////////////////////////////
// Termination pipeline
////////////////////////////////////////////////////////////

always_ff @(posedge clk) begin

    // drive the pipeline
    term_pipe[1:C_TERM_PIPE_SIZE-1] <= term_pipe[0:C_TERM_PIPE_SIZE-2];

    ////////////////////////////////////////////////////////////
    // Stage 0
    ////////////////////////////////////////////////////////////
    term_pipe[0].valid          <= Term_Valid_In;
    term_pipe[0].data           <= Term_Data_In_ext;
    term_pipe[0].suppress_error <= suppress_error;
    term_pipe[0].rd_en          <= '0;

    if (C_USE_AXI_ID == 1) begin

        if (Term_Valid_In) begin

            term_pipe[0].id <= Term_ID_In;

            if (term_pipe[0].id != Term_ID_In) begin

                term_pipe[0].rd_en <= 1'b1;

            end
        end

    end

    ////////////////////////////////////////////////////////////
    // Stage 2
    ////////////////////////////////////////////////////////////
    Term_PRBS_Seed_var      = Term_PRBS_Seed_out;
    for (int k = C_DATA_WIDTH-1; k >= 0; k--) begin

        Term_Data_var[k] = ^(C_PRBS_CHECK[k] & Term_PRBS_Seed_var); // use current seed to expected data

    end
    Term_PRBS_Seed_var = Term_Data_1[30:0];


    if (term_pipe[0].rd_en) begin

        Term_PRBS_Seed_out <= Term_PRBS_Seed_RAM[term_pipe[0].id];

    end else if (Term_Valid_1) begin

        Term_PRBS_Seed_out   <= Term_PRBS_Seed_var;

    end

    if (Term_Valid_1) begin

        Term_PRBS_Seed_RAM[Term_ID_1]   <= Term_PRBS_Seed_var;

        Term_PRBS_Seed                  <= Term_PRBS_Seed_var;
        Term_PRBS_Seed_d                <= Term_PRBS_Seed_out;

        Expected_Data                   <= Term_Data_var;

    end

    if (C_USE_AXI_ID == 0) begin

        term_pipe[2].valid          <= Term_Valid_1;
        term_pipe[2].data           <= Term_Data_1_ext;
        term_pipe[2].id             <= Term_ID_1;
        term_pipe[2].suppress_error <= suppress_error;

    end


    ////////////////////////////////////////////////////////////
    // Stage 3 - Term seed error
    ////////////////////////////////////////////////////////////
    if (ctrl_clear_err_pulse) begin

        stat_term_seed_err_latch  <= 1'b0;

    end

    dbg_Term_Seed_Err <= 1'b0;
    if (term_pipe[2].valid) begin

        if (~term_pipe[2].suppress_error) begin // suppress term seed error at resync as last data in previous run could equal first data in next run

            if (Term_PRBS_Seed_d == Term_PRBS_Seed) begin

                dbg_Term_Seed_Err                   <= 1'b1;
                stat_term_seed_err_latch            <= 1'b1;

            end

        end

    end

    // Check data
    Term_Error_3_var = 'h0;
    for (int n = C_TERM_WIDTH-1; n > -1 ; n--) begin

        Term_Error_3_var[n/C_DIV_STAGE_1] = Term_Error_3_var[n/C_DIV_STAGE_1] | (term_pipe[2].data[n] ^ Expected_Data_ext[n]);

    end
    if (term_pipe[2].valid) begin

        term_pipe[3].error <= Term_Error_3_var;

    end


    ////////////////////////////////////////////////////////////
    // Stage 4 - Detect error
    ////////////////////////////////////////////////////////////
    Term_Error_4_var = '0;
    for (int n = C_TERM_WIDTH/C_DIV_STAGE_1; n > -1 ; n--) begin

        Term_Error_4_var[n / C_DIV_STAGE_2] = Term_Error_4_var[n / C_DIV_STAGE_2] | term_pipe[3].error[n];

    end
    if (term_pipe[3].valid) begin

        term_pipe[4].error <= Term_Error_4_var;

    end


    ////////////////////////////////////////////////////////////
    // Stage 5 - Detect error
    ////////////////////////////////////////////////////////////
    Term_Error_5_var = '0;
    for (int n = C_TERM_WIDTH/C_DIV_STAGE_1/C_DIV_STAGE_2; n > -1 ; n--) begin

        Term_Error_5_var[n / C_DIV_STAGE_3] = Term_Error_5_var[n / C_DIV_STAGE_3] | term_pipe[4].error[n];

    end
    if (term_pipe[4].valid) begin

        term_pipe[5].error <= Term_Error_5_var;

    end


    ////////////////////////////////////////////////////////////
    // Stage 6 - Detect error
    ////////////////////////////////////////////////////////////
    Term_Error_6_var = '0;
    for (int n = C_TERM_WIDTH/C_DIV_STAGE_1/C_DIV_STAGE_2/C_DIV_STAGE_3; n > -1 ; n--) begin

        Term_Error_6_var[0] = Term_Error_6_var[0] | term_pipe[5].error[n];

    end
    if (term_pipe[5].valid) begin

        term_pipe[6].error <= Term_Error_6_var;

        if (term_pipe[5].suppress_error) begin

            term_pipe[6].error <= '0;

        end

    end


    ////////////////////////////////////////////////////////////
    // Stage 7 - Count incorrect words
    ////////////////////////////////////////////////////////////
    if (ctrl_clear_err_pulse) begin

        stat_term_err_latch <= 1'b0;
        stat_term_err_cnt   <= '0;

    end

    dbg_Term_Err <= 1'b0;
    if (term_pipe[6].valid) begin

        if (term_pipe[6].error[0]) begin

            dbg_Term_Err        <= 1'b1;
            stat_term_err_latch <= 1'b1;
            if (~stat_term_err_cnt[$high(stat_term_err_cnt)]) begin

                stat_term_err_cnt <= stat_term_err_cnt + 1;

            end

        end

    end

    if (rst) begin

        term_pipe[0].rd_en          <= '0;
        term_pipe[0].valid          <= '0;

        // No need to reset term seed as we suppress term seed error at resync
        // Term_PRBS_Seed_out          <= C_RST_PRBS_SEED;
        // Term_PRBS_Seed              <= C_RST_PRBS_SEED;
        // Term_PRBS_Seed_d            <= C_RST_PRBS_SEED;

        stat_term_seed_err_latch    <= '0;
        stat_term_err_latch         <= '0;
        stat_term_err_cnt           <= '0;

    end
end

endmodule: PRBS31_Gen_Term
`default_nettype wire
