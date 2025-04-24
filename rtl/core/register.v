`include "../defines.v"
module register (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        input  wire [`RegAddrBus]   rs1_raddr   ,
        input  wire [`RegAddrBus]   rs2_raddr   ,
        input  wire [`RegAddrBus]   rd_waddr    ,
        input  wire [`InstBus   ]   rd_wdata    ,
        input  wire                 wen         ,
        output wire [`InstBus   ]   rs1_data    ,
        output wire [`InstBus   ]   rs2_data
    );

    wire [`InstBus] reg_mem [`Regnum-1:0];
    wire [`Regnum-1:0] rf_wen;

    // register file address index
    genvar rf;
    generate
        for (rf=0; rf < `Regnum; rf=rf+1)
        begin:regfile//{
            if(rf==0)
            begin: rf0
                // x0 cannot be wrote since it is constant-zeros
                assign rf_wen[rf] = `Disable;
                assign reg_mem[rf] = `ZeroWord;
            end
            else
            begin: rfno0
                // rd_waddr == register and wen
                assign rf_wen[rf] = wen & (rd_waddr == rf) ;
                DFF #(`Wordnum) register(
                        .clk      (clk         ),
                        .rstn     (rstn        ),
                        .CE       (rf_wen[rf]  ),
                        .set_data (`ZeroWord   ),
                        .d        (rd_wdata    ),
                        .q        (reg_mem[rf] )
                    );
            end
        end
    endgenerate

    assign rs1_data = reg_mem[rs1_raddr];
    assign rs2_data = reg_mem[rs2_raddr];

endmodule
