
`include "../defines.v"
module IF (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        input  wire                 inst_CE     ,
        input  wire                 inst_sel    ,
        input  wire [`InstBus]      mem_rdata   ,
        output wire [`InstBus]      inst
    );

    wire [`InstBus] inst_dff;

    assign inst = inst_sel ? inst_dff : mem_rdata;

    DFF #(`Wordnum) INST_DFF(
            .clk      (clk      ),
            .rstn     (rstn     ),
            .CE       (inst_CE  ),
            .set_data (`INST_NOP),
            .d        (mem_rdata),
            .q        (inst_dff )
        );

endmodule
