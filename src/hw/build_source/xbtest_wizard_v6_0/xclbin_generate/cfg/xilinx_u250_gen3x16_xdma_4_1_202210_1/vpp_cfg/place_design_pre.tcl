# Create pblocks for GT
create_pblock gt_krnl0
resize_pblock [get_pblocks gt_krnl0] -add {CLOCKREGION_X0Y9:CLOCKREGION_X7Y11}
add_cells_to_pblock -quiet [get_pblocks gt_krnl0] [get_cells -hierarchical -filter {NAME =~ level0_i/level1/level1_i/ulp/krnl_gt_mac_test0_1/*/mac_wrapper/gty_4lanes.xxv_ip.mac/*}]

create_pblock gt_krnl1
resize_pblock [get_pblocks gt_krnl1] -add {CLOCKREGION_X0Y8:CLOCKREGION_X7Y9}
resize_pblock [get_pblocks gt_krnl1] -add {CLOCKREGION_X6Y10:CLOCKREGION_X7Y10}
add_cells_to_pblock -quiet [get_pblocks gt_krnl1] [get_cells -hierarchical -filter {NAME =~ level0_i/level1/level1_i/ulp/krnl_gt_mac_test1_1/*/mac_wrapper/gty_4lanes.xxv_ip.mac/*}]