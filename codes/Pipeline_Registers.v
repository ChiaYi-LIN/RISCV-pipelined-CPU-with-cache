module Pipeline_Registers (
    clk_i,
    dcache_stall_i,

    // IF/ID
    pc_i,
    instr_i,
    stall_i,
    flush_i,
    pc_o,
    instr_o,

    // ID/EX
    ID_EX_RegWrite_i,
    ID_EX_MemtoReg_i,
    ID_EX_MemRead_i,
    ID_EX_MemWrite_i,
    ALUOp_i,
    ALUSrc_i,
    read_data_1_i,
    read_data_2_i,
    imm_data_i,
    funct_i,
    ID_EX_rs1_i,
    ID_EX_rs2_i,
    ID_EX_rd_i,
    ID_EX_RegWrite_o,
    ID_EX_MemtoReg_o,
    ID_EX_MemRead_o,
    ID_EX_MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    read_data_1_o,
    read_data_2_o,
    imm_data_o,
    funct_o,
    ID_EX_rs1_o,
    ID_EX_rs2_o,
    ID_EX_rd_o,

    // EX/MEM
    EX_MEM_RegWrite_i,
    EX_MEM_MemtoReg_i,
    EX_MEM_MemRead_i,
    EX_MEM_MemWrite_i,
    EX_MEM_alu_result_i,
    mem_write_data_i,
    EX_MEM_rd_i,
    EX_MEM_RegWrite_o,
    EX_MEM_MemtoReg_o,
    EX_MEM_MemRead_o,
    EX_MEM_MemWrite_o,
    EX_MEM_alu_result_o,
    mem_write_data_o,
    EX_MEM_rd_o,

    // MEM/WB
    MEM_WB_RegWrite_i,
    MEM_WB_MemtoReg_i,
    MEM_WB_alu_result_i,
    mem_read_data_i,
    MEM_WB_rd_i,
    MEM_WB_RegWrite_o,
    MEM_WB_MemtoReg_o,
    MEM_WB_alu_result_o,
    mem_read_data_o,
    MEM_WB_rd_o
);

// Ports
input               clk_i;
input               dcache_stall_i;
// IF/ID
input   wire[31:0]  pc_i;
input   wire[31:0]  instr_i;
input   wire        stall_i;
input   wire        flush_i;
output  reg[31:0]   pc_o;
output  reg[31:0]   instr_o;

// ID/EX
input   wire        ID_EX_RegWrite_i;
input   wire        ID_EX_MemtoReg_i;
input   wire        ID_EX_MemRead_i;
input   wire        ID_EX_MemWrite_i;
input   wire[1:0]   ALUOp_i;
input   wire        ALUSrc_i;
input   wire[31:0]  read_data_1_i;
input   wire[31:0]  read_data_2_i;
input   wire[31:0]  imm_data_i;
input   wire[9:0]   funct_i;
input   wire[4:0]   ID_EX_rs1_i;
input   wire[4:0]   ID_EX_rs2_i;
input   wire[4:0]   ID_EX_rd_i;
output  reg         ID_EX_RegWrite_o;
output  reg         ID_EX_MemtoReg_o;
output  reg         ID_EX_MemRead_o;
output  reg         ID_EX_MemWrite_o;
output  reg[1:0]    ALUOp_o;
output  reg         ALUSrc_o;
output  reg[31:0]   read_data_1_o;
output  reg[31:0]   read_data_2_o;
output  reg[31:0]   imm_data_o;
output  reg[9:0]    funct_o;
output  reg[4:0]    ID_EX_rs1_o;
output  reg[4:0]    ID_EX_rs2_o;
output  reg[4:0]    ID_EX_rd_o;

// EX/MEM
input   wire        EX_MEM_RegWrite_i;
input   wire        EX_MEM_MemtoReg_i;
input   wire        EX_MEM_MemRead_i;
input   wire        EX_MEM_MemWrite_i;
input   wire[31:0]  EX_MEM_alu_result_i;
input   wire[31:0]  mem_write_data_i;
input   wire[4:0]   EX_MEM_rd_i;
output  reg         EX_MEM_RegWrite_o;
output  reg         EX_MEM_MemtoReg_o;
output  reg         EX_MEM_MemRead_o;
output  reg         EX_MEM_MemWrite_o;
output  reg[31:0]   EX_MEM_alu_result_o;
output  reg[31:0]   mem_write_data_o;
output  reg[4:0]    EX_MEM_rd_o;

// MEM/WB
input   wire        MEM_WB_RegWrite_i;
input   wire        MEM_WB_MemtoReg_i;
input   wire[31:0]  MEM_WB_alu_result_i;
input   wire[31:0]  mem_read_data_i;
input   wire[4:0]   MEM_WB_rd_i;
output  reg         MEM_WB_RegWrite_o;
output  reg         MEM_WB_MemtoReg_o;
output  reg[31:0]   MEM_WB_alu_result_o;
output  reg[31:0]   mem_read_data_o;
output  reg[4:0]    MEM_WB_rd_o;

// 
// IF/ID
always @ (posedge clk_i) begin
    if (~dcache_stall_i) begin
        if (~stall_i) begin  // important
            if (flush_i) begin
                pc_o <= pc_i;
                instr_o <= 32'b0;
            end
            else begin
                pc_o <= pc_i;
                instr_o <= instr_i;
            end
        end
    end
end

// ID/EX
always @ (posedge clk_i) begin
    if (~dcache_stall_i) begin
        ID_EX_RegWrite_o <= ID_EX_RegWrite_i;
        ID_EX_MemtoReg_o <= ID_EX_MemtoReg_i;
        ID_EX_MemRead_o <= ID_EX_MemRead_i;
        ID_EX_MemWrite_o <= ID_EX_MemWrite_i;
        ALUOp_o <= ALUOp_i;
        ALUSrc_o <= ALUSrc_i;
        read_data_1_o <= read_data_1_i;
        read_data_2_o <= read_data_2_i;
        imm_data_o <= imm_data_i;
        funct_o <= funct_i;
        ID_EX_rs1_o <= ID_EX_rs1_i;
        ID_EX_rs2_o <= ID_EX_rs2_i;
        ID_EX_rd_o <= ID_EX_rd_i;
    end
end

// EX/MEM
always @ (posedge clk_i) begin
    if (~dcache_stall_i) begin
        EX_MEM_RegWrite_o <= EX_MEM_RegWrite_i;
        EX_MEM_MemtoReg_o <= EX_MEM_MemtoReg_i;
        EX_MEM_MemRead_o <= EX_MEM_MemRead_i;
        EX_MEM_MemWrite_o <= EX_MEM_MemWrite_i;
        EX_MEM_alu_result_o <= EX_MEM_alu_result_i;
        mem_write_data_o <= mem_write_data_i;
        EX_MEM_rd_o <= EX_MEM_rd_i;
    end
end

// MEM/WB
always @ (posedge clk_i) begin
    if (~dcache_stall_i) begin
        MEM_WB_RegWrite_o <= MEM_WB_RegWrite_i;
        MEM_WB_MemtoReg_o <= MEM_WB_MemtoReg_i;
        MEM_WB_alu_result_o <= MEM_WB_alu_result_i;
        mem_read_data_o <= mem_read_data_i;
        MEM_WB_rd_o <= MEM_WB_rd_i;
    end
end

endmodule