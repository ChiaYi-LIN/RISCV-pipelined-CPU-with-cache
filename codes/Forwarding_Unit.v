module Forwarding_Unit (
    EX_rs1_i,
    EX_rs2_i,
    MEM_RegWrite_i,
    MEM_rd_i,
    WB_RegWrite_i,
    WB_rd_i,
    forward_a_o,
    forward_b_o
);

// port
input   wire[4:0]    EX_rs1_i;
input   wire[4:0]    EX_rs2_i;
input   wire         MEM_RegWrite_i;
input   wire[4:0]    MEM_rd_i;
input   wire         WB_RegWrite_i;
input   wire[4:0]    WB_rd_i;
output  reg[1:0]     forward_a_o;
output  reg[1:0]     forward_b_o;


always @(*) begin
    if (MEM_RegWrite_i == 1'b1 && MEM_rd_i != 5'b0 && MEM_rd_i == EX_rs1_i) begin
        forward_a_o <= 2'b10;
    end
    else if (WB_RegWrite_i == 1'b1 && WB_rd_i != 5'b0 && WB_rd_i == EX_rs1_i) begin
        forward_a_o <= 2'b01;
    end
    else begin
        forward_a_o <= 2'b00;
    end
end

always @(*) begin
    if (MEM_RegWrite_i == 1'b1 && MEM_rd_i != 5'b0 && MEM_rd_i == EX_rs2_i) begin
        forward_b_o <= 2'b10;
    end
    else if (WB_RegWrite_i == 1'b1 && WB_rd_i != 5'b0 && WB_rd_i == EX_rs2_i) begin
        forward_b_o <= 2'b01;
    end
    else begin
        forward_b_o <= 2'b00;
    end
end
    
endmodule