`timescale 1ns / 1ns
module tb();

	reg clk;
	reg rst;
	
	wire x3 = tb.RISCV_SOC_inst.TOP_RISCV_inst.REGS_inst.regs[3];
	wire x26 = tb.RISCV_SOC_inst.TOP_RISCV_inst.REGS_inst.regs[26];
	wire x27 = tb.RISCV_SOC_inst.TOP_RISCV_inst.REGS_inst.regs[27];

	always #10 clk = ~clk;
	
	integer i;
	
	initial begin
		clk <= 1'b1;
		rst <= 1'b1;
		/*for(i=0; i<4096; i=i+1)
			begin
				tb.RISCV_SOC_inst.RAM_inst.ram[i] = 64'b0;
			end*/
		#30;
		rst <= 1'b0;	
	end
	
	//rom 初始值
	initial begin
		$readmemh("G:/download/pipeline_riscv_cpu/sim/generated/inst_data.txt",tb.RISCV_SOC_inst.ROM_inst.rom);
	end

	integer r;
	initial begin		
		wait(x26 == 32'b1);
		
		#1000
		if(x27 == 32'b1) begin
			//$display("############################");
			$display("pass");
			//$display("############################");
		end
		else begin
			$display("############################");
			$display("########  fail  !!!#########");
			$display("############################");
			$display("fail testnum = %2d", x3);
			for(r = 0;r < 32; r = r + 1)begin
				$display("x%2d register value is %h",r,tb.RISCV_SOC_inst.TOP_RISCV_inst.REGS_inst.regs[r]);	
			end	
		end
		
		$stop;
		
	end
	
	RISCV_SOC RISCV_SOC_inst
	(
		.clk        (clk        ),
		.rst        (rst        )
	);

endmodule 
