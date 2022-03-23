module Hazard_Detection_Unit (
    ID_rs1_i,
    ID_rs2_i,
    EX_MemRead_i,
    EX_rd_i,
    PCWrite_o,
    Stall_o,
    NoOp_o
);

// port
input   wire[4:0]   ID_rs1_i;
input   wire[4:0]   ID_rs2_i;
input   wire        EX_MemRead_i;
input   wire[4:0]   EX_rd_i;
output  reg         PCWrite_o;
output  reg         Stall_o;
output  reg         NoOp_o;

always @(*) begin
    if (EX_MemRead_i == 1'b1 && EX_rd_i != 5'b0 && (EX_rd_i == ID_rs1_i || EX_rd_i == ID_rs2_i)) begin
        PCWrite_o <= 1'b0;
        Stall_o <= 1'b1;
        NoOp_o <= 1'b1;
        
    end
    else begin
        PCWrite_o <= 1'b1;
        Stall_o <= 1'b0;
        NoOp_o <= 1'b0;
    end
end
    
endmodule