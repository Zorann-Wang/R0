`include "../riscv_core/define.sv"

module timer(
    input   wire                        clk_i,
    input   wire                        rst_n_i,
    
    input   wire                        wen_i,    // write enable
    input   wire [`INST_ADDR_BUS]       waddr_i,  // write address
    input   wire [`INST_DATA_BUS]       wdata_i,  // write data
    
    input   wire [`INST_ADDR_BUS]       raddr_i,  // read address
    output  reg  [`INST_DATA_BUS]       rdata_o,  // read data

    output  wire                        timer_int_flag_o
);

localparam TIMER_CTRL = 4'h0;
localparam TIMER_COUNT = 4'h4;
localparam TIMER_EVALUE = 4'h8;

// addr offset: 0x00
reg [31:0] timer_ctrl;

// addr offset: 0x04
reg [31:0] timer_count;

// addr offset: 0x08
reg [31:0] timer_evalue;

reg [`INST_ADDR_BUS]        raddr_reg;

always_comb begin
    timer_int_flag_o = (timer_ctrl[2] && timer_ctrl[1])? 1'b1 : 1'b0;
end

always_ff @ (posedge clk_i ) begin
    if (!rst_n_i) begin
        timer_ctrl      <= 32'b0;
        timer_evalue    <= 32'b0;
    end
    else begin
        if (wen_i) begin
            priority case (waddr_i[3:0])
                TIMER_CTRL: begin
                    timer_ctrl      <= {wdata_i[31:3], (timer_ctrl[2] & wdata_i[2]), wdata_i[1:0]};
                    timer_evalue    <= timer_evalue;
                end

                TIMER_EVALUE: begin
                    timer_ctrl      <= timer_ctrl;
                    timer_evalue    <= wdata_i;
                end

                default: begin
                    timer_ctrl      <= 32'b0;
                    timer_evalue    <= 32'b0;
                end
            endcase
        end
        
        if(timer_ctrl[0] && timer_count >= timer_evalue) begin
            timer_ctrl[0] <= 1'b0;
            timer_ctrl[2] <= 1'b1;
        end

        raddr_reg <= raddr_i;
    end
end

always_comb begin
    priority case (raddr_reg[3:0])
        TIMER_CTRL: begin
            rdata_o = timer_ctrl;
        end
        TIMER_COUNT: begin
            rdata_o = timer_count;
        end
        TIMER_EVALUE: begin
            rdata_o = timer_evalue;
        end
        default: begin
            rdata_o = 32'b0;
        end
    endcase
end

always_ff @ (posedge clk_i) begin
    if (!rst_n_i) begin
        timer_count <= 32'b0;
    end
    else if (~timer_ctrl[0] || timer_count >= timer_evalue) begin
            timer_count <= 32'b0;
    end
    else begin
            timer_count <= timer_count + 1'b1;
    end
end

endmodule