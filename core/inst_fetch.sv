`include "defines.v"

module inst_fetch(
    input   wire                        clk_i,
    input   wire                        rst_n_i,
    input   wire [`HOLD_BUS]            hold_flag_i,       // pipeline pasue
    input   wire [`INT_BUS]             interrupt_flag_i,  // peripherals interrupt input
    output  reg  [`INT_BUS]             interrupt_flag_o,  // peripherals interrupt output
    input   wire [`INST_DATA_BUS]       inst_i,            // instruction input
    input   wire [`INST_ADDR_BUS]       inst_addr_i,       // instruction address input
    output  reg  [`INST_DATA_BUS]       inst_o,            // instruction output
    output  reg  [`INST_ADDR_BUS]       inst_addr_o        // instruction address input
);

wire hold_id_en = (hold_flag_reg > HOLD_PC); // enable hold flag when hold flag is for IF or ID

always_ff @(posedge clk_i) begin 
    if (!rst_n_i) begin
        interrupt_flag_o    <= `INT_NONE;
        inst_o              <= `INST_NOP;
        inst_addr_o         <= `RESET_ADDR;
    end
    else if (hold_id_en) begin
        interrupt_flag_o    <= `INT_NONE;
        inst_o              <= `INST_NOP;
        inst_addr_o         <= `RESET_ADDR;
    end
    else begin
        interrupt_flag_o    <= interrupt_flag_i;
        inst_o              <= inst_i;
        ins_addr_o          <= {ins_addr_i[31:2], {2'b0}};
    end
end

endmodule
