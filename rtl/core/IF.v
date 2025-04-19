
`include "../defines.v"
module IF (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        input  wire [`StateBus]     state       ,
        input  wire [`RegBus]       mem_rdata   ,
        output wire [`RegBus]       inst  
    );

    wire [`RegBus] inst_dff;

    // 在EX阶段选择读回来的inst
    // 在IF/WB阶段选择寄存器存住的inst
    assign inst = ({32{state[`EX]}} & mem_rdata)|
        ({32{state[`IF] | state[`WB]}} & inst_dff);

    DFFD #(`Regnum) INST_DFF(
        .clk      (clk          ),
        .rstn     (rstn         ),
        .CE       (state[`EX]   ),
        .set_data (`INST_NOP    ),
        .d        (mem_rdata    ),
        .q        (inst_dff    )
    );

endmodule
