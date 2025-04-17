
`define NEW


`include "../defines.v"
module control (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        input  wire                 hold        ,
        input  wire [`RegBus]       inst        ,
        input  wire                 JC          ,
        // to imm_gen
        output wire [`sw_imm_bus]   imm_ctrl    ,   // ALU Control
        output wire [`RegAddrBus]   rs1_addr    ,   // Register 1 Address
        output wire [`RegAddrBus]   rs2_addr    ,   // Register 2 Address
        output wire [`RegAddrBus]   rd_addr     ,   // Register Destination Address
        output wire                 rmem        ,   // Memory   Read  Enable
        output wire                 wmem        ,   // Memory   Write Enable
        output wire                 wen         ,   // Register Write Enable
        output wire                 jmp         ,   // Jump
        output wire                 jcc         ,   // Jump on Condition
        output wire [`ALU_ctrl_bus] alu_ctrl    ,   // ALU Control
        output wire                 jal         ,   // JAL  Instruction
        output wire                 jalr        ,   // JALR Instruction
        output wire                 lui         ,   // LUI Instruction
        output wire                 auipc       ,   // AUIPC Instruction
        output wire                 inst_R      ,   // INST TYPE R
        output wire [`mem_type_bus] mem_type    ,   // Load/Store Data Type
        output wire                 mem_sign    ,   // Load/Store Data Sign
        output wire                 sign        ,   // ALU SIGN
        output wire                 sub         ,   // ALU SUB
        output reg  [`StateBus]     state       ,
        output wire                 jump

    );

    // 分线
    assign  rs1_addr  = inst[19:15];
    assign  rs2_addr  = inst[24:20];
    assign  rd_addr   = inst[11: 7];


    wire [6:0] func7   = inst[31:25];
    wire [2:0] func3   = inst[14:12];
    wire [6:0] opcode  = inst[ 6: 0];


    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            state <= `IF_STATE;
        else if(hold)
            state <= `IF_STATE;
        else
            state <= {state[`Statenum-2:0],state[`Statenum-1]};
    end

    assign imm_ctrl =   ({`sw_imm_num{opcode == `INST_TYPE_I}} |
                         {`sw_imm_num{opcode == `INST_TYPE_L}} |
                         {`sw_imm_num{opcode == `INST_JALR  }}) & `sw_immI |
                        ({`sw_imm_num{opcode == `INST_TYPE_S}}) & `sw_immS |
                        ({`sw_imm_num{opcode == `INST_LUI   }} |
                         {`sw_imm_num{opcode == `INST_AUIPC }}) & `sw_immU |
                        ({`sw_imm_num{opcode == `INST_TYPE_B}}) & `sw_immB |
                        ({`sw_imm_num{opcode == `INST_JAL   }}) & `sw_immJ ;

    // INST signal
    assign jalr = (opcode == `INST_JALR);
    assign jal  = (opcode == `INST_JAL);
    assign lui  = (opcode == `INST_LUI);
    assign inst_R  = (opcode == `INST_TYPE_R_M);
    assign auipc = (opcode == `INST_AUIPC);


    // Jump signal
    assign jcc  = (opcode == `INST_TYPE_B);

    assign jmp  = (opcode == `INST_JAL ||
                   opcode == `INST_JALR);

    // ALU signal
    assign alu_ctrl = func3 & {3{~auipc & ~lui & ~jmp & ~rmem & ~wmem}};
    assign sub  = (opcode == `INST_TYPE_R_M) ? func7[5] : `Disable;

    // Shift Left Sign/Zero Extension
    assign sign = func7[5];

    // memory signal
    assign rmem = (opcode == `INST_TYPE_L);
    assign wmem = (opcode == `INST_TYPE_S);
    // memory Sign/Zero Extension
    // memory Byte/Half/Word type
    assign {mem_sign,mem_type} = func3;

    // register write enable
    assign wen  = (opcode == `INST_TYPE_I   ||
                   opcode == `INST_TYPE_R_M ||
                   opcode == `INST_TYPE_L   ||
                   opcode == `INST_JAL      ||
                   opcode == `INST_JALR     ||
                   opcode == `INST_LUI      ||
                   opcode == `INST_AUIPC);

    assign jump = jmp | (jcc & JC);


endmodule //control
