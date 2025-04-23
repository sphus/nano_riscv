
`include "../defines.v"
module IF (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        input  wire                 inst_L      ,
        input  wire [`StateBus]     state       ,
        input  wire [`InstBus]      mem_rdata   ,
        output wire [`InstBus]      inst
    );

    wire [`InstBus] inst_dff;

    // IF阶段:如果是inst_L选择inst_dff,不然选择mem_rdata
    // EX阶段:选择mem_rdata
    // WB阶段:选择inst_dff
    assign inst =
           ({32{(state[`IF] &  inst_L) | state[`MEM]}} & inst_dff )|
           ({32{(state[`IF] & ~inst_L) | state[`EX]}} & mem_rdata);

    DFF #(`Wordnum) INST_DFF(
            .clk      (clk              ),
            .rstn     (rstn             ),
            .CE       (state[`EX]&inst_L),
            .set_data (`INST_NOP        ),
            .d        (mem_rdata        ),
            .q        (inst_dff         )
        );

endmodule
