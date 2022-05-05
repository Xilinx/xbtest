# Create pblock for GT kernel_0
create_pblock gt_krnl0
resize_pblock [get_pblocks gt_krnl0] -add {CLOCKREGION_X0Y5:CLOCKREGION_X4Y7}
add_cells_to_pblock -quiet [get_pblocks gt_krnl0] [get_cells -hierarchical -filter {NAME =~ level0_i/ulp/krnl_gt_mac_test0_1/*/mac_wrapper/gty_4lanes.xxv_ip.mac/*}]
