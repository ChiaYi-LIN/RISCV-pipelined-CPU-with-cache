module Control(
    Op_i,
    NoOp_i,
    ALUOp_o,
    ALUSrc_o,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    Branch_o
);

// Ports
input   wire[6:0]   Op_i;
input   wire        NoOp_i;
output  reg[1:0]    ALUOp_o;
output  reg         ALUSrc_o;
output  reg         RegWrite_o;
output  reg         MemtoReg_o;
output  reg         MemRead_o;
output  reg         MemWrite_o;
output  reg         Branch_o;

always @ (*) begin
    case (Op_i) 
        7'b0110011: ALUOp_o <= 2'b10; // R-type
        7'b0010011: ALUOp_o <= 2'b11; // immediate arithmetic
        7'b0000011: ALUOp_o <= 2'b11; // lw
        7'b0100011: ALUOp_o <= 2'b00; // sw
        7'b1100011: ALUOp_o <= 2'b01; // beq
    endcase
end

always @ (*) begin
    case (Op_i) 
        7'b0110011: ALUSrc_o <= 1'b0; // R-type
        7'b0010011: ALUSrc_o <= 1'b1; // immediate arithmetic
        7'b0000011: ALUSrc_o <= 1'b1; // lw
        7'b0100011: ALUSrc_o <= 1'b1; // sw
        7'b1100011: ALUSrc_o <= 1'b0; // beq
    endcase
end

always @ (*) begin
    if (NoOp_i)
        RegWrite_o <= 1'b0;
    else begin
        case (Op_i) 
            7'b0110011: RegWrite_o <= 1'b1; // R-type
            7'b0010011: RegWrite_o <= 1'b1; // immediate arithmetic
            7'b0000011: RegWrite_o <= 1'b1; // lw
            7'b0100011: RegWrite_o <= 1'b0; // sw
            7'b1100011: RegWrite_o <= 1'b0; // beq
            default: RegWrite_o <= 1'b0;
        endcase
    end
end

always @ (*) begin
    case (Op_i) 
        7'b0110011: MemtoReg_o <= 1'b0; // R-type
        7'b0010011: MemtoReg_o <= 1'b0; // immediate arithmetic
        7'b0000011: MemtoReg_o <= 1'b1; // lw
        7'b0100011: MemtoReg_o <= 1'bx; // sw
        7'b1100011: MemtoReg_o <= 1'bx; // beq
    endcase
end

always @ (*) begin
    if (NoOp_i)
        MemRead_o <= 1'b0;
    else begin
        case (Op_i) 
            7'b0110011: MemRead_o <= 1'b0; // R-type
            7'b0010011: MemRead_o <= 1'b0; // immediate arithmetic
            7'b0000011: MemRead_o <= 1'b1; // lw
            7'b0100011: MemRead_o <= 1'b0; // sw
            7'b1100011: MemRead_o <= 1'b0; // beq
            default: MemRead_o <= 1'b0;
        endcase
    end
end

always @ (*) begin
    if (NoOp_i)
        MemWrite_o <= 1'b0;
    else begin
        case (Op_i) 
            7'b0110011: MemWrite_o <= 1'b0; // R-type
            7'b0010011: MemWrite_o <= 1'b0; // immediate arithmetic
            7'b0000011: MemWrite_o <= 1'b0; // lw
            7'b0100011: MemWrite_o <= 1'b1; // sw
            7'b1100011: MemWrite_o <= 1'b0; // beq
            default: MemWrite_o <= 1'b0;
        endcase
    end
end

always @ (*) begin
    if (NoOp_i)
        Branch_o <= 1'b0;
    else begin
        case (Op_i) 
            7'b0110011: Branch_o <= 1'b0; // R-type
            7'b0010011: Branch_o <= 1'b0; // immediate arithmetic
            7'b0000011: Branch_o <= 1'b0; // lw
            7'b0100011: Branch_o <= 1'b0; // sw
            7'b1100011: Branch_o <= 1'b1; // beq
            default: Branch_o <= 1'b0;
        endcase
    end
end

endmodule