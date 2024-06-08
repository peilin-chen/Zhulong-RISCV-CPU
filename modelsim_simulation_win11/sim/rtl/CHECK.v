module CHECK
(
	//from id
	input wire [4 :0] rs1_addr_i       ,
	input wire [4 :0] rs2_addr_i       ,
	//from ex
	input wire [63:0] ram_addr_i       ,
	input wire        ram_req_i        ,
	//from ex                          
	input wire [4 :0] ex_rd_addr_i     ,
	input wire [63:0] ex_rd_data_i     ,
	input wire        ex_rd_wen_i      ,
	//from ex_mem mem                     
	input wire [4 :0] mem_rd_addr_i    ,
	input wire [63:0] mem_rd_data_i    ,
	input wire        mem_rd_wen_i     ,
	//input wire        ex_mem_ram_we_i  ,
	//input wire [63:0] ex_mem_ram_addr_i,
	//input wire [63:0] ex_mem_ram_data_i,
	//input wire        ex_mem_ram_req_i ,
	//to id 
	output reg [63:0] rs1_data_o       ,
	output reg [63:0] rs2_data_o       ,
	output reg        rs1_valid        ,
	output reg        rs2_valid        
	//to ex                            
	//output reg [63:0] ram_data_o       ,
	//output reg        ram_data_valid
);

	//check ram_addr_i
	/*always @(*)
		begin
			if(ram_req_i == 1'b1 && ex_mem_ram_we_i == 1'b1 && ex_mem_ram_req_i == 1'b1 && ram_addr_i == ex_mem_ram_addr_i) begin
				ram_data_o     = ex_mem_ram_data_i;
				ram_data_valid = 1'b1             ;
			end
			else begin
				ram_data_o     = 64'b0;
				ram_data_valid = 1'b0 ;
			end
		end*/
	
	//check rs1_addr_i
	always @(*)
		begin
			if(rs1_addr_i == ex_rd_addr_i && ex_rd_wen_i == 1'b1 && rs1_addr_i != 5'b0) begin
				rs1_data_o = ex_rd_data_i;
				rs1_valid  = 1'b1        ;
			end
			else if(rs1_addr_i == mem_rd_addr_i && mem_rd_wen_i == 1'b1 && rs1_addr_i != 5'b0) begin
				rs1_data_o = mem_rd_data_i;
				rs1_valid  = 1'b1         ;
			end
			else if(rs1_addr_i == 5'b0) begin
				rs1_data_o = 64'b0;
				rs1_valid  = 1'b1 ;
			end
			else begin
				rs1_data_o = 64'b0;
				rs1_valid  = 1'b0 ;
			end
		end
		
	//chech rs2_addr_i
	always @(*)
		begin
			if(rs2_addr_i == ex_rd_addr_i && ex_rd_wen_i == 1'b1 && rs2_addr_i != 5'b0) begin
				rs2_data_o = ex_rd_data_i;
				rs2_valid  = 1'b1        ;
			end
			else if(rs2_addr_i == mem_rd_addr_i && mem_rd_wen_i == 1'b1 && rs2_addr_i != 5'b0) begin
				rs2_data_o = mem_rd_data_i;
				rs2_valid  = 1'b1         ;
			end
			else if(rs2_addr_i == 5'b0) begin
				rs2_data_o = 64'b0;
				rs2_valid  = 1'b1 ;
			end
			else begin
				rs2_data_o = 64'b0;
				rs2_valid  = 1'b0 ;
			end
		end

endmodule


