`include "defines.v"

module CLINT
(
	input wire        clk            ,
	input wire        rst            ,
	//from id                        
	input wire [31:0] inst_i         ,
	input wire [63:0] inst_addr_i    ,
	//from ex                        
	input wire        jump_flag_i    ,
	input wire [63:0] jump_addr_i    ,
	//from csr_regs                  
	input wire [63:0] data_i         ,
	input wire [63:0] csr_mtvec      ,
	input wire [63:0] csr_mepc       ,
	input wire [63:0] csr_mstatus    ,
	//to ctrl                        
	output wire       hold_flag_o    ,
	//to csr_regs                    
	output reg        we_o           ,
	output reg [63:0] waddr_o        ,
	output reg [63:0] raddr_o        ,
	output reg [63:0] data_o         ,
	//to ex                          
	output reg [63:0] int_addr_o     ,
	output reg        int_assert_o   ,
	
	input wire        global_int_en_i
);

	localparam S_INT_IDLE         = 4'b0001;
	localparam S_INT_SYNC_ASSERT  = 4'b0010;
	localparam S_INT_ASYNC_ASSERT = 4'b0100;
	localparam S_INT_MRET         = 4'b1000;
	
	localparam S_CSR_IDLE         = 5'b00001;
	localparam S_CSR_MSTATUS      = 5'b00010;
	localparam S_CSR_MEPC         = 5'b00100;
	localparam S_CSR_MSTATUS_MRET = 5'b01000;
	localparam S_CSR_MCAUSE       = 5'b10000;
	
	reg [3 :0] int_state;
	reg [4 :0] csr_state;
	reg [63:0] inst_addr;
	reg [63:0] cause    ;
	
	assign hold_flag_o = ((int_state != S_INT_IDLE) | (csr_state != S_CSR_IDLE))?1'b1:1'b0;
	
	//中断仲裁逻辑
	always @(*)
		begin
			if(rst == 1'b1) begin
				int_state = S_INT_IDLE;
			end
			else begin
				if(inst_i == `INST_ECALL || inst_i == `INST_EBREAK) begin
					int_state = S_INT_IDLE;
				end
				else if(global_int_en_i == 1'b1) begin
					int_state = S_INT_ASYNC_ASSERT;
				end
				else if(inst_i == `INST_MRET) begin
					int_state = S_INT_MRET;
				end
				else begin
					int_state = S_INT_IDLE;
				end
			end
		end

	//写CSR寄存器状态切换
	always @(posedge clk) 
		begin
			if(rst == 1'b1) begin
				csr_state <= S_CSR_IDLE;
				cause     <= 64'b0     ;
				inst_addr <= 64'b0     ;
			end
			else begin
				case(csr_state)
					S_CSR_IDLE:begin
						if(int_state == S_INT_SYNC_ASSERT) begin
							csr_state <= S_CSR_MEPC;
							if(jump_flag_i == 1'b1) begin
								inst_addr <= jump_addr_i - 4'h4;
							end
							else begin
								inst_addr <= inst_addr_i;
							end
							case(inst_i)
								`INST_ECALL:begin
									cause <= 64'd11;
								end
								`INST_EBREAK:begin
									cause <= 64'd3;
								end
								default:begin
									cause <= 64'd10;
								end
							endcase
						end
						else if(int_state == S_INT_MRET) begin
							csr_state <= S_CSR_MSTATUS_MRET;
						end
					end
					S_CSR_MEPC:begin
						csr_state <= S_CSR_MSTATUS;
					end
					S_CSR_MSTATUS:begin
						csr_state <= S_CSR_MCAUSE;
					end
					S_CSR_MCAUSE:begin
						csr_state <= S_CSR_IDLE;
					end
					S_CSR_MSTATUS_MRET:begin
						csr_state <= S_CSR_IDLE;
					end
					default:begin
						csr_state <= S_CSR_IDLE;
					end
				endcase
			end
		end
	
	//在发送中断信号前，先写几个CSR寄存器
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				we_o    <= 1'b0 ;
				waddr_o <= 64'b0;
				data_o  <= 64'b0;
			end
			else begin
				case(csr_state)
					//将mepc寄存器的值设为当前指令地址
					S_CSR_MEPC:begin
						we_o    <= 1'b1                                ;
						waddr_o <= {52'b0,`INST_CSR_MEPC};
						data_o  <= inst_addr                           ;
					end
					//写中断产生的原因
					S_CSR_MCAUSE:begin
						we_o    <= 1'b1                                  ;
						waddr_o <= {52'b0,`INST_CSR_MCAUSE};
						data_o  <= cause                                 ;
					end
					//关闭全局中断
					S_CSR_MSTATUS:begin
						we_o    <= 1'b1                                       ;
						waddr_o <= {52'b0,`INST_CSR_MSTATUS}    ; 
						data_o  <= {csr_mstatus[63:4], 1'b0, csr_mstatus[2:0]};
					end
					//中断返回
					S_CSR_MSTATUS_MRET:begin
						we_o    <= 1'b1                                                 ;
						waddr_o <= {52'b0,`INST_CSR_MSTATUS}              ;
						data_o  <= {csr_mstatus[63:4], csr_mstatus[7], csr_mstatus[2:0]};
					end
					default:begin
						we_o    <= 1'b0 ;
						waddr_o <= 64'b0;
						data_o  <= 64'b0;
					end
				endcase
			end
		end
	
	//发送中断信号给ex
	always @(posedge clk) 
		begin
			if(rst == 1'b1) begin
				int_assert_o <= 1'b0 ;
				int_addr_o   <= 64'b0;
			end
			else begin
				case(csr_state)
					S_CSR_MCAUSE:begin
						int_assert_o <= 1'b1     ;
						int_addr_o   <= csr_mtvec;
					end
					S_CSR_MSTATUS_MRET:begin
						int_assert_o <= 1'b1    ;
						int_addr_o   <= csr_mepc;
					end
					default:begin
						int_assert_o <= 1'b0 ;
						int_addr_o   <= 64'b0;
					end
				endcase
			end
		end
	
endmodule


