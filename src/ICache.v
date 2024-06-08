`timescale 1ns / 1ns

//cache共32块，分为16组，每组2块，即两路组相联，1块=4字，1字=4字节 cache size: 512 Byte
//主存共1024块，4096个字
//主存地址共12位，[1:0]为块内偏移，[5:2]为组地址，[11:6]为Tag
//V、D、Tag、Data=1+1+6+128=136
//更新策略：回写    分配策略：读分配+写分配    替换策略：随机替换

module ICache
(
    input               clk           ,
    input               rst           ,
    //cpu<->cache  
    input      [11:0]   cpu_req_addr  ,
    input               cpu_req_valid ,
    input               cpu_req_rw    ,
    input      [31:0]   cpu_data_write,
    input               cpu_jump      ,
    output reg [31:0]   cpu_data_read ,
    output reg          cpu_ready     ,
    output              icache_hit    ,
    //cache<->rom
    //读地址
    output reg [11:0]  rom_axi_araddr , //cache向主存发起读请求时使用的地址
    output reg         rom_axi_arvalid, //cache向主存发起读请求的请求信号
    input              rom_axi_arready, //读请求是否被接收到的握手信号
    //读数据
    input      [127:0] rom_axi_rdata  , //主存向cache返回的数据
    input              rom_axi_rvalid , //主存向cache返回数据时的数据有效信号
    output             rom_axi_rready , //标识当前的cache已经准备好可以接受主存返回的数据
    //写地址
    output reg [11:0]  rom_axi_awaddr , //cache向主存发起写请求时使用的地址
    output reg         rom_axi_awvalid, //cache向主存发起写请求的请求信号
    input              rom_axi_awready, //写请求是否被接受到的握手信号
    //写数据
    output reg [127:0] rom_axi_wdata  , //cache向主存写入的数据
    output reg         rom_axi_wvalid , //主存向cache写入数据时的数据有效信号
    input              rom_axi_wready   //标识主存已经准备好可以接受cache写入的数据
);

    parameter IDLE       = 0; 
    parameter CompareTag = 1;
    parameter Allocate   = 2;
    parameter WriteBack  = 3;

    parameter V        = 135;
    parameter D        = 134;
    parameter TagMSB   = 133;
    parameter TagLSB   = 128;
    parameter BlockMSB = 127;
    parameter BlockLSB = 0  ;

    reg [135:0] cache_data[0:31] ; //32个块
    reg [1  :0] state, next_state;
    reg         hit              ;
    reg         hit1 ,hit2       ;
    reg         way              ; //若hit，则way无意义，若miss，则way表示分配的那一路

    wire [3:0] cpu_req_index ;
    wire [5:0] cpu_req_tag   ;
    wire [1:0] cpu_req_offset;

    assign cpu_req_offset = cpu_req_addr[1 :0]; //块内偏移
    assign cpu_req_index  = cpu_req_addr[5 :2]; //组地址
    assign cpu_req_tag    = cpu_req_addr[11:6]; //Tag

    integer i;
    //初始化cache
    //initial
    //    begin
    //        for(i = 0; i < 32; i = i+1)
    //            cache_data[i] = 136'd0;
    //    end

    always @(posedge clk) begin
        if(rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    //state change
    always @(*) begin
        case(state)
            IDLE:
                if(cpu_req_valid)
                    next_state = CompareTag;
                else
                    next_state = IDLE;
            CompareTag:
                if(hit)                     //若hit
                    next_state = IDLE;
                else if(cache_data[2*cpu_req_index+way][V:D] == 2'b11) //被分配的块有效且脏，则先写回主存
                    next_state = WriteBack;
                else
                    next_state = Allocate;
            Allocate:
                if(rom_axi_rvalid && rom_axi_arready)
                    next_state = CompareTag;
                else
                    next_state = Allocate;
            WriteBack:
                if(rom_axi_awready && rom_axi_wready)
                    next_state = Allocate;
                else
                    next_state = WriteBack;
            default:next_state = IDLE;
        endcase
    end

    //way1 hit
    always @(*) begin
        if(state == CompareTag) begin
            if(cache_data[2*cpu_req_index][V] == 1'b1 && cache_data[2*cpu_req_index][TagMSB:TagLSB] == cpu_req_tag)
                hit1=1'b1;
            else
                hit1=1'b0;
        end
        else
            hit1=1'b0;
    end

    //way2 hit
    always @(*) begin
        if(state == CompareTag) begin
            if(cache_data[2*cpu_req_index+1][V] == 1'b1 && cache_data[2*cpu_req_index+1][TagMSB:TagLSB] == cpu_req_tag)
                hit2 = 1'b1;
            else
                hit2 = 1'b0;
        end
        else
            hit2 = 1'b0;
    end

    //hit
    always @(*) begin
        if(state == CompareTag)
            hit = hit1 || hit2;
        else
            hit = 1'b0;
    end

    //way       cache miss时分配的块在组内的位置
    always @(*) begin 
        if((state == CompareTag) && (hit == 1'b0)) begin   //未命中
            case({cache_data[2*cpu_req_index][V], cache_data[2*cpu_req_index+1][V]})
                2'b01  :way = 1'b0;                    //第0路可用
                2'b10  :way = 1'b1;                    //第1路可用
                2'b00  :way = 1'b0;                    //第0、1路均可用
                2'b11  :way = 1'b0;                    //第0、1路均不可用，默认替换第0路
                default:way = 1'b0;
            endcase
        end
    end

    //CompareTag
    always @(posedge clk) begin
        if(state == CompareTag && hit) begin
            if(cpu_req_rw == 1'b0) //read hit
                begin
                    cpu_ready <= 1'b1;
                    if(hit1 && cpu_jump==1'b0) //语法的一般形式是[start_index +: size]，其中start_index是要选择的起始位的索引，size是要选择的位的数量
                        cpu_data_read <= cache_data[2*cpu_req_index][32*cpu_req_offset +: 32]; 
                    else if(hit1 && cpu_jump==1'b1) 
                        cpu_data_read <= 32'h00000013;
                    else if(hit2 && cpu_jump==1'b0)
                        cpu_data_read <= cache_data[2*cpu_req_index+1][32*cpu_req_offset +: 32];
                    else if(hit2 && cpu_jump==1'b1)
                        cpu_data_read <= 32'h00000013;
                end
            else //write hit
                begin
                    cpu_ready <= 1'b1;
                    if(hit1) 
                        begin                                
                            cache_data[2*cpu_req_index][32*cpu_req_offset +:32] <= cpu_data_write;
                            cache_data[2*cpu_req_index][D]                      <= 1'b1          ;
                        end
                    else
                        begin
                            cache_data[2*cpu_req_index+1][32*cpu_req_offset +:32] <= cpu_data_write;
                            cache_data[2*cpu_req_index+1][D]                      <= 1'b1          ;
                        end
                end
        end
        else
            cpu_ready<=1'b0;

        //Allocate and WriteBack
        if(state == Allocate) begin //load new block from memory to cache
            if(!rom_axi_rvalid)
                begin
                    rom_axi_arvalid <= 1'b1                       ;
                    rom_axi_araddr  <= {cpu_req_addr[11:2], 2'b00};
                end
            else
                begin
                    rom_axi_arvalid                   <= 1'b0                               ;
                    cache_data[2*cpu_req_index+way] <= {2'b10, cpu_req_tag, rom_axi_rdata};
                end
        end
        else if(state == WriteBack) begin //write dirty old block to memory
            if(!rom_axi_wready)
                begin
                    rom_axi_awvalid  <= 1'b1                                                                  ;
                    rom_axi_wvalid   <= 1'b1;
                    rom_axi_awaddr   <= {cache_data[2*cpu_req_index+way][TagMSB:TagLSB], cpu_req_index, 2'b00};
                    rom_axi_wdata <= cache_data[2*cpu_req_index+way][BlockMSB:BlockLSB]                    ;                
                end
            else
                rom_axi_awvalid <= 1'b0;
                rom_axi_wvalid  <= 1'b0;
        end
        else begin
            rom_axi_arvalid <= 1'b0;
            rom_axi_awvalid <= 1'b0;
            rom_axi_wvalid  <= 1'b0;
        end
    end

    //Allocate and WriteBack
    /*always @(posedge clk) begin
        if(state == Allocate) begin //load new block from memory to cache
            if(!rom_axi_rvalid)
                begin
                    rom_axi_arvalid <= 1'b1                       ;
                    rom_axi_araddr  <= {cpu_req_addr[11:2], 2'b00};
                end
            else
                begin
                    rom_axi_arvalid                   <= 1'b0                               ;
                    cache_data[2*cpu_req_index+way] <= {2'b10, cpu_req_tag, rom_axi_rdata};
                end
        end
        else if(state == WriteBack) begin //write dirty old block to memory
            if(!rom_axi_wready)
                begin
                    rom_axi_awvalid  <= 1'b1                                                                  ;
                    rom_axi_wvalid   <= 1'b1;
                    rom_axi_awaddr   <= {cache_data[2*cpu_req_index+way][TagMSB:TagLSB], cpu_req_index, 2'b00};
                    rom_axi_wdata <= cache_data[2*cpu_req_index+way][BlockMSB:BlockLSB]                    ;                
                end
            else
                rom_axi_awvalid <= 1'b0;
                rom_axi_wvalid  <= 1'b0;
        end
        else begin
            rom_axi_arvalid <= 1'b0;
            rom_axi_awvalid <= 1'b0;
            rom_axi_wvalid  <= 1'b0;
        end
    end*/

    assign rom_axi_rready = (state == Allocate) ? 1:0;
    assign icache_hit = hit;

endmodule

