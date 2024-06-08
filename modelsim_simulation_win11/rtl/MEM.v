`include "defines.v"

module MEM
(
	input wire [4 :0]  rd_addr_i      ,
	input wire [63:0]  rd_data_i      ,
	input wire         rd_wen_i       ,
	input wire         read_ram_i     ,
	input wire         write_ram_i    ,
	input wire [31:0]  inst_i         ,
	input wire [63:0]  inst_addr_i    ,
	input wire [31:0]  id_axi_araddr_i,
	input wire [63:0]  op2_i          ,
	//to mem_wb check
	output reg [4 :0] rd_addr_o      ,
	output reg [63:0] rd_data_o      ,
	output reg        rd_wen_o       ,
	//from clint
	input  wire       int_assert_i   ,
	//to ctrl
	output reg        hold_flag_mem_o, 
	//D-Cache访问接口
	//to dcache
	output reg [11:0]  dcache_req_addr  ,
	output reg         dcache_req_valid ,
	output reg         dcache_req_rw    ,
	output reg [63:0]  dcache_data_write,
	//from dcache
	input wire [63:0]  dcache_data_read,
	input wire         dcache_ready    ,
	input wire         dcache_hit
);

	wire [6 :0] opcode;
	wire [2 :0] funct3;
	wire [4 :0] rd    ;

	assign opcode = inst_i[6 :0 ];
	assign funct3 = inst_i[14:12];
	assign rd     = inst_i[11:7 ];

	wire [2:0] store_index = id_axi_araddr_i[2:0];
	wire [2:0] load_index  = id_axi_araddr_i[2:0];

	//assign hold_flag_mem_o = (dcache_hit == 1'b1) ? 1'b0:1'b1;

	always @(*) begin
		case(opcode)
			`INST_TYPE_S:begin
				rd_addr_o = 5'b0 ;
				rd_wen_o  = 1'b0 ;
				rd_data_o = 64'b0;
				hold_flag_mem_o  = (dcache_hit == 1'b1 && dcache_ready== 1'b0) ? 1'b0:1'b1;
				dcache_req_valid = (dcache_hit == 1'b0 && dcache_ready == 1'b1) ? 1'b0:1'b1;
				case(funct3)
					`INST_SD:begin
						dcache_req_rw     = 1'b1                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						dcache_data_write = op2_i                ;
					end
					`INST_SW:begin
						dcache_req_rw     = 1'b1                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						case(store_index[2])
							1'b0:begin
								dcache_data_write = {32'b0,op2_i[31:0]};
							end
							1'b1:begin
								dcache_data_write = {op2_i[31:0],32'b0};
							end
						endcase
					end
					`INST_SH:begin
						dcache_req_rw     = 1'b1                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						case(store_index[2:1])
							2'b00:begin
								//dcache_data_write = {48'b0,op2_i[15:0]};
								dcache_data_write = {dcache_data_read[63:16],op2_i[15:0]};
							end
							2'b01:begin
								dcache_data_write = {dcache_data_read[63:32],op2_i[15:0],dcache_data_read[15:0]};
							end
							2'b10:begin
								dcache_data_write = {dcache_data_read[63:48],op2_i[15:0],dcache_data_read[31:0]};
							end
							2'b11:begin
								dcache_data_write = {op2_i[15:0],dcache_data_read[47:0]};
							end
						endcase
					end
					`INST_SB:begin
						dcache_req_rw     = 1'b1                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						case(store_index[2:0])
							3'b000:begin
								dcache_data_write = {dcache_data_read[63:8],op2_i[7:0]};
							end
							3'b001:begin
								dcache_data_write = {dcache_data_read[63:16],op2_i[7:0],dcache_data_read[7:0]};
							end
							3'b010:begin
								dcache_data_write = {dcache_data_read[63:24],op2_i[7:0],dcache_data_read[15:0]};
							end
							3'b011:begin
								dcache_data_write = {dcache_data_read[63:32],op2_i[7:0],dcache_data_read[23:0]};
							end
							3'b100:begin
								dcache_data_write = {dcache_data_read[63:40],op2_i[7:0],dcache_data_read[31:0]};
							end
							3'b101:begin
								dcache_data_write = {dcache_data_read[63:48],op2_i[7:0],dcache_data_read[39:0]};
							end
							3'b110:begin
								dcache_data_write = {dcache_data_read[63:56],op2_i[7:0],dcache_data_read[47:0]};
							end
							3'b111:begin
								dcache_data_write = {op2_i[7:0],dcache_data_read[55:0]};
							end
						endcase
					end
					default:begin
						dcache_req_rw     = 1'b1 ;
						dcache_req_addr   = 12'b0;
						//dcache_req_valid  = 1'b0 ;
						dcache_data_write = 64'b0;
					end
				endcase
			end
			`INST_TYPE_L:begin
				hold_flag_mem_o  = (dcache_hit == 1'b0 && dcache_ready == 1'b1) ? 1'b0:1'b1;
				dcache_req_valid = (dcache_hit == 1'b0 && dcache_ready == 1'b1) ? 1'b0:1'b1;
				case(funct3)
					`INST_LD:begin
						dcache_req_rw     = 1'b0                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						dcache_data_write = 64'b0                ;
						rd_data_o         = (dcache_ready == 1'b1) ? dcache_data_read:64'b0;
						rd_addr_o         = rd                   ;
						rd_wen_o          = 1'b1                 ;
					end
					`INST_LW:begin
						dcache_req_rw     = 1'b0                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						dcache_data_write = 64'b0                ;
						rd_addr_o         = rd                   ;
						rd_wen_o          = 1'b1                 ;
						case(load_index[2])
							1'b0:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{32{dcache_data_read[31]}},dcache_data_read[31:0]}:64'b0;
							end
							1'b1:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{32{dcache_data_read[63]}},dcache_data_read[63:32]}:64'b0;
							end
						endcase
					end
					`INST_LH:begin
						dcache_req_rw     = 1'b0                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						dcache_data_write = 64'b0                ;
						rd_addr_o         = rd                   ;
						rd_wen_o          = 1'b1                 ;
						case(load_index[2:1])
							2'b00:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{48{dcache_data_read[15]}},dcache_data_read[15:0]}:64'b0;
							end
							2'b01:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{48{dcache_data_read[31]}},dcache_data_read[31:16]}:64'b0;
							end
							2'b10:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{48{dcache_data_read[47]}},dcache_data_read[47:32]}:64'b0;
							end
							2'b11:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{48{dcache_data_read[63]}},dcache_data_read[63:48]}:64'b0;
							end
						endcase
					end
					`INST_LB:begin
						dcache_req_rw     = 1'b0                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						dcache_data_write = 64'b0                ;
						rd_addr_o         = rd                   ;
						rd_wen_o          = 1'b1                 ;
						case(load_index[2:0])
							3'b000:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{dcache_data_read[7]}} ,dcache_data_read[7 :0]}:64'b0;
							end
							3'b001:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{dcache_data_read[15]}},dcache_data_read[15:8]}:64'b0;
							end
							3'b010:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{dcache_data_read[23]}},dcache_data_read[23:16]}:64'b0;
							end
							3'b011:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{dcache_data_read[31]}},dcache_data_read[31:24]}:64'b0;
							end
							3'b100:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{dcache_data_read[39]}},dcache_data_read[39:32]}:64'b0;
							end
							3'b101:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{dcache_data_read[47]}},dcache_data_read[47:40]}:64'b0;
							end
							3'b110:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{dcache_data_read[55]}},dcache_data_read[55:48]}:64'b0;
							end
							3'b111:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{dcache_data_read[63]}},dcache_data_read[63:56]}:64'b0;
							end
						endcase
					end
					`INST_LBU:begin
						dcache_req_rw     = 1'b0                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						dcache_data_write = 64'b0                ;
						rd_addr_o         = rd                   ;
						rd_wen_o          = 1'b1                 ;
						case(load_index[2:0])
							3'b000:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{1'b0}} ,dcache_data_read[7 :0]}:64'b0;
							end
							3'b001:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{1'b0}},dcache_data_read[15:8]}:64'b0;
							end
							3'b010:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{1'b0}},dcache_data_read[23:16]}:64'b0;
							end
							3'b011:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{1'b0}},dcache_data_read[31:24]}:64'b0;
							end
							3'b100:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{1'b0}},dcache_data_read[39:32]}:64'b0;
							end
							3'b101:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{1'b0}},dcache_data_read[47:40]}:64'b0;
							end
							3'b110:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{1'b0}},dcache_data_read[55:48]}:64'b0;
							end
							3'b111:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{56{1'b0}},dcache_data_read[63:56]}:64'b0;
							end
						endcase
					end
					`INST_LHU:begin
						dcache_req_rw     = 1'b0                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						dcache_data_write = 64'b0                ;
						rd_addr_o         = rd                   ;
						rd_wen_o          = 1'b1                 ;
						case(load_index[2:1])
							2'b00:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{48{1'b0}},dcache_data_read[15:0]}:64'b0;
							end
							2'b01:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{48{1'b0}},dcache_data_read[31:16]}:64'b0;
							end
							2'b10:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{48{1'b0}},dcache_data_read[47:32]}:64'b0;
							end
							2'b11:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{48{1'b0}},dcache_data_read[63:48]}:64'b0;
							end
						endcase
					end
					`INST_LWU:begin
						dcache_req_rw     = 1'b0                 ;
						dcache_req_addr   = id_axi_araddr_i[13:2];
						//dcache_req_valid  = 1'b1                 ;
						dcache_data_write = 64'b0                ;
						rd_addr_o         = rd                   ;
						rd_wen_o          = 1'b1                 ;
						case(load_index[2])
							1'b0:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{32{1'b0}},dcache_data_read[31:0 ]}:64'b0;
							end
							1'b1:begin
								rd_data_o = (dcache_ready == 1'b1) ? {{32{1'b0}},dcache_data_read[63:32]}:64'b0;
							end
						endcase
					end
					default:begin
						dcache_req_rw     = 1'b0 ;
						dcache_req_addr   = 12'b0;
						//dcache_req_valid  = 1'b0 ;
						dcache_data_write = 64'b0;
						rd_addr_o         = 5'b0 ;
						rd_wen_o          = 1'b0 ;
						rd_data_o         = 64'b0;
					end
				endcase
			end
			default:begin
				dcache_req_rw     = 1'b0     ;
				dcache_req_addr   = 12'b0    ;
				dcache_req_valid  = 1'b0     ;
				dcache_data_write = 64'b0    ;
				rd_addr_o         = rd_addr_i;
				rd_data_o         = rd_data_i;
				rd_wen_o          = rd_wen_i ;
				hold_flag_mem_o   = 1'b0     ;
			end
		endcase
	end
	
	//assign mem_axi_awaddr  = {1'b1, ram_addr_i[30:0]}                              ;
	//assign mem_axi_awvalid = (int_assert_i == 1'b1) ? 1'b0 : (ram_we_i & ram_req_i);
	//assign mem_axi_wdata   = ram_data_i                                            ;
	//assign mem_axi_wstrb   = 8'hff                                                 ;
	//assign mem_axi_wvalid  = (int_assert_i == 1'b1) ? 1'b0 : (ram_we_i & ram_req_i);

endmodule


