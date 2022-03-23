// `include "Control.v"
// `include "Adder.v"
// `include "PC.v"
// `include "Instruction_Memory.v"
// `include "Registers.v"
// `include "MUX32.v"
// `include "Imm_Gen.v"
// `include "ALU.v"
// `include "ALU_Control.v"
// `include "And.v"
// `include "Equal.v"
// `include "Forwarding_Unit.v"
// `include "Hazard_Detection_Unit.v"
// `include "MUX32_4_to_1.v"
// `include "Pipeline_Registers.v"
// `include "Shift_Left_1.v"
// `include "Data_Memory.v"

module CPU
(
    clk_i, 
    rst_i,
    start_i,

    mem_data_i,
    mem_ack_i,
    mem_data_o,
    mem_addr_o,
    mem_enable_o,
    mem_write_o
);

// Ports
input           clk_i;
input           rst_i;
input           start_i;

// Wires
// General
// Hazard Detextion Unit
wire            PCWrite;
wire            stall;
wire            NoOp;
// Forwarding Unit
wire[1:0]       forward_A;
wire[1:0]       forward_B;

// IF stage
wire[31:0]      IF_pc_cur;
wire[31:0]      IF_pc_cur_plus_4;
wire[31:0]      IF_pc_next;
wire[31:0]      IF_instr;

// ID stage
wire[31:0]      ID_instr;
wire[31:0]      ID_pc;
// Main Control
wire[1:0]       ID_ALUOp;
wire            ID_ALUSrc;
wire            ID_RegWrite;
wire            ID_MemtoReg;
wire            ID_MemRead;
wire            ID_MemWrite;
wire            ID_Branch;
// Branch And
wire            Flush;
wire            zero;
// Branch address Adder
wire[31:0]      branch_relative;
wire[31:0]      branch_addr;
// REG
wire[31:0]      ID_read_data_1;
wire[31:0]      ID_read_data_2;
// SE
wire[31:0]      ID_imm_data;

// EX stage
wire[4:0]       EX_rs1;
wire[4:0]       EX_rs2;
wire[4:0]       EX_rd;
// Main Control
wire[1:0]       EX_ALUOp;
wire            EX_ALUSrc;
wire            EX_RegWrite;
wire            EX_MemtoReg;
wire            EX_MemRead;
wire            EX_MemWrite;
// REG
wire[31:0]      EX_read_data_1;
wire[31:0]      EX_read_data_2;
// Mux ALUSrc
wire[31:0]      EX_mux_to_mux_data;
// SE
wire[31:0]      EX_se_data;
// ALU Ctrl
wire[9:0]       EX_funct;
wire[3:0]       EX_ALUCtrl;
// ALU
wire[31:0]      EX_alu_data_1;
wire[31:0]      EX_alu_data_2;
wire[31:0]      EX_alu_result;

// MEM stage
wire            MEM_RegWrite;
wire            MEM_MemtoReg;
wire            MEM_MemRead;
wire            MEM_MemWrite;
wire[31:0]      MEM_addr;
wire[31:0]      MEM_write_data;
wire[31:0]      MEM_read_data;
wire[4:0]       MEM_rd;
// to Data_Memory interface        
input[255:0]    mem_data_i; 
input           mem_ack_i; 
output[255:0]   mem_data_o; 
output[31:0]    mem_addr_o;     
output          mem_enable_o; 
output          mem_write_o;
// Data_Cache stall signal
wire            MEM_dcache_stall;

// WB stage
wire            WB_RegWrite;
wire            WB_MemtoReg;
wire[31:0]      WB_data_not_mem;
wire[31:0]      WB_data_mem;
wire[31:0]      WB_data;
wire[4:0]       WB_rd;

/**/
// IF stage
MUX32 Next_PC(
    .data1_i                (IF_pc_cur_plus_4),
    .data2_i                (branch_addr),
    .select_i               (Flush),
    .data_o                 (IF_pc_next)
);

PC PC(
    .clk_i                  (clk_i),
    .rst_i                  (rst_i),
    .start_i                (start_i),
    .stall_i                (MEM_dcache_stall),
    .PCWrite_i              (PCWrite),
    .pc_i                   (IF_pc_next),
    .pc_o                   (IF_pc_cur)
);

