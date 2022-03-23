module MUX32_4_to_1 (
    data_00_i,
    data_01_i,
    data_10_i,
    data_11_i,
    forward_i,
    data_o
);

input   wire[31:0]  data_00_i;
input   wire[31:0]  data_01_i;
input   wire[31:0]  data_10_i;
input   wire[31:0]  data_11_i;
input   wire[1:0]   forward_i;
output  reg[31:0]   data_o;

always @(*) begin
    case (forward_i)
        2'b00: data_o <= data_00_i;
        2'b01: data_o <= data_01_i;
        2'b10: data_o <= data_10_i;
    endcase
end

    
endmodule