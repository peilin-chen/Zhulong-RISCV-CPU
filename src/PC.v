module PC
(
	input  wire        clk           ,
	input  wire        rst           ,
	input  wire [63:0] jump_addr_i   ,
	input  wire        jump_en       ,
	input  wire [1 :0] hold_flag_i   ,//流水线暂停标志
	//to if
	output wire [63:0] inst_addr_o
);

	reg [63:0] pc_o;

	always @(posedge clk)
		begin
			if(rst == 1'b1) 
				pc_o <= 64'h0000_0000_0000_0000;
			else if(jump_en)
				pc_o <= jump_addr_i;
			else if(hold_flag_i == 2'b01 || hold_flag_i == 2'b10) 
				pc_o <= pc_o;
			else
				pc_o <= pc_o + 64'd4;
		end

	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff1
	(
		.clk        (clk          ),
		.rst        (rst          ),
		.hold_flag_i(hold_flag_i  ),
		.set_data   (64'b0        ),
	    .data_i     (pc_o         ),
        .data_o     (inst_addr_o  )
	);

endmodule


