
module ram #(
        parameter AW = 32,
        parameter DW = 32,
        parameter MEM_NUM = 4096
    )
    (
        input   wire            clk   ,
        input   wire 			rstn  ,
        input   wire [3:0]		wen   ,
        input   wire [AW-1:0]	addr,
        input   wire [DW-1:0]   w_data,
        input   wire 			ren   ,
        output  wire [DW-1:0]   r_data
    );
    // byte0
    dual_ram #(
                 .DW      	(DW >> 2),
                 .AW      	(AW     ),
                 .MEM_NUM 	(MEM_NUM))
             ram_byte0(
                 .clk   (clk                ),
                 .rstn  (rstn               ),
                 .wen   (wen[0]             ),
                 .addr 	(addr >> 2          ),// addr/4,because DW/8 = 4
                 .w_data(w_data[0*8+7:0*8]  ),
                 .ren   (ren                ),
                 .r_data(r_data[0*8+7:0*8]  )
             );
    // byte1
    dual_ram #(
                 .DW      	(DW >> 2),
                 .AW      	(AW     ),
                 .MEM_NUM 	(MEM_NUM))
             ram_byte1(
                 .clk   (clk                ),
                 .rstn  (rstn               ),
                 .wen   (wen[1]             ),
                 .addr  (addr >> 2          ),// addr/4,because DW/8 = 4
                 .w_data(w_data[1*8+7:1*8]  ),
                 .ren   (ren                ),
                 .r_data(r_data[1*8+7:1*8]  )
             );
    // byte2
    dual_ram #(
                 .DW      	(DW >> 2),
                 .AW      	(AW     ),
                 .MEM_NUM 	(MEM_NUM))
             ram_byte2(
                 .clk   (clk                ),
                 .rstn  (rstn               ),
                 .wen   (wen[2]             ),
                 .addr 	(addr >> 2          ),// addr/4,because DW/8 = 4
                 .w_data(w_data[2*8+7:2*8]  ),
                 .ren   (ren                ),
                 .r_data(r_data[2*8+7:2*8]  )
             );
    // byte3
    dual_ram #(
                 .DW      	(DW >> 2),
                 .AW      	(AW     ),
                 .MEM_NUM 	(MEM_NUM))
             ram_byte3(
                 .clk   (clk                ),
                 .rstn  (rstn               ),
                 .wen   (wen[3]             ),
                 .addr 	(addr >> 2          ),// addr/4,because DW/8 = 4
                 .w_data(w_data[3*8+7:3*8]  ),
                 .ren   (ren                ),
                 .r_data(r_data[3*8+7:3*8]  )
             );

endmodule
