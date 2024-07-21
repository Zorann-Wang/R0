`include "defines.v"

module id_to_ex(
    input   wire                        clk_i,
    input   wire                        rst_n_i,
    input   wire [`HOLD_BUS]            hold_flag_i,                        

    // from ID   
    input   wire [`MEM_ADDR_BUS]        op1_i,
    input   wire [`MEM_ADDR_BUS]        op2_i,
    input   wire [`MEM_ADDR_BUS]        op1_jump_i,
    input   wire [`MEM_ADDR_BUS]        op2_jump_i,
    input   wire [`INST_DATA_BUS]       inst_i,         
    input   wire [`INST_ADDR_BUS]       inst_addr_i,  
    input   wire                        reg_wen_i,   
    input   wire [`REG_DATA_BUS]        reg1_rdata_i,       
    input   wire [`REG_DATA_BUS]        reg2_rdata_i,     
    input   wire [`REG_ADDR_BUS]        reg_waddr_i,    
    input   wire                        csr_wen_i,        
    input   wire [`REG_DATA_BUS]        csr_rdata_i,      
    input   wire [`MEM_ADDR_BUS]        csr_waddr_i,

    // to EX     
    output  reg  [`MEM_ADDR_BUS]        op1_o,
    output  reg  [`MEM_ADDR_BUS]        op2_o,
    output  reg  [`MEM_ADDR_BUS]        op1_jump_o,
    output  reg  [`MEM_ADDR_BUS]        op2_jump_o,
    output  reg  [`INST_DATA_BUS]       inst_o,         
    output  reg  [`INST_ADDR_BUS]       inst_addr_o,
    output  reg                         reg_wen_o,    
    output  reg  [`REG_DATA_BUS]        reg1_rdata_o,       
    output  reg  [`REG_DATA_BUS]        reg2_rdata_o,     
    output  reg  [`REG_ADDR_BUS]        reg_waddr_o,    
    output  reg                         csr_wen_o,        
    output  reg  [`REG_DATA_BUS]        csr_rdata_o,      
    output  reg  [`MEM_ADDR_BUS]        csr_waddr_o      
);

wire hold_en;

always_comb begin
    if (hold_flag_i >= `HOLD_ID_EX) begin
        hold_en = 1'b1;
    end
    else begin
        hold_en = 1'b0;
    end
end

always_ff @( posedge clk_i ) begin 
    if (rst_n_i) begin
        inst_o          = `INST_NOP;
        inst_addr_o     = 32'b0;
        reg_wen_o       = 1'b0;
        reg_waddr_o     = 5'b0;
        reg1_rdata_o    = 32'b0;
        reg2_rdata_o    = 32'b0;
        op1_o           = 32'b0;
        op2_o           = 32'b0;
        op1_jump_o      = 32'b0;
        op2_jump_o      = 32'b0;
        csr_wen_o       = 1'b0;
        csr_waddr_o     = 32'b0;
        csr_rdata_o     = 32'b0;
    end
    else if (hold_en) begin
        inst_o          = `INST_NOP;
        inst_addr_o     = 32'b0;
        reg_wen_o       = 1'b0;
        reg_waddr_o     = 5'b0;
        reg1_rdata_o    = 32'b0;
        reg2_rdata_o    = 32'b0;
        op1_o           = 32'b0;
        op2_o           = 32'b0;
        op1_jump_o      = 32'b0;
        op2_jump_o      = 32'b0;
        csr_wen_o       = 1'b0;
        csr_waddr_o     = 32'b0;
        csr_rdata_o     = 32'b0;
    end
    else begin
        inst_o          = inst_i;
        inst_addr_o     = inst_addr_i;
        reg_wen_o       = reg_wen_i;
        reg_waddr_o     = reg_waddr_i;
        reg1_rdata_o    = reg1_rdata_i;
        reg2_rdata_o    = reg2_rdata_i;
        op1_o           = op1_i;
        op2_o           = op2_i;
        op1_jump_o      = op1_jump_i;
        op2_jump_o      = op2_jump_i;
        csr_wen_o       = csr_wen_i;
        csr_waddr_o     = csr_waddr_i;
        csr_rdata_o     = csr_rdata_i;
    end
end

endmodule