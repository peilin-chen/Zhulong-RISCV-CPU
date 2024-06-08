sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
verdiWindowResize -win $_Verdi_1 "0" "25" "1918" "802"
debImport "+v2k" "-sverilog" "-top" "RISCV_SOC" "-f" "../scripts/FileList.f"
debLoadSimResult /home/IC/Desktop/risc_cpu/debug/RISCV_SOC.fsdb
wvCreateWindow
verdiDockWidgetDisplay -dock widgetDock_WelcomePage
debExit
