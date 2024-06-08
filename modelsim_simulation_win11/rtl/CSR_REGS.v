`include "defines.v"

module CSR_REGS
(
	input wire         clk              ,
	input wire         rst              ,
	//from ex id                          
	input wire         we_i             ,
	input wire [63:0]  raddr_i          ,
	input wire [63:0]  waddr_i          ,
	input wire [63:0]  data_i           ,
	//from clint                        
	input wire         clint_we_i       ,
	input wire [63:0]  clint_raddr_i    ,
	input wire [63:0]  clint_waddr_i    ,
	input wire [63:0]  clint_data_i     ,
	//to id                           
	output reg [63:0]  data_o           ,
	//to clint                         
	output reg  [63:0] clint_data_o     ,
	output wire [63:0] clint_csr_mtvec  ,
	output wire [63:0] clint_csr_mepc   ,
	output wire [63:0] clint_csr_mstatus,
	output wire        global_int_en_o
);

	//reg [127:0] cycle   ;
	reg [63 :0] mtvec   ;
	reg [63 :0] mcause  ;
	reg [63 :0] mepc    ;
	reg [63 :0] mie     ;
	reg [63 :0] mstatus ;
	reg [63 :0] mscratch;
	
	assign global_int_en_o   = (mstatus[3] == 1'b1)?1'b1:1'b0;
	assign clint_csr_mtvec   = mtvec                         ;
	assign clint_csr_mepc    = mepc                          ;
	assign clint_csr_mstatus = mstatus                       ;
	
	//cycle counter
	/*always @(posedge clk) 
		begin
			if(rst == 1'b1) begin
				cycle <= 128'b0;
			end
			else begin
				cycle <= cycle + 1'b1;
			end
		end*/
	
	//write reg
	always @(posedge clk) 
		begin
			if(rst == 1'b1) begin
				mtvec    <= 64'b0;
				mcause   <= 64'b0;
				mepc     <= 64'b0;
				mie      <= 64'b0;
				mstatus  <= 64'b0;
				mscratch <= 64'b0;
			end
			else begin
				if(we_i == 1'b1) begin
					case(waddr_i[11:0])
						`INST_CSR_MTVEC:begin
							mtvec    <= data_i;
						end
						`INST_CSR_MCAUSE:begin
							mcause   <= data_i;
						end
						`INST_CSR_MEPC:begin
							mepc     <= data_i;
						end
						`INST_CSR_MIE:begin
							mie      <= data_i;
						end
						`INST_CSR_MSTATUS:begin
							mstatus  <= data_i;
						end
						`INST_CSR_MSCRATCH:begin
							mscratch <= data_i;
						end
						default:begin
						
						end
					endcase
				end
				else if(clint_we_i == 1'b1) begin
					case(clint_waddr_i[11:0])
						`INST_CSR_MTVEC:begin
							mtvec    <= clint_data_i;
						end
						`INST_CSR_MCAUSE:begin
							mcause   <= clint_data_i;
						end
						`INST_CSR_MEPC:begin
							mepc     <= clint_data_i;
						end
						`INST_CSR_MIE:begin
							mie      <= clint_data_i;
						end
						`INST_CSR_MSTATUS:begin
							mstatus  <= clint_data_i;
						end
						`INST_CSR_MSCRATCH:begin
							mscratch <= clint_data_i;
						end
						default:begin
						
						end
					endcase
				end
			end
		end
	//read reg
	//ex
	always @(*) 
		begin
			if(waddr_i[11:0] == raddr_i[11:0] && (we_i == 1'b1)) begin
				data_o = data_i;
			end
			else begin
				case(raddr_i[11:0])
					/*`INST_CSR_CYCLE:begin
						data_o = cycle[63:0];
					end
					`INST_CSR_CYCLEH:begin
						data_o = cycle[127:64];
					end*/
					`INST_CSR_MTVEC:begin
						data_o = mtvec;
					end
					`INST_CSR_MCAUSE:begin
						data_o = mcause;
					end
					`INST_CSR_MEPC:begin
						data_o = mepc;
					end
					`INST_CSR_MIE:begin
						data_o = mie;
					end
					`INST_CSR_MSTATUS:begin
						data_o = mstatus;
					end
					`INST_CSR_MSCRATCH:begin
						data_o = mscratch;
					end
					default:begin
						data_o = 64'b0;
					end
				endcase
			end
		end
	
	//read reg
	//clint
	always @(*) 
		begin
			if(clint_waddr_i[11:0] == clint_raddr_i[11:0] && (clint_we_i == 1'b1)) begin
				clint_data_o = clint_data_i;
			end
			else begin
				case(clint_raddr_i[11:0])
					/*`INST_CSR_CYCLE:begin
						clint_data_o = cycle[63:0];
					end
					`INST_CSR_CYCLEH:begin
						clint_data_o = cycle[127:64];
					end*/
					`INST_CSR_MTVEC:begin
						clint_data_o = mtvec;
					end
					`INST_CSR_MCAUSE:begin
						clint_data_o = mcause;
					end
					`INST_CSR_MEPC:begin
						clint_data_o = mepc;
					end
					`INST_CSR_MIE:begin
						clint_data_o = mie;
					end
					`INST_CSR_MSTATUS:begin
						clint_data_o = mstatus;
					end
					`INST_CSR_MSCRATCH:begin
						clint_data_o = mscratch;
					end
					default:begin
						clint_data_o = 64'b0;
					end
				endcase
			end
		end
	
endmodule


