module Adder
(
    data_1_i,
    data_2_i,
    data_o
);

// Ports
input   wire[31:0]  data_1_i;
input   wire[31:0]  data_2_i;
output  wire[31:0]  data_o;

assign data_o = data_1_i + data_2_i;

endmodule