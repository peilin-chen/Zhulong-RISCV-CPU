module Multiplier
(
	input  wire        clk        ,
	input  wire        rst        ,
	input  wire        mult_ready ,
	input  wire [9 :0] inst_op_f3 ,
	input  wire [63:0] mult_op1   ,
	input  wire [63:0] mult_op2   ,
	output wire [63:0] product_val,
	output wire        mult_finish,
	output reg         busy_o
);
	
	parameter INST_MUL    = 10'b0110011000;
	parameter INST_MULH   = 10'b0110011001;
	parameter INST_MULHSU = 10'b0110011010;
	parameter INST_MULHU  = 10'b0110011011;
	parameter INST_MULW   = 10'b0111011000;
	
	reg        mult_valid;
	reg [63:0] multiplier;
	
	assign mult_finish = mult_valid & ~(|multiplier);
	
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				mult_valid <= 1'b1;
			end
			else if(~mult_ready | mult_finish) begin
				mult_valid <= 1'b0;
			end
			else begin
				mult_valid <= 1'b1;
			end
		end
	
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				busy_o <= 1'b0;
			end
			else if(mult_finish) begin
				busy_o <= 1'b0;
			end
			else if(mult_ready) begin
				busy_o <= 1'b1;
			end
			else begin
				busy_o <= 1'b0;
			end
		end
	
	wire        op1_signbit ;
	wire        op2_signbit ;
	wire [63:0] op1_absolute;
	wire [63:0] op2_absolute;
	
	assign op1_signbit  = mult_op1[63]                          ;
	assign op2_signbit  = mult_op2[63]                          ;
	assign op1_absolute = ((op1_signbit&&inst_op_f3==INST_MUL) || (op1_signbit&&inst_op_f3==INST_MULHSU) || (op1_signbit&&inst_op_f3==INST_MULH) || (op1_signbit&&inst_op_f3==INST_MULW)) ? (~mult_op1+1) : mult_op1;
	assign op2_absolute = ((op2_signbit&&inst_op_f3==INST_MUL) || (op2_signbit&&inst_op_f3==INST_MULH) || (op2_signbit&&inst_op_f3==INST_MULW)) ? (~mult_op2+1) : mult_op2;
	
	reg [127:0] multiplicand;
	
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				multiplicand <= 128'b0;
			end
			else if(mult_valid) begin
				multiplicand <= {multiplicand[126:0], 1'b0}; //左移
			end
			else if(mult_ready) begin
				multiplicand <= {64'b0, op1_absolute};
			end
		end
		
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				multiplier <= 64'b0;
			end
			else if(mult_valid) begin
				multiplier <= {1'b0, multiplier[63:1]}; //右移
			end
			else if(mult_ready) begin
				multiplier <= op2_absolute;
			end
		end
		
	wire [127:0] product_lins;
	
	assign product_lins = multiplier[0] ? multiplicand : 128'b0;
	
	reg [127:0] product_temp;
	
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				product_temp <= 128'b0;
			end
			else if(mult_valid) begin
				product_temp <= product_temp + product_lins;
			end
			else if(mult_ready) begin
				product_temp <= 128'b0;
			end
		end
	
	reg product_signbit;
	
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				product_signbit <= 1'b0;
			end
			else if(mult_valid) begin
				product_signbit <= op1_signbit ^ op2_signbit;
			end
			else begin
				product_signbit <= op1_signbit ^ op2_signbit;
			end
		end
	
	assign product_val = (inst_op_f3 == INST_MUL   ) ? ((product_signbit&&mult_op1!=64'd0&&mult_op2!=64'd0) ? ~product_temp[63 :0 ]+64'd1 : product_temp[63 :0 ]) :
						 (inst_op_f3 == INST_MULH  ) ? ((product_signbit&&mult_op1!=64'd0&&mult_op2!=64'd0) ? ~product_temp[127:64]+64'd1 : product_temp[127:64]) :
						 (inst_op_f3 == INST_MULHU ) ? product_temp[127:64]                                               :
						 (inst_op_f3 == INST_MULHSU) ? ((op1_signbit&&mult_op1!=64'd0&&mult_op2!=64'd0) ? ~product_temp[127:64] : product_temp[127:64])     :
						 (inst_op_f3 == INST_MULW  ) ? ((product_signbit&&mult_op1!=64'd0&&mult_op2!=64'd0) ? (~product_temp[31] ? {32'hffffffff,(~product_temp[31:0]+32'd1)} : {32'b0,(~product_temp[31:0]+32'd1)}) : (product_temp[31] ? {32'hffffffff,product_temp[31:0]} : {32'b0,product_temp[31:0]})) : 64'b0;
endmodule


