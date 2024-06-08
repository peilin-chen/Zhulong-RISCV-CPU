#需要编译的.v路径
set file_name G:/download/pipeline_riscv_cpu/sim/rtl/*.v  

#编译Verilog文件
vlog $file_name

# 启动仿真器并运行仿真
vsim tb

run -all

# 解析仿真日志文件，判断仿真是否通过
set logfile [open "G:/download/pipeline_riscv_cpu/sim/transcript" r]
set logdata [read $logfile]
close $logfile

if {[string first "pass" $logdata] != -1} {
    puts "Simulation passed"
} else {
    puts "Simulation failed"
}

quit -f