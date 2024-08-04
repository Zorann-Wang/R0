`include "defines.v"

module csr_reg (
    input   wire                        clk_i,
    input   wire                        rst_n_i,

    // EX
    input   wire                        csr_wen_i,        
    input   wire [`CSR_ADDR_BUS]        csr_raddr_i,      
    input   wire [`CSR_ADDR_BUS]        csr_waddr_i, 
    input   wire [`CSR_DATA_BUS]        csr_wdata_i,
    output  reg  [`CSR_DATA_BUS]        csr_rdata_o,

    // clint
    input   wire                        clint_wen_i,        
    input   wire [`CSR_ADDR_BUS]        clint_raddr_i,      
    input   wire [`CSR_ADDR_BUS]        clint_waddr_i, 
    input   wire [`CSR_DATA_BUS]        clint_wdata_i,
    output  reg  [`CSR_DATA_BUS]        clint_rdata_o,
    output  wire [`CSR_DATA_BUS]        clint_csr_mtvec_o, 
    output  wire [`CSR_DATA_BUS]        clint_csr_mepc_o, 
    output  wire [`CSR_DATA_BUS]        clint_csr_mstatus_o
);

reg     [63:0]              cycle;
reg     [`CSR_DATA_BUS]     mtvec;
reg     [`CSR_DATA_BUS]     mcause;
reg     [`CSR_DATA_BUS]     mepc;
reg     [`CSR_DATA_BUS]     mie;
reg     [`CSR_DATA_BUS]     mstatus;
reg     [`CSR_DATA_BUS]     mscratch;
wire                        csr_wr_same_addr;
wire                        clint_wr_same_addr;

