
`define PYTHON
`define SIM_TIME 60000
// `define ONE_INST_TEST
// `define PRINT_REGISTER
`define TEST_FILE "./generated/rv32ui-p-lb.txt"

`define RstnEnable  1'b0
`define RstnDisable 1'b1
`define Enable      1'b1
`define Disable     1'b0
`define Regnum      32
`define Wordnum     32


`define Statenum      3
`define StateBus      (`Statenum - 1):0
`define IF_STATE  3'b001
`define EX_STATE  3'b010
`define WB_STATE  3'b100
`define IF  0
`define EX  1
`define MEM  2

`define pc_rstn     32'h0
`define ZeroReg     5'h0
`define ZeroWord    32'h0

// Bus
`define RegAddrnum  5
`define RegAddrBus  (`RegAddrnum-1):0
`define RegBus      (`Regnum - 1):0
`define InstBus     (`Wordnum - 1):0

// hold
`define Hold_num    1
`define Hold_Bus    (`Hold_num-1):0

// ALU Switch
`define ALU_ctrl_num    3
`define ALU_ctrl_bus    (`ALU_ctrl_num - 1):0
`define ALU_sel_num     5
`define ALU_sel_bus     (`ALU_sel_num - 1):0

// Immdiate Switch
`define sw_imm_num  5
`define sw_imm_bus  (`sw_imm_num-1):0
`define IMMJ     4
`define IMMB     3
`define IMMU     2
`define IMMS     1
`define IMMI     0

`define mem_type_num 2
`define mem_type_bus (`mem_type_num-1):0
`define LS_B        2'b00
`define LS_H        2'b01
`define LS_W        2'b10
`define LS_signed   1'b0
`define LS_unsigned 1'b1

// I type inst
`define INST_TYPE_I 7'b0010011

// L type inst
`define INST_TYPE_L 7'b0000011

// S type inst
`define INST_TYPE_S 7'b0100011

// R and M type inst
`define INST_TYPE_R_M 7'b0110011

// J type inst
`define INST_JAL    7'b1101111
`define INST_JALR   7'b1100111

`define INST_LUI    7'b0110111
`define INST_AUIPC  7'b0010111
`define INST_NOP    32'h00000013

// B type inst
`define INST_TYPE_B 7'b1100011
