############################################################
# 1、逻辑库、技术库等基本参数设定
############################################################
lappend search_path ../ref/db ../ref/tlup
set_app_var target_library "/home/IC/Desktop/risc_cpu/syn/ref/db/sc_max.db"
set_app_var link_library "* /home/IC/Desktop/risc_cpu/syn/ref/db/sc_max.db"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# TOP_RISCV setup variables
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set my_mw_lib TOP_RISCV
set mw_path "../ref/mw_lib"
set tech_file " ../ref/tech/cb13_6m.tf"
set tlup_map "../ref/tlup/cb13_6m.map"
set tlup_max "../ref/tlup/cb13_6m_max.tluplus"
set tlup_min "../ref/tlup/cb13_6m_min.tluplus"
set top_design   "TOP_RISCV"
set verilog_file "../work/TOP_RISCV.v"
set sdc_file     "../work/TOP_RISCV.sdc"
#set def_file     "../work/TOP_RISCV.def"
set ctrl_file    "opt_ctrl.tcl"
set derive_pg_file    "derive_pg.tcl"
set MODULE_NAME TOP_RISCV
############################################################
# 2、创建自己的Milkyway文件夹
############################################################
file delete -force $my_mw_lib
create_mw_lib $my_mw_lib -open -technology $tech_file \
	-mw_reference_library "$mw_path/sc"
#加载门级网表文件
import_designs $verilog_file \
	-format verilog \
	-top $top_design
#加载线负载模型
set_tlu_plus_files \
	-max_tluplus $tlup_max \
	-min_tluplus $tlup_min \
	-tech2itf_map  $tlup_map
#加载VDD、VSS信息
source $derive_pg_file
#derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
#加载约束文件
read_sdc $sdc_file
source $ctrl_file
source zic_timing.tcl
exec cat zic.timing
remove_ideal_network [get_ports scan_en]
save_mw_cel -as TOP_RISCV_data_setup
############################################################
# 3、布局规划floorplan
############################################################
# 读入布局信息并布局
#read_def $def_file
set_pnet_options -complete {METAL3 METAL4}
create_floorplan -start_first_row -flip_first_row -left_io2core 10 -bottom_io2core 10 -right_io2core 10 -top_io2core 10

create_floorplan -core_utilization 0.701901 -core_aspect_ratio 0.997691 -start_first_row -flip_first_row -left_io2core 10 -bottom_io2core 10 -right_io2core 10 -top_io2core 10

create_rectangular_rings  -nets  {VDD VSS}  -left_offset 1 -left_segment_layer METAL6 -left_segment_width 3 -right_offset 1 -right_segment_layer METAL6 -right_segment_width 3 -bottom_offset 1 -bottom_segment_layer METAL5 -bottom_segment_width 3 -top_offset 1 -top_segment_layer METAL5 -top_segment_width 3

preroute_standard_cells -connect horizontal  -remove_floating_pieces  -fill_empty_rows  -port_filter_mode off -cell_master_filter_mode off -cell_instance_filter_mode off -voltage_area_filter_mode off -route_type {P/G Std. Cell Pin Conn}

preroute_instances

create_fp_placement

legalize_fp_placement

save_mw_cel -as TOP_RISCV_floorplanned
############################################################
# 4、布局placement，放置基本单元
############################################################
place_opt
redirect -tee place_opt.timing {report_timing}
#report_congestion -grc_based -by_layer -routing_stage global
save_mw_cel -as TOP_RISCV_placed
############################################################
# 5、时钟树综合clock tree synthesis
############################################################
remove_clock_uncertainty [all_clocks]
set_fix_hold [all_clocks]
#时钟树综合
clock_opt
redirect -tee clock_opt.timing {report_timing}
# 保存文件
save_mw_cel -as TOP_RISCV_cts
############################################################
# 6、布线routing
############################################################
route_opt
#报告物理信息
#report_design -physical
redirect -tee route_opt.physical {report_design -physical}
save_mw_cel -as TOP_RISCV_routed
############################################################
# 7、输出文件
############################################################
file mkdir files
write  -format ddc  -hierarchy   -output files/$MODULE_NAME.apr.ddc
write  -format verilog -hierarchy -output files/$MODULE_NAME.netlist.v
write_verilog -no_tap_cells files/$MODULE_NAME.lvs.v -pg -no_core_filler_cells
write_verilog -no_tap_cells files/$MODULE_NAME.sim.v -no_core_filler_cells

save_mw_cel -as TOP_RISCV_final
close_mw_cel

write_stream -cells TOP_RISCV_final riscv_cpu.gdsii
close_mw_lib
