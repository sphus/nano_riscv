
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

    // IF state: select inst_dff if inst_L, mem_rdata otherwise
    // EX state: Select mem_rdata
    // WB state: Select inst_dff
    assign inst =
           ({32{(state[`IF] &  inst_L) | state[`MEM]}} & inst_dff )|
           ({32{(state[`IF] & ~inst_L) | state[`EX] }} & mem_rdata);

    DFF #(`Wordnum) INST_DFF(
            .clk      (clk              ),
            .rstn     (rstn             ),
            .CE       (state[`EX]&inst_L),
            .set_data (`INST_NOP        ),
            .d        (mem_rdata        ),
            .q        (inst_dff         )
        );

endmodule
