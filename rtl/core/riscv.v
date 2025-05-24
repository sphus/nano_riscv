`include "../defines.v"

module riscv(
        input  wire                 clk             ,
        input  wire                 rstn            ,
        input  wire [`InstBus]      mem_rdata       ,
        output wire [`InstBus]      mem_wdata       ,
        output wire [`InstBus]      mem_addr        ,
        output wire [`mem_type_bus] mem_type        ,
        output wire                 mem_sign        ,
        output wire                 rmem            ,
        output wire                 wmem			,

        // jtag
        input  wire					halt_req_i		,
        input  wire					reset_req_i
    );

    // test signal
    wire [`Hold_Bus] hold = `Disable;
    wire [`Hold_Bus] halt_req = {`Hold_num{halt_req_i}};
    wire reset_req = reset_req_i;

    // data
    wire [`InstBus      ]   inst        ;
    wire [`InstBus      ]   inst_addr   ;
    wire [`RegAddrBus   ]   rs1_addr    ;
    wire [`RegAddrBus   ]   rs2_addr    ;
    wire [`RegAddrBus   ]   rd_addr     ;
    wire [`InstBus      ]   rs1_data    ;
    wire [`InstBus      ]   rs2_data    ;
    wire [`InstBus      ]   result      ;
    wire [`InstBus      ]   rd_data     ;

    // control
    wire                    wen         ;   // register write enable
    wire                    wb_mem      ;   // write back memory data
    wire                    inst_L      ;   // Load inst
    wire [`ALU_sel_bus  ]   alu_sel     ;   // ALU Select
    wire [`ALU_ctrl_bus ]   alu_ctrl    ;   // ALU Control
    wire                    sign        ;   // ALU SIGN
    wire                    sub         ;   // ALU SUB
    wire [`InstBus      ]   imm         ;   // immediate
    wire [`StateBus     ]   state       ;   // state
    wire                    JC          ;   // JC signal
    wire [`sw_imm_bus]      imm_ctrl    ;   // Immediate Control

    // decode
    assign  rs1_addr  = inst[19:15];
    assign  rs2_addr  = inst[24:20];
    assign  rd_addr   = inst[11: 7];

    DFF #(`Wordnum) pc_inst(
             .clk      (clk       ),
             .rstn     (rstn      ),
             .CE       (state[`IF]),
             .set_data (`pc_rstn  ),
             .d        (mem_addr  ),
             .q        (inst_addr )
         );

    IF IF_inst(
           .clk         (clk        ),
           .rstn        (rstn       ),
           .inst_L      (inst_L     ),
           .state       (state      ),
           .mem_rdata   (mem_rdata  ),
           .inst        (inst       )
       );


    control control_inst(
                .clk        (clk        ),
                .rstn       (rstn       ),
                .hold       (hold       ),
                .inst       (inst       ),
                .JC         (JC         ),
                .imm_ctrl   (imm_ctrl   ),
                .alu_sel    (alu_sel    ),
                .alu_ctrl   (alu_ctrl   ),
                .inst_L     (inst_L     ),
                .wb_mem     (wb_mem     ),
                .rmem       (rmem       ),
                .wmem       (wmem       ),
                .wen        (wen        ),
                .mem_type   (mem_type   ),
                .mem_sign   (mem_sign   ),
                .sign       (sign       ),
                .sub        (sub        ),
                .state      (state      )
            );

    imm_gen imm_gen_inst(
                .inst     (inst     ),
                .imm_ctrl (imm_ctrl ),
                .imm      (imm      )
            );

    register register_inst(
                 .clk       (clk        ),
                 .rstn      (rstn       ),
                 .rs1_raddr (rs1_addr   ),
                 .rs2_raddr (rs2_addr   ),
                 .rd_waddr  (rd_addr    ),
                 .rd_wdata  (rd_data    ),
                 .wen       (wen        ),
                 .rs1_data  (rs1_data   ),
                 .rs2_data  (rs2_data   )
             );

    ex ex_inst(
           .clk         (clk        ),
           .rstn        (rstn       ),
           .inst_addr   (inst_addr  ),
           .rs1_data    (rs1_data   ),
           .rs2_data    (rs2_data   ),
           .imm         (imm        ),
           .alu_ctrl    (alu_ctrl   ),
           .alu_sel     (alu_sel    ),
           .sign        (sign       ),
           .sub         (sub        ),
           .result      (result     ),
           .JC          (JC         )
       );

    // MEM_inst
    assign mem_addr     = result;
    assign mem_wdata    = rs2_data;

    wb wb_inst(
           .mem_rdata   (mem_rdata  ),
           .result      (result     ),
           .wb_mem      (wb_mem     ),
           .rd_data     (rd_data    )
       );

endmodule

