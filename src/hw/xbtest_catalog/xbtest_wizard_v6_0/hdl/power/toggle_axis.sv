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

module toggle_axis #(
    parameter integer C_AXIS_DATA_WIDTH = 128
) (
    input  wire                             clk,
    input  wire                             rst,
    input  wire                             enable,
    input  wire                             tog_en,
    input  wire                             ctrl_tog_update,

    output wire [C_AXIS_DATA_WIDTH-1:0]     m_axis_tdata,
    output logic                            m_axis_tvalid = '0,
    input  wire                             m_axis_tready,
    output wire [C_AXIS_DATA_WIDTH/8-1:0]   m_axis_tkeep,
    output wire                             m_axis_tlast,

    input  wire [C_AXIS_DATA_WIDTH-1:0]     s_axis_tdata,
    input  wire                             s_axis_tvalid,
    output wire                             s_axis_tready,
    input  wire  [C_AXIS_DATA_WIDTH/8-1:0]  s_axis_tkeep,
    input  wire                             s_axis_tlast,

    output wire [31:0]                      cycle_cnt,

    output wire [31:0]                      m_tready_cnt,
    output wire [31:0]                      m_txfer_cnt,
    output wire [31:0]                      s_txfer_cnt
);

wire ff_en;
logic ff = 1'b0;
logic ff_d = 1'b0;
logic ctrl_tog_update_d = 1'b0;

assign ff_en = tog_en & enable;
generate
    if (C_AXIS_DATA_WIDTH == 128) begin
        assign m_axis_tdata = {{32{ff_d}}, {32{ff}}, {32{ff_d}}, {32{ff}}};
    end
    if (C_AXIS_DATA_WIDTH == 64) begin
        assign m_axis_tdata = {{32{ff_d}}, {32{ff}}};
    end
    if (C_AXIS_DATA_WIDTH == 32) begin
        assign m_axis_tdata = {32{ff_d}};
    end
endgenerate
assign m_axis_tkeep     = {C_AXIS_DATA_WIDTH/8{1'b1}};
assign m_axis_tlast     = m_axis_tvalid;
assign s_axis_tready    = 1'b1;

logic [32:0] cycle_cnt_int = '0;
logic [31:0] m_tready_cnt_int = '0;
logic [31:0] m_txfer_cnt_int = '0;
logic [31:0] s_txfer_cnt_int = '0;

assign cycle_cnt       = cycle_cnt_int[31:0];
assign m_tready_cnt    = m_tready_cnt_int;
assign m_txfer_cnt     = m_txfer_cnt_int;
assign s_txfer_cnt     = s_txfer_cnt_int;

always_ff @(posedge clk) begin
    cycle_cnt_int <= cycle_cnt_int+1;
    if (m_axis_tready) begin
        m_tready_cnt_int <= m_tready_cnt_int+1;
    end

    if (m_axis_tready & m_axis_tvalid) begin
        ff                  <= ~ff;
        ff_d                <= ff;
        m_txfer_cnt_int   <= m_txfer_cnt_int+1;
        m_axis_tvalid       <= 1'b0;
    end
    if (ff_en) begin
        m_axis_tvalid   <= 1'b1;
    end

    if (s_axis_tvalid) begin
        s_txfer_cnt_int   <= s_txfer_cnt_int+1;
    end

    ctrl_tog_update_d <= ctrl_tog_update;
    if ((ctrl_tog_update_d != ctrl_tog_update) || (cycle_cnt_int[$high(cycle_cnt_int)])) begin
        cycle_cnt_int       <= 'h0;
        m_tready_cnt_int    <= 'h0;
        m_txfer_cnt_int     <= 'h0;
        s_txfer_cnt_int     <= 'h0;
    end

    if (rst) begin
        m_axis_tvalid   <= 1'b0;
    end

end


endmodule : toggle_axis
`default_nettype wire
