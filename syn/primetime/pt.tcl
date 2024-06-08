set target_library "/home/IC/Desktop/risc_cpu/syn/ref/db/sc_max.db"
set link_library [list * /home/IC/Desktop/risc_cpu/syn/ref/db/sc_max.db]
read_verilog /home/IC/Desktop/risc_cpu/syn/work/TOP_RISCV.v
link_design TOP_RISCV
list_designs
report_cell
read_sdc /home/IC/Desktop/risc_cpu/syn/work/TOP_RISCV.sdc
read_sdf /home/IC/Desktop/risc_cpu/syn/work/TOP_RISCV.sdf

#for further debugging
#check_timing -verbose

#generate initial reports
report_qor
report_global_timing
report_global_slack
report_constraint -all
report_analysis_coverage
report_timing
#report_delay_calculation

#save the session
save_session pt_session
