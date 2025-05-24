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
    wire [`Regnum-1:0] rf_index_wen;

    // register file address index
    genvar rf_index;
    generate
        for (rf_index=0; rf_index < `Regnum; rf_index=rf_index+1)
        begin:regfile//{
            if(rf_index==0)
            begin: rf_index_0
                // x0 cannot be wrote since it is constant-zeros
                assign rf_index_wen[rf_index] = `Disable;
                assign reg_mem[rf_index] = `ZeroWord;
            end
            else
            begin: rf_index_no0
                assign rf_index_wen[rf_index] = wen & (rd_waddr == rf_index) ;
                DFF #(`Wordnum) register(
                        .clk      (clk                      ),
                        .rstn     (rstn                     ),
                        .CE       (rf_index_wen[rf_index]   ),
                        .set_data (`ZeroWord                ),
                        .d        (rd_wdata                 ),
                        .q        (reg_mem[rf_index]        )
                    );
            end
        end
    endgenerate

    assign rs1_data = reg_mem[rs1_raddr];
    assign rs2_data = reg_mem[rs2_raddr];

endmodule
