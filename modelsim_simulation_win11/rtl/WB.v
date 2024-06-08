module WB
(
	input wire [4 :0]  rd_addr_i,
	input wire [63:0]  rd_data_i,
	input wire         rd_wen_i ,
	//to regs
	output wire [4 :0] rd_addr_o,
	output wire [63:0] rd_data_o,
	output wire        rd_wen_o 
);

	assign rd_addr_o = rd_addr_i;
	assign rd_data_o = rd_data_i;
	assign rd_wen_o  = rd_wen_i ;

endmodule


