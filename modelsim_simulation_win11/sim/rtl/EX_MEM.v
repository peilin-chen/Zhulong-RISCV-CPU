`include "defines.v"


module EX_MEM
(
	input  wire        clk            ,
	input  wire        rst            ,
	//from ctrl    
	//input wire [1 :0]  hold_flag_i    ,
	input wire         mem_en         ,
	//from ex                        
	input wire [4 :0]  rd_addr_i      ,
	input wire [63:0]  rd_data_i      ,
	input wire         rd_wen_i       , 
	//input wire         ram_we_i   ,
	//input wire [63:0]  ram_addr_i ,
	//input wire [63:0]  ram_data_i ,
	//input wire         ram_req_i  ,
	input wire         read_ram_i     ,
	input wire         write_ram_i    ,
	input wire [31:0]  inst_i         ,
	input wire [63:0]  inst_addr_i    ,
	input wire [31:0]  id_axi_araddr_i,
	input wire [63:0]  op2_i          ,
	//to mem 
	output wire [4 :0] rd_addr_o      ,
	output wire [63:0] rd_data_o      ,
	output wire        rd_wen_o       ,
	output wire        read_ram_o     ,
	output wire        write_ram_o    ,
	output wire [31:0] inst_o         ,
	output wire [63:0] inst_addr_o    ,
	output wire [31:0] id_axi_araddr_o,
	output wire [63:0] op2_o
	//output wire        ram_we_o   ,
	//output wire [63:0] ram_addr_o ,
	//output wire [63:0] ram_data_o ,
	//output wire        ram_req_o  ,
	//to check 
	//output wire [63:0] addr_o     ,
	//output wire [63:0] data_o     ,
	//output wire        req_o      ,
	//output wire        we_o  
);

	//assign addr_o = ram_addr_o;
	//assign data_o = ram_data_o;
	//assign req_o  = ram_req_o ;
	//assign we_o   = ram_we_o  ;

	DFF_SET 
	#
	(
		.DW(5)
	) 
	dff1
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i((mem_en==1'b1) ? 2'b10:2'b00),
		.set_data   (5'b0       ),
	    .data_i     (rd_addr_i  ),
        .data_o     (rd_addr_o  )
	);
	
	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff2
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i((mem_en==1'b1) ? 2'b10:2'b00),
		.set_data   (64'b0      ),
	    .data_i     (rd_data_i  ),
        .data_o     (rd_data_o  )
	);
	
	DFF_SET 
	#
	(
		.DW(1)
	) 
	dff3
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i((mem_en==1'b1) ? 2'b10:2'b00),
		.set_data   (1'b0       ),
	    .data_i     (rd_wen_i   ),
        .data_o     (rd_wen_o   )
	);
	
	DFF_SET 
	#
	(
		.DW(1)
	) 
	dff4
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i((mem_en==1'b1) ? 2'b10:2'b00),
		.set_data   (1'b0       ),
	    .data_i     (read_ram_i ),
        .data_o     (read_ram_o )
	);
	
	DFF_SET 
	#
	(
		.DW(1)
	) 
	dff5
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i((mem_en==1'b1) ? 2'b10:2'b00),
		.set_data   (1'b0       ),
	    .data_i     (write_ram_i),
        .data_o     (write_ram_o)
	);
	
	DFF_SET 
	#
	(
		.DW(32)
	) 
	dff6
	(
		.clk        (clk                    ),
		.rst        (rst                    ),
		.hold_flag_i((mem_en==1'b1) ? 2'b10:2'b00),
		.set_data   (`INST_NOP),
	    .data_i     (inst_i                 ),
        .data_o     (inst_o                 )
	);
	
	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff7
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i((mem_en==1'b1) ? 2'b10:2'b00),
		.set_data   (64'b0      ),
	    .data_i     (inst_addr_i),
        .data_o     (inst_addr_o)
	);

	DFF_SET 
	#
	(
		.DW(32)
	) 
	dff8
	(
		.clk        (clk            ),
		.rst        (rst            ),
		.hold_flag_i((mem_en==1'b1) ? 2'b10:2'b00),
		.set_data   (32'b0          ),
	    .data_i     (id_axi_araddr_i),
        .data_o     (id_axi_araddr_o)
	);

	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff9
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i((mem_en==1'b1) ? 2'b10:2'b00),
		.set_data   (64'b0      ),
	    .data_i     (op2_i      ),
        .data_o     (op2_o      )
	);

endmodule


