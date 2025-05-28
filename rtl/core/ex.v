
`include "../defines.v"
module ex (
        input  wire                     clk         ,
        input  wire                     rstn        ,
        input  wire                     hold        ,
        // data
        input  wire [`InstBus]          inst_addr   ,
        input  wire [`InstBus]          rs1_data    ,
        input  wire [`InstBus]          rs2_data    ,
        input  wire [`InstBus]          imm         ,   // immediate
        // control
        input  wire [`ALU_sel_bus]      alu_sel     ,   // ALU Select
        input  wire [`ALU_ctrl_bus]     alu_ctrl    ,   // ALU Control
        input  wire                     sign        ,   // ALU SIGN
        input  wire                     sub         ,   // ALU SUB

        output wire [`InstBus]          result      ,
        output wire                     JC
    );

    wire rstn_reg;
    wire [`InstBus] result_alu;

    wire [`InstBus] op1 =
         {`Wordnum{|alu_sel[1:0]}} & rs1_data  |
         {`Wordnum{ alu_sel[2]  }} & `ZeroWord |
         {`Wordnum{|alu_sel[4:3]}} & inst_addr;

    wire [`InstBus] op2 =
         {`Wordnum{ alu_sel[0]  }} & rs2_data  |
         {`Wordnum{|alu_sel[3:1]}} & imm       |
         {`Wordnum{ alu_sel[4]  }} & 32'd4;

    ALU ALU_inst(
            .op1      (op1      ),
            .op2      (op2      ),
            .alu_ctrl (alu_ctrl ),
            .sub      (sub      ),
            .sign     (sign     ),
            .result   (result_alu),
            .JC       (JC       )
        );

    DFF #(1) rstn_dff(
            .clk      (clk      ),
            .rstn     (rstn     ),
            .CE       (~hold    ),
            .set_data (`Enable  ),
            .d        (`Disable ),
            .q        (rstn_reg )
        );

    assign result =
           ({`Wordnum{ rstn_reg}} & inst_addr  ) |
           ({`Wordnum{~rstn_reg}} & result_alu ) ;

endmodule
