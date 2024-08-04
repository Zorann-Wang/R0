`include "defines.v"

module ctrl(
    input   wire                        clk_i,
    input   wire                        rst_n_i,

    // from ex
    input   wire                        jump_flag_i,
    input   wire [`INST_ADDR_BUS]       jump_addr_i,

    // from rib
    input   wire                        hold_flag_rib_i,

    // from jtag
    input   wire                        jtag_flag_i,

    // from clint
    input   wire                        hold_flag_clint_i,

    // to pc_reg
    output  reg                         jump_flag_o,
    output  reg [`INST_ADDR_BUS]        jump_addr_o,

    output  reg [`HOLD_BUS]             hold_flag_o
);

always_comb begin
    jump_addr_o = jump_addr_i;
    jump_flag_o = jump_flag_i;

    if (jump_flag_i | hold_flag_clint_i) begin
        hold_flag_o = `HOLD_ID_EX;
    end
    else if (hold_flag_rib_i) begin
        hold_flag_o = `HOLD_PC;
    end
    else if (jtag_flag_i) begin
        hold_flag_o = `HOLD_ID_EX;
    end
    else begin
        hold_flag_o = `HOLD_NONE;
    end
end

endmodule