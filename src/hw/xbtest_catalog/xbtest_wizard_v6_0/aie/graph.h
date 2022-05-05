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

#ifndef __GRAPH_H__
#define __GRAPH_H__

#include <adf.h>
#include "kernels.h"
#include "../user_parameters.h"

using namespace adf;
class TopGraph : public adf::graph {
    private:
        kernel krnl [NUMCORES];
    public:
        port<input> in0;
        port<output> out0;

        TopGraph() {
            for (uint i=0; i<NUMCORES; i++) {
                krnl[i] = kernel::create(compute);
                source(krnl[i]) = "kernels/compute.cc";
                runtime<ratio>(krnl[i])  = 1.0;
            }
            connect<stream> net_in (in0, krnl[0].in[0]);
            fifo_depth(net_in)  = 2*STREAM_FIFO_DEPTH;
            connect<stream> net_out (krnl[NUMCORES-1].out[0], out0);
            fifo_depth(net_out)  = 2*STREAM_FIFO_DEPTH;
            for (uint i=0; i<NUMCORES-1; i++) {
                connect<stream> net_str(krnl[i].out[0], krnl[i+1].in[0]);
                fifo_depth(net_str) = 2*STREAM_FIFO_DEPTH;
            }
        };
};

#endif /**********__GRAPH_H__**********/
