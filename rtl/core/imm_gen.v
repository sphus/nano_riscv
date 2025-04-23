
`include "../defines.v"

module imm_gen (
        input  wire [`InstBus]       inst    ,
        input  wire [`sw_imm_bus]   imm_ctrl,
        output wire [`InstBus]       imm
    );

    wire [`InstBus] immJ = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}    ;
    wire [`InstBus] immB = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}      ;
    wire [`InstBus] immU = {inst[31:12], 12'b0}                                          ;
    wire [`InstBus] immS = {{20{inst[31]}}, inst[31:25], inst[11:7]}                     ;
    wire [`InstBus] immI = {{20{inst[31]}}, inst[31:20]}                                 ;

    assign imm =
           ({`Wordnum{imm_ctrl[`IMMJ]}} & immJ) |
           ({`Wordnum{imm_ctrl[`IMMB]}} & immB) |
           ({`Wordnum{imm_ctrl[`IMMU]}} & immU) |
           ({`Wordnum{imm_ctrl[`IMMS]}} & immS) |
           ({`Wordnum{imm_ctrl[`IMMI]}} & immI) ;

endmodule //imm_gen
