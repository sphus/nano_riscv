
`define NEW


`include "../defines.v"
module control (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        input  wire                 hold        ,
        input  wire [`RegBus]       inst        ,
        input  wire                 JC          ,
        // to imm_gen
        output wire [`sw_imm_bus]   imm_ctrl    ,   // IMM Control
        output wire [`ALU_sel_bus]  alu_sel     ,   // ALU Select
        output wire [`ALU_ctrl_bus] alu_ctrl    ,   // ALU Control
        output wire                 rmem        ,   // Memory   Read  Enable
        output wire                 wmem        ,   // Memory   Write Enable
        output wire                 wen         ,   // Register Write Enable
        output wire [`mem_type_bus] mem_type    ,   // Load/Store Data Type
        output wire                 mem_sign    ,   // Load/Store Data Sign
        output wire                 sign        ,   // ALU SIGN
        output wire                 sub         ,   // ALU SUB
        output reg  [`StateBus]     state
    );

    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            state <= `IF_STATE;
        else if(hold)
            state <= `IF_STATE;
        else
            state <= {state[`Statenum-2:0],state[`Statenum-1]};
    end

    wire [6:0] func7   = inst[31:25];
    wire [2:0] func3   = inst[14:12];
    wire [6:0] opcode  = inst[ 6: 0];

    // INST signal
    wire    jalr    = (opcode == `INST_JALR     );
    wire    jal     = (opcode == `INST_JAL      );
    wire    lui     = (opcode == `INST_LUI      );
    wire    auipc   = (opcode == `INST_AUIPC    );
    wire    inst_R  = (opcode == `INST_TYPE_R_M );
    wire    inst_I  = (opcode == `INST_TYPE_I   );
    wire    inst_L  = (opcode == `INST_TYPE_L   );
    wire    inst_S  = (opcode == `INST_TYPE_S   );
    wire    jcc     = (opcode == `INST_TYPE_B   );

    // Jump signal
    assign imm_ctrl ={
               (jal                ),   //  J
               (jcc                ),   //  B
               (lui    |auipc      ),   //  U
               (inst_S             ),   //  S
               (inst_I |inst_L|jalr)};  //  I



    wire    cjump_reg;
    wire    jal_reg  ;
    wire    jalr_reg ;
    wire    cjump   = jcc & JC;
    wire    jump_reg    = (cjump_reg|jal_reg|jalr_reg) & state[`IF];

    // DFF #(1)DFF_inst (clk,rstn,CE     ,set_data,d    ,q          );
    DFF #(1)CJUMP_DFF   (clk,rstn,`Enable,`Disable,cjump,cjump_reg  );
    DFF #(1)JAL_DFF     (clk,rstn,`Enable,`Disable,jal  ,jal_reg    );
    DFF #(1)JALR_DFF    (clk,rstn,`Enable,`Disable,jalr ,jalr_reg   );



    // ALU signal
    assign alu_ctrl = func3 & {`ALU_ctrl_num{(inst_I | inst_R | jcc) & (state[`EX]|state[`WB])}};
    assign sub      = inst_R& func7[5] & (state[`EX]|state[`WB]);

    // Shift Left Sign/Zero Extension
    assign sign = func7[5];

    // memory Sign/Zero Extension
    // memory Byte/Half/Word type
    assign {mem_sign,mem_type} = (func3 & {3{state[`EX] | state[`WB]}}) |
           ({`LS_unsigned,`LS_W} & {3{state[`IF]}}) ;

    // register write enable
    assign wen  = (inst_I|
                   inst_R|
                   inst_L|
                   jal  |
                   jalr |
                   lui  |
                   auipc) & state[`WB];

    assign wmem = inst_S & state[`WB];
    // assign rmem = state[`IF] | (inst_L & (state[`EX] | state[`WB]));
    assign rmem = state[`IF] | (inst_L & (state[`EX] | state[`WB]));

    // EX_WB阶段计算result
    wire [`ALU_sel_bus]  alu_sel_MEM_WB =
         {jal   |jalr       ,
          auipc             ,
          lui               ,
          inst_I|inst_L|inst_S,
          inst_R|jcc    }
         & {`ALU_sel_num{state[`EX]|state[`WB]}};

    // 在IF阶段计算inst_addr
    wire [`ALU_sel_bus]  alu_sel_IF =
         {~{cjump_reg|jal_reg|jalr_reg},
          cjump_reg|jal_reg,
          `Disable    ,
          jalr_reg  ,
          `Disable}
         & {`ALU_sel_num{state[`IF]}};

    // sel信号合并
    assign alu_sel = alu_sel_MEM_WB | alu_sel_IF;

endmodule //control
