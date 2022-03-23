module ALU (
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o,
);

input   wire[31:0]  data1_i;
input   wire[31:0]  data2_i;
input   wire[3:0]   ALUCtrl_i;
output  reg[31:0]   data_o;

always @ (*) begin
    case (ALUCtrl_i) 
        4'b0000: data_o <= data1_i & data2_i;
        4'b0001: data_o <= data1_i ^ data2_i;
        4'b0010: data_o <= data1_i << data2_i;
        4'b0011: data_o <= data1_i + data2_i;
        4'b0100: data_o <= data1_i - data2_i;
        4'b0101: data_o <= data1_i * data2_i;
        4'b0110: data_o <= data1_i + {{20{data2_i[31]}}, data2_i[31:20]};  //addi, lw
        4'b0111: data_o <= $signed(data1_i) >>> data2_i[24:20];  //srai
        4'b1000: data_o <= data1_i + {{20{data2_i[31]}}, data2_i[31:25], data2_i[11:7]};  //sw
    endcase
end

endmodule