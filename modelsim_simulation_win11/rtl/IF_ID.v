`include "defines.v"

module IF_ID
(
	input wire         clk        ,
	input wire         rst        ,
	//from ctrl
	input wire  [1 :0] hold_flag_i,
	//from if
	input wire  [63:0] inst_addr_i,
	input wire  [31:0] inst_i ,
	//to id
	output wire [63:0] inst_addr_o,
	output wire [31:0] inst_o
);

	/*reg rom_flag;
	
	always @(posedge clk) 
		begin
			if(rst == 1'b1 | hold_flag_i == 2'b01) begin
				rom_flag <= 1'b0;
			end
			else begin
				rom_flag <= 1'b1;
			end
		end
	
	assign rom_inst_o = rom_flag?rom_inst_i:64'h0000_0013;
	
	//wire [63:0] rom_inst_t;

	//assign rom_inst_t = {32'b0, rom_inst_i};*/

	DFF_SET 
	#
	(
		.DW(64)
	) 
	dff1
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
		.DW(32)
	) 
	dff2
	(
		.clk        (clk          ),
		.rst        (rst          ),
		.hold_flag_i(hold_flag_i  ),
		.set_data   (`INST_NOP),
	    .data_i     (inst_i   ),
        .data_o     (inst_o   )
	);
		
endmodule


