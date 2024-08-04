`include "defines.v"

module clint (
    input   wire                        clk_i,
    input   wire                        rst_n_i,

    input   wire [`INST_DATA_BUS]       inst_i,         
    input   wire [`INST_ADDR_BUS]       inst_addr_i,
    input   wire                        jump_flag_o,
    input   wire [`INST_ADDR_BUS]       jump_addr_o,

    input   wire [`CSR_DATA_BUS]        csr_mtvec_i,
    input   wire [`CSR_DATA_BUS]        csr_mepc_i,
    input   wire [`CSR_DATA_BUS]        csr_mstatus_i,

    input   reg  [`CSR_DATA_BUS]        clint_rdata_i,
    output  reg  [`CSR_ADDR_BUS]        clint_raddr_o,
    output  reg                         clint_wen_o,
    output  reg  [`CSR_ADDR_BUS]        clint_waddr_o,
    output  reg  [`CSR_DATA_BUS]        clint_wdata_o,

    input   wire [`INT_BUS]             int_flag_i, 
    output  wire                        clint_busy_o, 
    output  reg [`INST_ADDR_BUS]        int_addr_o, 
    output  reg                         int_assert_o          
);

localparam INT_IDLE            = 3'b001;
localparam INT_SYNC_ASSERT     = 3'b010;
localparam INT_ASYNC_ASSERT    = 3'b011;
localparam INT_MRET            = 3'b100;

localparam CSR_IDLE            = 3'b001;
localparam CSR_MSTATUS         = 3'b010;
localparam CSR_MEPC            = 3'b011;
localparam CSR_MSTATUS_MRET    = 3'b100;
localparam CSR_MCAUSE          = 3'b101;

reg [2:0]               int_state;
reg [2:0]               csr_state;
reg [`REG_DATA_BUS]     cause;
reg [`INST_DATA_BUS]    inst_addr;

always_comb begin
    clint_busy_o = ((int_state != INT_IDLE) | (csr_state != CSR_IDLE)) ? 1'b1 : 1'b0;
end

always_comb begin 
    if (!rst_n_i) begin
        int_state = INT_IDLE;
    end
    else begin
        if (inst_i == `INST_ECALL || inst_i == `INST_EBREAK) begin
            int_state = INT_IDLE;
        end
        else if (int_flag_i != `INT_NONE && csr_mstatus_i[3] == 1'b1) begin
            int_state = INT_ASYNC_ASSERT;
        end
        else if (ins_i == `INS_MRET) begin
                int_state = INT_MRET;
        end 
        else begin
            int_state = INT_IDLE;
        end
    end
end

always_ff @( posedge clk_i ) begin 
    if (!rst_n_i) begin
        csr_state   <= CSR_IDLE;
        cause       <= 32'b0;
        inst_addr   <= 32'b0;
    end
    else begin
        priority case (csr_state)
            CSR_IDLE: begin
                clint_wen_o     <= 1'b0;
                clint_waddr_o   <= 32'b0;
                clint_wdata_o   <= 32'b0;

                priority case (int_state)
                    `INT_SYNC_ASSERT: begin
                        csr_state <= CSR_MEPC;
                        inst_addr <= inst_addr_i;

                        if (inst_i == `INS_ECALL) begin
                            cause <= 32'd11;
                        end
                        else if (inst_i == `INS_EBREAK) begin
                            cause <= 32'd3;
                        end
                        else begin
                            cause <= 32'd10;
                        end
                    end

                    `INT_ASYNC_ASSERT: begin
                        csr_state <= CSR_MEPC;
                        inst_addr <= (jump_flag_i) ? jump_addr_i : inst_addr_i;

                        if (int_flag_i & `INT_TIMER) begin
                            cause <= 32'h80000007;
                        end
                        else if (int_flag_i & `INT_UART_REV) begin
                            cause <= 32'h8000000b;
                        end
                        else begin
                            cause <= 32'h8000000a;
                        end
                    end

                    `INT_MRET: begin
                        csr_state   <= CSR_MSTATUS_MRET;
                        inst_addr   <= inst_addr;
                        cause       <= cause;
                    end

                    default: begin
                        csr_state   <= CSR_IDLE;
                        inst_addr   <= inst_addr;
                        cause       <= cause;
                    end
                endcase
            end
            CSR_MEPC: begin
                csr_state       <= CSR_MSTATUS;
                inst_addr       <= inst_addr;
                cause           <= cause;
                clint_wen_o     <= 1'b1;
                clint_waddr_o   <= {20'h0, `CSR_MEPC};
                clint_wdata_o   <= inst_addr;
            end
            CSR_MSTATUS: begin
                csr_state       <= CSR_MCAUSE;
                inst_addr       <= inst_addr;
                cause           <= cause;
                clint_wen_o     <= 1'b1;
                clint_waddr_o   <= {20'h0, `CSR_MSTATUS};
                clint_wdata_o   <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
            end
            CSR_MCAUSE: begin
                csr_state       <= CSR_IDLE;
                inst_addr       <= inst_addr;
                cause           <= cause;
                clint_wen_o     <= 1'b1;
                clint_waddr_o   <= {20'h0, `CSR_MCAUSE};
                clint_wdata_o   <= cause;
            end
            CSR_MSTATUS_MRET: begin
                csr_state       <= CSR_IDLE;
                inst_addr       <= inst_addr;
                cause           <= cause;
                clint_wen_o     <= 1'b1;
                clint_waddr_o   <= {20'h0, `CSR_MSTATUS_MRET};
                clint_wdata_o   <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
            end
            default: begin
                csr_state       <= CSR_IDLE;
                inst_addr       <= inst_addr;
                cause           <= cause;
                clint_wen_o     <= 1'b0;
                clint_waddr_o   <= 32'b0;
                clint_wdata_o   <= 32'b0;
            end
        endcase
    end
end

always_ff @( posedge clk_i ) begin
     if (!rst_n_i) begin
        int_assert_o    <= 1'b0;
        int_addr_o      <= 32'b0;
    end 
    else begin
        case (csr_state)
            CSR_MCAUSE: begin
                int_assert_o    <= 1'b1;
                int_addr_o      <= csr_mtvec;
            end
            CSR_MSTATUS_MRET: begin
                int_assert_o    <= 1'b1;
                int_addr_o      <= csr_mepc;
            end
            default: begin
                int_assert_o    <= 1'b0;
                int_addr_o      <= 32'b0;
            end
        endcase
    end
end

endmodule