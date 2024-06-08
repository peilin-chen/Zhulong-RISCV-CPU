set hdlin_unresolved_modules "black_box"
set verification_failing_point_limit 0

read_db   -libname  tech_lib  -technology_library "/home/IC/Desktop/risc_cpu/syn/ref/db/sc_max.db"

set hdlin_error_on_mismatch_message  false
set hdlin_warn_on_mismatch_message  {FMR_ELAB-147 FMR_ELAB-115}
suppress_message FMR_ELAB-147

set_svf  ../work/TOP_RISCV.svf
read_verilog -r  -libname design_lib { ../../src/TOP_RISCV.v  \
                                    ../../src/defines.v   \
                                    ../../src/CHECK.v    \
                                    ../../src/CLINT.v    \
                                    ../../src/CSR_REGS.v    \
                                    ../../src/CTRL.v    \
                                    ../../src/DFF_SET.v   \
                                    ../../src/Divider.v    \
                                    ../../src/EX.v    \   
                                    ../../src/EX_MEM.v  \
				    ../../src/ID.v  \
                                    ../../src/ID_EX.v  \
                                    ../../src/IF.v  \
				    ../../src/IF_ID.v  \
                                    ../../src/MEM.v  \
                                    ../../src/MEM_WB.v  \
				    ../../src/Multiplier.v  \
                                    ../../src/PC.v  \
                                    ../../src/REGS.v  \
                                    ../../src/WB.v }

set_top TOP_RISCV

read_verilog -i -libname design_lib [list ../../syn/work/*.v  ]
set_top TOP_RISCV

set verification_set_undriven_signals synthesis

match 

report_matched_points > ./log/matched.info

report_unmatched_points > ./log/unmatched.info

verify 

report_passing_points > ./log/verify_passing_points.info

report_failing_points > ./log/verify_failing_points.info

report_aborted_points > ./log/verify_aborted_points.info