Adder Add_PC(
    .data_1_i               (IF_pc_cur),
    .data_2_i               (32'd4),
    .data_o                 (IF_pc_cur_plus_4)
);

Instruction_Memory Instruction_Memory(
    .addr_i                 (IF_pc_cur), 
    .instr_o                (IF_instr)
);

// ID stage
Hazard_Detection_Unit Hazard_Detection(
    .ID_rs1_i               (ID_instr[19:15]),
    .ID_rs2_i               (ID_instr[24:20]),
    .EX_MemRead_i           (EX_MemRead),
    .EX_rd_i                (EX_rd),
    .PCWrite_o              (PCWrite),
    .Stall_o                (stall),
    .NoOp_o                 (NoOp)
);

Shift_Left_1 SLL_1(
    .instr_i                ({{20{ID_imm_data[31]}}, ID_imm_data[31], ID_imm_data[7], ID_imm_data[30:25], ID_imm_data[11:8]}),
    .instr_o                (branch_relative)
);

Adder Branch_Address(
    .data_1_i               (branch_relative),
    .data_2_i               (ID_pc),
    .data_o                 (branch_addr)
);

Control Control(
    .Op_i                   (ID_instr[6:0]),
    .NoOp_i                 (NoOp),
    .ALUOp_o                (ID_ALUOp),
    .ALUSrc_o               (ID_ALUSrc),
    .RegWrite_o             (ID_RegWrite),
    .MemtoReg_o             (ID_MemtoReg),
    .MemRead_o              (ID_MemRead),
    .MemWrite_o             (ID_MemWrite),
    .Branch_o               (ID_Branch)
);

Flush_And Flush_And(
    .Branch_i               (ID_Branch),
    .zero_i                 (zero),
    .Branch_o               (Flush)
);

Registers Registers(
    .clk_i                  (clk_i),
    .RS1addr_i              (ID_instr[19:15]),
    .RS2addr_i              (ID_instr[24:20]),
    .RDaddr_i               (WB_rd), 
    .RDdata_i               (WB_data),
    .RegWrite_i             (WB_RegWrite), 
    .RS1data_o              (ID_read_data_1), 
    .RS2data_o              (ID_read_data_2) 
);

Equal Equal(
    .read_data_1_i          (ID_read_data_1),
    .read_data_2_i          (ID_read_data_2),
    .zero_o                 (zero)
);

Imm_Gen Imm_Gen(
    .data_i                 (ID_instr),
    .data_o                 (ID_imm_data)
);

// EX stage
MUX32_4_to_1 MUX_4_to_1_A(
    .data_00_i              (EX_read_data_1),
    .data_01_i              (WB_data),
    .data_10_i              (MEM_addr),
    .data_11_i              (32'b0),
    .forward_i              (forward_A),
    .data_o                 (EX_alu_data_1)
);

MUX32_4_to_1 MUX_4_to_1_B(
    .data_00_i              (EX_read_data_2),
    .data_01_i              (WB_data),
    .data_10_i              (MEM_addr),
    .data_11_i              (32'b0),
    .forward_i              (forward_B),
    .data_o                 (EX_mux_to_mux_data)
);

MUX32 MUX_ALUSrc(
    .data1_i                (EX_mux_to_mux_data),
    .data2_i                (EX_se_data),
    .select_i               (EX_ALUSrc),
    .data_o                 (EX_alu_data_2)
);

ALU ALU(
    .data1_i                (EX_alu_data_1),
    .data2_i                (EX_alu_data_2),
    .ALUCtrl_i              (EX_ALUCtrl),
    .data_o                 (EX_alu_result)
);

ALU_Control ALU_Control(
    .funct_i                (EX_funct),
    .ALUOp_i                (EX_ALUOp),
    .ALUCtrl_o              (EX_ALUCtrl)
);

Forwarding_Unit Forwarding_Unit(
    .EX_rs1_i               (EX_rs1),
    .EX_rs2_i               (EX_rs2),
    .MEM_RegWrite_i         (MEM_RegWrite),
    .MEM_rd_i               (MEM_rd),
    .WB_RegWrite_i          (WB_RegWrite),
    .WB_rd_i                (WB_rd),
    .forward_a_o            (forward_A),
    .forward_b_o            (forward_B)
);

// MEM stage
dcache_controller dcache(
    .clk_i                  (clk_i),
    .rst_i                  (rst_i),
    // to Data Memory interface
    .mem_data_i             (mem_data_i),
    .mem_ack_i              (mem_ack_i),
    .mem_data_o             (mem_data_o),
    .mem_addr_o             (mem_addr_o),
    .mem_enable_o           (mem_enable_o),
    .mem_write_o            (mem_write_o),
    // to CPU interface
    .cpu_data_i             (MEM_write_data),
    .cpu_addr_i             (MEM_addr),
    .cpu_MemRead_i          (MEM_MemRead),
    .cpu_MemWrite_i         (MEM_MemWrite),
    .cpu_data_o             (MEM_read_data),
    .cpu_stall_o            (MEM_dcache_stall)
);

// WB stage
MUX32 To_Reg(
    .data1_i                (WB_data_not_mem),
    .data2_i                (WB_data_mem),
    .select_i               (WB_MemtoReg),
    .data_o                 (WB_data)
);

// Pipeline Registers
Pipeline_Registers Pipeline_Registers(
    .clk_i                  (clk_i),
    .dcache_stall_i         (MEM_dcache_stall),

    // IF/ID
    .pc_i                   (IF_pc_cur),
    .instr_i                (IF_instr),
    .stall_i                (stall),
    .flush_i                (Flush),
    .pc_o                   (ID_pc),
    .instr_o                (ID_instr),

    // ID/EX
    .ID_EX_RegWrite_i       (ID_RegWrite),
    .ID_EX_MemtoReg_i       (ID_MemtoReg),
    .ID_EX_MemRead_i        (ID_MemRead),
    .ID_EX_MemWrite_i       (ID_MemWrite),
    .ALUOp_i                (ID_ALUOp),
    .ALUSrc_i               (ID_ALUSrc),
    .read_data_1_i          (ID_read_data_1),
    .read_data_2_i          (ID_read_data_2),
    .imm_data_i             (ID_imm_data),
    .funct_i                ({ID_instr[31:25], ID_instr[14:12]}),
    .ID_EX_rs1_i            (ID_instr[19:15]),
    .ID_EX_rs2_i            (ID_instr[24:20]),
    .ID_EX_rd_i             (ID_instr[11:7]),
    .ID_EX_RegWrite_o       (EX_RegWrite),
    .ID_EX_MemtoReg_o       (EX_MemtoReg),
    .ID_EX_MemRead_o        (EX_MemRead),
    .ID_EX_MemWrite_o       (EX_MemWrite),
    .ALUOp_o                (EX_ALUOp),
    .ALUSrc_o               (EX_ALUSrc),
    .read_data_1_o          (EX_read_data_1),
    .read_data_2_o          (EX_read_data_2),
    .imm_data_o             (EX_se_data),
    .funct_o                (EX_funct),
    .ID_EX_rs1_o            (EX_rs1),
    .ID_EX_rs2_o            (EX_rs2),
    .ID_EX_rd_o             (EX_rd),

    // EX/MEM
    .EX_MEM_RegWrite_i      (EX_RegWrite),
    .EX_MEM_MemtoReg_i      (EX_MemtoReg),
    .EX_MEM_MemRead_i       (EX_MemRead),
    .EX_MEM_MemWrite_i      (EX_MemWrite),
    .EX_MEM_alu_result_i    (EX_alu_result),
    .mem_write_data_i       (EX_mux_to_mux_data),
    .EX_MEM_rd_i            (EX_rd),
    .EX_MEM_RegWrite_o      (MEM_RegWrite),
    .EX_MEM_MemtoReg_o      (MEM_MemtoReg),
    .EX_MEM_MemRead_o       (MEM_MemRead),
    .EX_MEM_MemWrite_o      (MEM_MemWrite),
    .EX_MEM_alu_result_o    (MEM_addr),
    .mem_write_data_o       (MEM_write_data),
    .EX_MEM_rd_o            (MEM_rd),

    // MEM/WB
    .MEM_WB_RegWrite_i      (MEM_RegWrite),
    .MEM_WB_MemtoReg_i      (MEM_MemtoReg),
    .MEM_WB_alu_result_i    (MEM_addr),
    .mem_read_data_i        (MEM_read_data),
    .MEM_WB_rd_i            (MEM_rd),
    .MEM_WB_RegWrite_o      (WB_RegWrite),
    .MEM_WB_MemtoReg_o      (WB_MemtoReg),
    .MEM_WB_alu_result_o    (WB_data_not_mem),
    .mem_read_data_o        (WB_data_mem),
    .MEM_WB_rd_o            (WB_rd)
);

endmodule

