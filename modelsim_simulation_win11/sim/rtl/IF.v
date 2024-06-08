module IF
(
	//from pc 
	input wire  [63:0] inst_addr_i     ,
	//I-Cache访问接口
	//to icache
	output wire [11:0] icache_req_addr ,
	output wire        icache_req_valid,
	output wire        icache_req_rw   ,
	//from icache
	input wire [31:0]  icache_data_read,
	input wire         icache_ready    ,
	input wire         icache_hit      ,
	//to if_id
	output wire [63:0] inst_addr_o     ,
	output wire [31:0] inst_o          ,
	//to ctrl
	output wire        hold_flag_if_o
);

	assign inst_addr_o   = inst_addr_i ;

	assign icache_req_addr  = inst_addr_i[13:2];
	assign icache_req_valid = 1'b1             ;
	assign icache_req_rw    = 1'b0             ;
	
	assign inst_o = (icache_ready == 1'b1) ? icache_data_read:32'h00000013;

	assign hold_flag_if_o = (icache_hit == 1'b0 && icache_ready == 1'b1) ? 1'b0:1'b1;
 
endmodule


