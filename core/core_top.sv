`include "defines.v"

module core_top (
    input   wire                        clk_i,
    input   wire                        rst_n_i,

    // pc_reg
    output  wire [`INST_ADDR_BUS]       pc_addr_o,

    // inst_fetch
    input   wire [`INST_DATA_BUS]       rib_inst_i,           
    input   wire [`INST_ADDR_BUS]       rib_inst_addr_i, 

    // rib
    input   wire [`INT_BUS]             int_flag_i,
    input   wire [`MEM_DATA_BUS]        mem_rdata_i,
    output  wire                        mem_rib_rreq_o,
    output  wire [`MEM_ADDR_BUS]        mem_raddr_o,
    output  wire                        mem_rib_wreq_o,
    output  wire                        mem_wen_o, 
    output  wire [`MEM_ADDR_BUS]        mem_waddr_o,
    output  wire [`MEM_DATA_BUS]        mem_wdata_o,
);

// pc_reg
wire [`HOLD_BUS]            hold_flag_ctrl;
wire                        jump_flag_ctrl;
wire [`INST_ADDR_BUS]       jump_addr_ctrl;

// inst_fetch
wire [`HOLD_BUS]            hold_flag_ctrl;       

wire [`INT_BUS]             int_flag_id;  
wire [`INST_DATA_BUS]       inst_if;         
wire [`INST_ADDR_BUS]       inst_addr_if;      

// inst_decode
wire [`REG_DATA_BUS]        reg1_rdata_id;
wire [`REG_ADDR_BUS]        reg1_raddr_id;
wire [`REG_DATA_BUS]        reg2_rdata_id;
wire [`REG_ADDR_BUS]        reg2_raddr_id;
wire [`CSR_DATA_BUS]        csr_rdata_id;
wire [`CSR_ADDR_BUS]        csr_raddr_id;
wire [`REG_DATA_BUS]        op1_id;
wire [`REG_DATA_BUS]        op2_id;
wire [`REG_DATA_BUS]        offset_id;
wire [`INST_DATA_BUS]       inst_id;         
wire [`INST_ADDR_BUS]       inst_addr_id;        
wire                        reg_wen_id;             
wire [`REG_ADDR_BUS]        reg_waddr_id;    
wire                        csr_wen_id;        
wire [`CSR_DATA_BUS]        csr_rdata_id;      
wire [`CSR_ADDR_BUS]        csr_waddr_id;
wire                        mem_rd_flag_id;

// id_to_ex
wire [`REG_DATA_BUS]        op1_id_to_ex;
wire [`REG_DATA_BUS]        op2_id_to_ex;
wire [`REG_DATA_BUS]        offset_id_to_ex;
wire [`INST_DATA_BUS]       inst_id_to_ex;         
wire [`INST_ADDR_BUS]       inst_addr_id_to_ex;        
wire                        reg_wen_id_to_ex;             
wire [`REG_ADDR_BUS]        reg_waddr_id_to_ex;    
wire                        csr_wen_id_to_ex;        
wire [`CSR_DATA_BUS]        csr_rdata_id_to_ex;      
wire [`CSR_ADDR_BUS]        csr_waddr_id_to_ex;

// inst_execute
wire                        reg_wen_ie;
wire [`REG_ADDR_BUS]        reg_waddr_ie;
wire [`REG_DATA_BUS]        reg_wdata_ie;
wire                        csr_wen_ie;
wire [`CSR_ADDR_BUS]        csr_waddr_ie;
wire [`CSR_DATA_BUS]        csr_wdata_ie;

wire                        jump_flag_ie;
wire [`INST_ADDR_BUS]       jump_addr_ie;
wire [`REG_DATA_BUS]        alu_data;     
wire [`REG_DATA_BUS]        alu_data1_ie;
wire [`REG_DATA_BUS]        alu_data2_ie;
wire [3:0]                  alu_op_ie;

pc_reg          u_pc_reg (
    .clk_i                  (clk_i),
    .rst_n_i                (rst_n_i),
    .hold_flag_i            (hold_flag_ctrl),
    .jump_flag_i            (jump_flag_ctrl),
    .jump_addr_i            (jump_addr_ctrl),
    .pc_addr_o              (pc_addr_o)
);

inst_fetch      u_if(
    .clk_i                  (clk_i),
    .rst_n_i                (rst_n_i),
    .hold_flag_i            (hold_flag_ctrl),       
    .interrupt_flag_i       (int_flag_i),  
    .interrupt_flag_o       (int_flag_id),  
    .inst_i                 (rib_inst_i),            
    .inst_addr_i            (rib_inst_addr_i),       
    .inst_o                 (inst_if),            
    .inst_addr_o            (inst_addr_if)        
);

inst_decode     u_id(
    .clk_i                  (clk_i),
    .rst_n_i                (rst_n_i),
    .inst_i                 (inst_if),            
    .inst_addr_i            (inst_addr_if),       
    
    .reg1_rdata_i           (reg1_rdata_id),
    .reg2_rdata_i           (reg2_rdata_id),
    .reg1_raddr_o           (reg1_raddr_id),
    .reg2_raddr_o           (reg2_raddr_id),

    .csr_rdata_i            (csr_rdata_id),
    .csr_raddr_o            (csr_raddr_id),  

    .op1_o                  (op1_id),
    .op2_o                  (op2_id),
    .offset_o               (offset_id),
    .inst_o                 (inst_id),         
    .inst_addr_o            (inst_addr_id),        
    .reg_wen_o              (reg_wen_id),             
    .reg_waddr_o            (reg_waddr_id),    
    .csr_wen_o              (csr_wen_id),        
    .csr_rdata_o            (csr_rdata_id),      
    .csr_waddr_o            (csr_waddr_id)
);

id_to_ex        u_id_to_ex(
    .clk_i                  (clk_i),
    .rst_n_i                (rst_n_i),
    .hold_flag_i            (),                        

    .op1_i                  (op1_id),
    .op2_i                  (op2_id),
    .offset_i               (offset_id),
    .inst_i                 (inst_id),         
    .inst_addr_i            (inst_addr_id),        
    .reg_wen_i              (reg_wen_id),             
    .reg_waddr_i            (reg_waddr_id),    
    .csr_wen_i              (csr_wen_id),        
    .csr_rdata_i            (csr_rdata_id),      
    .csr_waddr_i            (csr_waddr_id),   
    
    .op1_o                  (op1_id_to_ex),
    .op2_o                  (op2_id_to_ex),
    .offset_o               (offset_id_to_ex),
    .inst_o                 (inst_id_to_ex),         
    .inst_addr_o            (inst_addr_id_to_ex),        
    .reg_wen_o              (reg_wen_id_to_ex),             
    .reg_waddr_o            (reg_waddr_id_to_ex),    
    .csr_wen_o              (csr_wen_id_to_ex),        
    .csr_rdata_o            (csr_rdata_id_to_ex),      
    .csr_waddr_o            (csr_waddr_id_to_ex)  
);

inst_execute    u_ie(
    .clk_i                  (clk_i),
    .rst_n_i                (rst_n_i),

    .op1_i                  (op1_id_to_ex),
    .op2_i                  (op2_id_to_ex),
    .offset_i               (offset_id_to_ex),
    .inst_i                 (inst_addr_id_to_ex),         
    .inst_addr_i            (inst_addr_id_to_ex),        
    .reg_wen_i              (reg_wen_id_to_ex),             
    .reg_waddr_i            (reg_waddr_id_to_ex),    
    .csr_wen_i              (csr_wen_id_to_ex),        
    .csr_rdata_i            (csr_rdata_id_to_ex),      
    .csr_waddr_i            (csr_waddr_id_to_ex),    

    .reg_wen_o              (reg_wen_ie),
    .reg_waddr_o            (reg_wdata_ie),
    .reg_wdata_o            (reg_wdata_ie),

    .csr_wen_o              (csr_wen_ie),
    .csr_waddr_o            (csr_waddr_ie),
    .csr_wdata_o            (csr_waddr_ie),
    
    .mem_rdata_i            (mem_rdata_i),
    .mem_rib_rreq_o         (mem_rib_rreq_o),
    .mem_raddr_o            (mem_raddr_o),
    .mem_rib_wreq_o         (mem_rib_wreq_o),
    .mem_wen_o              (mem_wen_o), 
    .mem_waddr_o            (mem_waddr_o), 
    .mem_wdata_o            (mem_wdata_o),

    .jump_flag_o            (jump_flag_ie),
    .jump_addr_o            (jump_addr_ie),

    .alu_data_i             (alu_data),     
    .alu_data1_o            (alu_data1_ie),
    .alu_data2_o            (alu_data2_ie),
    .alu_op_o               (alu_op_ie)
);

alu             u_alu(
    .alu_data1_i            (alu_data1_ie), 
    .alu_data2_i            (alu_data2_ie),
    .alu_op_i               (alu_op_ie),
    .alu_data_o             (alu_data)
);

gp_reg          u_gp_reg(
    .clk_i                  (clk_i),
    .rst_n_i                (rst_n_i),

    .reg_wen_i              (reg_wen_ie),
    .reg_waddr_i            (reg_waddr_ie),
    .reg_wdata_i            (reg_wdata_ie),

    .jtag_en_i              (),
    .jtag_addr_i            (),
    .jtag_data_i            (),
    .jtag_data_o            (),

    .reg1_raddr_i           (reg1_raddr_id),
    .reg1_rdata_o           (reg1_rdata_id),
    .reg2_raddr_i           (reg2_raddr_id),
    .reg2_rdata_o           (reg2_rdata_id)
);

csr_reg         u_csr_reg(
    .clk_i                  (clk_i),
    .rst_n_i                (rst_n_i),

    .csr_wen_i              (csr_wen_id_to_ex),        
    .csr_raddr_i            (csr_raddr_id),      
    .csr_waddr_i            (csr_waddr_ie), 
    .csr_wdata_i            (csr_wdata_ie),
    .csr_rdata_o            (csr_rdata_id),

    .clint_wen_i            (),        
    .clint_raddr_i          (),      
    .clint_waddr_i          (), 
    .clint_wdata_i          (),
    .clint_rdata_o          (),
    .clint_csr_mtvec_o      (), 
    .clint_csr_mepc_o       (), 
    .clint_csr_mstatus_o    ()
);

ctrl(
    .clk_i                  (clk_i),
    .rst_n_i                (rst_n_i),

    .jump_flag_i            (),
    .jump_addr_i            (),
    .hold_flag_rib_i        (),
    .jtag_flag_i            (),
    .hold_flag_clint_i      (),
    .jump_flag_o            (),
    .jump_addr_o            (),
    .hold_flag_o            ()
);

clint (
    .clk_i                  (clk_i),
    .rst_n_i                (rst_n_i),

    .inst_i                 (),         
    .inst_addr_i            (),
    .jump_flag_o            (),
    .jump_addr_o            (),

    .csr_mtvec_i            (),
    .csr_mepc_i             (),
    .csr_mstatus_i          (),

    .clint_rdata_i          (),
    .clint_raddr_o          (),
    .clint_wen_o            (),
    .clint_waddr_o          (),
    .clint_wdata_o          (),

    .int_flag_i             (), 
    .clint_busy_o           (), 
    .int_addr_o             (), 
    .int_assert_o           ()
);

endmodule