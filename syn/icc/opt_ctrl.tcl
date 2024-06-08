# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# General timing and optimization control settings
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set_app_var timing_enable_multiple_clocks_per_reg true
set_app_var case_analysis_with_logic_constants true
set_app_var physopt_delete_unloaded_cells false
set_app_var physopt_power_critical_range 0.8
set_app_var physopt_area_critical_range 0.8
set_app_var enable_recovery_removal_arcs true

# set_false_path from <clock_name> -to <clock_name>
set_fix_multiple_port_nets -all -buffer_constants
set_auto_disable_drc_nets -constant false 
set_timing_derate -max -early 0.95
# set_dont_use <off_limit_cells>
# set_prefer -min <hold_fixing_cells>
set_max_area 0
group_path -name INPUTS -from [all_inputs]
group_path -name OUTPUTS -to [all_outputs]
group_path -name COMBO -from [all_inputs] -to [all_outputs]
set_ideal_network [all_fanout -flat -clock_tree]
# set_cost_priority {max_transistion max_delay}
