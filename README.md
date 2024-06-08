# Zhulong-RISCV-CPU

## Directory structure
```
  / Zhulong_RISCV_CPU /
             |--- debug/
             |         |--- Makefile
             |
             |--- debug_netlist/
             |                 |--- Makefile
             |
             |--- modelsim_simulation_win11/
             |                             |--- rtl
             |                             |--- sim
             |                             |--- tb
             |                             \--- utils
             |
             |--- scripts/
             |           |--- filelist
             |           |--- FileList_netlist.f
             |           \--- FileList.f
             |
             |--- src/
             |       |--- AXI4_Lite.v
             |       |--- CHECK.v
             |       |--- CLINT.v
             |       |--- CSR_REGS.v
             |       |--- CTRL.v
             |       |--- DCache.v
             |       |--- defines.v
             |       |--- DFF_SET.v
             |       |--- Divider.v
             |       |--- EX.v
             |       |--- EX_MEM.v
             |       |--- ICache.v
             |       |--- ID.v
             |       |--- ID_EX.v
             |       |--- IF.v
             |       |--- IF_ID.v
             |       |--- MEM.v
             |       |--- MEM_WB.v
             |       |--- Multiplier.v
             |       |--- PC.v
             |       |--- RAM.v
             |       |--- REGS.v
             |       |--- RISCV_SOC.v
             |       |--- ROM.v
             |       |--- tb.v
             |       |--- TOP_RISCV.v
             |       \--- WB.v
             |
             |--- syn/
             |       |---exec\
             |       |       |---run
             |       |       |---synthesis.tcl
             |       |       \---...
             |       |       
             |       |---formality\
             |       |            |---log\
             |       |            |      |---matched.info
             |       |            |      |---unmached.info
             |       |            |      |---verify_aborted_points.info
             |       |            |      |---verify_failing_points.info
             |       |            |      \---verify_passing_points.info
             |       |            |
             |       |            |---run
             |       |            |---fm.tcl
             |       |            \---...
             |       |
             |       |---icc\
             |       |       |---clock_opt.timing
             |       |       |---icc.tcl
             |       |       |---place_opt.timing
             |       |       |---riscv_cpu.gdsii
             |       |       |---route_opt.physical
             |       |       |---run
             |       |       \---...
             |       |       
             |       |---logs\
             |       |       |---synthesis.log
             |       |
             |       |---primetime\
             |       |       |---pt.tcl
             |       |       |---run
             |       |       \---...
             |       |
             |       |---ref\
             |       |       |---db
             |       |       |---mw_lib
             |       |       |---tech
             |       |       |---tlup
             |       |       \---...
             |       |
             |       |---rpts\
             |       |       |---xxx.rpt
             |       |       \---...
             |       |
             |       |---temp\
             |       |       |---xxx.pvl
             |       |       |---xxx.syn
             |       |       |---xxx.mr
             |       |       \---...
             |       |
             |       \---work\
             |               |---TOP_RISCV.ddc
             |               |---TOP_RISCV.sdc
             |               |---TOP_RISCV.sdf
             |               |---TOP_RISCV.svf
             |               \---TOP_RISCV.v
             |
             |
             \--- README.md
```
