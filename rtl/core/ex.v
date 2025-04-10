
`include "../defines.v"
module ex (
        // data
        input  wire [`RegBus]       inst_addr    ,
        input  wire [`RegBus]       rs1_data     ,
        input  wire [`RegBus]       rs2_data     ,
        // control
        input  wire                 rmem         ,    // memory   read  enable
        input  wire                 wmem         ,    // memory   write enable
        input  wire                 jmp          ,    // Jump
        input  wire                 jcc          ,    // Jump on Condition
        input  wire [`ALU_ctrl_bus] alu_ctrl     ,    // ALU Control
        input  wire                 jal          ,    // JAL  Instruction
        input  wire                 jalr         ,    // JALR Instruction
        input  wire                 lui          ,    // LUI Instruction
        input  wire                 auipc        ,    // AUIPC Instruction
        input  wire                 inst_R       ,    // INST TYPE R
        input  wire                 sign         ,    // ALU SIGN
        input  wire                 sub          ,    // ALU SUB
        input  wire [`RegBus]       imm          ,    // immediate

        output wire [`RegBus]       jump_addr    ,
        output wire [`RegBus]       result       ,
        output wire                 jump
    );

    // jump_addr
    wire [`RegBus]  basic_addr   = (jal | jcc) ? inst_addr : rs1_data;
    wire [`RegBus]  offset_addr  = imm ;
    assign jump_addr = basic_addr + offset_addr;

    // ALU
    wire mem    = rmem | wmem;

    wire [`RegBus] op1 = lui ?`ZeroWord :
         (jmp|auipc) ? inst_addr : rs1_data;

    wire [`RegBus] op2 = jmp ? 32'd4 :
         (inst_R|jcc) ? rs2_data : imm;

    wire JC;

    ALU ALU_inst(
            .op1      (op1      ),
            .op2      (op2      ),
            .alu_ctrl (alu_ctrl ),
            .sub      (sub      ),
            .sign     (sign     ),
            .result   (result   ),
            .JC       (JC       )
        );

    assign jump = jmp | (jcc & JC);

endmodule
