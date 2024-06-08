module ROM
(
	input  wire       clk            ,
	input  wire       rst            ,
	
	//AXI4-Lite总线接口 slave
	//写地址
	input wire [11:0] rom_axi_awaddr ,
	input wire        rom_axi_awvalid,
	output reg        rom_axi_awready,
	//写数据
	input wire [127:0]rom_axi_wdata  ,
	input wire [7 :0] rom_axi_wstrb  ,
	input wire        rom_axi_wvalid ,
	output reg        rom_axi_wready ,
	//读地址
	input wire [11:0] rom_axi_araddr ,
	input wire        rom_axi_arvalid,
	output reg        rom_axi_arready,
	//读数据
	output reg [127:0]rom_axi_rdata  ,
	output reg        rom_axi_rvalid ,
	output reg [2 :0] rom_axi_rlast  ,
	input wire        rom_axi_rready
);

	reg [31:0] rom[0:1023];

	reg [11:0]  addr;
	reg         we  ;
	reg [127:0] dout;
	reg [127:0] din ;

	wire axi_whsk = rom_axi_awvalid & rom_axi_wvalid                                                   ;//写通道握手
	wire axi_rhsk = rom_axi_arvalid & (~rom_axi_rvalid | (rom_axi_rready & rom_axi_rvalid)) & ~axi_whsk;

	//读响应控制
	always @(posedge clk) 
		begin
			if(rst == 1'b1) begin
				rom_axi_rvalid <= 1'b0;
				rom_axi_rlast  <= 1'b0;
			end
			else begin
				if(axi_rhsk) begin
					rom_axi_rvalid <= 1'b1;
				end
				else if(rom_axi_rvalid & rom_axi_rready) begin
					rom_axi_rvalid <= 1'b0;
				end
				else begin
					rom_axi_rvalid <= rom_axi_rvalid;
				end
			end
		end

	always @(*)
		begin
			rom_axi_awready = axi_whsk     ;
			rom_axi_wready  = axi_whsk     ;
			rom_axi_rdata   = dout         ;
			rom_axi_arready = axi_rhsk     ;
			din             = rom_axi_wdata;
			if(axi_whsk) begin
				addr = rom_axi_awaddr;
				we   = 1'b1          ;
			end
			else begin
				if(axi_rhsk) begin
					addr = rom_axi_araddr;
					we   = 1'b0          ;
				end
				else begin
					addr = 12'b0;
					we   = 1'b0 ;
				end
			end
		end

	always @(posedge clk) 
		begin
			if(we == 1'b1) begin
				rom[addr + 3] <= din[127:96];
				rom[addr + 2] <= din[95 :64];
				rom[addr + 1] <= din[63 :32];
				rom[addr    ] <= din[31 :0 ];
			end
		end
	
	always @(*)
		begin
			if(rst == 1'b1) begin
				dout = 128'b0;
			end
			else begin
				dout = {rom[addr+3], rom[addr+2], rom[addr+1], rom[addr]};
			end
		end

endmodule


