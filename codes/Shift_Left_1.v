module Shift_Left_1 (
    instr_i,
    instr_o
);
    
// port
input   wire[31:0]    instr_i;
output   wire[31:0]    instr_o;

assign  instr_o = {instr_i[30:0], 1'b0};

endmodule