always_comb begin 
    csr_wr_same_addr    = ((csr_waddr_i[11:0] == csr_raddr_i[11:0]) && (csr_wen_i == 1'b1)) ? 1'b1 : 1'b0;
    clint_wr_same_addr  = ((clint_waddr_i[11:0] == clint_raddr_i[11:0]) && (clint_wen_i == 1'b1)) ? 1'b1 : 1'b0;
end

always_ff @( posedge clk_i ) begin 
    if (!rst_n_i) begin
        cycle <= 64'b0;
    end
    else begin
        cycle <= cycle + 1'b1;
    end
end

always_ff @( posedge clk_i ) begin 
    if (!rst_n_i) begin
        mtvec       <= 32'b0;
        mcause      <= 32'b0;
        mepc        <= 32'b0;
        mie         <= 32'b0;
        mstatus     <= 32'b0;
        mscratch    <= 32'b0;
    end
    else if (csr_wen_i) begin
        priority case (csr_waddr_i[11:0])
            `CSR_MTVEC: begin
                mtvec       <= csr_wdata_i;
                mcause      <= 32'b0;
                mepc        <= 32'b0;
                mie         <= 32'b0;
                mstatus     <= 32'b0;
                mscratch    <= 32'b0;
            end
            `CSR_MCAUSE: begin
                mtvec       <= 32'b0;
                mcause      <= csr_wdata_i;
                mepc        <= 32'b0;
                mie         <= 32'b0;
                mstatus     <= 32'b0;
                mscratch    <= 32'b0;
            end
            `CSR_MEPC: begin
                mtvec       <= 32'b0;
                mcause      <= 32'b0;
                mepc        <= csr_wdata_i;
                mie         <= 32'b0;
                mstatus     <= 32'b0;
                mscratch    <= 32'b0;
            end
            `CSR_MIE: begin
                mtvec       <= 32'b0;
                mcause      <= 32'b0;
                mepc        <= 32'b0;
                mie         <= csr_wdata_i;
                mstatus     <= 32'b0;
                mscratch    <= 32'b0;
            end
            `CSR_MSTATUS: begin
                mtvec       <= 32'b0;
                mcause      <= 32'b0;
                mepc        <= 32'b0;
                mie         <= 32'b0;
                mstatus     <= csr_wdata_i;
                mscratch    <= 32'b0;
            end
            `CSR_MSCRATCH: begin
                mmtvec      <= 32'b0;
                mcause      <= 32'b0;
                mepc        <= 32'b0;
                mie         <= 32'b0;
                mstatus     <= 32'b0;
                mscratch    <= csr_wdata_i;
            end: 
            default: begin
                mtvec       <= 32'b0;
                mcause      <= 32'b0;
                mepc        <= 32'b0;
                mie         <= 32'b0;
                mstatus     <= 32'b0;
                mscratch    <= 32'b0;
            end
        endcase
    end
    else if (clint_wen_i) begin
        priority case (clint_waddr_i[11:0])
            `CSR_MTVEC: begin
                mtvec       <= clint_wdata_i;
                mcause      <= 32'b0;
                mepc        <= 32'b0;
                mie         <= 32'b0;
                mstatus     <= 32'b0;
                mscratch    <= 32'b0;
            end
            `CSR_MCAUSE: begin
                mtvec       <= 32'b0;
                mcause      <= clint_wdata_i;
                mepc        <= 32'b0;
                mie         <= 32'b0;
                mstatus     <= 32'b0;
                mscratch    <= 32'b0;
            end
            `CSR_MEPC: begin
                mtvec       <= 32'b0;
                mcause      <= 32'b0;
                mepc        <= clint_wdata_i;
                mie         <= 32'b0;
                mstatus     <= 32'b0;
                mscratch    <= 32'b0;
            end
            `CSR_MIE: begin
                mtvec       <= 32'b0;
                mcause      <= 32'b0;
                mepc        <= 32'b0;
                mie         <= clint_wdata_i;
                mstatus     <= 32'b0;
                mscratch    <= 32'b0;
            end
            `CSR_MSTATUS: begin
                mtvec       <= 32'b0;
                mcause      <= 32'b0;
                mepc        <= 32'b0;
                mie         <= 32'b0;
                mstatus     <= clint_wdata_i;
                mscratch    <= 32'b0;
            end
            `CSR_MSCRATCH: begin
                mmtvec      <= 32'b0;
                mcause      <= 32'b0;
                mepc        <= 32'b0;
                mie         <= 32'b0;
                mstatus     <= 32'b0;
                mscratch    <= clint_wdata_i;
            end: 
            default: begin
                mtvec       <= 32'b0;
                mcause      <= 32'b0;
                mepc        <= 32'b0;
                mie         <= 32'b0;
                mstatus     <= 32'b0;
                mscratch    <= 32'b0;
            end
        endcase
    end
end

always_comb begin 
    if (csr_wr_same_addr) begin
        csr_rdata_o = csr_wdata_i;
    end
    else begin
        priority case (csr_raddr_i[11:0])
            `CSR_CYCLE: begin
                csr_rdata_o = cycle[31:0];
            end
            `CSR_CYCLEH: begin
                csr_rdata_o = cycle[63:32];
            end
            `CSR_MTVEC: begin
                csr_rdata_o = mtvec;
            end
            `CSR_MCAUSE: begin
                csr_rdata_o = mcause;
            end
            `CSR_MEPC: begin
                csr_rdata_o = mepc;
            end
            `CSR_MIE: begin
                csr_rdata_o = mie;
            end
            `CSR_MSTATUS: begin
                csr_rdata_o = mstatus;
            end
            `CSR_MSCRATCH: begin
                csr_rdata_o = mscratch;
            end
            default: begin
                csr_rdata_o = 32'b0;
            end
        endcase
    end
end

always_comb begin 
    if (clint_wr_same_addr) begin
        clint_rdata_o = clint_wdata_i;
    end
    else begin
        priority case (csr_raddr_i[11:0])
            `CSR_CYCLE: begin
                clint_rdata_o = cycle[31:0];
            end
            `CSR_CYCLEH: begin
                clint_rdata_o = cycle[63:32];
            end
            `CSR_MTVEC: begin
                clint_rdata_o = mtvec;
            end
            `CSR_MCAUSE: begin
                clint_rdata_o = mcause;
            end
            `CSR_MEPC: begin
                clint_rdata_o = mepc;
            end
            `CSR_MIE: begin
                clint_rdata_o = mie;
            end
            `CSR_MSTATUS: begin
                clint_rdata_o = mstatus;
            end
            `CSR_MSCRATCH: begin
                clint_rdata_o = mscratch;
            end
            default: begin
                clint_rdata_o = 32'b0;
            end
        endcase
    end
end

endmodule