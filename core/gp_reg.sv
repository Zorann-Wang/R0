`include "defines.sv"

module gp_reg (
    input   wire                    clk_i,
    input   wire                    rst_n_i,

    input   wire                    reg_wen_i,
    input   wire [REG_ADDR_BUS]     reg_waddr_i,
    input   wire [REG_DATA_BUS]     reg_wdata_i,

    input   wire                    jtag_en_i,
    input   wire [REG_ADDR_BUS]     jtag_addr_i,
    input   wire [REG_DATA_BUS]     jtag_data_i,
    output  wire [REG_DATA_BUS]     jtag_data_o,

    input   wire [REG_ADDR_BUS]     reg1_raddr_i,
    output  reg  [REG_DATA_BUS]     reg1_rdata_o,
    input   wire [REG_ADDR_BUS]     reg2_raddr_i,
    output  reg  [REG_DATA_BUS]     reg2_rdata_o
);

integer     i;
reg         [REG_DATA_BUS] regs [0:31];
wire        reg_waddr_valid;
wire        jtag_addr_valid;
wire        reg1_raddr_valid;
wire        reg2_raddr_valid;
wire        reg1_addr_same;
wire        reg2_addr_same;

always_comb begin 
    reg_waddr_valid     = (reg_waddr_i != 32'b0) ? 1'b1 : 1'b0;
    jtag_addr_valid     = (jtag_addr_i != 32'b0) ? 1'b1 : 1'b0;
    reg1_raddr_valid    = (reg1_raddr_i != 32'b0) ? 1'b1 : 1'b0;
    reg2_raddr_valid    = (reg2_raddr_i != 32'b0) ? 1'b1 : 1'b0;
    reg1_addr_same      = ((reg1_raddr_i == reg_waddr_i) && reg_wen_i) ? 1'b1 : 1'b0;
    reg2_addr_same      = ((reg2_raddr_i == reg_waddr_i) && reg_wen_i) ? 1'b1 : 1'b0;
end

always_ff @( posedge clk_i ) begin 
    if (!rst_n_i) begin
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] <= 32'b0;
        end
    end
    else if (reg_waddr_valid && reg_wen_i) begin
        regs[waddr_i] <= reg_wdata_i;
    end
    else if (jtag_addr_valid && jtag_en_i) begin
        regs[waddr_i] <= jtag_data_i;
    end
    else begin
        regs <= regs;
    end
end

always_comb begin 
    if (!reg1_raddr_valid) begin
        reg1_rdata_o = 32'b0;
    end
    else if (reg1_addr_same) begin
        reg1_rdata_o = reg_wdata_i;
    end
    else begin
        reg1_rdata_o = regs[reg1_raddr_i];
    end
end

always_comb begin 
    if (!reg2_raddr_valid) begin
        reg2_rdata_o = 32'b0;
    end
    else if (reg2_addr_same) begin
        reg2_rdata_o = reg_wdata_i;
    end
    else begin
        reg2_rdata_o = regs[reg2_raddr_i];
    end
end

always_comb begin 
    if (!jtag_addr_valid) begin
        jtag_data_o = 32'b0;
    end
    else begin
        jtag_data_o = regs[jtag_addr_i];
    end
end
    
endmodule