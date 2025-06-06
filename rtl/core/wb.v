
`include "../defines.v"
module wb (
        // data
        input  wire [`InstBus]  mem_rdata   ,
        input  wire [`InstBus]  result      ,
        // control
        input  wire             wb_mem      ,

        // data
        output wire [`InstBus]  rd_data   

    );

    assign rd_data = wb_mem ? mem_rdata : result;
     
endmodule
