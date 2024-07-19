`include "defines.v"

module pc_reg (
    input   wire                        clk_i,
    input   wire                        rst_n_i,
    input   wire [`HOLD_BUS]            hold_flag_i,
    input   wire                        jump_flag_i,
    input   wire [`INST_ADDR_BUS]       jump_addr_i,
    output  reg  [`INST_ADDR_BUS]       pc_addr_o
);

wire hold_pc_en = (hold_flag_i != HOLD_NONE) ; //enable hold flag when hold flag is for PC, IF or ID

always_ff @(posedge clk_i) begin 
    if (!rst_n_i) begin
        pc_addr_o <= `RESET_ADDR;
    end
    else if (hold_pc_en) begin
        pc_addr_o <= pc_addr_o;
    end
    else if (jump_flag_i) begin
        pc_addr_o <= jump_addr_i;
    end
    else begin
        pc_addr_o <= pc_addr_o + 4'd4;
    end
end

endmodule