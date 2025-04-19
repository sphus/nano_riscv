
`include "../defines.v"

module imm_gen (
        input  wire [`RegBus]       inst    ,
        input  wire [`sw_imm_bus]   imm_ctrl,
        output wire [`RegBus]       imm
    );

    assign imm =
           ({`Regnum{imm_ctrl[`IMMJ]}} & {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}    ) |
           ({`Regnum{imm_ctrl[`IMMU]}} & {inst[31:12], 12'b0}                                          ) |
           ({`Regnum{imm_ctrl[`IMMB]}} & {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}      ) |
           ({`Regnum{imm_ctrl[`IMMS]}} & {{20{inst[31]}}, inst[31:25], inst[11:7]}                     ) |
           ({`Regnum{imm_ctrl[`IMMI]}} & {{20{inst[31]}}, inst[31:20]}                                 ) ;

endmodule //imm_gen
