`include "defines.v"

module EX
(
	//from id_ex
	input wire [31:0]  inst_i          ,
	input wire [63:0]  inst_addr_i     ,
	input wire [63:0]  op1_i           ,
	input wire [63:0]  op2_i           ,
	input wire [4 :0]  rd_addr_i       ,
	input wire         rd_wen_i        ,
	input wire [63:0]  base_addr_i     ,
	input wire [63:0]  addr_offset_i   ,
	input wire         csr_we_i        ,
	input wire [63:0]  csr_rdata_i     ,
	input wire [63:0]  csr_waddr_i     ,
	input wire [31:0]  id_axi_araddr_i ,
	input wire         read_ram_i      ,
	input wire         write_ram_i     ,
 	//from clint                       
	input wire         int_assert_i    ,
	input wire [63:0]  int_addr_i      ,
	//to ex_mem                  
	output wire [4 :0] rd_addr_o       ,
	output wire [63:0] rd_data_o       ,
	output wire        rd_wen_o        ,
	output wire [31:0] id_axi_araddr_o ,
	output wire        read_ram_o      ,
	output wire        write_ram_o     ,
	output wire [31:0] inst_o          ,
	output wire [63:0] inst_addr_o     ,
	output wire [63:0] op2_o           ,
	//to csr regs                      
	output wire        csr_we_o        ,
	output reg  [63:0] csr_wdata_o     ,
	output wire [63:0] csr_waddr_o     ,
	//to ctrl clint                         
	output wire [63:0] jump_addr_o     ,
	output wire        jump_en_o       ,
	output wire        hold_flag_o     ,
	//from divider
	input wire         div_finish_i    ,
	input wire [63:0]  div_rem_data_i  ,
	input wire         div_busy_i      ,
	//to divider
	output reg         div_ready_o     ,
	output reg  [63:0] div_dividend_o  ,
	output reg  [63:0] div_divisor_o   ,
	output reg  [9 :0] div_op_o        ,
	//from multiplier
	input wire         mult_finish_i   ,
	input wire [63:0]  mult_product_val,
	input wire         mult_busy_i     ,
	//to multiplier                    
	output reg         mult_ready_o    ,
	output reg [63:0]  mult_op1_o      ,
	output reg [63:0]  mult_op2_o      ,
	output reg [9 :0]  mult_op_o       
);

	wire [6 :0] opcode;
	wire [4 :0] rd    ;
	wire [2 :0] funct3;
	wire [4 :0] rs1   ;
	wire [4 :0] rs2   ;
	wire [6 :0] funct7;
	wire [11:0] imm   ;
	wire [5 :0] shamt ;
	wire [4 :0] uimm  ;
	
	//wire [63:0] ram_data_i    ;
	//wire [63:0] ram_ram_data_i;
	
	assign opcode = inst_i[6 :0 ];
	assign rd     = inst_i[11:7 ];
	assign funct3 = inst_i[14:12];
	assign rs1    = inst_i[19:15];
	assign rs2    = inst_i[24:20];
	assign funct7 = inst_i[31:25];
	assign imm    = inst_i[31:20];
	assign shamt  = inst_i[25:20];
	assign uimm   = inst_i[19:15];

	assign read_ram_o      = read_ram_i     ;
	assign write_ram_o     = write_ram_i    ;
	assign inst_o          = inst_i         ;
	assign inst_addr_o     = inst_addr_i    ;
	assign id_axi_araddr_o = id_axi_araddr_i;
	assign op2_o           = op2_i          ;

	//assign ram_ram_data_i = ex_axi_rdata;
	
	//assign ram_data_i = (valid == 1'b1)?check_ram_data_i:ram_ram_data_i;
	
	wire        op1_i_equal_op2_i        ;
	wire        op1_i_less_op2_i_signed  ;
	wire        op1_i_less_op2_i_unsigned;
	
	assign op1_i_equal_op2_i         = (op1_i == op2_i)?1'b1:1'b0                 ;
	assign op1_i_less_op2_i_signed   = ($signed(op1_i) < $signed(op2_i))?1'b1:1'b0;
	assign op1_i_less_op2_i_unsigned = (op1_i < op2_i)?1'b1:1'b0                  ;
	
	wire [63:0] op1_i_add_op2_i          ;
	wire [63:0] op1_i_sub_op2_i          ;
	wire [63:0] op1_i_and_op2_i          ;
	wire [63:0] op1_i_xor_op2_i          ;
	wire [63:0] op1_i_or_op2_i           ;
	wire [63:0] op1_i_shift_left_op2_i   ;
	wire [63:0] op1_i_shift_right_op2_i  ;
	wire [63:0] base_addr_add_addr_offset;
	
	assign op1_i_add_op2_i           = op1_i + op2_i              ;	// 加法器
	assign op1_i_sub_op2_i           = op1_i - op2_i              ;	// 减法器
	assign op1_i_and_op2_i           = op1_i & op2_i              ;	// 与
	assign op1_i_xor_op2_i           = op1_i ^ op2_i              ;	// 异或
	assign op1_i_or_op2_i 			 = op1_i | op2_i              ;	// 或
	assign op1_i_shift_left_op2_i 	 = op1_i << op2_i             ;	// 左移
	assign op1_i_shift_right_op2_i 	 = op1_i >> op2_i             ;	// 右移
	assign base_addr_add_addr_offset = base_addr_i + addr_offset_i; // 计算地址单元
	
	//assign check_ram_addr_o = base_addr_add_addr_offset              ;
	//assign ex_axi_araddr    = {1'b1, base_addr_add_addr_offset[30:0]};
	//assign ex_axi_arvalid   = 1'b1                                   ;
	//assign ex_axi_rready    = 1'b1                                   ;
	
	wire [63:0] SRA_mask;
	
	assign SRA_mask = 64'hffff_ffff_ffff_ffff >> op2_i[5:0];
	
	// tpye store && load index
	wire [2:0] load_index = base_addr_add_addr_offset[2:0];
	wire [2:0] store_index = base_addr_add_addr_offset[2:0];
	
	//乘积
	reg  [63 :0] op1_mul     ;
	reg  [63 :0] op2_mul     ;
	wire [127:0] mul_temp    ;
	wire [127:0] mul_temp_inv;
	//除法、余数
	reg  [63 :0] op1_div_op2_res  ;
	reg  [63 :0] op1_rem_op2_res  ;
	reg  [31 :0] op1_div_op2_res_w;
	reg  [31 :0] op1_rem_op2_res_w;
	
	wire [63 :0] op1_i_inv;
	wire [63 :0] op2_i_inv;
	
	assign op1_i_inv = ~op1_i + 1;
	assign op2_i_inv = ~op2_i + 1;
	
	assign mul_temp     = op1_i * op2_i;
	assign mul_temp_inv = ~mul_temp + 1;
	
	wire [63 :0] sli_shift               ;
	wire [31 :0] op1_lower32bit_mask     ;
	wire [31 :0] op1_lower32bit_rlshift  ;
	wire [31 :0] op1_lower32bit_rashift  ;
	wire [31 :0] op1_lower32bit_srawmask ;
	wire [31 :0] op1_lower32bit_srlwshift;
	wire [31 :0] op1_lower32bit_srawshift;
	wire [31 :0] sllw_temp               ;
	
	reg [4:0] div_reg_waddr ;
	reg [4:0] mult_reg_waddr;
	
	assign sli_shift                = op1_i << {58'b0,op2_i[5:0]}                                                               ;
	assign op1_lower32bit_mask      = ~(32'hffff_ffff >> {59'b0,op2_i[4:0]})                                                    ;
	assign op1_lower32bit_rlshift   = op1_i[31:0] >> {59'b0,op2_i[4:0]}                                                         ;
	assign op1_lower32bit_rashift   = (op1_i[31] == 1)?op1_lower32bit_mask|op1_lower32bit_rlshift:op1_lower32bit_rlshift        ;
	assign op1_lower32bit_srawmask  = ~(32'hffff_ffff >> op2_i[4:0])                                                            ;
	assign op1_lower32bit_srlwshift = op1_i[31:0] >> op2_i[4:0]                                                                 ;
	assign op1_lower32bit_srawshift = (op1_i[31] == 1)?op1_lower32bit_srawmask|op1_lower32bit_srlwshift:op1_lower32bit_srlwshift;
	assign sllw_temp                = op1_i[31:0] << op2_i[4:0]                                                                 ;
	
	//响应中断时不写csr寄存器
	assign csr_we_o    = (int_assert_i == 1'b1) ? 1'b0 : csr_we_i;
	assign csr_waddr_o = csr_waddr_i                             ;
	
	reg [63:0] reg_wdata;
	reg        reg_we   ;
	reg [4 :0] reg_waddr;
	reg        hold_flag;
	reg        jump_flag;
	reg [63:0] jump_addr;
	
	reg [63:0] div_wdata    ;
	reg        div_we       ;
	reg [4 :0] div_waddr    ;
	reg        div_hold_flag;
	reg [63:0] div_jump_addr;
	reg        div_jump_flag;
	
	reg [63:0] mult_wdata    ;
	reg        mult_we       ;
	reg [4 :0] mult_waddr    ;
	reg        mult_hold_flag;
	reg [63:0] mult_jump_addr;
	reg        mult_jump_flag;
	
	//响应中断时不写通用寄存器
	assign rd_data_o   = reg_wdata | div_wdata | mult_wdata                                                    ;
	assign rd_wen_o    = (int_assert_i == 1'b1) ? 1'b0 : (reg_we || div_we || mult_we)                         ;
	assign rd_addr_o   = reg_waddr | div_waddr | mult_waddr                                                    ;

	//还需加上响应中断时不写内存、响应中断时不向总线请求访问内存    分别在id mem里实现

	assign hold_flag_o = hold_flag || div_hold_flag || mult_hold_flag                                          ;
	assign jump_en_o   = jump_flag || div_jump_flag || mult_jump_flag || ((int_assert_i == 1'b1) ? 1'b1 : 1'b0);
	assign jump_addr_o = (int_assert_i == 1'b1) ? int_addr_i : (jump_addr | div_jump_addr | mult_jump_addr)    ;
	
	always @ (*) begin
		if((opcode == `INST_TYPE_R_M) && (funct7 == 7'b0000001)) begin
			div_we         = 1'b0            ;
			div_wdata      = 64'b0           ;
			div_waddr      = 5'b0            ;
			div_dividend_o = op1_i           ;
			div_divisor_o  = op2_i           ;
			div_op_o       = {opcode, funct3};
			div_reg_waddr  = rd_addr_i       ;
			case (funct3)
				`INST_DIV, `INST_DIVU, `INST_REM, `INST_REMU:begin
					div_ready_o   = 1'b1                     ;
					div_jump_flag = 1'b1                     ;
					div_hold_flag = 1'b1                     ;
					div_jump_addr = base_addr_add_addr_offset;
				end 
				default:begin
					div_ready_o   = 1'b0;
					div_jump_flag = 1'b0;
					div_hold_flag = 1'b0;
					div_jump_addr = 1'b0;
				end
			endcase
		end   
		else if((opcode == `INST_TYPE_R_M_64W) && (funct7 == 7'b0000001)) begin
			div_we         = 1'b0            ;
			div_wdata      = 64'b0           ;
			div_waddr      = 5'b0            ;
			div_dividend_o = op1_i           ;
			div_divisor_o  = op2_i           ;
			div_op_o       = {opcode, funct3};
			div_reg_waddr  = rd_addr_i       ;
			case (funct3)
				`INST_DIVW, `INST_DIVUW, `INST_REMW, `INST_REMUW:begin
					div_ready_o   = 1'b1                     ;
					div_jump_flag = 1'b1                     ;
					div_hold_flag = 1'b1                     ;
					div_jump_addr = base_addr_add_addr_offset;
				end 
				default:begin
					div_ready_o   = 1'b0 ;
					div_jump_flag = 1'b0 ;
					div_hold_flag = 1'b0 ;
					div_jump_addr = 64'b0;
				end
			endcase
		end
		else begin
			div_jump_flag = 1'b0 ;
			div_jump_addr = 64'b0;
			if(div_busy_i == 1'b1) begin
				div_ready_o   = 1'b1 ;
				div_we        = 1'b0 ;
				div_wdata     = 64'b0;
				div_waddr     = 5'b0 ;
				div_hold_flag = 1'b1 ;
			end
			else begin
				div_ready_o   = 1'b0;
				div_hold_flag = 1'b0;
				if(div_finish_i == 1'b1) begin
					div_wdata = div_rem_data_i;
					div_waddr = div_reg_waddr ;
					div_we    = 1'b1          ;
				end
				else begin
					div_wdata = 64'b0;
					div_waddr = 5'b0 ;
					div_we    = 1'b0 ;
				end
			end
		end
	end
	
	always @ (*) begin
		if((opcode == `INST_TYPE_R_M) && (funct7 == 7'b0000001)) begin
			mult_we        = 1'b0            ;
			mult_wdata     = 64'b0           ;
			mult_waddr     = 5'b0            ;
			mult_op1_o     = op1_i           ;
			mult_op2_o     = op2_i           ;
			mult_op_o      = {opcode, funct3};
			mult_reg_waddr = rd_addr_i       ;
			case (funct3)
				`INST_MUL, `INST_MULHU, `INST_MULHSU, `INST_MULH: begin
					mult_ready_o   = 1'b1                     ;
					mult_jump_flag = 1'b1                     ;
					mult_hold_flag = 1'b1                     ;
					mult_jump_addr = base_addr_add_addr_offset;
				end
				default: begin
					mult_ready_o   = 1'b0 ;
					mult_jump_flag = 1'b0 ;
					mult_hold_flag = 1'b0 ;
					mult_jump_addr = 64'b0;
				end
			endcase
		end
		else if((opcode == `INST_TYPE_R_M_64W) && (funct3 == `INST_ADD_SUB_MULW) && (funct7 == 7'b0000001)) begin
			mult_we        = 1'b0                     ;
			mult_wdata     = 64'b0                    ;
			mult_waddr     = 5'b0                     ;
			mult_ready_o   = 1'b1                     ;
			mult_jump_flag = 1'b1                     ;
			mult_hold_flag = 1'b1                     ;
			mult_jump_addr = base_addr_add_addr_offset;
			mult_op1_o     = op1_i                    ;
			mult_op2_o     = op2_i                    ;
			mult_op_o      = {opcode, funct3}         ;
			mult_reg_waddr = rd_addr_i                ; 
		end
		else begin
			mult_jump_flag = 1'b0 ;
			mult_jump_addr = 64'b0;
			if(mult_finish_i == 1'b1) begin
				mult_ready_o   = 1'b0            ;
				mult_hold_flag = 1'b0            ;
				mult_wdata     = mult_product_val;
				mult_waddr     = mult_reg_waddr  ;
				mult_we        = 1'b1            ;
			end
			else if(mult_busy_i == 1'b1) begin
				mult_ready_o   = 1'b1 ;
				mult_we        = 1'b0 ;
				mult_wdata     = 64'b0;
				mult_waddr     = 5'b0 ;
				mult_hold_flag = 1'b1 ;
			end
			else begin
				mult_ready_o   = 1'b0 ;
				mult_we        = 1'b0 ;
				mult_wdata     = 64'b0;
				mult_waddr     = 5'b0 ;
				mult_hold_flag = 1'b0 ;
			end
		end
	end
	
	always @(*) begin
		case(opcode)
			`INST_TYPE_I:begin
				jump_addr       = 64'b0;
				jump_flag       = 1'b0 ;
				hold_flag       = 1'b0 ;
				//ram_we_o        = 1'b0 ;
				//ram_addr_o      = 64'b0;
				//ram_req_o       = 1'b0 ;
				//ram_data_o      = 64'b0;
				csr_wdata_o     = 64'b0;
				//check_ram_req_o = 1'b0 ;
				//ex_axi_arvalid  = 1'b0 ;
				case(funct3)
					`INST_ADDI:begin
						reg_wdata = op1_i_add_op2_i;
						reg_waddr = rd_addr_i      ;
						reg_we    = 1'b1           ;
					end
					`INST_SLTI:begin
						reg_wdata = {63'b0,op1_i_less_op2_i_signed};
						reg_waddr = rd_addr_i                      ;
						reg_we    = 1'b1                           ;
					end
					`INST_SLTIU:begin
						reg_wdata = {63'b0,op1_i_less_op2_i_unsigned};
						reg_waddr = rd_addr_i                        ;
						reg_we    = 1'b1                             ;
					end
					`INST_XORI:begin
						reg_wdata = op1_i_xor_op2_i;
						reg_waddr = rd_addr_i      ;
						reg_we    = 1'b1           ;
					end
					`INST_ORI:begin
						reg_wdata = op1_i_or_op2_i;
						reg_waddr = rd_addr_i     ;
						reg_we    = 1'b1          ;
					end
					`INST_ANDI:begin
						reg_wdata = op1_i_and_op2_i;
						reg_waddr = rd_addr_i      ;
						reg_we    = 1'b1           ;
					end
					`INST_SLLI:begin
						reg_wdata = op1_i_shift_left_op2_i;
						reg_waddr = rd_addr_i             ;
						reg_we    = 1'b1                  ;
					end
					`INST_SRI:begin
						if(funct7[5] == 1'b1) begin
							reg_wdata = ((op1_i_shift_right_op2_i) & SRA_mask) | ({64{op1_i[31]}} & (~SRA_mask));
							reg_waddr = rd_addr_i                                                               ;
							reg_we    = 1'b1                                                                    ;
						end
						else begin
							reg_wdata = op1_i_shift_right_op2_i;
							reg_waddr = rd_addr_i              ;
							reg_we    = 1'b1                   ;
						end
					end
					default:begin
						reg_wdata = 64'b0;
						reg_waddr = 5'b0 ;
						reg_we    = 1'b0 ;
					end
				endcase
			end
			/*`INST_TYPE_S:begin
				jump_addr       = 64'b0;
				jump_flag       = 1'b0 ;
				hold_flag       = 1'b0 ;
				reg_wdata       = 64'b0;
				reg_waddr       = 5'b0 ;
				reg_we          = 1'b0 ;
				csr_wdata_o     = 64'b0;
				check_ram_req_o = 1'b0 ;
				//ex_axi_arvalid  = 1'b0 ;
				case(funct3)
					`INST_SD:begin
						ram_we_o   = 1'b1                     ;
						ram_addr_o = base_addr_add_addr_offset;
						ram_req_o  = 1'b1                     ;
						ram_data_o = op2_i                    ;
					end
					`INST_SW:begin
						ram_we_o   = 1'b1                     ;
						ram_addr_o = base_addr_add_addr_offset;
						ram_req_o  = 1'b1                     ;
						case(store_index[2])
							1'b0:begin
								ram_data_o = {32'b0,op2_i[31:0]};
							end
							1'b1:begin
								ram_data_o = {op2_i[31:0],32'b0};
							end
						endcase
					end
					`INST_SH:begin
						ram_we_o   = 1'b1                     ;
						ram_addr_o = base_addr_add_addr_offset;
						ram_req_o  = 1'b1                     ;
						case(store_index[2:1])
							2'b00:begin
								ram_data_o = {ram_data_i[63:16],op2_i[15:0]};
							end
							2'b01:begin
								ram_data_o = {ram_data_i[63:32],op2_i[15:0],ram_data_i[15:0]};
							end
							2'b10:begin
								ram_data_o = {ram_data_i[63:48],op2_i[15:0],ram_data_i[31:0]};
							end
							2'b11:begin
								ram_data_o = {op2_i[15:0],ram_data_i[47:0]};
							end
						endcase
					end
					`INST_SB:begin
						ram_we_o   = 1'b1                     ;
						ram_addr_o = base_addr_add_addr_offset;
						ram_req_o  = 1'b1                     ;
						case(store_index[2:0])
							3'b000:begin
								ram_data_o = {ram_data_i[63:8],op2_i[7:0]};
							end
							3'b001:begin
								ram_data_o = {ram_data_i[63:16],op2_i[7:0],ram_data_i[7:0]};
							end
							3'b010:begin
								ram_data_o = {ram_data_i[63:24],op2_i[7:0],ram_data_i[15:0]};
							end
							3'b011:begin
								ram_data_o = {ram_data_i[63:32],op2_i[7:0],ram_data_i[23:0]};
							end
							3'b100:begin
								ram_data_o = {ram_data_i[63:40],op2_i[7:0],ram_data_i[31:0]};
							end
							3'b101:begin
								ram_data_o = {ram_data_i[63:48],op2_i[7:0],ram_data_i[39:0]};
							end
							3'b110:begin
								ram_data_o = {ram_data_i[63:56],op2_i[7:0],ram_data_i[47:0]};
							end
							3'b111:begin
								ram_data_o = {op2_i[7:0],ram_data_i[55:0]};
							end
						endcase
					end
					default:begin
						ram_we_o   = 1'b0 ;
						ram_addr_o = 64'b0;
						ram_req_o  = 1'b0 ;
						ram_data_o = 64'b0;
					end
				endcase
			end
			`INST_TYPE_L:begin
				jump_addr       = 64'b0          ;
				jump_flag       = 1'b0           ;
				hold_flag       = 1'b0           ;
				ram_we_o        = 1'b0           ;
				ram_addr_o      = 64'b0          ;
				ram_req_o       = 1'b0           ;
				ram_data_o      = 64'b0          ;
				csr_wdata_o     = 64'b0          ;
				check_ram_req_o = 1'b1           ;
				id_axi_araddr_o = id_axi_araddr_i;
				//ex_axi_arvalid  = 1'b1 ;
				case(funct3)
					`INST_LD:begin
						reg_wdata = ram_data_i;
						reg_waddr = rd_addr_i ;
						reg_we    = 1'b1      ;
					end
					`INST_LW:begin
						reg_waddr = rd_addr_i;
						reg_we    = 1'b1     ;
						case(load_index[2])
							1'b0:begin
								reg_wdata = {{32{ram_data_i[31]}},ram_data_i[31:0]};
							end
							1'b1:begin
								reg_wdata = {{32{ram_data_i[63]}},ram_data_i[63:32]};
							end
						endcase
					end
					`INST_LH:begin
						reg_waddr = rd_addr_i;
						reg_we    = 1'b1     ;
						case(load_index[2:1])
							2'b00:begin
								reg_wdata = {{48{ram_data_i[15]}},ram_data_i[15:0]};
							end
							2'b01:begin
								reg_wdata = {{48{ram_data_i[31]}},ram_data_i[31:16]};
							end
							2'b10:begin
								reg_wdata = {{48{ram_data_i[47]}},ram_data_i[47:32]};
							end
							2'b11:begin
								reg_wdata = {{48{ram_data_i[63]}},ram_data_i[63:48]};
							end
						endcase
					end
					`INST_LB:begin
						reg_waddr = rd_addr_i;
						reg_we    = 1'b1     ;
						case(load_index[2:0])
							3'b000:begin
								reg_wdata = {{56{ram_data_i[7]}} ,ram_data_i[7 :0]};
							end
							3'b001:begin
								reg_wdata = {{56{ram_data_i[15]}},ram_data_i[15:8]};
							end
							3'b010:begin
								reg_wdata = {{56{ram_data_i[23]}},ram_data_i[23:16]};
							end
							3'b011:begin
								reg_wdata = {{56{ram_data_i[31]}},ram_data_i[31:24]};
							end
							3'b100:begin
								reg_wdata = {{56{ram_data_i[39]}},ram_data_i[39:32]};
							end
							3'b101:begin
								reg_wdata = {{56{ram_data_i[47]}},ram_data_i[47:40]};
							end
							3'b110:begin
								reg_wdata = {{56{ram_data_i[55]}},ram_data_i[55:48]};
							end
							3'b111:begin
								reg_wdata = {{56{ram_data_i[63]}},ram_data_i[63:56]};
							end
						endcase
					end
					`INST_LBU:begin
						reg_waddr = rd_addr_i;
						reg_we    = 1'b1     ;
						case(load_index[2:0])
							3'b000:begin
								reg_wdata = {{56{1'b0}} ,ram_data_i[7 :0]};
							end
							3'b001:begin
								reg_wdata = {{56{1'b0}},ram_data_i[15:8]};
							end
							3'b010:begin
								reg_wdata = {{56{1'b0}},ram_data_i[23:16]};
							end
							3'b011:begin
								reg_wdata = {{56{1'b0}},ram_data_i[31:24]};
							end
							3'b100:begin
								reg_wdata = {{56{1'b0}},ram_data_i[39:32]};
							end
							3'b101:begin
								reg_wdata = {{56{1'b0}},ram_data_i[47:40]};
							end
							3'b110:begin
								reg_wdata = {{56{1'b0}},ram_data_i[55:48]};
							end
							3'b111:begin
								reg_wdata = {{56{1'b0}},ram_data_i[63:56]};
							end
						endcase
					end
					`INST_LHU:begin
						reg_waddr = rd_addr_i;
						reg_we    = 1'b1     ;
						case(load_index[2:1])
							2'b00:begin
								reg_wdata = {{48{1'b0}},ram_data_i[15:0]};
							end
							2'b01:begin
								reg_wdata = {{48{1'b0}},ram_data_i[31:16]};
							end
							2'b10:begin
								reg_wdata = {{48{1'b0}},ram_data_i[47:32]};
							end
							2'b11:begin
								reg_wdata = {{48{1'b0}},ram_data_i[63:48]};
							end
						endcase
					end
					`INST_LWU:begin
						reg_waddr = rd_addr_i;
						reg_we    = 1'b1     ;
						case(load_index[2])
							1'b0:begin
								reg_wdata = {{32{1'b0}},ram_data_i[31:0 ]};
							end
							1'b1:begin
								reg_wdata = {{32{1'b0}},ram_data_i[63:32]};
							end
						endcase
					end
					default:begin
						reg_wdata = 64'b0;
						reg_waddr = 5'b0 ;
						reg_we    = 1'b0 ;
					end
				endcase
			end*/
			`INST_TYPE_B:begin
				reg_wdata       = 64'b0;
				reg_waddr       = 5'b0 ;
				reg_we          = 1'b0 ;
				//ram_we_o        = 1'b0 ;
				//ram_addr_o      = 64'b0;
				//ram_req_o       = 1'b0 ;
				//ram_data_o      = 64'b0;
				csr_wdata_o     = 64'b0;
				//check_ram_req_o = 1'b0 ;
				//ex_axi_arvalid  = 1'b0 ;
				case(funct3)
					`INST_BNE:begin
						jump_addr = base_addr_add_addr_offset;
						jump_flag = ~op1_i_equal_op2_i       ;
						hold_flag = 1'b0                     ;
					end
					`INST_BEQ:begin
						jump_addr = base_addr_add_addr_offset;
						jump_flag = op1_i_equal_op2_i        ;
						hold_flag = 1'b0                     ;
					end
					`INST_BLT:begin
						jump_addr = base_addr_add_addr_offset;
						jump_flag = op1_i_less_op2_i_signed  ;
						hold_flag = 1'b0                     ;
					end
					`INST_BGE:begin
						jump_addr = base_addr_add_addr_offset;
						jump_flag = ~op1_i_less_op2_i_signed ;
						hold_flag = 1'b0                     ;
					end
					`INST_BLTU:begin
						jump_addr = base_addr_add_addr_offset;
						jump_flag = op1_i_less_op2_i_unsigned;
						hold_flag = 1'b0                     ;
					end
					`INST_BGEU:begin
						jump_addr = base_addr_add_addr_offset ;
						jump_flag = ~op1_i_less_op2_i_unsigned;
						hold_flag = 1'b0                      ;
					end
					default:begin
						jump_addr = 64'b0;
						jump_flag = 1'b0 ;
						hold_flag = 1'b0 ;
					end
				endcase
			end
			`INST_TYPE_64IW:begin
				jump_addr       = 64'b0;
				jump_flag       = 1'b0 ;
				hold_flag       = 1'b0 ;
				//ram_we_o        = 1'b0 ;
				//ram_addr_o      = 64'b0;
				//ram_req_o       = 1'b0 ;
				//ram_data_o      = 64'b0;
				csr_wdata_o     = 64'b0;
				//check_ram_req_o = 1'b0 ;
				//ex_axi_arvalid  = 1'b0 ;
				case(funct3)
					`INST_ADDIW:begin
						reg_wdata = {{32{op1_i_add_op2_i[31]}},op1_i_add_op2_i[31:0]};
						reg_waddr = rd_addr_i                                        ;
						reg_we    = 1'b1                                             ;
					end
					`INST_SLLIW:begin
						reg_wdata = {{32{sli_shift[31]}},sli_shift[31:0]};
						reg_waddr = rd_addr_i                            ;
						reg_we    = 1'b1                                 ;
					end
					`INST_SRIW:begin
						if(funct7[5] == 1'b1) begin
							reg_wdata = {{32{op1_lower32bit_rashift[31]}},op1_lower32bit_rashift};
							reg_waddr = rd_addr_i                                                ;
							reg_we    = 1'b1                                                     ;
						end
						else begin
							reg_wdata = {{32{op1_lower32bit_rlshift[31]}},op1_lower32bit_rlshift};
							reg_waddr = rd_addr_i                                                ;
							reg_we    = 1'b1                                                     ;
						end
					end
					default:begin
						reg_wdata = 64'b0;
						reg_waddr = 5'b0 ;
						reg_we    = 1'b0 ;
					end
				endcase
			end
			`INST_TYPE_R_M_64W:begin
				jump_addr       = 64'b0;
				jump_flag       = 1'b0 ;
				hold_flag       = 1'b0 ;
				//ram_we_o        = 1'b0 ;
				//ram_addr_o      = 64'b0;
				//ram_req_o       = 1'b0 ;
				//ram_data_o      = 64'b0;
				csr_wdata_o     = 64'b0;
				//check_ram_req_o = 1'b0 ;
				//ex_axi_arvalid  = 1'b0 ;
				case(funct3)
					`INST_ADD_SUB_MULW:begin
						if(funct7 == 7'b0100000) begin     //-
							reg_wdata = {{32{op1_i_sub_op2_i[31]}},op1_i_sub_op2_i[31:0]};
							reg_waddr = rd_addr_i                                        ;
							reg_we    = 1'b1                                             ;
						end
						else if(funct7 == 7'b0000000) begin//+
							reg_wdata = {{32{op1_i_add_op2_i[31]}},op1_i_add_op2_i[31:0]};
							reg_waddr = rd_addr_i                                        ;
							reg_we    = 1'b1                                             ;
						end
						else begin
							reg_wdata = 64'b0;
							reg_waddr = 5'b0 ;
							reg_we    = 1'b0 ;
						end
					end
					`INST_SLLW:begin
						reg_wdata = {{32{sllw_temp[31]}},sllw_temp};
						reg_waddr = rd_addr_i                      ;
						reg_we    = 1'b1                           ;
					end
					`INST_SRW_DIVUW:begin
						if(funct7 == 7'b0100000) begin
							reg_wdata = {{32{op1_lower32bit_srawshift[31]}},op1_lower32bit_srawshift[31:0]};
							reg_waddr = rd_addr_i                                                          ;
							reg_we    = 1'b1                                                               ;
						end
						else if(funct7 == 7'b0000000) begin
							reg_wdata = {{32{op1_lower32bit_srlwshift[31]}},op1_lower32bit_srlwshift[31:0]};
							reg_waddr = rd_addr_i                                                          ;
							reg_we    = 1'b1                                                               ;
						end
						else begin
							reg_wdata = 64'b0;
							reg_waddr = 5'b0 ;
							reg_we    = 1'b0 ;
						end
					end
					default:begin
						reg_wdata = 64'b0;
						reg_waddr = 5'b0 ;
						reg_we    = 1'b0 ;
					end
				endcase
			end
			`INST_TYPE_R_M:begin
				jump_addr       = 64'b0;
				jump_flag       = 1'b0 ;
				hold_flag       = 1'b0 ;
				//ram_we_o        = 1'b0 ;
				//ram_addr_o      = 64'b0;
				//ram_req_o       = 1'b0 ;
				//ram_data_o      = 64'b0;
				csr_wdata_o     = 64'b0;
				//check_ram_req_o = 1'b0 ;
				//ex_axi_arvalid  = 1'b0 ;
				if((funct7 == 7'b0000000) || (funct7 == 7'b0100000)) begin
					case(funct3)
						`INST_ADD_SUB:begin
							if(funct7 == 7'b000_0000) begin
								reg_wdata = op1_i_add_op2_i;
								reg_waddr = rd_addr_i      ;
								reg_we    = 1'b1           ;
							end
							else begin
								reg_wdata = op1_i_sub_op2_i;
								reg_waddr = rd_addr_i      ;
								reg_we    = 1'b1           ;
							end
						end
						`INST_SLL:begin
							reg_wdata = op1_i_shift_left_op2_i;
							reg_waddr = rd_addr_i             ;
							reg_we    = 1'b1                  ;
						end
						`INST_SLT:begin
							reg_wdata = {63'b0,op1_i_less_op2_i_signed};
							reg_waddr = rd_addr_i                      ;
							reg_we    = 1'b1                           ;
						end
						`INST_SLTU:begin
							reg_wdata = {63'b0,op1_i_less_op2_i_unsigned};
							reg_waddr = rd_addr_i                        ;
							reg_we    = 1'b1                             ;
						end
						`INST_XOR:begin
							reg_wdata = op1_i_xor_op2_i;
							reg_waddr = rd_addr_i      ;
							reg_we    = 1'b1           ;
						end
						`INST_OR:begin
							reg_wdata = op1_i_or_op2_i;
							reg_waddr = rd_addr_i     ;
							reg_we    = 1'b1          ;
						end
						`INST_AND:begin
							reg_wdata = op1_i_and_op2_i;
							reg_waddr = rd_addr_i      ;
							reg_we    = 1'b1           ;
						end
						`INST_SR:begin
							if(funct7[5] == 1'b1) begin //sra
								reg_wdata = ((op1_i_shift_right_op2_i) & SRA_mask) | ({64{op1_i[31]}} & (~SRA_mask));
								reg_waddr = rd_addr_i                                                               ;
								reg_we    = 1'b1                                                                    ;
							end
							else begin//srl
								reg_wdata = op1_i_shift_right_op2_i;
								reg_waddr = rd_addr_i              ;
								reg_we    = 1'b1                   ;
							end
						end
						default:begin
							reg_wdata = 64'b0;
							reg_waddr = 5'b0 ;
							reg_we    = 1'b0 ;
						end
					endcase
				end
				else begin
					reg_wdata = 64'b0;
					reg_waddr = 5'b0 ;
					reg_we    = 1'b0 ;
				end
			end
			`INST_JAL:begin
				reg_wdata       = op1_i_add_op2_i          ;
				reg_waddr       = rd_addr_i                ;
				reg_we          = 1'b1                     ;
				jump_addr       = base_addr_add_addr_offset;
				jump_flag       = 1'b1                     ;
				hold_flag       = 1'b0                     ;
				//ram_we_o        = 1'b0                     ;
				//ram_addr_o      = 64'b0                    ;
				//ram_req_o       = 1'b0                     ;
				//ram_data_o      = 64'b0                    ;
				csr_wdata_o     = 64'b0                    ;
				//check_ram_req_o = 1'b0                     ;
				//ex_axi_arvalid  = 1'b0                     ;
			end
			`INST_JALR:begin
				reg_wdata       = op1_i_add_op2_i          ;
				reg_waddr       = rd_addr_i                ;
				reg_we          = 1'b1                     ;
				jump_addr       = base_addr_add_addr_offset;
				jump_flag       = 1'b1                     ;
				hold_flag       = 1'b0                     ;
				//ram_we_o        = 1'b0                     ;
				//ram_addr_o      = 64'b0                    ;
				//ram_req_o       = 1'b0                     ;
				//ram_data_o      = 64'b0                    ;
				csr_wdata_o     = 64'b0                    ;
				//check_ram_req_o = 1'b0                     ;
				//ex_axi_arvalid  = 1'b0                     ;
			end
			`INST_LUI:begin
				reg_wdata       = op1_i    ;
				reg_waddr       = rd_addr_i;
				reg_we          = 1'b1     ;
				jump_addr       = 64'b0    ;
				jump_flag       = 1'b0     ;
				hold_flag       = 1'b0     ;
				//ram_we_o        = 1'b0     ;
				//ram_addr_o      = 64'b0    ;
				//ram_req_o       = 1'b0     ;
				//ram_data_o      = 64'b0    ;
				csr_wdata_o     = 64'b0    ;
				//check_ram_req_o = 1'b0     ;
				//ex_axi_arvalid  = 1'b0     ;
			end
			`INST_AUIPC:begin
				reg_wdata       = op1_i_add_op2_i;
				reg_waddr       = rd_addr_i      ;
				reg_we          = 1'b1           ;
				jump_addr       = 64'b0          ;
				jump_flag       = 1'b0           ;
				hold_flag       = 1'b0           ;
				//ram_we_o        = 1'b0           ;
				//ram_addr_o      = 64'b0          ;
				//ram_req_o       = 1'b0           ;
				//ram_data_o      = 64'b0          ;
				csr_wdata_o     = 64'b0          ;
				//check_ram_req_o = 1'b0           ;
				//ex_axi_arvalid  = 1'b0           ;
			end
			`INST_CSR:begin
				jump_addr       = 64'b0;
				jump_flag       = 1'b0 ;
				hold_flag       = 1'b0 ;
				//ram_we_o        = 1'b0 ;
				//ram_addr_o      = 64'b0;
				//ram_req_o       = 1'b0 ;
				//ram_data_o      = 64'b0;
				//check_ram_req_o = 1'b0 ;
				//ex_axi_arvalid  = 1'b0 ;
				case(funct3)
					`INST_CSRRW:begin
						csr_wdata_o = op1_i      ;
						reg_wdata   = csr_rdata_i;
						reg_waddr   = rd_addr_i  ;
						reg_we      = 1'b1       ;
					end
					`INST_CSRRS:begin
						csr_wdata_o = op1_i | csr_rdata_i;
						reg_wdata   = csr_rdata_i        ;
						reg_waddr   = rd_addr_i          ;
						reg_we      = 1'b1               ;
					end
					`INST_CSRRC:begin
						csr_wdata_o = op1_i & (~csr_rdata_i);
						reg_wdata   = csr_rdata_i           ;
						reg_waddr   = rd_addr_i             ;
						reg_we      = 1'b1                  ;
					end
					`INST_CSRRWI:begin
						csr_wdata_o = {59'b0,uimm};
						reg_wdata   = csr_rdata_i ;
						reg_waddr   = rd_addr_i   ;
						reg_we      = 1'b1        ;
					end
					`INST_CSRRSI:begin
						csr_wdata_o = {59'b0,uimm} | csr_rdata_i;
						reg_wdata   = csr_rdata_i               ;
						reg_waddr   = rd_addr_i                 ;
						reg_we      = 1'b1                      ;
					end
					`INST_CSRRCI:begin
						csr_wdata_o = (~{59'b0,uimm}) & csr_rdata_i;
						reg_wdata   = csr_rdata_i                  ;
						reg_waddr   = rd_addr_i                    ;
						reg_we      = 1'b1                         ;
					end
					default:begin
						csr_wdata_o = 64'b0;
						reg_wdata   = 64'b0;
						reg_waddr   = 5'b0 ;
						reg_we      = 1'b0 ;
					end
				endcase
			end
			default:begin
				//check_ram_req_o = 1'b0 ;
				reg_wdata       = 64'b0;
				reg_waddr       = 5'b0 ;
				reg_we          = 1'b0 ;
				jump_addr       = 64'b0;
				jump_flag       = 1'b0 ;
				hold_flag       = 1'b0 ;
				//ram_we_o        = 1'b0 ;
				//ram_addr_o      = 64'b0;
				//ram_req_o       = 1'b0 ;
				//ram_data_o      = 64'b0;
				csr_wdata_o     = 64'b0;
				//ex_axi_arvalid  = 1'b0 ;
			end
		endcase
	end
	
endmodule


