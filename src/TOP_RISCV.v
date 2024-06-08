module TOP_RISCV
(
	input  wire        clk            ,
	input  wire        rst            ,
	//pc<-->icache
	output wire [11:0] if_icache_req_addr ,
	output wire        if_icache_req_valid,
	output wire        if_icache_req_rw   ,
	output wire        cpu_jump           ,
	input wire [31:0]  if_icache_data_read,
	input wire         if_icache_ready    ,
	input wire         if_icache_hit      ,
	//mem<-->dcache
	output wire [11:0] mem_dcache_req_addr  ,
	output wire        mem_dcache_req_valid ,
	output wire        mem_dcache_req_rw    ,
	output wire [63:0] mem_dcache_data_write,
	input wire [63:0]  mem_dcache_data_read ,
	input wire         mem_dcache_ready     ,
	input wire         mem_dcache_hit      
);
	//pc to if
	wire [63:0] pc_inst_addr_o;
	//if to if_id
	wire [63:0] if_inst_addr_o;     
	wire [31:0] if_inst_o     ;     
	//if to ctrl
	wire        if_hold_flag_if_o;
	//if_id to id
	wire [63:0] if_id_inst_addr_o;
	wire [31:0] if_id_rom_inst_o ;
	//id to regs
	wire [4:0] id_rs1_addr_o;
	wire [4:0] id_rs2_addr_o;
	//regs to id
	wire [63:0] regs_reg1_rdata_o;
	wire [63:0] regs_reg2_rdata_o;
	//wb to regs
	wire [4 :0] wb_rd_addr_o;
	wire [63:0] wb_rd_data_o;
	wire        wb_rd_wen_o ;
	//id to id_ex
	wire [31:0] id_inst_o       ;
	wire [63:0] id_inst_addr_o  ;
	wire [63:0] id_op1_o        ;
	wire [63:0] id_op2_o        ;
	wire [4 :0] id_rd_addr_o    ;
	wire        id_reg_wen      ;
	wire [63:0] id_base_addr_o  ;
	wire [63:0] id_addr_offset_o;
	wire        id_csr_we_o     ;
	wire [63:0] id_csr_rdata_o  ;
	wire [63:0] id_csr_waddr_o  ;
	wire [31:0] id_id_axi_araddr;
	wire        id_read_ram     ;
	wire        id_write_ram    ;
	//id_ex to ex
	wire [31:0] id_ex_inst_o         ;
	wire [63:0] id_ex_inst_addr_o    ;
	wire [63:0] id_ex_op1_o          ;
	wire [63:0] id_ex_op2_o          ;
	wire [4 :0] id_ex_rd_addr_o      ;
	wire        id_ex_reg_wen_o      ;
	wire [63:0] id_ex_base_addr_o    ;
	wire [63:0] id_ex_addr_offset_o  ;
	wire        id_ex_csr_we_o       ;
	wire [63:0] id_ex_csr_rdata_o    ;
	wire [63:0] id_ex_csr_waddr_o    ;
	wire [31:0] id_ex_id_axi_araddr_o;
	wire        id_ex_read_ram_o     ;
	wire        id_ex_write_ram_o    ;
	//ex to ex_mem
	wire [4 :0] ex_rd_addr_o      ;
	wire [63:0] ex_rd_data_o      ;
	wire        ex_rd_wen_o       ;
	wire [31:0] ex_id_axi_araddr_o;
	wire        ex_read_ram_o     ;
	wire        ex_write_ram_o    ;
	wire [31:0] ex_inst_o         ;
	wire [63:0] ex_inst_addr_o    ;
	wire [63:0] ex_op2_o          ;
	//ex to ctrl
	wire [63:0] ex_jump_addr_o;
	wire        ex_jump_en_o  ;
	wire        ex_hold_flag_o;
	//ctrl to pc if_id id_ex 
	wire [63:0] ctrl_jump_addr_o;
	wire        ctrl_jump_en_o  ;
	wire [1 :0] ctrl_hold_flag_o;
	//ctrl to ex_mem
	wire        ctrl_mem_en;
	//ex_mem to mem
	wire [4 :0] ex_mem_rd_addr_o        ;
	wire [63:0] ex_mem_rd_data_o        ;
	wire        ex_mem_rd_wen_o         ;
	wire        ex_mem_read_ram_o       ;
	wire        ex_mem_write_ram_o      ;
	wire [31:0] ex_mem_inst_o           ;
	wire [63:0] ex_mem_inst_addr_o      ;
	wire [31:0] ex_mem_id_axi_araddr_o  ;
	wire [63:0] ex_mem_op2_o            ;
	//mem to mem_wb
	wire [4 :0] mem_rd_addr_o;
	wire [63:0] mem_rd_data_o;
	wire        mem_rd_wen_o ;
	//mem to ctrl
	wire        mem_hold_flag_mem_o;
	//mem_wb to wb
	wire [4 :0] mem_wb_rd_addr_o;
	wire [63:0] mem_wb_rd_data_o;
	wire        mem_wb_rd_wen_o ;
	//check to id
	wire [63:0] check_rs1_data_o;
	wire [63:0] check_rs2_data_o;
	wire        check_rs1_valid ;
	wire        check_rs2_valid ;
	//clint to ctrl
	wire clint_hold_flag_o;
	//clint to ex
	wire [63:0] clint_int_addr_o  ;
	wire        clint_int_assert_o;
	//clint to csr_regs
	wire        clint_we_o   ;
	wire [63:0] clint_waddr_o;
	wire [63:0] clint_raddr_o;
	wire [63:0] clint_data_o ;
	//csr_regs to clint
	wire [63:0] csr_regs_clint_data_o     ;
	wire [63:0] csr_regs_clint_csr_mtvec  ;
	wire [63:0] csr_regs_clint_csr_mepc   ;
	wire [63:0] csr_regs_clint_csr_mstatus;
	wire        csr_regs_global_int_en_o  ;
	//csr_regs to id
	wire [63:0] csr_regs_data_o;
	//id to csr_regs
	wire [63:0] id_csr_raddr_o;
	//ex to csr_regs
	wire        ex_csr_we_o   ;
	wire [63:0] ex_csr_wdata_o;
	wire [63:0] ex_csr_waddr_o;
	//ex to check
	wire [63:0] ex_check_ram_addr_o;
	wire        ex_check_ram_req_o ;
	//divider to ex 
	wire [63:0] div_rem_data_o;
	wire        div_finish_o  ;
	wire        div_busy_o    ;
	//ex to divider
	wire [63:0] ex_div_dividend_o;
	wire [63:0] ex_div_divisor_o ;
	wire [9 :0] ex_div_op_o      ;
	wire        ex_div_ready_o   ;
	//multiplier to ex
	wire [63:0] mult_product_val_o;
	wire        mult_finish_o     ;
	wire        mult_busy_o       ;
	//ex to multiplier
	wire [63:0] ex_mult_op1_o  ;
	wire [63:0] ex_mult_op2_o  ;
	wire [9 :0] ex_mult_op_o   ;
	wire        ex_mult_ready_o;

	assign cpu_jump = ctrl_jump_en_o;
	
	Multiplier Multiplier_inst
	(
		.clk        (clk               ),
		.rst        (rst               ),
		.mult_ready (ex_mult_ready_o   ),
		.inst_op_f3 (ex_mult_op_o      ),
		.mult_op1   (ex_mult_op1_o     ),
		.mult_op2   (ex_mult_op2_o     ),
		.product_val(mult_product_val_o),
		.mult_finish(mult_finish_o     ),
		.busy_o     (mult_busy_o       )
	);
	
	Divider Divider_inst
	(
		.clk         (clk              ),
		.rst         (rst              ),
		.diviser     (ex_div_divisor_o ),
		.dividend    (ex_div_dividend_o),
		.inst_op_f3  (ex_div_op_o      ),
		.div_ready   (ex_div_ready_o   ),
		.div_rem_data(div_rem_data_o   ),
		.div_finish  (div_finish_o     ),
		.busy_o      (div_busy_o       )
	);
	
	CHECK CHECK_inst
	(
		.rs1_addr_i       (id_rs1_addr_o       ),
		.rs2_addr_i       (id_rs2_addr_o       ),
		.ram_addr_i       (ex_check_ram_addr_o ),
		.ram_req_i        (ex_check_ram_req_o  ),
		.ex_rd_addr_i     (ex_rd_addr_o        ),
		.ex_rd_data_i     (ex_rd_data_o        ),
		.ex_rd_wen_i      (ex_rd_wen_o         ),
		.mem_rd_addr_i    (mem_rd_addr_o       ),
		.mem_rd_data_i    (mem_rd_data_o       ),
		.mem_rd_wen_i     (mem_rd_wen_o        ),
		.rs1_data_o       (check_rs1_data_o    ),
		.rs2_data_o       (check_rs2_data_o    ),
		.rs1_valid        (check_rs1_valid     ),
		.rs2_valid        (check_rs2_valid     )
	);
	
	PC PC_inst
	(
		.clk                (clk                ),
		.rst                (rst                ),
		.jump_addr_i        (ctrl_jump_addr_o   ),
		.jump_en            (ctrl_jump_en_o     ),
		.hold_flag_i        (ctrl_hold_flag_o   ),
		.inst_addr_o        (pc_inst_addr_o     )
	);

	IF IF_inst
	(
		.inst_addr_i     (pc_inst_addr_o     ),
		//.jump_en_i       (ctrl_jump_en_o     ),
		.icache_req_addr (if_icache_req_addr ),
		.icache_req_valid(if_icache_req_valid),
		.icache_req_rw   (if_icache_req_rw   ),
		.icache_data_read(if_icache_data_read),
		.icache_ready    (if_icache_ready    ),
		.icache_hit      (if_icache_hit      ),
		.inst_addr_o     (if_inst_addr_o     ),
		.inst_o          (if_inst_o          ),
		.hold_flag_if_o  (if_hold_flag_if_o  )
	);
	
	IF_ID IF_ID_inst
	(
		.clk        (clk              ),
		.rst        (rst              ),
		.inst_i     (if_inst_o        ),
		.hold_flag_i(ctrl_hold_flag_o ),
		.inst_addr_i(if_inst_addr_o   ),
		.inst_addr_o(if_id_inst_addr_o),
		.inst_o     (if_id_rom_inst_o )
	);
	
	ID ID_inst
	(
		.rom_inst_i      (if_id_rom_inst_o  ),
		.inst_addr_i     (if_id_inst_addr_o ),
		.rs1_addr_o      (id_rs1_addr_o     ),
		.rs2_addr_o      (id_rs2_addr_o     ),
		.regs_rs1_data_i (regs_reg1_rdata_o ),
		.regs_rs2_data_i (regs_reg2_rdata_o ),
		.chack_rs1_data_i(check_rs1_data_o  ),
		.chack_rs2_data_i(check_rs2_data_o  ),
		.rs1_valid       (check_rs1_valid   ),
		.rs2_valid       (check_rs2_valid   ),
		.base_addr_o     (id_base_addr_o    ),
		.addr_offset_o   (id_addr_offset_o  ),
		.inst_o          (id_inst_o         ),
		.inst_addr_o     (id_inst_addr_o    ),
		.op1_o           (id_op1_o          ),
		.op2_o           (id_op2_o          ),
		.rd_addr_o       (id_rd_addr_o      ),
		.reg_wen         (id_reg_wen        ),
		.csr_we_o        (id_csr_we_o       ),
		.csr_rdata_o     (id_csr_rdata_o    ),
		.csr_waddr_o     (id_csr_waddr_o    ),
		.csr_raddr_o     (id_csr_raddr_o    ),
		.csr_rdata_i     (csr_regs_data_o   ),
		.int_assert_i    (clint_int_assert_o),
		.id_axi_araddr   (id_id_axi_araddr  ),   
		.read_ram        (id_read_ram       ),
		.write_ram       (id_write_ram      )
	);
	
	REGS REGS_inst
	(
		.clk         (clk              ),
		.rst         (rst              ),
		.reg1_raddr_i(id_rs1_addr_o    ),
		.reg2_raddr_i(id_rs2_addr_o    ),
		.reg1_rdata_o(regs_reg1_rdata_o),
		.reg2_rdata_o(regs_reg2_rdata_o),
		.reg_waddr_i (wb_rd_addr_o     ),
		.reg_wdata_i (wb_rd_data_o     ),
		.reg_wen     (wb_rd_wen_o      )
	);
	
	ID_EX ID_EX_inst
	(
		.clk            (clk                  ),
		.rst            (rst                  ),
		.hold_flag_i    (ctrl_hold_flag_o     ),                 
		.base_addr_i    (id_base_addr_o       ),
		.addr_offset_i  (id_addr_offset_o     ),
		.inst_i         (id_inst_o            ),
		.inst_addr_i    (id_inst_addr_o       ),
		.op1_i          (id_op1_o             ),
		.op2_i          (id_op2_o             ),
		.rd_addr_i      (id_rd_addr_o         ),
		.reg_wen_i      (id_reg_wen           ),
		.csr_we_i       (id_csr_we_o          ),
		.csr_rdata_i    (id_csr_rdata_o       ),
		.csr_waddr_i    (id_csr_waddr_o       ),
		.id_axi_araddr_i(id_id_axi_araddr     ),
		.read_ram_i     (id_read_ram          ),
		.write_ram_i    (id_write_ram         ),
		.base_addr_o    (id_ex_base_addr_o    ),
		.addr_offset_o  (id_ex_addr_offset_o  ),
		.inst_o         (id_ex_inst_o         ),
		.inst_addr_o    (id_ex_inst_addr_o    ),
		.op1_o          (id_ex_op1_o          ),
		.op2_o          (id_ex_op2_o          ),
		.rd_addr_o      (id_ex_rd_addr_o      ),
		.reg_wen_o      (id_ex_reg_wen_o      ),
		.csr_we_o       (id_ex_csr_we_o       ),
		.csr_rdata_o    (id_ex_csr_rdata_o    ),
		.csr_waddr_o    (id_ex_csr_waddr_o    ),
		.id_axi_araddr_o(id_ex_id_axi_araddr_o),
		.read_ram_o     (id_ex_read_ram_o     ),
		.write_ram_o    (id_ex_write_ram_o    )
	);
	
	EX EX_inst
	(
		.inst_i          (id_ex_inst_o         ),
		.inst_addr_i     (id_ex_inst_addr_o    ),
		.op1_i           (id_ex_op1_o          ),
		.op2_i           (id_ex_op2_o          ),
		.rd_addr_i       (id_ex_rd_addr_o      ),
		.rd_wen_i        (id_ex_reg_wen_o      ),
		.base_addr_i     (id_ex_base_addr_o    ),
		.addr_offset_i   (id_ex_addr_offset_o  ),
		.csr_we_i        (id_ex_csr_we_o       ),
		.csr_rdata_i     (id_ex_csr_rdata_o    ),
		.csr_waddr_i     (id_ex_csr_waddr_o    ),
		.id_axi_araddr_i (id_ex_id_axi_araddr_o),
		.read_ram_i      (id_ex_read_ram_o     ),
		.write_ram_i     (id_ex_write_ram_o    ),
		.int_assert_i    (clint_int_assert_o   ),
		.int_addr_i      (clint_int_addr_o     ),
		.csr_we_o        (ex_csr_we_o          ),
		.csr_wdata_o     (ex_csr_wdata_o       ),
		.csr_waddr_o     (ex_csr_waddr_o       ),
		.rd_addr_o       (ex_rd_addr_o         ),
		.rd_data_o       (ex_rd_data_o         ),
		.rd_wen_o        (ex_rd_wen_o          ),
		.id_axi_araddr_o (ex_id_axi_araddr_o   ),
		.read_ram_o      (ex_read_ram_o        ),
		.write_ram_o     (ex_write_ram_o       ),
		.inst_o          (ex_inst_o            ),
		.inst_addr_o     (ex_inst_addr_o       ),
		.op2_o           (ex_op2_o             ),
		.jump_addr_o     (ex_jump_addr_o       ),
		.jump_en_o       (ex_jump_en_o         ),
		.hold_flag_o     (ex_hold_flag_o       ),
		.div_finish_i    (div_finish_o         ),
		.div_rem_data_i  (div_rem_data_o       ),
		.div_busy_i      (div_busy_o           ),
		.div_ready_o     (ex_div_ready_o       ),
		.div_dividend_o  (ex_div_dividend_o    ),
		.div_divisor_o   (ex_div_divisor_o     ),
		.div_op_o        (ex_div_op_o          ),
		.mult_finish_i   (mult_finish_o        ),
		.mult_product_val(mult_product_val_o   ),
		.mult_busy_i     (mult_busy_o          ),               
		.mult_ready_o    (ex_mult_ready_o      ),
		.mult_op1_o      (ex_mult_op1_o        ),
		.mult_op2_o      (ex_mult_op2_o        ),
		.mult_op_o       (ex_mult_op_o         )
	);
	
	CTRL CTRL_inst
	(
		.jump_addr_i      (ex_jump_addr_o     ),
		.jump_en_i        (ex_jump_en_o       ),
		.hold_flag_ex_i   (ex_hold_flag_o     ),
		.hold_flag_clint_i(clint_hold_flag_o  ),
		.hold_flag_mem_i  (mem_hold_flag_mem_o),
		.hold_flag_if_i   (if_hold_flag_if_o  ),
		.jump_addr_o      (ctrl_jump_addr_o   ),
		.jump_en_o        (ctrl_jump_en_o     ),
		.hold_flag_o      (ctrl_hold_flag_o   ),
		.mem_en           (ctrl_mem_en        )
	);

	EX_MEM EX_MEM_inst
	(
		.clk            (clk                   ),
		.rst            (rst                   ),
		//.hold_flag_i    (ctrl_hold_flag_o      ),
		.mem_en         (ctrl_mem_en           ),
		.rd_addr_i      (ex_rd_addr_o          ),
		.rd_data_i      (ex_rd_data_o          ),
		.rd_wen_i       (ex_rd_wen_o           ),
		.read_ram_i     (ex_read_ram_o         ),
		.write_ram_i    (ex_write_ram_o        ),
		.inst_i         (ex_inst_o             ),
		.inst_addr_i    (ex_inst_addr_o        ),
		.id_axi_araddr_i(ex_id_axi_araddr_o    ),
		.op2_i          (ex_op2_o              ), 
		.rd_addr_o      (ex_mem_rd_addr_o      ),
		.rd_data_o      (ex_mem_rd_data_o      ),
		.rd_wen_o       (ex_mem_rd_wen_o       ),
		.read_ram_o     (ex_mem_read_ram_o     ), 
		.write_ram_o    (ex_mem_write_ram_o    ),
		.inst_o         (ex_mem_inst_o         ),
		.inst_addr_o    (ex_mem_inst_addr_o    ),
		.id_axi_araddr_o(ex_mem_id_axi_araddr_o),
		.op2_o          (ex_mem_op2_o          )
	);
	
	MEM MEM_inst
	(
		.rd_addr_i       (ex_mem_rd_addr_o      ),
		.rd_data_i       (ex_mem_rd_data_o      ),
		.rd_wen_i        (ex_mem_rd_wen_o       ),
		.read_ram_i      (ex_mem_read_ram_o     ),
		.write_ram_i     (ex_mem_write_ram_o    ),
		.inst_i          (ex_mem_inst_o         ),
		.inst_addr_i     (ex_mem_inst_addr_o    ),
		.id_axi_araddr_i (ex_mem_id_axi_araddr_o),
		.op2_i           (ex_mem_op2_o          ),
		.rd_addr_o       (mem_rd_addr_o         ),
		.rd_data_o       (mem_rd_data_o         ),
		.rd_wen_o        (mem_rd_wen_o          ),
		.int_assert_i    (clint_int_assert_o    ),
		.hold_flag_mem_o (mem_hold_flag_mem_o   ),
		.dcache_req_addr (mem_dcache_req_addr   ),
		.dcache_req_valid(mem_dcache_req_valid  ),
		.dcache_req_rw   (mem_dcache_req_rw     ),
		.dcache_data_write(mem_dcache_data_write),
		.dcache_data_read(mem_dcache_data_read  ),
		.dcache_ready    (mem_dcache_ready      ),
		.dcache_hit      (mem_dcache_hit        )
	);

	MEM_WB MEM_WB_inst
	(
		.clk      (clk             ),
		.rst      (rst             ),
		.rd_addr_i(mem_rd_addr_o   ),
		.rd_data_i(mem_rd_data_o   ),
		.rd_wen_i (mem_rd_wen_o    ), 
		.rd_addr_o(mem_wb_rd_addr_o),
		.rd_data_o(mem_wb_rd_data_o),
		.rd_wen_o (mem_wb_rd_wen_o )
	);
	
	WB WB_inst
	(
		.rd_addr_i(mem_wb_rd_addr_o),
		.rd_data_i(mem_wb_rd_data_o),
		.rd_wen_i (mem_wb_rd_wen_o ),
		.rd_addr_o(wb_rd_addr_o    ),
		.rd_data_o(wb_rd_data_o    ),
		.rd_wen_o (wb_rd_wen_o     )
	);
	
	CSR_REGS CSR_REGS_inst
	(
		.clk              (clk                       ),
		.rst              (rst                       ),                  
		.we_i             (ex_csr_we_o               ),
		.raddr_i          (id_csr_raddr_o            ),
		.waddr_i          (ex_csr_waddr_o            ),
		.data_i           (ex_csr_wdata_o            ),               
		.clint_we_i       (clint_we_o                ),
		.clint_raddr_i    (clint_raddr_o             ),
		.clint_waddr_i    (clint_waddr_o             ),
		.clint_data_i     (clint_data_o              ),       
		.data_o           (csr_regs_data_o           ),         
		.clint_data_o     (csr_regs_clint_data_o     ),
		.clint_csr_mtvec  (csr_regs_clint_csr_mtvec  ),
		.clint_csr_mepc   (csr_regs_clint_csr_mepc   ),
		.clint_csr_mstatus(csr_regs_clint_csr_mstatus),
		.global_int_en_o  (csr_regs_global_int_en_o  )
	);
	
	CLINT CLINT_inst
	(
		.clk            (clk                       ),
		.rst            (rst                       ),           
		.inst_i         (id_inst_o                 ),
		.inst_addr_i    (id_inst_addr_o            ),           
		.jump_flag_i    (ex_jump_en_o              ),
		.jump_addr_i    (ex_jump_addr_o            ),                     
		.data_i         (csr_regs_clint_data_o     ),
		.csr_mtvec      (csr_regs_clint_csr_mtvec  ),
		.csr_mepc       (csr_regs_clint_csr_mepc   ),
		.csr_mstatus    (csr_regs_clint_csr_mstatus),             
		.hold_flag_o    (clint_hold_flag_o         ),              
		.we_o           (clint_we_o                ),
		.waddr_o        (clint_waddr_o             ),
		.raddr_o        (clint_raddr_o             ),
		.data_o         (clint_data_o              ),           
		.int_addr_o     (clint_int_addr_o          ),
		.int_assert_o   (clint_int_assert_o        ),
		.global_int_en_i(csr_regs_global_int_en_o  )
	);
	
endmodule


