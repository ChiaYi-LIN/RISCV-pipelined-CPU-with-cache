module ALU_Control(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

input   wire[9:0]   funct_i;
input   wire[1:0]   ALUOp_i;
output  reg[3:0]    ALUCtrl_o;

always @ (*) begin

    if (ALUOp_i == 2'b10) begin
        case (funct_i) 
            10'b0000000111: ALUCtrl_o <= 4'b0000;
            10'b0000000100: ALUCtrl_o <= 4'b0001;
            10'b0000000001: ALUCtrl_o <= 4'b0010;
            10'b0000000000: ALUCtrl_o <= 4'b0011;
            10'b0100000000: ALUCtrl_o <= 4'b0100;
            10'b0000001000: ALUCtrl_o <= 4'b0101;
        endcase
    end
    else if (ALUOp_i == 2'b11) begin
        casex (funct_i) 
            10'bxxxxxxx000: ALUCtrl_o <= 4'b0110;  //addi
            10'b0100000101: ALUCtrl_o <= 4'b0111;  //srai
            10'bxxxxxxx010: ALUCtrl_o <= 4'b0110;  //lw
        endcase
    end
    else if (ALUOp_i == 2'b00) begin
        ALUCtrl_o <= 4'b1000;  //sw
    end
    else if (ALUOp_i == 2'b01) begin
        ALUCtrl_o <= 4'b1001;  //brancd (not used)
    end
end

endmodule
