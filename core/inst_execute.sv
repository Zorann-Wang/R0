`include "define.sv"

module inst_execute (
    input   wire                        clk_i,
    input   wire                        rst_n_i,

    // ID
    input   reg  [`REG_DATA_BUS]        op1_i,
    input   reg  [`REG_DATA_BUS]        op2_i,
    input   reg  [`REG_DATA_BUS]        offset_i,
    input   reg  [`INST_DATA_BUS]       inst_i,         
    input   reg  [`INST_ADDR_BUS]       inst_addr_i,        
    input   reg                         reg_wen_i,             
    input   reg  [`REG_ADDR_BUS]        reg_waddr_i,    
    input   reg                         csr_wen_i,        
    input   reg  [`CSR_DATA_BUS]        csr_rdata_i,      
    input   reg  [`CSR_ADDR_BUS]        csr_waddr_i,    

    // reg
    output  reg                         reg_wen_o,
    output  reg  [`REG_ADDR_BUS]        reg_waddr_o,
    output  reg  [`REG_DATA_BUS]        reg_wdata_o,

    // csr
    output  reg                         csr_wen_o,
    output  reg  [`CSR_ADDR_BUS]        csr_waddr_o,
    output  reg  [`CSR_DATA_BUS]        csr_wdata_o,
    
    // memory
    input   wire [`MEM_DATA_BUS]        mem_rdata_i,
    output  logic                       mem_rib_rreq_o,
    output  reg  [`MEM_ADDR_BUS]        mem_raddr_o,
    output  reg                         mem_rib_wreq_o,
    output  reg                         mem_wen_o, 
    output  logic[`MEM_ADDR_BUS]        mem_waddr_o, 
    output  reg  [`MEM_DATA_BUS]        mem_wdata_o,

    // jump
    output  logic                       jump_flag_o,
    output  logic[`INST_ADDR_BUS]       jump_addr_o,

    input   wire                        int_flag_i,          
    input   wire [`INST_ADDR_BUS]       int_addr_i, 

    // alu 
    input   wire [`REG_DATA_BUS]        alu_data_i,     
    //input   wire                        alu_zero_i,    
    //input   wire                        alu_sign_i,
    output  reg  [`REG_DATA_BUS]        alu_data1_o,
    output  reg  [`REG_DATA_BUS]        alu_data2_o,
    output  reg  [3:0]                  alu_op_o
);

