`include "defines.v"

module inst_execute (
    input   wire                        clk_i,
    input   wire                        rst_n_i,

    // ID
    input   wire [`REG_DATA_BUS]        op1_i,
    input   wire [`REG_DATA_BUS]        op2_i,
    input   wire [`REG_DATA_BUS]        offset_i,
    input   wire [`MEM_ADDR_BUS]        op1_jump_i,
    input   wire [`MEM_ADDR_BUS]        op2_jump_i,
    input   wire [`INST_DATA_BUS]       inst_i,         
    input   wire [`INST_ADDR_BUS]       inst_addr_i,
    input   wire [`REG_DATA_BUS]        reg1_rdata_i,       
    input   wire [`REG_DATA_BUS]        reg2_rdata_i,     
    input   wire [`REG_ADDR_BUS]        reg_waddr_i, 

    // reg
    output  reg                         reg_wen_o,
    output  reg  [`INST_REG_ADDR]       reg_waddr_o,
    output  reg  [`INST_REG_DATA]       reg_wdata_o,
    
    // memory
    input   wire [`MEM_DATA_BUS]        mem_rdata_i,
    output  reg  [`MEM_ADDR_BUS]        mem_raddr_o,
    output  reg                         mem_rib_wreq_o,
    output  reg                         mem_wen_o, 
    output  wire [`MEM_ADDR_BUS]        mem_waddr_o, 
    output  reg  [`MEM_DATA_BUS]        mem_wdata_o,

    input   wire                        csr_wen_i,        
    input   wire [`REG_DATA_BUS]        csr_rdata_i,      
    input   wire [`MEM_ADDR_BUS]        csr_waddr_i,

    // alu 
    input   wire [`REG_DATA_BUS]        alu_data_i,     
    input   wire                        alu_zero_i,    
    input   wire                        alu_sign_i,
    output  reg  [`REG_DATA_BUS]        alu_data1_o,
    output  reg  [`REG_DATA_BUS]        alu_data2_o,
    output  reg  [3:0]                  alu_op_o
);

wire [6:0]              func7;
wire [2:0]              func3;
wire [6:0]              opcode;
wire [`MEM_ADDR_BUS]    mem_raddr_byte;
wire [`MEM_ADDR_BUS]    mem_waddr_byte;

always_comb begin
    func7           = inst_i [31:25];
    func3           = inst_i [14:12];   
    opcode          = inst_i [6 :0]; 
    mem_raddr_byte  = (opcode == `INST_L_TYPE) ? (op1_i + offset_i) : 32'b0;
    mem_waddr_byte  = (opcode == `INST_S_TYPE) ? (op1_i + offset_i) : 32'b0;
end

always_comb begin 
    priority case (opcode)
        `INST_R_TYPE: begin
            priority case (func3)
                `INST_ADD, `INST_SUB: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = (func7) ? `ALU_SUB : `ALU_ADD;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_SLL: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLL;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_SLT: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLT;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_SLTU: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLTU;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_XOR: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_XOR;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_SRL: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SRL;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_SRA: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SRA;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_OR: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_OR;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_AND: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_AND;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                default: begin
                    alu_data1_o     = 32'b0;
                    alu_data2_o     = 32'b0;
                    alu_op_o        = 4'b0;
                    reg_wen_o       = 1'b0;
                    reg_waddr_o     = 5'b0;
                    reg_wdata_o     = 32'b0;
                end
            endcase
        end

        `INST_I_TYPE: begin
            priority case (func3)
                `INST_ADDI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_AND;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_SLTI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLT;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_SLTIU: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLTU;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_XORI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_XOR;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_ORI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_OR;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_ANDI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_AND;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_SLLI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SLL;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_SRLI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SRL;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                `INST_SRAI: begin
                    alu_data1_o     = op1_i;
                    alu_data2_o     = op2_i;
                    alu_op_o        = `ALU_SRA;
                    reg_wen_o       = 1'b1;
                    reg_waddr_o     = reg_waddr_i;
                    reg_wdata_o     = alu_res_i;
                end

                default: begin
                    alu_data1_o     = 32'b0;
                    alu_data2_o     = 32'b0;
                    alu_op_o        = 4'b0;
                    reg_wen_o       = 1'b0;
                    reg_waddr_o     = 5'b0;
                    reg_wdata_o     = 32'b0;
                end
            endcase
        end

        `INST_L_TYPE: begin
            alu_data1_o     = 32'b0;
            alu_data2_o     = 32'b0;
            alu_op_o        = 4'b0;
            reg_wen_o       = 1'b0;
            reg_waddr_o     = 5'b0;

            priority case (func3)
                `INST_LB: begin
                    priority case(mem_raddr_byte[1:0])
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
                    endcase
                end

                `INST_LH: begin
                    if(|mem_raddr_byte[1:0]) begin
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
                    priority case(mem_raddr_byte[1:0])
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
                    endcase
                end

                `INST_LHU: begin
                    if(|mem_raddr_byte[1:0]) begin
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

        `INST_S_TYPE: begin
            alu_data1_o     = 32'b0;
            alu_data2_o     = 32'b0;
            alu_op_o        = 4'b0;
            reg_wen_o       = 1'b0;
            reg_waddr_o     = 5'b0;
            mem_rib_wreq_o  = 1'b1;
            mem_wen_o       = 1'b1;
            mem_waddr_o     = op1_i + offset_i;
            mem_raddr_o     = op1_i + offset_i;

            priority case (func3)
                `INST_SB: begin
                    priority case(mem_waddr_byte[1:0])
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
                    endcase
                end

                `INST_SH: begin
                    if(|mem_raddr_byte[1:0]) begin
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


        endcase
    
end

endmodule