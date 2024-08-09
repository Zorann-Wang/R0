`include "defines.v"

module inst_decode(
    input   wire                        clk_i,
    input   wire                        rst_n_i,

    // IF
    input   wire [`INST_DATA_BUS]       inst_i,            // instruction input
    input   wire [`INST_ADDR_BUS]       inst_addr_i,       // instruction address input
    
    // gp_regs
    input   wire [`REG_DATA_BUS]        reg1_rdata_i,
    input   wire [`REG_DATA_BUS]        reg2_rdata_i,
    output  reg  [`REG_ADDR_BUS]        reg1_raddr_o,
    output  reg  [`REG_ADDR_BUS]        reg2_raddr_o,
    
    // csr_reg
    input   wire [`CSR_DATA_BUS]        csr_rdata_i,
    output  reg  [`CSR_ADDR_BUS]        csr_raddr_o,  

    // EX
    output  reg  [`REG_DATA_BUS]        op1_o,
    output  reg  [`REG_DATA_BUS]        op2_o,
    output  reg  [`REG_DATA_BUS]        offset_o,
    output  reg  [`INST_DATA_BUS]       inst_o,         
    output  reg  [`INST_ADDR_BUS]       inst_addr_o,        
    output  reg                         reg_wen_o,             
    output  reg  [`REG_ADDR_BUS]        reg_waddr_o,    
    output  reg                         csr_wen_o,        
    output  reg  [`CSR_DATA_BUS]        csr_rdata_o,      
    output  reg  [`CSR_ADDR_BUS]        csr_waddr_o
);
    
// 32-bit instructions info
wire [6:0]  func7;
wire [4:0]  rs2;
wire [4:0]  rs1;
wire [2:0]  func3;
wire [4:0]  rd;
wire [6:0]  opcode;

always_comb begin 
    func7   = inst_i [31:25];
    rs2     = inst_i [24:20];   
    rs1     = inst_i [19:15];   
    func3   = inst_i [14:12];   
    rd      = inst_i [11:7];  
    opcode  = inst_i [6:0]; 
end

always_comb begin
    inst_o          = inst_i;
    inst_addr_o     = inst_addr_i;
    csr_rdata_o     = csr_rdata_i;

    priority case (opcode)
        `INST_R_TYPE: begin
            offset_o        = 32'b0;
            csr_wen_o       = 1'b0;
            csr_raddr_o     = 32'b0;
            csr_waddr_o     = 32'b0;

            priority case (func3)
                 `INST_ADD, `INST_SUB, `INST_SLL, `INST_SLT, `INST_SLTU, `INST_XOR, `INST_SRL, `INST_SRA, `INST_OR, `INST_AND: begin
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = rd;
                    reg1_raddr_o    = rs1;
                    reg2_raddr_o    = rs2;
                    op1_o           = reg1_rdata_i;
                    op2_o           = reg2_rdata_i;
                end
                default: begin
                    reg_wen_o       = 1'b0;
                    reg_waddr_o     = 5'b0;
                    reg1_raddr_o    = 5'b0;
                    reg2_raddr_o    = 5'b0;
                    op1_o           = 32'b0;
                    op2_o           = 32'b0;
                end
            endcase
        end

        `INST_I_TYPE: begin
            offset_o        = 32'b0;
            csr_wen_o       = 1'b0;
            csr_raddr_o     = 32'b0;
            csr_waddr_o     = 32'b0;

            priority case (func3)
                `INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI, `INST_SLLI, `INST_SRLI, `INST_SRAI: begin
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = rd;
                    reg1_raddr_o    = rs1;
                    reg2_raddr_o    = 5'b0;
                    op1_o           = reg1_rdata_i;
                    op2_o           = {20{inst_i[31]},inst_i[31:20]};
                end
                default: begin
                    reg_wen_o       = 1'b0;
                    reg_waddr_o     = 5'b0;
                    reg1_raddr_o    = 5'b0;
                    reg2_raddr_o    = 5'b0;
                    op1_o           = 32'b0;
                    op2_o           = 32'b0;
                end
            endcase
        end

        `INST_L_TYPE: begin
            offset_o        = 32'b0;
            csr_wen_o       = 1'b0;
            csr_raddr_o     = 32'b0;
            csr_waddr_o     = 32'b0;         

            priority case (func3)
                 `INST_LB, `INST_LH, `INST_LW, `INST_LBU, `INST_LHU: begin
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = rd;
                    reg1_raddr_o    = rs1;
                    reg2_raddr_o    = 5'b0;
                    op1_o           = reg1_rdata_i;
                    op2_o           = {20{inst_i[31]},inst_i[31:20]};
                end
                default: begin
                    reg_wen_o       = 1'b0;
                    reg_waddr_o     = 5'b0;
                    reg1_raddr_o    = 5'b0;
                    reg2_raddr_o    = 5'b0;
                    op1_o           = 32'b0;
                    op2_o           = 32'b0;
                end
            endcase
        end


        `INST_JAL: begin
            reg_wen_o       = 1'b1;
            reg_waddr_o     = rd;
            reg1_raddr_o    = 5'b0;
            reg2_raddr_o    = 5'b0;
            op1_o           = inst_addr_i;
            op2_o           = 32'b0;
            offset_o        = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
            csr_wen_o       = 1'b0;
            csr_raddr_o     = 32'b0;
            csr_waddr_o     = 32'b0;
        end

        `INST_JALR: begin
            reg_wen_o       = 1'b1;
            reg_waddr_o     = rd;
            reg1_raddr_o    = rs1;
            reg2_raddr_o    = 5'b0;
            op1_o           = reg1_rdata_i;
            op2_o           = inst_addr_i;
            offset_o        = {{20{inst_i[31]}}, inst_i[31:20]};
            csr_wen_o       = 1'b0;
            csr_raddr_o     = 32'b0;
            csr_waddr_o     = 32'b0;
        end

        `INST_S_TYPE: begin
            csr_wen_o       = 1'b0;
            csr_raddr_o     = 32'b0;
            csr_waddr_o     = 32'b0;

            priority case (func3)
                `INST_SB, `INST_SH, `INST_SW: begin
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = 5'b0;
                    reg1_raddr_o    = rs1;
                    reg2_raddr_o    = rs2;
                    op1_o           = reg1_rdata_i;
                    op2_o           = reg2_rdata_i;
                    offset_o        = {20{inst_i[31]},inst_i[31:25],inst_i[11:7]};
                end
                default: begin
                    reg_wen_o       = 1'b0;
                    reg_waddr_o     = 5'b0;
                    reg1_raddr_o    = 5'b0;
                    reg2_raddr_o    = 5'b0;
                    op1_o           = 32'b0;
                    op2_o           = 32'b0;
                    offset_o        = 32'b0;
                end
            endcase
        end

        `INST_B_TYPE: begin
            csr_wen_o       = 1'b0;
            csr_raddr_o     = 32'b0;
            csr_waddr_o     = 32'b0;

            priority case (func3)
                `INST_BEQ, `INST_BNE, `INST_BLT, `INST_BGE, `INST_BLTU, `INST_BGEU: begin
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = 5'b0;
                    reg1_raddr_o    = rs1;
                    reg2_raddr_o    = rs2;
                    op1_o           = reg1_rdata_i;
                    op2_o           = reg2_rdata_i;
                    offset_o        = {20{inst_i[31]},inst_i[7],inst_i[30:25],inst_i[11:8]};
                end
                default: begin
                    reg_wen_o       = 1'b0;
                    reg_waddr_o     = 5'b0;
                    reg1_raddr_o    = 5'b0;
                    reg2_raddr_o    = 5'b0;
                    op1_o           = 32'b0;
                    op2_o           = 32'b0;
                    offset_o        = 32'b0;
                end
            endcase
        end

        `INST_LUI, `INST_AUIPC: begin
            reg_wen_o       = 1'b1;
            reg_waddr_o     = rd;
            reg1_raddr_o    = 5'b0;
            reg2_raddr_o    = 5'b0;
            op1_o           = {inst_i[31:12],12'b0};
            op2_o           = 32'b0;
            offset_o        = 32'b0;
            csr_wen_o       = 1'b0;
            csr_raddr_o     = 32'b0;
            csr_waddr_o     = 32'b0;
        end
        
        `INST_CSR_TYPE: begin
            priority case (func3)
                `INST_CSRRW, `INST_CSRRS, `INST_CSRRC: begin
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = rd;
                    reg1_raddr_o    = rs1;
                    reg2_raddr_o    = 5'b0;
                    op1_o           = reg1_raddr_i;
                    op2_o           = 32'b0;
                    offset_o        = 32'b0;
                    csr_wen_o       = 1'b1;
                    csr_raddr_o     = {20'h0, inst_i[31:20]};
                    csr_waddr_o     = {20'h0, inst_i[31:20]};
                end
                `INST_CSRRWI, `INST_CSRRSI, `INST_CSRRCI: begin
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = rd;
                    reg1_raddr_o    = 5'b0;
                    reg2_raddr_o    = 5'b0;
                    op1_o           = {27'h0, ins_i[19:15]};
                    op2_o           = 32'b0;
                    offset_o        = 32'b0;
                    csr_wen_o       = 1'b1;
                    csr_raddr_o     = {20'h0, inst_i[31:20]};
                    csr_waddr_o     = {20'h0, inst_i[31:20]};
                end
                default: begin
                    reg_wen_o       = 1'b0;
                    reg_waddr_o     = 5'b0;
                    reg1_raddr_o    = 5'b0;
                    reg2_raddr_o    = 5'b0;
                    op1_o           = 32'b0;
                    op2_o           = 32'b0;
                    offset_o        = 32'b0;
                    csr_wen_o       = 1'b0;
                    csr_raddr_o     = 32'b0;
                    csr_waddr_o     = 32'b0;
                end
            endcase
        end

        `INST_FENCE: begin
            reg_wen_o       = 1'b0;
            reg_waddr_o     = 5'b0;
            reg1_raddr_o    = 5'b0;
            reg2_raddr_o    = 5'b0;
            op1_o           = inst_addr_i;
            op2_o           = 32'h4;
            offset_o        = 32'b0;
            csr_wen_o       = 1'b0;
            csr_raddr_o     = 32'b0;
            csr_waddr_o     = 32'b0;
        end

        default: begin
            reg_wen_o       = 1'b0;
            reg_waddr_o     = 5'b0;
            reg1_raddr_o    = 5'b0;
            reg2_raddr_o    = 5'b0;
            op1_o           = 32'b0;
            op2_o           = 32'b0;
            offset_o        = 32'b0;
            csr_wen_o       = 1'b0;
            csr_raddr_o     = 32'b0;
            csr_waddr_o     = 32'b0;
        end
    endcase
end

endmodule