logic [6:0]              func7;
logic [2:0]              func3;
logic [6:0]              opcode;
logic [`INST_ADDR_BUS]   jump_addr;
logic                    reg_wen;
logic                    csr_wen;
logic                    mem_rib_rreq;
logic                    mem_rib_wreq;
logic                    mem_wen;

always_comb begin
    func7           = inst_i [31:25];
    func3           = inst_i [14:12];   
    opcode          = inst_i [6:0]; 
    
    if (int_flag_i) begin
        jump_addr_o     = int_addr_i;
        reg_wen_o       = 1'b0;
        csr_wen_o       = 1'b0;
        mem_rib_rreq_o  = 1'b0;
        mem_rib_wreq_o  = 1'b0;
        mem_wen_o       = 1'b0;
    end
    else begin
        jump_addr_o = jump_addr;
        reg_wen_o       = reg_wen;
        csr_wen_o       = csr_wen;
        mem_rib_rreq_o  = mem_rib_rreq;
        mem_rib_wreq_o  = mem_rib_wreq;
        mem_wen_o       = mem_wen;
    end
end

always_comb begin 
    reg_wen         = reg_wen_i;
    reg_waddr_o     = reg_waddr_i;
    csr_wen         = csr_wen_i;
    csr_waddr_o     = csr_waddr_i;

    priority case (opcode)
        `INST_R_TYPE: begin
            csr_wdata_o     = 32'b0;
            mem_rib_wreq    = 1'b0;
            mem_wen         = 1'b0;
            mem_waddr_o     = 32'b0;
            mem_rib_rreq    = 1'b0;
            mem_raddr_o     = 32'b0;
            mem_wdata_o     = 32'b0;
            jump_flag_o     = 1'b0;
            jump_addr       = 32'b0;

            priority case (func3)
                `INST_ADD, `INST_SUB: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = (func7) ? `ALU_SUB : `ALU_ADD;                  
                    reg_wdata_o     = alu_data_i;
                end

                `INST_SLL: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLL;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_SLT: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLT;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_SLTU: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLTU;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_XOR: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_XOR;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_SRL: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SRL; 
                    reg_wdata_o     = alu_data_i;
                end

                `INST_SRA: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SRA;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_OR: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_OR;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_AND: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_AND;
                    reg_wdata_o     = alu_data_i;
                end

                default: begin
                    alu_data1_o     = 32'b0;
                    alu_data2_o     = 32'b0;
                    alu_op_o        = 4'b0;
                    reg_wdata_o     = 32'b0;
                end
            endcase
        end

        `INST_I_TYPE: begin
            csr_wdata_o     = 32'b0;
            mem_rib_wreq    = 1'b0;
            mem_wen         = 1'b0;
            mem_waddr_o     = 32'b0;
            mem_rib_rreq    = 1'b0;
            mem_raddr_o     = 32'b0;
            mem_wdata_o     = 32'b0;
            jump_flag_o     = 1'b0;
            jump_addr       = 32'b0;

            priority case (func3)
                `INST_ADDI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_AND;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_SLTI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLT;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_SLTIU: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLTU;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_XORI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_XOR;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_ORI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_OR;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_ANDI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_AND;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_SLLI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLL;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_SRLI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SRL;
                    reg_wdata_o     = alu_data_i;
                end

                `INST_SRAI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SRA;
                    reg_wdata_o     = alu_data_i;
                end

                default: begin
                    alu_data1_o     = 32'b0;
                    alu_data2_o     = 32'b0;
                    alu_op_o        = 4'b0;
                    reg_wdata_o     = 32'b0;
                end
            endcase
        end

        `INST_L_TYPE: begin
            alu_data1_o     = $signed(op1_i);
            alu_data2_o     = $signed(op2_i);
            alu_op_o        = `ALU_ADD;
            csr_wdata_o     = 32'b0;
            mem_rib_wreq    = 1'b0;
            mem_wen         = 1'b0;
            mem_waddr_o     = 32'b0;
            mem_wdata_o     = 32'b0;
            mem_rib_rreq    = 1'b1;
            mem_raddr_o     = alu_data_i;
            jump_flag_o     = 1'b0;
            jump_addr       = 32'b0;

            priority case (func3)
                `INST_LB: begin
                    priority case(alu_data_i[1:0])
                        2'b00: begin
                            reg_wdata_o = {{24{mem_rdata_i[7]}}, mem_rdata_i[7:0]};
                        end
                        2'b01: begin
                            reg_wdata_o = {{24{mem_rdata_i[15]}}, mem_rdata_i[15:8]};
                        end
                        2'b10: begin
                            reg_wdata_o = {{24{mem_rdata_i[23]}}, mem_rdata_i[23:16]};
                        end
                        2'b11: begin
                            reg_wdata_o = {{24{mem_rdata_i[31]}}, mem_rdata_i[31:24]};
                        end
                        default: begin
                            reg_wdata_o = 32'b0;
                        end
                    endcase
                end

                `INST_LH: begin
                    if(|alu_data_i[1:0]) begin
                        reg_wdata_o = {{16{mem_rdata_i[31]}}, mem_rdata_i[31:16]};
                    end
                    else begin
                        reg_wdata_o = {{16{mem_rdata_i[15]}}, mem_rdata_i[15:0]};
                    end
                end

                `INST_LW: begin
                    reg_wdata_o = mem_rdata_i;
                end

                `INST_LBU: begin
                    priority case(alu_data_i[1:0])
                        2'b00: begin
                            reg_wdata_o = {{24{1'b0}}, mem_rdata_i[7:0]};
                        end
                        2'b01: begin
                            reg_wdata_o = {{24{1'b0}}, mem_rdata_i[15:8]};
                        end
                        2'b10: begin
                            reg_wdata_o = {{24{1'b0}}, mem_rdata_i[23:16]};
                        end
                        2'b11: begin
                            reg_wdata_o = {{24{1'b0}}, mem_rdata_i[31:24]};
                        end
                        default: begin
                            reg_wdata_o = 32'b0;
                        end
                    endcase
                end

                `INST_LHU: begin
                    if(|alu_data_i[1:0]) begin
                        reg_wdata_o = {{16{1'b0}}, mem_rdata_i[31:16]};
                    end
                    else begin
                        reg_wdata_o = {{16{1'b0}}, mem_rdata_i[15:0]};
                    end
                end

                default: begin
                    reg_wdata_o = 32'b0;
                end
            endcase
        end

        `INST_JAL: begin
            alu_data1_o     = op1_i;
            alu_data2_o     = offset_i;
            alu_op_o        = `ALU_ADD;
            reg_wdata_o     = op1_i + 32'h4;
            csr_wdata_o     = 32'b0;
            mem_rib_wreq    = 1'b0;
            mem_wen         = 1'b0;
            mem_waddr_o     = 32'b0;
            mem_wdata_o     = 32'b0;
            mem_rib_rreq    = 1'b0;
            mem_raddr_o     = 32'b0;
            jump_flag_o     = 1'b1;
            jump_addr       = alu_data_i;
        end

        `INST_JALR: begin
            alu_data1_o     = op1_i;
            alu_data2_o     = offset_i;
            alu_op_o        = `ALU_ADD;
            reg_wdata_o     = op2_i + 32'h4;
            csr_wdata_o     = 32'b0;
            mem_rib_wreq    = 1'b0;
            mem_wen         = 1'b0;
            mem_waddr_o     = 32'b0;
            mem_wdata_o     = 32'b0;
            mem_rib_rreq    = 1'b0;
            mem_raddr_o     = 32'b0;
            jump_flag_o     = 1'b1;
            jump_addr       = alu_data_i & ~32'b1;
        end

        `INST_S_TYPE: begin
            alu_data1_o     = $signed(op1_i);
            alu_data2_o     = $signed(offset_i);
            alu_op_o        = `ALU_ADD;
            reg_waddr_o     = 5'b0;
            reg_wdata_o     = 32'b0;
            csr_wdata_o     = 32'b0;
            mem_rib_wreq    = 1'b1;
            mem_wen         = 1'b1;
            mem_waddr_o     = alu_data_i;
            mem_rib_rreq    = 1'b1;
            mem_raddr_o     = alu_data_i;
            jump_flag_o     = 1'b0;
            jump_addr       = 32'b0;

            priority case (func3)
                `INST_SB: begin
                    priority case(alu_data_i[1:0])
                        2'b00: begin
                            mem_wdata_o = {mem_rdata_i[31:8], op2_i[7:0]};
                        end
                        2'b01: begin
                            mem_wdata_o = {mem_rdata_i[31:16], op2_i[7:0], mem_rdata_i[7:0]};
                        end
                        2'b10: begin
                            mem_wdata_o = {mem_rdata_i[31:24], op2_i[7:0], mem_rdata_i[15:0]};
                        end
                        2'b11: begin
                            mem_wdata_o = {op2_i[7:0], mem_rdata_i[23:0]};
                        end
                        default: begin
                            mem_wdata_o = 32'b0;
                        end
                    endcase
                end

                `INST_SH: begin
                    if(|alu_data_i[1:0]) begin
                        mem_wdata_o = {op2_i[15:0], mem_rdata_i[15:0]};
                    end
                    else begin
                        mem_wdata_o = {mem_rdata_i[31:16], op2_i[15:0]};
                    end
                end

                `INST_SW: begin
                    mem_wdata_o = op2_i;
                end

                default: begin
                    mem_wdata_o = 32'b0;
                end
            endcase
        end

        `INST_B_TYPE: begin
            reg_wdata_o     = 32'b0;
            csr_wdata_o     = 32'b0;
            mem_rib_wreq    = 1'b0;
            mem_wen         = 1'b0;
            mem_waddr_o     = 32'b0;
            mem_rib_rreq    = 1'b0;
            mem_raddr_o     = 32'b0;
            mem_wdata_o     = 32'b0;

            priority case (func3)
                `INST_BEQ: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SUB;
                    jump_flag_o     = (|alu_data_i) ? 1'b0 : 1'b1;
                    jump_addr       = (|alu_data_i) ? 32'b0 : (inst_addr_i + offset_i);
                end

                `INST_BNE: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SUB;
                    jump_flag_o     = (|alu_data_i) ? 1'b1 : 1'b0;
                    jump_addr       = (|alu_data_i) ? (inst_addr_i + offset_i) : 32'b0;
                end

                `INST_BLT: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLT;
                    jump_flag_o     = (|alu_data_i) ? 1'b1 : 1'b0;
                    jump_addr       = (|alu_data_i) ? (inst_addr_i + offset_i) : 32'b0;
                end

                `INST_BGE: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLT;
                    jump_flag_o     = (|alu_data_i) ? 1'b0 : 1'b1;
                    jump_addr       = (|alu_data_i) ? 32'b0 : (inst_addr_i + offset_i);
                end

                `INST_BLTU: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLTU;
                    jump_flag_o     = (|alu_data_i) ? 1'b1 : 1'b0;
                    jump_addr       = (|alu_data_i) ? (inst_addr_i + offset_i) : 32'b0;
                end

                `INST_BGEU: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLTU;
                    jump_flag_o     = (|alu_data_i) ? 1'b0 : 1'b1;
                    jump_addr       = (|alu_data_i) ? 32'b0 : (inst_addr_i + offset_i);
                end

                default: begin
                    alu_data1_o     = 32'b0;
                    alu_data2_o     = 32'b0;
                    alu_op_o        = 4'b0;
                    jump_flag_o     = 1'b0;
                    jump_addr       = 32'b0;
                end
            endcase
        end

        `INST_LUI: begin
            alu_data1_o     = 32'b0;
            alu_data2_o     = 32'b0;
            alu_op_o        = 4'b0;
            reg_wdata_o     = op1_i;
            csr_wdata_o     = 32'b0;
            mem_rib_wreq    = 1'b0;
            mem_wen         = 1'b0;
            mem_waddr_o     = 32'b0;
            mem_rib_rreq    = 1'b0;
            mem_raddr_o     = 32'b0;
            mem_wdata_o     = 32'b0;
            jump_flag_o     = 1'b0;
            jump_addr       = 32'b0;
        end

        `INST_AUIPC: begin
            alu_data1_o     = op1_i;
            alu_data2_o     = inst_i;
            alu_op_o        = `ALU_ADD;
            reg_wdata_o     = alu_data_i;
            csr_wdata_o     = 32'b0;
            mem_rib_wreq    = 1'b0;
            mem_wen         = 1'b0;
            mem_waddr_o     = 32'b0;
            mem_rib_rreq    = 1'b0;
            mem_raddr_o     = 32'b0;
            mem_wdata_o     = 32'b0;
            jump_flag_o     = 1'b0;
            jump_addr       = 32'b0;
        end

        `INST_CSR_TYPE: begin
            mem_rib_wreq    = 1'b0;
            mem_wen         = 1'b0;
            mem_waddr_o     = 32'b0;
            mem_rib_rreq    = 1'b0;
            mem_raddr_o     = 32'b0;
            mem_wdata_o     = 32'b0;
            jump_flag_o     = 1'b0;
            jump_addr       = 32'b0;

            priority case (func3)
                `INST_CSRRW, `INST_CSRRWI: begin
                    alu_data1_o     = 32'b0;
                    alu_data2_o     = 32'b0;
                    alu_op_o        = 4'b0;
                    reg_wdata_o     = csr_rdata_i;
                    csr_wdata_o     = op1_i;
                end

                `INST_CSRRS, `INST_CSRRSI: begin
                    alu_data1_o     = csr_rdata_i;
                    alu_data2_o     = op1_i;
                    alu_op_o        = `ALU_OR;
                    reg_wdata_o     = csr_rdata_i;
                    csr_wdata_o     = alu_data_i;
                end

                `INST_CSRRC, `INST_CSRRCI: begin
                    alu_data1_o     = csr_rdata_i;
                    alu_data2_o     = ~ op1_i;
                    alu_op_o        = `ALU_AND;
                    reg_wdata_o     = csr_rdata_i;
                    csr_wdata_o     = alu_data_i;
                end

                default: begin
                    alu_data1_o     = 32'b0;
                    alu_data2_o     = 32'b0;
                    alu_op_o        = 4'b0;
                    reg_wdata_o     = 32'b0;
                    csr_wdata_o     = 32'b0;
                end
            endcase
        end

        default: begin
            alu_data1_o     = 32'b0;
            alu_data2_o     = 32'b0;
            alu_op_o        = 4'b0;
            reg_wdata_o     = 32'b0;
            csr_wdata_o     = 32'b0;
            mem_rib_wreq    = 1'b0;
            mem_wen         = 1'b0;
            mem_waddr_o     = 32'b0;
            mem_rib_rreq    = 1'b0;
            mem_raddr_o     = 32'b0;
            mem_wdata_o     = 32'b0;
            jump_flag_o     = 1'b0;
            jump_addr       = 32'b0;
        end      
    endcase
end

endmodule