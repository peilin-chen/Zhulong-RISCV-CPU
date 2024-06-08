# Zhulong-RISCV-CPU

Zhulong CPU is a five-stage pipeline, in-order, single-issue, single-core processor based on the RISC-V instruction set architecture.

The microarchitecture of Zhulong CPU:

<p float="middle">
  <img src="/figures/zhulong_cpu_arch.png" alt="architecture" width="65%">
</p>

Features:

1) Five-stage Pipeline;
2) 64-bit Processor;
3) RV64IM ISA (contain 62 instructions);
4) 512 bytes Instruction Cache and 1024 bytes Data Cache;
5) AXI4-Lite Bus;
6) 64-bit Multiplier and Divider.

Use Synopsys's EDA tools for logic synthesis, static timing analysis, formal verification, and physical synthesis of Zhulong RISCV Core. It achieves a working frequency of 200MHz on TSMC 130nm process, with a total power consumption and chip area of 26.6073mW and 821967.86µm² respectively.

The layout of Zhulong CPU:

<p float="middle">
  <img src="/figures/zhulong_cpu_layout.png" alt="layout" width="100%">
</p>

## Directory structure
```
  / Zhulong_RISCV_CPU /
             |--- debug/
             |         |--- Makefile
             |
             |--- debug_netlist/
             |                 |--- Makefile
             |
             |--- figures
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
