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

#include "graph.h"
#include "../user_parameters.h"

// PL_FREQ_MHZ is set via command line
PLIO *  in0 = new PLIO( "in0", adf::plio_128_bits,  "data/input0.txt", PL_FREQ_MHZ);
PLIO * out0 = new PLIO("out0", adf::plio_128_bits, "data/output0.txt", PL_FREQ_MHZ);

simulation::platform<1,1> pfm(in0, out0);

TopGraph G;
connect<> n_in0  (pfm.src[0],       G.in0);
connect<> n_out0 (    G.out0, pfm.sink[0]);

int main(void) {
    G.init();
    G.run();
    return 0;
}