
`include "../rtl/defines.v"
`timescale 1ns/1ns
module tb_riscv();


`define CLK_PERIOD 20

`define PYTHON_FILE "../generated/inst_data.txt"


`ifdef PYTHON
    `define READ_FILE `PYTHON_FILE
`else
`define READ_FILE `TEST_FILE
`endif


    // 生成波形文件,给GTKWAVE调用
    // initial begin
    //     $dumpfile("wave.vcd");
    //     $dumpvars;
    // end

    reg  clk ;
    reg  rstn;

    always #(`CLK_PERIOD / 2) clk = ~clk;

    initial
    begin
        clk  = 1'b1;
        rstn = 1'b0;
        #(`CLK_PERIOD * 1.5);
        rstn = 1'b1;
    end

    parameter DEPTH = 2**13;  // 总地址 1M
    parameter RAM_DEPTH = DEPTH / 4;  // 每块 RAM 的大小 2^18

    reg [31:0] temp_mem [0:RAM_DEPTH-1]; // 读取 32-bit 数据

    integer i;

    // initial ram
    initial
    begin
        $readmemh(`READ_FILE, temp_mem); // 读取 32-bit 数据
        for (i = 0; i < RAM_DEPTH; i = i + 1)
        begin
            tb_riscv.riscv_soc_inst.ram_inst.ram_byte0.dual_ram_template_inst.memory[i] = temp_mem[i][7:0];   // 低 8 位
            tb_riscv.riscv_soc_inst.ram_inst.ram_byte1.dual_ram_template_inst.memory[i] = temp_mem[i][15:8];  // 次低 8 位
            tb_riscv.riscv_soc_inst.ram_inst.ram_byte2.dual_ram_template_inst.memory[i] = temp_mem[i][23:16]; // 次高 8 位
            tb_riscv.riscv_soc_inst.ram_inst.ram_byte3.dual_ram_template_inst.memory[i] = temp_mem[i][31:24]; // 高 8 位
        end
    end

    wire [31:0] inst_addr = tb_riscv.riscv_soc_inst.riscv_inst.inst_addr;
    wire        jump_flag = tb_riscv.riscv_soc_inst.riscv_inst.control_inst.jump_reg;
    wire [31:0] jump_addr = tb_riscv.riscv_soc_inst.riscv_inst.result;

    wire [31:0] x [31:0];

    genvar y;

    generate
        for(y = 0 ; y < 31; y = y + 1)
        begin
            assign x[y] = tb_riscv.riscv_soc_inst.riscv_inst.register_inst.reg_mem[y];
        end
    endgenerate


    integer r;

    initial
    begin
        wait(x[26] == 32'b1);
        #(`CLK_PERIOD*6);
        if(x[27] == 32'b1)
        begin
            $display("############################");
            $display("########  pass  !!!#########");
            $display("############################");
        end
        else
        begin
            for(r = 0;r < 31; r = r + 4)
                $display("x%2d to x%2d:%x %x %x %x",r,r+3,x[r],x[r+1],x[r+2],x[r+3]);
            $display("############################");
            $display("########  fail  !!!#########");
            $display("############################");
            $display("fail testnum = %2d", x[3]);
        end

`ifdef PYTHON
        $finish;
`else
        $stop;
`endif

    end


`ifdef ONE_INST_TEST
    always @(inst_addr)
`else
    always @(x[3])
`endif

    begin
        $display("inst_addr is %x at %d",inst_addr,$time);
        for(r = 0;r < 31; r = r + 4)
            $display("x%2d to x%2d:%x %x %x %x",r,r+3,x[r],x[r+1],x[r+2],x[r+3]);
        $display("\n");
    end

    always @(posedge clk)
    begin
        if(jump_flag)
        begin
            $display("%x jump to %x at %d", inst_addr,jump_addr,$time);
        end

        if ($time >= `SIM_TIME)
        begin
            for(r = 0;r < 31; r = r + 4)
                $display("x%2d to x%2d:%x %x %x %x",r,r+3,x[r],x[r+1],x[r+2],x[r+3]);
            $display("############################");
            $display("######  timeout  !!!########");
            $display("############################");
`ifdef PYTHON

            $finish;
`else
            $stop;
`endif

        end
    end



    riscv_soc riscv_soc_inst(
                  .clk          (clk    ),
                  .rstn         (rstn   ),
                  .jtag_pin_TCK (1'b0   ),
                  .jtag_pin_TMS (1'b0   ),
                  .jtag_pin_TDI (1'b0   ),
                  .jtag_pin_TDO (       )
              );

endmodule
