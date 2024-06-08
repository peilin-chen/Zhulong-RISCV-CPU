module AXI4_Lite
(
	input wire clk                   ,
	input wire rst                   ,
	
	//AXI4-Lite总线接口
	
	//master 0 interface
	//AW写地址
	input  wire [11:0] M0_AXI_AWADDR ,
	input  wire        M0_AXI_AWVALID,
	output reg         M0_AXI_AWREADY,
	                    
	//W写数据           
	input  wire [127:0]M0_AXI_WDATA  ,
	input  wire [7 :0] M0_AXI_WSTRB  ,
	input  wire        M0_AXI_WVALID ,
	output reg         M0_AXI_WREADY ,
                        
	//B写响应                
	output reg  [1 :0] M0_AXI_BRESP  ,
    output reg         M0_AXI_BVALID ,
	input  wire        M0_AXI_BREADY ,
	                    
	//AR读地址                   
	input  wire [11:0] M0_AXI_ARADDR ,
	input  wire        M0_AXI_ARVALID,
	output reg         M0_AXI_ARREADY,
	                    
	//R读数据           
	output reg  [127:0]M0_AXI_RDATA  ,
	output reg  [1 :0] M0_AXI_RRESP  ,
	output reg         M0_AXI_RVALID ,
	input  wire        M0_AXI_RREADY ,
	
	//master 1 interface
	//AW写地址
	input  wire [11:0] M1_AXI_AWADDR ,
	input  wire        M1_AXI_AWVALID,
	output reg         M1_AXI_AWREADY,
	                    
	//W写数据           
	input  wire [255:0] M1_AXI_WDATA  ,
	input  wire [7 :0] M1_AXI_WSTRB  ,
	input  wire        M1_AXI_WVALID ,
	output reg         M1_AXI_WREADY ,
                        
	//B写响应              
	output reg  [1 :0] M1_AXI_BRESP  ,
    output reg         M1_AXI_BVALID ,
	input  wire        M1_AXI_BREADY ,
	                    
	//AR读地址                 
	input  wire [11:0] M1_AXI_ARADDR ,
	input  wire        M1_AXI_ARVALID,
	output reg         M1_AXI_ARREADY,
	                    
	//R读数据           
	output reg  [255:0] M1_AXI_RDATA  ,
	output reg  [1 :0] M1_AXI_RRESP  ,
	output reg         M1_AXI_RVALID ,
	input  wire        M1_AXI_RREADY ,
	
	//slave 0 interface
	//AW写地址
	output wire [11:0] S0_AXI_AWADDR ,
	output wire        S0_AXI_AWVALID,
	input  wire        S0_AXI_AWREADY,
   
	//W写数据       
	output wire [127:0]S0_AXI_WDATA  ,
	output wire [7 :0] S0_AXI_WSTRB  ,
	output wire        S0_AXI_WVALID ,
	input  wire        S0_AXI_WREADY ,
                       
	//AR读地址                
	output wire [11:0] S0_AXI_ARADDR ,
	output wire        S0_AXI_ARVALID,
	input  wire        S0_AXI_ARREADY,
	                   	
	//R读数据          
	input  wire [127:0]S0_AXI_RDATA  ,
	input  wire        S0_AXI_RVALID ,
	output wire        S0_AXI_RREADY ,
	
	//slave 1 interface
	//AW写地址
	output wire [11:0] S1_AXI_AWADDR ,
	output wire        S1_AXI_AWVALID,
	input  wire        S1_AXI_AWREADY,
                        
	//W写数据           
	output wire [255:0] S1_AXI_WDATA  ,
	output wire [7 :0] S1_AXI_WSTRB  ,
	output wire        S1_AXI_WVALID ,
	input  wire        S1_AXI_WREADY ,
                        
	//AR读地址              
	output wire [11:0] S1_AXI_ARADDR ,
	output wire        S1_AXI_ARVALID,
	input  wire        S1_AXI_ARREADY,
	                    
	//R读数据           
	input  wire [255:0] S1_AXI_RDATA  ,
	input  wire        S1_AXI_RVALID ,
	output wire        S1_AXI_RREADY 
);

	//m0/m1 <-> master0/master1
	wire [11:0] master0_axi_awaddr ;
	wire        master0_axi_awvalid;
	wire        master0_axi_awready;
	wire [127:0]master0_axi_wdata  ;
	wire [7 :0] master0_axi_wstrb  ;
	wire        master0_axi_wvalid ;
	wire        master0_axi_wready ;
	wire [11:0] master0_axi_araddr ;
	wire        master0_axi_arvalid;
	wire        master0_axi_arready;
	reg  [127:0]master0_axi_rdata  ;
	wire        master0_axi_rvalid ;
	wire        master0_axi_rready ;

	wire [11:0] master1_axi_awaddr ;
	wire        master1_axi_awvalid;
	wire        master1_axi_awready;
	wire [255:0] master1_axi_wdata ;
	wire [7 :0] master1_axi_wstrb  ;
	wire        master1_axi_wvalid ;
	wire        master1_axi_wready ;
	wire [11:0] master1_axi_araddr ;
	wire        master1_axi_arvalid;
	wire        master1_axi_arready;
	reg  [255:0] master1_axi_rdata ;
	wire        master1_axi_rvalid ;
	wire        master1_axi_rready ;
	
	//m0/m1->master0/master1
	assign master0_axi_awaddr  = M0_AXI_AWADDR ;
	assign master0_axi_awvalid = M0_AXI_AWVALID;
	assign master0_axi_wdata   = M0_AXI_WDATA  ;
	assign master0_axi_wstrb   = M0_AXI_WSTRB  ;
	assign master0_axi_wvalid  = M0_AXI_WVALID ;
	assign master0_axi_araddr  = M0_AXI_ARADDR ;
	assign master0_axi_arvalid = M0_AXI_ARVALID;
	assign master0_axi_rready  = M0_AXI_RREADY ;
	
	assign master1_axi_awaddr  = M1_AXI_AWADDR ;
	assign master1_axi_awvalid = M1_AXI_AWVALID;
	assign master1_axi_wdata   = M1_AXI_WDATA  ;
	assign master1_axi_wstrb   = M1_AXI_WSTRB  ;
	assign master1_axi_wvalid  = M1_AXI_WVALID ;
	assign master1_axi_araddr  = M1_AXI_ARADDR ;
	assign master1_axi_arvalid = M1_AXI_ARVALID;
	assign master1_axi_rready  = M1_AXI_RREADY ;
	
	//master0/master1 -> m0/m1
	always @(*)
		begin
			M0_AXI_AWREADY = master0_axi_awready;
			M0_AXI_WREADY  = master0_axi_wready ;
			M0_AXI_ARREADY = master0_axi_arready;
			M0_AXI_RDATA   = master0_axi_rdata  ;
			M0_AXI_RVALID  = master0_axi_rvalid ;
			M1_AXI_AWREADY = master1_axi_awready;
			M1_AXI_WREADY  = master1_axi_wready ;
			M1_AXI_ARREADY = master1_axi_arready;
			M1_AXI_RDATA   = master1_axi_rdata  ;
			M1_AXI_RVALID  = master1_axi_rvalid ;
		end
	
	//slave w <-> master w
	assign S0_AXI_AWADDR = master0_axi_awaddr;
	assign S1_AXI_AWADDR = master1_axi_awaddr;
	
	assign S0_AXI_AWVALID = master0_axi_awvalid;
	assign S1_AXI_AWVALID = master1_axi_awvalid;
	
	assign S0_AXI_WDATA = master0_axi_wdata;
	assign S1_AXI_WDATA = master1_axi_wdata;
	
	assign S0_AXI_WSTRB = master0_axi_wstrb;
	assign S1_AXI_WSTRB = master1_axi_wstrb;
	
	assign S0_AXI_WVALID = master0_axi_wvalid;
	assign S1_AXI_WVALID = master1_axi_wvalid;
	
	assign master0_axi_awready = S0_AXI_AWREADY;
	assign master1_axi_awready = S1_AXI_AWREADY;
							   
	assign master0_axi_wready = S0_AXI_WREADY;
	assign master1_axi_wready = S1_AXI_WREADY;
	
	//slave a <-> master a
	assign S0_AXI_ARADDR = master0_axi_araddr;
	assign S1_AXI_ARADDR = master1_axi_araddr;
	
	assign S0_AXI_ARVALID = master0_axi_arvalid;
	assign S1_AXI_ARVALID = master1_axi_arvalid;
	
	assign master0_axi_arready = S0_AXI_ARREADY;
	assign master1_axi_arready = S1_AXI_ARREADY;

	//slave r <-> master r
	assign S0_AXI_RREADY = master0_axi_rready;
	assign S1_AXI_RREADY = master1_axi_rready;
							 
	assign master0_axi_rvalid = S0_AXI_RVALID;
	assign master1_axi_rvalid = S1_AXI_RVALID;
	
	/*assign master0_axi_rdata = S0_AXI_RDATA;
	assign master1_axi_rdata = S1_AXI_RDATA;*/
	
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				master0_axi_rdata <= 128'b0;
				master1_axi_rdata <= 256'b0;
			end
			else begin
				master0_axi_rdata <= S0_AXI_RDATA;
				master1_axi_rdata <= S1_AXI_RDATA;
			end
		end
	
	//多余端口处理
	wire valid = 1'b1;
	
	always @(*)
		begin
			M0_AXI_BRESP  = 2'b00;
			M0_AXI_BVALID = valid;
			M0_AXI_RRESP  = 2'b00;
			M1_AXI_BRESP  = 2'b00;
			M1_AXI_BVALID = valid;
			M1_AXI_RRESP  = 2'b00;
		end
	
endmodule


