module CTRL
(
	input  wire [63:0] jump_addr_i      ,
	input  wire        jump_en_i        ,
	input  wire        hold_flag_ex_i   ,
	input  wire        hold_flag_clint_i,
	input  wire        hold_flag_mem_i  ,
	input  wire        hold_flag_if_i   ,
	output reg  [63:0] jump_addr_o      ,
	output reg         jump_en_o        ,
	output reg  [1 :0] hold_flag_o      ,
	output reg         mem_en
);

	always @(*)
		begin
			jump_addr_o = jump_addr_i;
			jump_en_o   = jump_en_i  ;
			if(jump_en_i || hold_flag_ex_i || hold_flag_clint_i) begin
				hold_flag_o = 2'b01;
				mem_en      = 1'b0 ;
			end
			else if (hold_flag_mem_i) begin
				hold_flag_o = 2'b10;
				mem_en      = 1'b1 ;
			end
			else if (hold_flag_if_i) begin
				hold_flag_o = 2'b10;
				mem_en      = 1'b0 ;
			end
			else begin
				hold_flag_o = 2'b11;
				mem_en      = 1'b0 ;
			end
		end

endmodule


