`include "../defines.v"
module riscv_soc (
        input  wire clk     	,
        input  wire rstn    	,

		input  wire jtag_pin_TCK,
		input  wire jtag_pin_TMS,
		input  wire jtag_pin_TDI,
		output wire jtag_pin_TDO,
		output wire over        ,
		output wire pass
    );

    parameter DW = 32;
    parameter AW = 32;

    wire [31:0] inst_addr_rom   ;
    wire [31:0] inst_rom        ;

    wire [`InstBus]          mem_rdata       ;
    wire [`InstBus]          mem_wdata       ;
    wire [`InstBus]          mem_addr        ;
    wire [`mem_type_bus]    mem_type        ;
    wire                    mem_sign        ;
    wire                    rmem            ;
    wire                    wmem            ;
    wire [`InstBus]          addr            ;

    wire [3:0]		        wen             ;
    wire [AW-1:0]	        w_addr          ;
    wire [DW-1:0]           w_data          ;
    wire 			        ren             ;
    wire 			        busy            ;
    wire [AW-1:0]	        r_addr          ;
    wire [DW-1:0]           r_data          ;

    // jtag_signal
    wire 			        jtag_wen        ;
    wire [AW-1:0]	        jtag_waddr      ;
    wire [DW-1:0]           jtag_wdata      ;
    wire 			        jtag_halt_req   ;
    wire 			        jtag_reset_req  ;

    assign over = riscv_inst.register_inst.reg_mem[26];
    assign pass = riscv_inst.register_inst.reg_mem[27];


    riscv riscv_inst(
              .clk           (clk           ),
              .rstn          (rstn          ),
            //   .busy          (busy          ),
              .mem_rdata     (mem_rdata     ),
              .mem_wdata     (mem_wdata     ),
              .mem_addr      (mem_addr      ),
              .mem_type      (mem_type      ),
              .mem_sign      (mem_sign      ),
              .rmem          (rmem          ),
              .wmem          (wmem          ),

			  // jtag_signal
			  .halt_req_i	(jtag_halt_req	),
			  .reset_req_i	(jtag_reset_req	)
          );

    ram_interface ram_interface_inst(
                      .clk      (clk        ),
                      .rstn     (rstn       ),
                      .mem_rdata(mem_rdata  ),
                      .mem_wdata(mem_wdata  ),
                      .mem_addr (mem_addr   ),
                      .mem_type (mem_type   ),
                      .mem_sign (mem_sign   ),
                      .rmem     (rmem       ),
                      .wmem     (wmem       ),
                      .r_data   (r_data     ),
                      .w_data   (w_data     ),
                      .addr     (addr       ),
                      .wen      (wen        ),
                      .busy     (busy       ),
                      .ren      (ren        )
                  );


    ram  #(
             .DW      	(DW    ),
             .AW      	(AW    ),
             .MEM_NUM 	(2**13  ))
         ram_inst(
             .clk    (clk    ),
             .rstn   (rstn   ),
             .wen    (wen    ),
             .w_addr (addr   ),
             .w_data (w_data ),
             .ren    (ren    ),
             .r_addr (addr   ),
             .r_data (r_data )
         );

	jtag_top jtag_top_inst(
		.clk			(clk			),
		.jtag_rst_n		(rstn			),

		.jtag_pin_TCK	(jtag_pin_TCK	),
		.jtag_pin_TMS	(jtag_pin_TMS	),
		.jtag_pin_TDI	(jtag_pin_TDI	),
		.jtag_pin_TDO	(jtag_pin_TDO	),

		.mem_we_o		(jtag_wen		),
		.mem_addr_o		(jtag_waddr		),
		.mem_wdata_o	(jtag_wdata		),

		.halt_req_o		(jtag_halt_req	),
		.reset_req_o	(jtag_reset_req	)
	);



endmodule
