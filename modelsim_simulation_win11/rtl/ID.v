`include "defines.v"

module ID
(
	//from if_id
	input wire [63:0] inst_addr_i     ,
	input wire [31:0] rom_inst_i      ,
	//to regs check                         
	output reg [4 :0] rs1_addr_o      ,
	output reg [4 :0] rs2_addr_o      ,
	//from regs                    
	input wire [63:0] regs_rs1_data_i ,
	input wire [63:0] regs_rs2_data_i ,
	//from check 
	input wire [63:0] chack_rs1_data_i,
	input wire [63:0] chack_rs2_data_i,
	input wire        rs1_valid       ,
	input wire        rs2_valid       ,
	//to id_ex clint                
	output reg [63:0] base_addr_o     ,
	output reg [63:0] addr_offset_o   ,
	output reg [31:0] inst_o          ,
	output reg [63:0] inst_addr_o     ,
	output reg [63:0] op1_o           ,
	output reg [63:0] op2_o           ,
	output reg [4 :0] rd_addr_o       ,
	output reg        reg_wen         ,
	output reg        csr_we_o        ,
	output reg [63:0] csr_rdata_o     ,
	output reg [63:0] csr_waddr_o     ,
	output reg [31:0] id_axi_araddr   ,
	output reg        read_ram        ,
	output reg        write_ram       ,
	//to csr reg 
	output reg [63:0] csr_raddr_o     ,
	//from csr reg 
	input  wire [63:0] csr_rdata_i    ,
	//from clint
	input  wire        int_assert_i   
);
	
	wire [31:0] inst_i;
	wire [6 :0] opcode;
	wire [4 :0] rd    ;
	wire [2 :0] funct3;
	wire [4 :0] rs1   ;
	wire [4 :0] rs2   ;
	wire [6 :0] funct7;
	wire [11:0] imm   ;
	wire [5 :0] shamt ;

	reg [63:0] base_addr_add_addr_offset;
	
	assign inst_i = rom_inst_i;
	
	assign opcode = inst_i[6 :0 ];
	assign rd     = inst_i[11:7 ];
	assign funct3 = inst_i[14:12];
	assign rs1    = inst_i[19:15];
	assign rs2    = inst_i[24:20];
	assign funct7 = inst_i[31:25];
	assign imm    = inst_i[31:20];
	assign shamt  = inst_i[25:20];
	
	wire [63:0] rs1_data_i;
	wire [63:0] rs2_data_i;
	
	assign rs1_data_i = (rs1_valid == 1'b1)?chack_rs1_data_i:regs_rs1_data_i;
	assign rs2_data_i = (rs2_valid == 1'b1)?chack_rs2_data_i:regs_rs2_data_i;

	//reg id_axi_arvalid_temp;

	//assign id_axi_arvalid = (int_assert_i == 1'b1) ? 1'b0 : id_axi_arvalid_temp;

	//assign id_axi_rready = 1'b1;
	
	always @(*)
		begin
			inst_o      = inst_i     ;
			inst_addr_o = inst_addr_i;
			csr_rdata_o = csr_rdata_i;
			
			case(opcode)
				`INST_TYPE_I:begin
					base_addr_o         = 64'b0;
					addr_offset_o       = 64'b0;
					csr_raddr_o         = 64'b0;
					csr_waddr_o         = 64'b0;
					csr_we_o            = 1'b0 ;
					//id_axi_arvalid_temp = 1'b0 ;
					id_axi_araddr       = 32'b0;
					read_ram            = 1'b0 ;
					write_ram           = 1'b0 ;
					case(funct3)
						`INST_ADDI,`INST_SLTI,`INST_SLTIU,`INST_XORI,`INST_ORI,`INST_ANDI:begin
							rs1_addr_o = rs1                ;
							rs2_addr_o = 5'b0               ;
							op1_o      = rs1_data_i         ;
							op2_o      = {{52{imm[11]}},imm};
							rd_addr_o  = rd                 ;
							reg_wen    = 1'b1               ;
						end
						`INST_SLLI,`INST_SRI:begin
							rs1_addr_o = rs1          ;
							rs2_addr_o = 5'b0         ;
							op1_o      = rs1_data_i   ;
							op2_o      = {58'b0,shamt};
							rd_addr_o  = rd           ;
							reg_wen    = 1'b1         ;
						end
						default:begin
							rs1_addr_o = 5'b0 ;
							rs2_addr_o = 5'b0 ;
							op1_o 	   = 64'b0;
							op2_o      = 64'b0;
							rd_addr_o  = 5'b0 ;
							reg_wen    = 1'b0 ;	
						end
					endcase
				end
				`INST_TYPE_L:begin
					csr_raddr_o         = 64'b0;
					csr_waddr_o         = 64'b0;
					csr_we_o            = 1'b0 ;
					read_ram            = 1'b1 ;
					write_ram           = 1'b0 ;
					//id_axi_arvalid_temp = 1'b1 ;
					case(funct3)
						`INST_LB,`INST_LH,`INST_LW,`INST_LD,`INST_LBU,`INST_LHU,`INST_LWU:begin
							rs1_addr_o                = rs1                                    ;
							rs2_addr_o                = 5'b0                                   ;
							op1_o                     = 64'b0                                  ;
							op2_o                     = 64'b0                                  ;
							rd_addr_o                 = rd                                     ;
							reg_wen                   = 1'b1                                   ;
							base_addr_o               = rs1_data_i                             ;
							addr_offset_o             = {{52{imm[11]}},imm}                    ;
							base_addr_add_addr_offset = rs1_data_i + {{52{imm[11]}},imm}       ;
							id_axi_araddr             = {1'b1, base_addr_add_addr_offset[30:0]};
						end
						default:begin
							rs1_addr_o    = 5'b0 ;
							rs2_addr_o    = 5'b0 ;
							op1_o 	      = 64'b0;
							op2_o         = 64'b0;
							rd_addr_o     = 5'b0 ;
							reg_wen       = 1'b0 ;	
							base_addr_o   = 64'b0;
							addr_offset_o = 64'b0;
							id_axi_araddr = 32'b0;
						end
					endcase
				end
				`INST_TYPE_B:begin
					csr_raddr_o         = 64'b0;
					csr_waddr_o         = 64'b0;
					csr_we_o            = 1'b0 ;
					//id_axi_arvalid_temp = 1'b0 ;
					id_axi_araddr       = 32'b0;
					read_ram            = 1'b0 ;
					write_ram           = 1'b0 ;
					case(funct3)
						`INST_BEQ,`INST_BNE,`INST_BLT,`INST_BGE,`INST_BLTU,`INST_BGEU:begin
							rs1_addr_o    = rs1                                                                    ;
							rs2_addr_o    = rs2                                                                    ;
							op1_o         = rs1_data_i                                                             ;
							op2_o         = rs2_data_i                                                             ;
							rd_addr_o     = 5'b0                                                                   ;
							reg_wen       = 1'b0                                                                   ;
							base_addr_o   = inst_addr_i                                                            ;
							addr_offset_o = {{51{inst_i[31]}},inst_i[31],inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
						end
						default:begin
							rs1_addr_o    = 5'b0 ;
							rs2_addr_o    = 5'b0 ;
							op1_o 	      = 64'b0;
							op2_o         = 64'b0;
							rd_addr_o     = 5'b0 ;
							reg_wen       = 1'b0 ;	
							base_addr_o   = 64'b0;
							addr_offset_o = 64'b0;
						end
					endcase
				end
				`INST_TYPE_S:begin
					csr_raddr_o         = 64'b0;
					csr_waddr_o         = 64'b0;
					csr_we_o            = 1'b0 ;
					read_ram            = 1'b0 ;
					write_ram           = 1'b1 ;
					//id_axi_arvalid_temp = 1'b0 ;
					//id_axi_araddr       = 32'b0;
					case(funct3)
						`INST_SW,`INST_SH,`INST_SB,`INST_SD:begin
							rs1_addr_o                = rs1                                                       ;
							rs2_addr_o                = rs2                                                       ;
							op1_o                     = 64'b0                                                     ;
							op2_o                     = rs2_data_i                                                ;
							rd_addr_o                 = 5'b0                                                      ;
							reg_wen                   = 1'b0                                                      ;
							base_addr_o               = rs1_data_i                                                ;
							addr_offset_o             = {{52{inst_i[31]}},inst_i[31:25],inst_i[11:7]}             ;
							base_addr_add_addr_offset = rs1_data_i + {{52{inst_i[31]}},inst_i[31:25],inst_i[11:7]};
							id_axi_araddr             = {1'b1, base_addr_add_addr_offset[30:0]}                   ;
						end
						default:begin   
							rs1_addr_o    = 5'b0 ;
							rs2_addr_o    = 5'b0 ;
							op1_o 	      = 64'b0;
							op2_o         = 64'b0;
							rd_addr_o     = 5'b0 ;
							reg_wen       = 1'b0 ;	
							base_addr_o   = 64'b0;
							addr_offset_o = 64'b0;
							id_axi_araddr = 32'b0;
						end
					endcase
				end
				`INST_TYPE_R_M:begin
					csr_raddr_o         = 64'b0;
					csr_waddr_o         = 64'b0;
					csr_we_o            = 1'b0 ;
					//id_axi_arvalid_temp = 1'b0 ;
					id_axi_araddr       = 32'b0;
					read_ram            = 1'b0 ;
					write_ram           = 1'b0 ;
					if((funct7 == 7'b0000000) || (funct7 == 7'b0100000)) begin
						case(funct3)
							`INST_ADD_SUB,`INST_SLT,`INST_SLTU,`INST_XOR,`INST_OR,`INST_AND:begin
								rs1_addr_o    = rs1       ;
								rs2_addr_o    = rs2       ;
								op1_o         = rs1_data_i;
								op2_o         = rs2_data_i;
								rd_addr_o     = rd        ;
								reg_wen       = 1'b1      ;
								base_addr_o   = 64'b0     ;
								addr_offset_o = 64'b0     ;  
							end
							`INST_SLL,`INST_SR:begin
								rs1_addr_o    = rs1                    ;
								rs2_addr_o    = rs2                    ;
								op1_o         = rs1_data_i             ;
								op2_o         = {58'b0,rs2_data_i[5:0]};
								rd_addr_o     = rd                     ;
								reg_wen       = 1'b1                   ;
								base_addr_o   = 64'b0                  ;
								addr_offset_o = 64'b0                  ;  
							end
							default:begin
								rs1_addr_o    = 5'b0 ;
								rs2_addr_o    = 5'b0 ;
								op1_o 	      = 64'b0;
								op2_o         = 64'b0;
								rd_addr_o     = 5'b0 ;
								reg_wen       = 1'b0 ;	
								base_addr_o   = 64'b0;
								addr_offset_o = 64'b0;  
							end
						endcase
					end
					else if(funct7 == 7'b0000001) begin
						case(funct3)
							`INST_MUL,`INST_MULH,`INST_MULHSU,`INST_MULHU,`INST_DIV,`INST_DIVU,`INST_REM,`INST_REMU:begin
								rs1_addr_o    = rs1        ;
								rs2_addr_o    = rs2        ;
								op1_o         = rs1_data_i ;
								op2_o         = rs2_data_i ;
								rd_addr_o     = rd         ;
								reg_wen       = 1'b1       ;
								base_addr_o   = inst_addr_i;
								addr_offset_o = 64'h4      ;  
							end
							default:begin
								rs1_addr_o    = 5'b0 ;
								rs2_addr_o    = 5'b0 ;
								op1_o 	      = 64'b0;
								op2_o         = 64'b0;
								rd_addr_o     = 5'b0 ;
								reg_wen       = 1'b0 ;	
								base_addr_o   = 64'b0;
								addr_offset_o = 64'b0;  
							end
						endcase
					end
				end
				`INST_LUI:begin  
					rs1_addr_o          = 5'b0                                  ;
					rs2_addr_o          = 5'b0                                  ;
					op1_o 	            = {{32{inst_i[31]}},inst_i[31:12],12'b0};
					op2_o               = 64'b0                                 ;
					rd_addr_o           = rd                                    ;
					reg_wen             = 1'b1                                  ;	
					base_addr_o         = 64'b0                                 ;
					addr_offset_o       = 64'b0                                 ;
					csr_raddr_o         = 64'b0                                 ;
					csr_waddr_o         = 64'b0                                 ;
					csr_we_o            = 1'b0                                  ;
					//id_axi_arvalid_temp = 1'b0                                  ;
					id_axi_araddr       = 32'b0                                 ;
					read_ram            = 1'b0                                  ;
					write_ram           = 1'b0                                  ;
				end
				`INST_JALR:begin
					rs1_addr_o          = rs1                ;
					rs2_addr_o          = 5'b0               ;
					op1_o 	            = inst_addr_i        ;
					op2_o               = 64'h4              ;
					rd_addr_o           = rd                 ;
					reg_wen             = 1'b1               ;	
					base_addr_o         = rs1_data_i         ;
					addr_offset_o       = {{52{imm[11]}},imm};
					csr_raddr_o         = 64'b0              ;
					csr_waddr_o         = 64'b0              ;
					csr_we_o            = 1'b0               ;
					//id_axi_arvalid_temp = 1'b0               ;
					id_axi_araddr       = 32'b0              ;
					read_ram            = 1'b0               ;
					write_ram           = 1'b0               ;
				end
				`INST_AUIPC:begin  
					rs1_addr_o          = 5'b0                                  ;
					rs2_addr_o          = 5'b0                                  ;
					op1_o 	            = {{32{inst_i[31]}},inst_i[31:12],12'b0};
					op2_o               = inst_addr_i                           ;
					rd_addr_o           = rd                                    ;
					reg_wen             = 1'b1                                  ;	
					base_addr_o         = 64'b0                                 ;
					addr_offset_o       = 64'b0                                 ;
					csr_raddr_o         = 64'b0                                 ;
					csr_waddr_o         = 64'b0                                 ;
					csr_we_o            = 1'b0                                  ;
					//id_axi_arvalid_temp = 1'b0                                  ;
					id_axi_araddr       = 32'b0                                 ;
					read_ram            = 1'b0                                  ;
					write_ram           = 1'b0                                  ;
				end
				`INST_JAL:begin
					rs1_addr_o          = 5'b0                                                              ;
					rs2_addr_o          = 5'b0                                                              ;
					op1_o 	            = inst_addr_i                                                       ;
					op2_o               = 64'h4                                                             ;
					rd_addr_o           = rd                                                                ;
					reg_wen             = 1'b1                                                              ;	
					base_addr_o         = inst_addr_i                                                       ;
					addr_offset_o       = {{44{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
					csr_raddr_o         = 64'b0                                                             ;
					csr_waddr_o         = 64'b0                                                             ;
					csr_we_o            = 1'b0                                                              ;
					//id_axi_arvalid_temp = 1'b0                                                              ;
					id_axi_araddr       = 32'b0                                                             ;
					read_ram            = 1'b0                                                              ;
					write_ram           = 1'b0                                                              ;
				end
				`INST_TYPE_R_M_64W:begin
					csr_raddr_o         = 64'b0;
					csr_waddr_o         = 64'b0;
					csr_we_o            = 1'b0 ;
					//id_axi_arvalid_temp = 1'b0 ;
					id_axi_araddr       = 32'b0;
					read_ram            = 1'b0 ;
					write_ram           = 1'b0 ;
					case(funct3)
						`INST_ADD_SUB_MULW,`INST_SLLW,`INST_SRW_DIVUW,`INST_DIVW,`INST_REMW,`INST_REMUW:begin
							rs1_addr_o = rs1           ;
							rs2_addr_o = rs2           ;
							op1_o      = rs1_data_i    ;
							op2_o      = rs2_data_i    ;
							rd_addr_o  = rd            ;
							reg_wen    = 1'b1          ;
							base_addr_o   = inst_addr_i;
							addr_offset_o = 64'h4      ;  
						end
						default:begin
							rs1_addr_o    = 5'b0 ;
							rs2_addr_o    = 5'b0 ;
							op1_o 	      = 64'b0;
							op2_o         = 64'b0;
							rd_addr_o     = 5'b0 ;
							reg_wen       = 1'b0 ;	
							base_addr_o   = 64'b0;
							addr_offset_o = 64'b0;
						end
					endcase
				end
				`INST_TYPE_64IW:begin
					base_addr_o         = 64'b0;
					addr_offset_o       = 64'b0; 
					csr_raddr_o         = 64'b0;
					csr_waddr_o         = 64'b0;
					csr_we_o            = 1'b0 ;
					//id_axi_arvalid_temp = 1'b0 ;
					id_axi_araddr       = 32'b0;
					read_ram            = 1'b0 ;
					write_ram           = 1'b0 ;
					case(funct3)
						`INST_ADDIW,`INST_SLLIW,`INST_SRIW:begin
							rs1_addr_o = rs1                ;
							rs2_addr_o = 5'b0               ;
							op1_o      = rs1_data_i         ;
							op2_o      = {{52{imm[11]}},imm};
							rd_addr_o  = rd                 ;
							reg_wen    = 1'b1               ;
						end
						default:begin
							rs1_addr_o = 5'b0 ;
							rs2_addr_o = 5'b0 ;
							op1_o 	   = 64'b0;
							op2_o      = 64'b0;
							rd_addr_o  = 5'b0 ;
							reg_wen    = 1'b0 ;	
						end
					endcase
				end
				`INST_CSR:begin
					base_addr_o         = 64'b0                 ;
					addr_offset_o       = 64'b0                 ;  
					csr_raddr_o         = {52'h0, inst_i[31:20]};
					csr_waddr_o         = {52'h0, inst_i[31:20]};
					//id_axi_arvalid_temp = 1'b0                  ;
					id_axi_araddr       = 32'b0                 ;
					read_ram            = 1'b0                  ;
					write_ram           = 1'b0                  ;
					case(funct3)
						`INST_CSRRW,`INST_CSRRS,`INST_CSRRC:begin
							rs1_addr_o = rs1       ;
							rs2_addr_o = 5'b0      ;
							op1_o      = rs1_data_i;
							op2_o      = 64'b0     ;
							rd_addr_o  = rd        ;
							reg_wen    = 1'b1      ;
							csr_we_o   = 1'b1      ;
						end
						`INST_CSRRWI,`INST_CSRRSI,`INST_CSRRCI:begin
							rs1_addr_o = 5'b0 ;
							rs2_addr_o = 5'b0 ;
							op1_o      = 64'b0;
							op2_o      = 64'b0;
							rd_addr_o  = rd   ;
							reg_wen    = 1'b1 ;
							csr_we_o   = 1'b1 ;
						end
						default:begin
							rs1_addr_o = 5'b0 ;
							rs2_addr_o = 5'b0 ;
							op1_o      = 64'b0;
							op2_o      = 64'b0;
							rd_addr_o  = 5'b0 ;
							reg_wen    = 1'b0 ;
							csr_we_o   = 1'b0 ;
						end
					endcase
				end
				default:begin 
					rs1_addr_o          = 5'b0 ;
					rs2_addr_o          = 5'b0 ;
					op1_o 	            = 64'b0;
					op2_o               = 64'b0;
					rd_addr_o           = 5'b0 ;
					reg_wen             = 1'b0 ;	
					base_addr_o         = 64'b0;
					addr_offset_o       = 64'b0;
					csr_raddr_o         = 64'b0;
					csr_waddr_o         = 64'b0;
					csr_we_o            = 1'b0 ;
					//id_axi_arvalid_temp = 1'b0 ;
					id_axi_araddr       = 32'b0;
					read_ram            = 1'b0 ;
					write_ram           = 1'b0 ;
				end
			endcase
		end

endmodule


