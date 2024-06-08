module MEM_WB
(
	input  wire        clk      ,
	input  wire        rst      ,
	//from mem
	input wire [4 :0] rd_addr_i ,
	input wire [63:0] rd_data_i ,
	input wire        rd_wen_i  , 
	//to wb
	output wire [4 :0] rd_addr_o,
	output wire [63:0] rd_data_o,
	output wire        rd_wen_o 
);

	DFF_SET 
	#
	(
		.DW(5)
	) 
	dff1
	(
		.clk        (clk      ),
		.rst        (rst      ),
		.hold_flag_i(2'b00    ),
		.set_data   (5'b0     ),
	    .data_i     (rd_addr_i),
        .data_o     (rd_addr_o)
	);
	
	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff2
	(
		.clk        (clk      ),
		.rst        (rst      ),
		.hold_flag_i(2'b00    ),
		.set_data   (64'b0    ),
	    .data_i     (rd_data_i),
        .data_o     (rd_data_o)
	);
	
	DFF_SET 
	#
	(
		.DW(1)
	) 
	dff3
	(
		.clk        (clk     ),
		.rst        (rst     ),
		.hold_flag_i(2'b00   ),
		.set_data   (1'b0    ),
	    .data_i     (rd_wen_i),
        .data_o     (rd_wen_o)
	);

endmodule


