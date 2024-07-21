`include "defines.v"

module inst_execute (
    input   wire                        clk_i,
    input   wire                        rst_n_i,

    input   wire [`MEM_ADDR_BUS]        op1_i,
    input   wire [`MEM_ADDR_BUS]        op2_i,
    input   wire [`MEM_ADDR_BUS]        op1_jump_i,
    input   wire [`MEM_ADDR_BUS]        op2_jump_i,
    input   wire [`INST_DATA_BUS]       inst_i,         
    input   wire [`INST_ADDR_BUS]       inst_addr_i,
      
    // reg
    input   wire [`REG_DATA_BUS]        reg1_rdata_i,       
    input   wire [`REG_DATA_BUS]        reg2_rdata_i,     
    input   wire [`REG_ADDR_BUS]        reg_waddr_i, 
    output  reg                         reg_wen_o,
    output  reg  [`INST_REG_ADDR]       reg_waddr_o,
    output  reg  [`INST_REG_DATA]       reg_wdata_o,

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

wire [6:0]  func7;
wire [2:0]  func3;
wire [6:0]  opcode;

always_comb begin
    func7   = inst_i [31:25];
    func3   = inst_i [14:12];   
    opcode  = inst_i [6 :0]; 
end

always_comb begin 
    priority case (opcode)
        `INST_R_TYPE: begin
            priority case (func3)
                `INST_ADD, `INST_SUB: begin
                    alu_data1_o = reg1_rdata_i;
                    alu_data2_o = reg2_rdata_i;
                    alu_op_o    = (func7) ? `ALU_SUB : `ALU_ADD;
                    reg_wen_o   = 1'b1;
                end

                `INST_SLL: begin
                    alu_data1_o = reg1_rdata_i;
                    alu_data2_o = reg2_rdata_i;
                    alu_op_o    = `ALU_SLL;
                    reg_wen_o   = 1'b1;
                end

                `INST_SLT: begin
                    alu_data1_o = reg1_rdata_i;
                    alu_data2_o = reg2_rdata_i;
                    alu_op_o    = `ALU_SLT;
                    reg_wen_o   = 1'b1;
                end

                `INST_SLTU: begin
                    alu_data1_o = reg1_rdata_i;
                    alu_data2_o = reg2_rdata_i;
                    alu_op_o    = `ALU_SLTU;
                    reg_wen_o   = 1'b1;
                end

                default: 
            endcase
        end
        default: 
    endcase
    
end

endmodule