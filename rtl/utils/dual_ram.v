//读写冲突 等于新值的 双端口ram
module dual_ram #(
    parameter DW = 32,
    parameter AW = 32,
    parameter MEM_NUM = 4096
)
(
    input   wire            clk   ,
    input   wire 			rstn  ,
    input   wire 			wen   ,
    input   wire [AW-1:0]	w_addr,
    input   wire [DW-1:0]   w_data,
    input   wire 			ren   ,
    input   wire [AW-1:0]	r_addr,
    output  wire [DW-1:0]   r_data
);


wire [DW-1:0]   r_data_wire	;
reg  [DW-1:0]   w_data_reg  ;
reg 		    rd_eq_wr_reg;

wire rd_eq_wr = wen && ren && (w_addr == r_addr);


assign r_data = (rd_eq_wr_reg) ? w_data_reg : r_data_wire;

always @(posedge clk) begin
    if(!rstn)
        w_data_reg <= {DW{1'b0}};
    else
        w_data_reg <= w_data;
end

//切换
always @(posedge clk) begin
    if(!rstn)
        rd_eq_wr_reg <= 1'b0;
    else
        rd_eq_wr_reg <= rd_eq_wr;
end

dual_ram_template #(
                      .DW (DW),
                      .AW (AW),
                      .MEM_NUM (MEM_NUM)
                  )dual_ram_template_inst
                  (
                      .clk		(clk		),
                      .rstn		(rstn		),
                      .wen		(wen		),
                      .w_addr	(w_addr	    ),
                      .w_data	(w_data	    ),
                      .ren		(ren        ),
                      .r_addr	(r_addr	    ),
                      .r_data	(r_data_wire)
                  );

endmodule


module dual_ram_template #(
    parameter DW = 32,
    parameter AW = 32,
    parameter MEM_NUM = 4096
)
(
    input wire 			clk   ,
    input wire 			rstn  ,
    input wire 			wen   ,
    input wire[AW-1:0]	w_addr,
    input wire[DW-1:0]  w_data,
    input wire 			ren   ,
    input wire[AW-1:0]	r_addr,
    output reg[DW-1:0]  r_data
);
reg[DW-1:0] memory[0:MEM_NUM-1];

always @(posedge clk) begin
    if(ren)
        r_data <= memory[r_addr];
end

always @(posedge clk) begin
    // if(rstn && wen)
    if(wen)
        memory[w_addr] <= w_data;
end

endmodule
