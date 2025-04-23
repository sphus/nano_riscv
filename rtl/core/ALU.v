`include "../defines.v"
module ALU (
        input  wire [`InstBus]      op1         ,   // operands 1
        input  wire [`InstBus]      op2         ,   // operands 2
        input  wire [`ALU_ctrl_bus] alu_ctrl    ,   // ALU control
        input  wire                 sub         ,   // sub
        input  wire                 sign        ,   // sign
        output wire [`InstBus]      result      ,   // result
        output wire                 JC              // Jump Condition
    );

    // signed operand
    wire signed [`InstBus]       op1_s = op1;
    wire signed [`InstBus]       op2_s = op2;

    // ALU result
    wire        [`InstBus]       add_sub_val = op1 + (sub ? ~op2 + sub : op2);
    wire        [`InstBus]       xor_val     = op1 ^ op2;
    wire        [`InstBus]       or_val      = op1 | op2;
    wire        [`InstBus]       and_val     = op1 & op2;
    wire        [`RegAddrBus]    shamt       = op2[4:0];
    wire        [`InstBus]       sll_val     = op1 << shamt;
    wire        [`InstBus]       sr_val      = sign ? (op1_s >>> shamt) : (op1_s >> shamt);

    // JC signal
    wire eq             = (op1 == op2)      ;
    wire less_signed    = (op1_s < op2_s)   ;
    wire less_unsigned  = (op1 < op2)       ;

    // 控制信号:二进制码转独热码
    wire [7:0] ctrl = 8'h01 << alu_ctrl;

    assign result =
           add_sub_val   & {`Wordnum{ctrl[0]}} |
           sll_val       & {`Wordnum{ctrl[1]}} |
           less_signed   & {`Wordnum{ctrl[2]}} |
           less_unsigned & {`Wordnum{ctrl[3]}} |
           xor_val       & {`Wordnum{ctrl[4]}} |
           sr_val        & {`Wordnum{ctrl[5]}} |
           or_val        & {`Wordnum{ctrl[6]}} |
           and_val       & {`Wordnum{ctrl[7]}} ;

    assign JC =
           eq             & ctrl[0] |
           ~eq            & ctrl[1] |
           less_signed    & ctrl[4] |
           ~less_signed   & ctrl[5] |
           less_unsigned  & ctrl[6] |
           ~less_unsigned & ctrl[7] ;

endmodule //ALU
