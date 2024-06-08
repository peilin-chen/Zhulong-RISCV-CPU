module RISCV_SOC
(
	input  wire        clk        ,
	input  wire        rst        
);

	//top to icache
	wire [11:0] top_pc_icache_req_addr ;
	wire        top_pc_icache_req_valid;
	wire        top_pc_icache_req_rw   ;
	wire        top_cpu_jump           ;
	//icache to top
	wire [31:0] icache_pc_icache_data_read;
	wire        icache_pc_icache_ready    ;
	wire        icache_icache_hit         ;
	//top to dcache
	wire [11:0] top_mem_dcache_req_addr  ;
	wire        top_mem_dcache_req_valid ;
	wire        top_mem_dcache_req_rw    ;
	wire [63:0] top_mem_dcache_data_write;
	//dcache to top
	wire [63:0]  top_mem_dcache_data_read;
	wire         top_mem_dcache_ready    ;
	wire         top_mem_dcache_hit      ;
	//icache to axi
	wire [11:0] icache_rom_axi_araddr ;
	wire        icache_rom_axi_arvalid;
	wire        icache_rom_axi_rready ;
	wire [11:0] icache_rom_axi_awaddr ;
	wire        icache_rom_axi_awvalid;
	wire [127:0] icache_rom_axi_wdata ;
	wire         icache_rom_axi_wvalid;
	//axi to icache
	wire         axi_rom_axi_arready;
	wire [127:0] axi_rom_axi_rdata  ;
	wire         axi_rom_axi_rvalid ;
	wire         axi_rom_axi_awready;
	wire         axi_rom_axi_wready ;
	//dcache to axi
	wire [11:0]  dcache_ram_axi_araddr ;
	wire         dcache_ram_axi_arvalid;
	wire         dcache_ram_axi_rready ;
	wire [11:0]  dcache_ram_axi_awaddr ;
	wire         dcache_ram_axi_awvalid;
	wire [255:0] dcache_ram_axi_wdata  ;
	wire         dcache_ram_axi_wvalid ;
	//axi to dcache
	wire         axi_ram_axi_arready;
	wire [255:0] axi_ram_axi_rdata  ;
	wire         axi_ram_axi_rvalid ;
	wire         axi_ram_axi_awready;
	wire         axi_ram_axi_wready ;
	//rom to axi
	wire         rom_axi_awready;
	wire         rom_axi_wready ;
	wire         rom_axi_arready;
	wire [127:0] rom_axi_rdata  ;
	wire         rom_axi_rvalid ;
	//axi to rom
	wire [11:0]  axi_s0_axi_awaddr ;
	wire         axi_s0_axi_awvalid;
	wire [127:0] axi_s0_axi_wdata  ;
	wire         axi_s0_axi_wvalid ;
	wire [11:0]  axi_s0_axi_araddr ;
	wire         axi_s0_axi_arvalid;
	wire         axi_s0_axi_rready ;
	//ram to axi
	wire         ram_axi_awready   ;
	wire         ram_axi_wready    ;
	wire         ram_axi_arready   ;
	wire [255:0] ram_axi_rdata     ;
	wire         ram_axi_rvalid    ;
	//axi to ram
	wire [11:0]  axi_s1_axi_awaddr ;
	wire         axi_s1_axi_awvalid;
	wire [255:0] axi_s1_axi_wdata  ;
	wire         axi_s1_axi_wvalid ;
	wire [11:0]  axi_s1_axi_araddr ;
	wire         axi_s1_axi_arvalid;
	wire         axi_s1_axi_rready ;

	TOP_RISCV TOP_RISCV_inst
	(
		.clk                  (clk                       ),
		.rst                  (rst                       ),
		.if_icache_req_addr   (top_pc_icache_req_addr    ),
		.if_icache_req_valid  (top_pc_icache_req_valid   ),
		.if_icache_req_rw     (top_pc_icache_req_rw      ),
		.cpu_jump             (top_cpu_jump              ),
		.if_icache_data_read  (icache_pc_icache_data_read),
		.if_icache_ready      (icache_pc_icache_ready    ),
		.if_icache_hit        (icache_icache_hit         ),
		.mem_dcache_req_addr  (top_mem_dcache_req_addr   ),
		.mem_dcache_req_valid (top_mem_dcache_req_valid  ),
		.mem_dcache_req_rw    (top_mem_dcache_req_rw     ),
		.mem_dcache_data_write(top_mem_dcache_data_write ),
		.mem_dcache_data_read (top_mem_dcache_data_read  ),
		.mem_dcache_ready     (top_mem_dcache_ready      ),
		.mem_dcache_hit       (top_mem_dcache_hit        )
	);
	
	ICache ICache_inst
	(
		.clk            (clk                       ),
		.rst            (rst                       ),
		.cpu_req_addr   (top_pc_icache_req_addr    ),
		.cpu_req_valid  (top_pc_icache_req_valid   ),
		.cpu_req_rw     (top_pc_icache_req_rw      ),
		.cpu_data_write (                          ),
		.cpu_jump       (top_cpu_jump              ),
		.cpu_data_read  (icache_pc_icache_data_read),
		.cpu_ready      (icache_pc_icache_ready    ),
		.icache_hit     (icache_icache_hit         ),
		.rom_axi_araddr (icache_rom_axi_araddr     ), 
		.rom_axi_arvalid(icache_rom_axi_arvalid    ), 
		.rom_axi_arready(axi_rom_axi_arready       ), 
		.rom_axi_rdata  (axi_rom_axi_rdata         ), 
		.rom_axi_rvalid (axi_rom_axi_rvalid        ), 
		.rom_axi_rready (icache_rom_axi_rready     ),
		.rom_axi_awaddr (icache_rom_axi_awaddr     ), 
		.rom_axi_awvalid(icache_rom_axi_awvalid    ), 
		.rom_axi_awready(axi_rom_axi_awready       ), 
		.rom_axi_wdata  (icache_rom_axi_wdata      ), 
		.rom_axi_wvalid (icache_rom_axi_wvalid     ), 
		.rom_axi_wready (axi_rom_axi_wready        )  
	);

	DCache DCache_inst
	(
		.clk            (clk                      ),
		.rst            (rst                      ),
		.cpu_req_addr   (top_mem_dcache_req_addr  ),
		.cpu_req_valid  (top_mem_dcache_req_valid ),
		.cpu_req_rw     (top_mem_dcache_req_rw    ),
		.cpu_data_write (top_mem_dcache_data_write),
		.cpu_data_read  (top_mem_dcache_data_read ),
		.cpu_ready      (top_mem_dcache_ready     ),
		.dcache_hit     (top_mem_dcache_hit       ),
		.ram_axi_araddr (dcache_ram_axi_araddr    ), 
		.ram_axi_arvalid(dcache_ram_axi_arvalid   ), 
		.ram_axi_arready(axi_ram_axi_arready      ), 
		.ram_axi_rdata  (axi_ram_axi_rdata        ), 
		.ram_axi_rvalid (axi_ram_axi_rvalid       ), 
		.ram_axi_rready (dcache_ram_axi_rready    ),
		.ram_axi_awaddr (dcache_ram_axi_awaddr    ), 
		.ram_axi_awvalid(dcache_ram_axi_awvalid   ), 
		.ram_axi_awready(axi_ram_axi_awready      ), 
		.ram_axi_wdata  (dcache_ram_axi_wdata     ), 
		.ram_axi_wvalid (dcache_ram_axi_wvalid    ), 
		.ram_axi_wready (axi_ram_axi_wready       )  
	); 

	AXI4_Lite AXI4_Lite_inst
	(
		.clk           (clk                   ),
		.rst           (rst                   ),
		.M0_AXI_AWADDR (icache_rom_axi_awaddr ),
		.M0_AXI_AWVALID(icache_rom_axi_awvalid),
		.M0_AXI_AWREADY(axi_rom_axi_awready   ),
		.M0_AXI_WDATA  (icache_rom_axi_wdata  ),
		.M0_AXI_WSTRB  (8'hff                 ),
		.M0_AXI_WVALID (icache_rom_axi_wvalid ),
		.M0_AXI_WREADY (axi_rom_axi_wready    ),        
		.M0_AXI_BRESP  (                      ),
		.M0_AXI_BVALID (                      ),
		.M0_AXI_BREADY (                      ),           
		.M0_AXI_ARADDR (icache_rom_axi_araddr ),
		.M0_AXI_ARVALID(icache_rom_axi_arvalid),
		.M0_AXI_ARREADY(axi_rom_axi_arready   ),
		.M0_AXI_RDATA  (axi_rom_axi_rdata     ),
		.M0_AXI_RRESP  (                      ),
		.M0_AXI_RVALID (axi_rom_axi_rvalid    ),
		.M0_AXI_RREADY (icache_rom_axi_rready ),
		.M1_AXI_AWADDR (dcache_ram_axi_awaddr ),
		.M1_AXI_AWVALID(dcache_ram_axi_awvalid),
		.M1_AXI_AWREADY(axi_ram_axi_awready   ),    
		.M1_AXI_WDATA  (dcache_ram_axi_wdata  ),
		.M1_AXI_WSTRB  (8'hff                 ),
		.M1_AXI_WVALID (dcache_ram_axi_wvalid ),
		.M1_AXI_WREADY (axi_ram_axi_wready    ),     
		.M1_AXI_BRESP  (                      ),
		.M1_AXI_BVALID (                      ),
		.M1_AXI_BREADY (                      ),          
		.M1_AXI_ARADDR (dcache_ram_axi_araddr ),
		.M1_AXI_ARVALID(dcache_ram_axi_arvalid),
		.M1_AXI_ARREADY(axi_ram_axi_arready   ),    
		.M1_AXI_RDATA  (axi_ram_axi_rdata     ),
		.M1_AXI_RRESP  (                      ),
		.M1_AXI_RVALID (axi_ram_axi_rvalid    ),
		.M1_AXI_RREADY (dcache_ram_axi_rready ),
		.S0_AXI_AWADDR (axi_s0_axi_awaddr     ),
		.S0_AXI_AWVALID(axi_s0_axi_awvalid    ),
		.S0_AXI_AWREADY(rom_axi_awready       ), 
		.S0_AXI_WDATA  (axi_s0_axi_wdata      ),
		.S0_AXI_WSTRB  (                      ),
		.S0_AXI_WVALID (axi_s0_axi_wvalid     ),
		.S0_AXI_WREADY (rom_axi_wready        ),              
		.S0_AXI_ARADDR (axi_s0_axi_araddr     ),
		.S0_AXI_ARVALID(axi_s0_axi_arvalid    ),
		.S0_AXI_ARREADY(rom_axi_arready       ),    
		.S0_AXI_RDATA  (rom_axi_rdata         ),
		.S0_AXI_RVALID (rom_axi_rvalid        ),
		.S0_AXI_RREADY (axi_s0_axi_rready     ),
		.S1_AXI_AWADDR (axi_s1_axi_awaddr     ),
		.S1_AXI_AWVALID(axi_s1_axi_awvalid    ),
		.S1_AXI_AWREADY(ram_axi_awready       ),        
		.S1_AXI_WDATA  (axi_s1_axi_wdata      ),
		.S1_AXI_WSTRB  (                      ),
		.S1_AXI_WVALID (axi_s1_axi_wvalid     ),
		.S1_AXI_WREADY (ram_axi_wready        ),     
		.S1_AXI_ARADDR (axi_s1_axi_araddr     ),
		.S1_AXI_ARVALID(axi_s1_axi_arvalid    ),
		.S1_AXI_ARREADY(ram_axi_arready       ),
		.S1_AXI_RDATA  (ram_axi_rdata         ),
		.S1_AXI_RVALID (ram_axi_rvalid        ),
		.S1_AXI_RREADY (axi_s1_axi_rready     )
	);

	RAM RAM_inst
	(
		.clk            (clk               ),
		.rst            (rst               ),
		.ram_axi_awaddr (axi_s1_axi_awaddr ),
		.ram_axi_awvalid(axi_s1_axi_awvalid),
		.ram_axi_awready(ram_axi_awready   ),
		.ram_axi_wdata  (axi_s1_axi_wdata  ),
		.ram_axi_wstrb  (8'hff             ),
		.ram_axi_wvalid (axi_s1_axi_wvalid ),
		.ram_axi_wready (ram_axi_wready    ),
		.ram_axi_araddr (axi_s1_axi_araddr ),
		.ram_axi_arvalid(axi_s1_axi_arvalid),
		.ram_axi_arready(ram_axi_arready   ),
		.ram_axi_rdata  (ram_axi_rdata     ),
		.ram_axi_rvalid (ram_axi_rvalid    ),
		.ram_axi_rready (axi_s1_axi_rready )
	);

	ROM ROM_inst
	(
		.clk            (clk               ),
		.rst            (rst               ),
		.rom_axi_awaddr (axi_s0_axi_awaddr ),
		.rom_axi_awvalid(axi_s0_axi_awvalid),
		.rom_axi_awready(rom_axi_awready   ),
		.rom_axi_wdata  (axi_s0_axi_wdata  ),
		.rom_axi_wstrb  (8'hff             ),
		.rom_axi_wvalid (axi_s0_axi_wvalid ),
		.rom_axi_wready (rom_axi_wready    ),
		.rom_axi_araddr (axi_s0_axi_araddr ),
		.rom_axi_arvalid(axi_s0_axi_arvalid),
		.rom_axi_arready(rom_axi_arready   ),
		.rom_axi_rdata  (rom_axi_rdata     ),
		.rom_axi_rvalid (rom_axi_rvalid    ),
		.rom_axi_rlast  (                  ),
		.rom_axi_rready (axi_s0_axi_rready )
	);

endmodule


