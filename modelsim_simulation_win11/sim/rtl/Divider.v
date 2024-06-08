module Divider
(
	input  wire        clk         ,
	input  wire        rst         ,
	input  wire [63:0] diviser     ,
	input  wire [63:0] dividend    ,
	input  wire [9 :0] inst_op_f3  ,
	input  wire        div_ready   ,
	output wire [63:0] div_rem_data,
	output wire        div_finish  ,
	output reg         busy_o     
);
	
	parameter INST_DIV   = 10'b0110011100;
	parameter INST_DIVU  = 10'b0110011101;
	parameter INST_REM   = 10'b0110011110;
	parameter INST_REMU  = 10'b0110011111;
	parameter INST_DIVW  = 10'b0111011100;
	parameter INST_DIVUW = 10'b0111011101;
	parameter INST_REMW  = 10'b0111011110;
	parameter INST_REMUW = 10'b0111011111;
	
	reg [6 :0] counter   ;
	reg        sign      ;
	reg        sign_y    ;
	reg [63:0] dividend_t;
	reg [63:0] divider_t ;
	
	reg  [127:0] temp_a   ;
	reg  [127:0] temp_b   ;
	reg          finish   ;
	wire         sign_inst;
	
	assign sign_inst = (inst_op_f3 == INST_DIV) || (inst_op_f3 == INST_DIVW) || (inst_op_f3 == INST_REM) || (inst_op_f3 == INST_REMW);
	
	reg [63:0] yushu;
	reg [63:0] shang;

	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				counter    = 7'b0  ;
				dividend_t = 64'b0 ;
				divider_t  = 64'b0 ;
				temp_a     = 128'b0;
				temp_b     = 128'b0;
				finish     = 1'b0  ;
				sign       = 1'b0  ;
				sign_y     = 1'b0  ;
				busy_o     = 1'b0  ;
			end
			else begin
				case(counter)
					0:begin
						if(div_ready) begin
							counter = counter + 1;
							finish  = 1'b0       ;
							busy_o  = 1'b1       ;
							if(sign_inst && dividend[63] && diviser[63]) begin
								dividend_t = ~dividend + 1;
								divider_t  = ~diviser + 1 ;
								sign       = 1'b0         ;
								sign_y     = 1'b1         ;
							end
							else if(sign_inst && dividend[63]) begin
								dividend_t = ~dividend + 1;
								divider_t  = diviser      ;
								sign       = 1'b1         ;
								sign_y     = 1'b1         ;
							end
							else if(sign_inst && diviser[63]) begin
								divider_t  = ~diviser + 1;
								dividend_t = dividend    ;
								sign       = 1'b1        ;
								sign_y     = 1'b0        ;
							end
							else begin
								divider_t  = diviser ;
								dividend_t = dividend;
								sign       = 1'b0    ;
								sign_y     = 1'b0    ;
							end
						end
					end
					1:begin
						temp_a  = {64'b0, dividend_t};
						temp_b  = {divider_t, 64'b0 };
						counter = counter + 1        ;
						busy_o  = 1'b1               ;
					end
					66:begin
						finish  = 1'b1       ;
						counter = counter + 1;
						busy_o  = 1'b0       ;
					end
					67:begin
						counter = 7'b0;
						finish  = 1'b0;
						busy_o  = 1'b0;
					end
					default:begin
						counter = counter + 1;
						temp_a  = {temp_a[126:0], 1'b0};
						if(temp_a >= temp_b) begin
							temp_a = temp_a - temp_b + 1'b1;
						end
						else begin
							temp_a = temp_a;
						end
					end
				endcase
			end
		end
	
	always @(*)
		begin
			if(rst == 1'b1) begin
				yushu = 64'b0;
				shang = 64'b0;
			end
			else if(diviser == 64'd0) begin
				if((inst_op_f3 == INST_DIV) || (inst_op_f3 == INST_DIVU) || (inst_op_f3 == INST_DIVUW) || (inst_op_f3 == INST_DIVW)) begin
					shang = 64'hffff_ffff_ffff_ffff;
					yushu = 64'hffff_ffff_ffff_ffff;
				end
				else begin
					shang = 64'hffff_ffff_ffff_ffff;
					yushu = dividend               ;
				end
			end
			else if(finish) begin
				if(sign && (!sign_y)) begin
					yushu = temp_a[127:64]     ;
					shang = ~temp_a[63 : 0] + 1;
				end
				else if(sign && sign_y) begin
					yushu = ~temp_a[127:64] + 1;
					shang = ~temp_a[63 : 0] + 1;
				end
				else if((!sign) && (sign_y)) begin
					yushu = ~temp_a[127:64] + 1;
					shang = temp_a[63 : 0]     ;
				end
				else begin
					yushu = temp_a[127:64];
					shang = temp_a[63 : 0];
				end
			end
			else begin
				yushu = temp_a[127:64];
				shang = temp_a[63 : 0];
			end
		end
	
	assign div_finish = finish;
	assign div_rem_data = ((inst_op_f3 == INST_DIV) || (inst_op_f3 == INST_DIVU)) ? shang :
						  ((inst_op_f3 == INST_DIVUW) || (inst_op_f3 == INST_DIVW)) ? {{32{shang[31]}}, shang[31:0]} :
	                      ((inst_op_f3 == INST_REM) || (inst_op_f3 == INST_REMU)) ? yushu : 
						  ((inst_op_f3 == INST_REMUW) || (inst_op_f3 == INST_REMW)) ? {{32{yushu[31]}}, yushu[31:0]} : 64'b0;
	
endmodule


