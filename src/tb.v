`timescale 1ns / 1ns
module tb();

	reg clk;
	reg rst;
	
	always #10 clk = ~clk; //50MHz
	
	integer i;
	
	//ram 初始化
	initial begin
		clk <= 1'b1;
		rst <= 1'b1;
		/*for(i=0; i<4096; i=i+1)
			begin
				tb.RISCV_SOC_inst.RAM_inst.ram[i] = 64'bx;
			end*/
		#30;
		rst <= 1'b0;	
	end
	
	//rom 初始值加载s addiw and andi
	initial begin
		$readmemh("G:/download/pipeline_riscv_cpu/tb/generated/rv64ui-p-addi.txt",tb.RISCV_SOC_inst.ROM_inst.rom);
		//$readmemb("G:/download/pipeline_riscv_cpu/tb/inst_data_ADD.txt",tb.RISCV_SOC_inst.ROM_inst.rom);
	end

	integer r;
	initial begin		

		wait(tb.RISCV_SOC_inst.TOP_RISCV_inst.REGS_inst.regs[26] == 32'b1);
		#2000
		if(tb.RISCV_SOC_inst.TOP_RISCV_inst.REGS_inst.regs[27] == 32'b1) begin
			$display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
            $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
		end
		else begin
			$display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
			$display("fail testnum = %2d", tb.RISCV_SOC_inst.TOP_RISCV_inst.REGS_inst.regs[3]);
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

