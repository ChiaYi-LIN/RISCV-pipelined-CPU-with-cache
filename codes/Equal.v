module Equal (
    read_data_1_i,
    read_data_2_i,
    zero_o
);

input   wire[31:0]  read_data_1_i;
input   wire[31:0]  read_data_2_i;
output  wire        zero_o;

assign  zero_o = (read_data_1_i == read_data_2_i) ? 1'b1 : 1'b0;
    
endmodule