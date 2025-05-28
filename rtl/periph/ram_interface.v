`include "../defines.v"

module ram_interface (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        output wire [`InstBus]      mem_rdata   ,
        input  wire [`InstBus]      mem_wdata   ,
        input  wire [`InstBus]      mem_addr    ,
        input  wire [`mem_type_bus] mem_type    ,
        input  wire                 mem_sign    ,
        input  wire                 rimem       ,
        input  wire                 rdmem       ,
        input  wire                 wmem        ,

        input  wire [`InstBus]      r_data      ,
        output wire [`InstBus]      addr        ,
        output wire [`InstBus]      w_data      ,
        output wire [3:0]           wen         ,
        output wire                 dbusy       ,
        output wire                 ren
    );

    assign addr = mem_addr;
    assign ren  = rimem | rdmem;

    reg [`mem_type_bus] type_reg;
    reg [1:0]   addr_reg;
    reg         sign_reg;

    // busy sign generate
    wire r_busy_in  = rdmem;

    reg dbusy_reg;

    always @(posedge clk)
        dbusy_reg   <= rstn ? dbusy : `Disable;

    assign dbusy = ~dbusy_reg & r_busy_in;

    always @(posedge clk)
    begin
        if (!rstn)
            type_reg <= `LS_B;
        else if (rimem | rdmem | wmem)
            type_reg <= mem_type;
    end

    always @(posedge clk)
    begin
        if (!rstn)
            addr_reg <= `ZeroWord;
        else if (rimem | rdmem | wmem)
            addr_reg <= mem_addr[1:0];
    end

    always @(posedge clk)
    begin
        if (!rstn)
            sign_reg <= `Disable;
        else if (rimem | rdmem | wmem)
            sign_reg <= mem_sign;
    end

    // write memory signal

    wire [35:0] mem_wb =
         {36{mem_addr[1:0] == 2'b00}} & {4'b0001,24'b0,mem_wdata[7:0]      } |
         {36{mem_addr[1:0] == 2'b01}} & {4'b0010,16'b0,mem_wdata[7:0],8'b0 } |
         {36{mem_addr[1:0] == 2'b10}} & {4'b0100,8'b0 ,mem_wdata[7:0],16'b0} |
         {36{mem_addr[1:0] == 2'b11}} & {4'b1000,      mem_wdata[7:0],24'b0} ;

    wire [35:0] mem_wh = mem_addr[1] ?
         {4'b1100,mem_wdata[15: 0],16'b0}:
         {4'b0011,16'b0,mem_wdata[15: 0]};

    wire [35:0] mem_ww = {4'b1111,mem_wdata};

    assign {wen,w_data} = {36{wmem}} &
           ({36{mem_type == `LS_B}} & mem_wb |
            {36{mem_type == `LS_H}} & mem_wh |
            {36{mem_type == `LS_W}} & mem_ww);

    // read memory signal

    wire [`InstBus] mem_rb =
         {`Wordnum{addr_reg[1:0] == 2'b00}} & {{24{r_data[ 7]& ~sign_reg}},r_data[ 7: 0]} |
         {`Wordnum{addr_reg[1:0] == 2'b01}} & {{24{r_data[15]& ~sign_reg}},r_data[15: 8]} |
         {`Wordnum{addr_reg[1:0] == 2'b10}} & {{24{r_data[23]& ~sign_reg}},r_data[23:16]} |
         {`Wordnum{addr_reg[1:0] == 2'b11}} & {{24{r_data[31]& ~sign_reg}},r_data[31:24]} ;

    wire [`InstBus] mem_rh = addr_reg[1] ?
         {{16{r_data[31]& ~sign_reg}},r_data[31:16]}:
         {{16{r_data[15]& ~sign_reg}},r_data[15: 0]};

    assign mem_rdata =
           {`Wordnum{type_reg == `LS_B}} & mem_rb |
           {`Wordnum{type_reg == `LS_H}} & mem_rh |
           {`Wordnum{type_reg == `LS_W}} & r_data;

endmodule //ram_interface
