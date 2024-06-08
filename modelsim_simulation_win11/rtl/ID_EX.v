`include "defines.v"

module ID_EX
(
	input wire         clk            ,
	input wire         rst            ,
	//from ctrl                       
	input wire [1 :0]  hold_flag_i    ,
	//from id                         
	input wire [63:0]  base_addr_i    ,
	input wire [63:0]  addr_offset_i  ,
	input wire [31:0]  inst_i         ,
	input wire [63:0]  inst_addr_i    ,
	input wire [63:0]  op1_i          ,
	input wire [63:0]  op2_i          ,
	input wire [4 :0]  rd_addr_i      ,
	input wire         reg_wen_i      ,
	input wire         csr_we_i       ,
	input wire [63:0]  csr_rdata_i    ,
	input wire [63:0]  csr_waddr_i    ,
	input wire [31:0]  id_axi_araddr_i,
	input wire         read_ram_i     ,
	input wire         write_ram_i    ,
	//to ex                         
	output wire [63:0] base_addr_o    ,
	output wire [63:0] addr_offset_o  ,
	output wire [31:0] inst_o         ,
	output wire [63:0] inst_addr_o    ,
	output wire [63:0] op1_o          ,
	output wire [63:0] op2_o          ,
	output wire [4 :0] rd_addr_o      ,
	output wire        reg_wen_o      ,
	output wire        csr_we_o       ,
	output wire [63:0] csr_rdata_o    ,
	output wire [63:0] csr_waddr_o    ,
	output wire [31:0] id_axi_araddr_o,
	output wire        read_ram_o     ,
	output wire        write_ram_o   
);

	DFF_SET 
	#
	(
		.DW(32)
	) 
	dff1
	(
		.clk        (clk                    ),
		.rst        (rst                    ),
		.hold_flag_i(hold_flag_i            ),
		.set_data   (`INST_NOP),
	    .data_i     (inst_i                 ),
        .data_o     (inst_o                 )
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
		.hold_flag_i(hold_flag_i),
		.set_data   (64'b0      ),
	    .data_i     (inst_addr_i),
        .data_o     (inst_addr_o)
	);
	
	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff3
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i(hold_flag_i),
		.set_data   (64'b0      ),
	    .data_i     (op1_i      ),
        .data_o     (op1_o      )
	);
	
	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff4
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i(hold_flag_i),
		.set_data   (64'b0      ),
	    .data_i     (op2_i      ),
        .data_o     (op2_o      )
	);
	
	DFF_SET 
	#
	(
		.DW(5)
	) 
	dff5
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i(hold_flag_i),
		.set_data   (5'b0       ),
	    .data_i     (rd_addr_i  ),
        .data_o     (rd_addr_o  )
	);
	
	DFF_SET 
	#
	(
		.DW(1)
	) 
	dff6
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i(hold_flag_i),
		.set_data   (1'b0       ),
	    .data_i     (reg_wen_i  ),
        .data_o     (reg_wen_o  )
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
		.hold_flag_i(hold_flag_i),
		.set_data   (64'b0      ),
	    .data_i     (base_addr_i),
        .data_o     (base_addr_o)
	);
	
	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff8
	(
		.clk        (clk          ),
		.rst        (rst          ),
		.hold_flag_i(hold_flag_i  ),
		.set_data   (64'b0        ),
	    .data_i     (addr_offset_i),
        .data_o     (addr_offset_o)
	);
	
	DFF_SET 
	#
	(
		.DW(1)
	) 
	dff9
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i(hold_flag_i),
		.set_data   (1'b0       ),
	    .data_i     (csr_we_i   ),
        .data_o     (csr_we_o   )
	);
	
	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff10
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i(hold_flag_i),
		.set_data   (64'b0      ),
	    .data_i     (csr_rdata_i),
        .data_o     (csr_rdata_o)
	);
	
	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff11
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i(hold_flag_i),
		.set_data   (64'b0      ),
	    .data_i     (csr_waddr_i),
        .data_o     (csr_waddr_o)
	);

	DFF_SET 
	#
	(
		.DW(32)
	) 
	dff12
	(
		.clk        (clk            ),
		.rst        (rst            ),
		.hold_flag_i(hold_flag_i    ),
		.set_data   (32'b0          ),
	    .data_i     (id_axi_araddr_i),
        .data_o     (id_axi_araddr_o)
	);

	DFF_SET 
	#
	(
		.DW(1)
	) 
	dff13
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i(hold_flag_i),
		.set_data   (1'b0       ),
	    .data_i     (read_ram_i ),
        .data_o     (read_ram_o )
	);

	DFF_SET 
	#
	(
		.DW(1)
	) 
	dff14
	(
		.clk        (clk        ),
		.rst        (rst        ),
		.hold_flag_i(hold_flag_i),
		.set_data   (1'b0       ),
	    .data_i     (write_ram_i),
        .data_o     (write_ram_o)
	);

endmodule


