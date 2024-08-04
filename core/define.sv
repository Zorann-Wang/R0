`define RESET_ADDR      32'h0

`define REG_ADDR_BUS    4:0
`define REG_DATA_BUS    31:0

`define ROM_DEPTH       4096  // rom depth(how many words)

`define MEM_DEPTH       4096  // memory depth(how many words)
`define MEM_DATA_BUS    31:0
`define MEM_ADDR_BUS    31:0

`define HOLD_BUS        2:0
`define HOLD_NONE       3'b000
`define HOLD_PC         3'b001
`define HOLD_IF_ID      3'b010
`define HOLD_ID_EX      3'b011

`define INST_DATA_BUS   31:0      // width for instruction data bus
`define INST_ADDR_BUS   31:0      // width for instruction address bus
`define INST_NOP        32'h0013  // no operation; machine code for addi x0, x0, 0

`define INT_BUS         7:0       // width for interrupt bus
`define INT_NONE        8'h0
`define INT_TIMER       8'h1

`define CSR_ADDR_BUS    31:0
`define CSR_DATA_BUS    31:0
`define CSR_CYCLE       12'hc00
`define CSR_CYCLEH      12'hc80
`define CSR_MTVEC       12'h305
`define CSR_MCAUSE      12'h342
`define CSR_MEPC        12'h341
`define CSR_MIE         12'h304
`define CSR_MSTATUS     12'h300
`define CSR_MSCRATCH    12'h340

// R type instruction
`define INST_R_TYPE     7'b0110011
`define INST_ADD        3'b000
`define INST_SUB        3'b000
`define INST_SLL        3'b001
`define INST_SLT        3'b010
`define INST_SLTU       3'b011
`define INST_XOR        3'b100
`define INST_SRL        3'b101
`define INST_SRA        3'b101
`define INST_OR         3'b110
`define INST_AND        3'b111
`define ADD_FUNC        7'h0
`define SUB_FUNC        7'b0100000 
`define SRL_FUNC        7'h0
`define SRA_FUNC        7'h0100000 

// I and L type instruction
`define INST_L_TYPE     7'b0000011
`define INST_LB         3'b000
`define INST_LH         3'b001
`define INST_LW         3'b010
`define INST_LBU        3'b100
`define INST_LHU        3'b101

`define INST_I_TYPE     7'b0010011
`define INST_ADDI       3'b000
`define INST_SLTI       3'b010
`define INST_SLTIU      3'b011
`define INST_XORI       3'b100
`define INST_ORI        3'b110
`define INST_ANDI       3'b111
`define INST_SLLI       3'b001
`define INST_SRLI       3'b101
`define INST_SRAI       3'b101

// S type instruction
`define INST_S_TYPE     7'b0100011
`define INST_SB         3'b000
`define INST_SH         3'b001
`define INST_SW         3'b010

// B type instruction
`define INST_B_TYPE     7'b1100011
`define INST_BEQ        3'b000
`define INST_BNE        3'b001
`define INST_BLT        3'b100
`define INST_BGE        3'b101
`define INST_BLTU       3'b110
`define INST_BGEU       3'b111

// U type instruction
`define INST_LUI        7'b0110111
`define INST_AUIPC      7'b0010111     

// J type instruction
`define INST_JAL        7'b1101111
`define INST_JALR       7'b1100111

// CSR instruction
`define INST_CSR_TYPE   7'b1110011
`define INST_CSRRW      3'b001
`define INST_CSRRS      3'b010
`define INST_CSRRC      3'b011
`define INST_CSRRWI     3'b101
`define INST_CSRRSI     3'b110
`define INST_CSRRCI     3'b111

// other instruction
`define INST_FENCE      8'b0000_1111
`define INST_FENCE_I    8'b1000_1111
`define INST_ECALL      8'b0111_0011
`define INST_EBREAK     8'b1111_0011

// ALU operation code
`define ALU_ADD      4'b0001
`define ALU_SUB      4'b0010
`define ALU_SLL      4'b0011  
`define ALU_SLT      4'b0100  
`define ALU_SLTU     4'b0101  
`define ALU_XOR      4'b0110
`define ALU_SRL      4'b0111  
`define ALU_SRA      4'b1000  
`define ALU_OR       4'b1001
`define ALU_AND      4'b1010