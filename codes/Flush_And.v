module Flush_And (
    Branch_i,
    zero_i,
    Branch_o
);

input   wire    Branch_i;
input   wire    zero_i;
output  wire    Branch_o;

assign  Branch_o = (Branch_i & zero_i);
    
endmodule