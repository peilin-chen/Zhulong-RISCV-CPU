module RAM
(
	input  wire       clk            ,
	input  wire       rst            ,
	
	//AXI4-Lite总线接口 slave
	//写地址
	input wire [11:0]  ram_axi_awaddr ,
	input wire         ram_axi_awvalid,
	output reg         ram_axi_awready,
	//写数据 
	input wire [255:0] ram_axi_wdata  ,
	input wire [7 :0]  ram_axi_wstrb  ,
	input wire         ram_axi_wvalid ,
	output reg         ram_axi_wready ,
	//读地址 
	input wire [11:0]  ram_axi_araddr ,
	input wire         ram_axi_arvalid,
	output reg         ram_axi_arready,
	//读数据 
	output reg [255:0] ram_axi_rdata  ,
	output reg         ram_axi_rvalid ,
	input wire         ram_axi_rready
);

	reg [63:0] ram[0:1023];

	reg [11:0]  addr;
	reg         we  ;
	reg [255:0]  dout;
	reg [255:0]  din ;

	wire axi_whsk = ram_axi_awvalid & ram_axi_wvalid                                                   ;//写通道握手
	wire axi_rhsk = ram_axi_arvalid & (~ram_axi_rvalid | (ram_axi_rready & ram_axi_rvalid)) & ~axi_whsk;

	//读响应控制
	always @(posedge clk) 
		begin
			if(rst == 1'b1) begin
				ram_axi_rvalid <= 1'b0;
			end
			else begin
				if(axi_rhsk) begin
					ram_axi_rvalid <= 1'b1;
				end
				else if(ram_axi_rvalid & ram_axi_rready) begin
					ram_axi_rvalid <= 1'b0;
				end
				else begin
					ram_axi_rvalid <= ram_axi_rvalid;
				end
			end
		end

	always @(*)
		begin
			ram_axi_awready = axi_whsk     ;
			ram_axi_wready  = axi_whsk     ;
			ram_axi_rdata   = dout         ;
			ram_axi_arready = axi_rhsk     ;
			din             = ram_axi_wdata;
			if(axi_whsk) begin
				addr = ram_axi_awaddr;
				we   = 1'b1                ;
			end
			else begin
				if(axi_rhsk) begin
					addr = ram_axi_araddr;
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
				ram[addr + 3] <= din[255:192];
				ram[addr + 2] <= din[191:128];
				ram[addr + 1] <= din[127:64 ];
				ram[addr    ] <= din[63 :0  ];
			end
		end
	
	always @(*)
		begin
			if(rst == 1'b1) begin
				dout = 256'b0;
			end
			else if(ram_axi_awaddr == ram_axi_araddr) begin
				dout = din;
			end
			else begin
				dout = {ram[addr+3], ram[addr+2], ram[addr+1], ram[addr]};
			end
		end

endmodule





