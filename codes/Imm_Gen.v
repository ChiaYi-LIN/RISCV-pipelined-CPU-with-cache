module Imm_Gen (
    data_i,
    data_o
);

input   wire[31:0]  data_i;
output  wire[31:0]  data_o;

assign  data_o = data_i;

endmodule