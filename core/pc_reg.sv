module pc_reg #(
    parameter ADDR_WIDTH = 32;
)
(
    input   wire                     clk_i,
    input   wire                     rst_n_i,
    input   wire [2:0]               hold_flag_i,
    input   wire                     jump_flag_i,
    input   wire [ADDR_WIDTH-1:0]    jump_addr_i,
    output  reg  [ADDR_WIDTH-1:0]    pc_addr_o
);

always_ff @( posedge clk_i ) begin : pc_control
    if (!rst_n_i) begin
        pc_addr_o <= 32'b0;
    end
    else if (hold_flag_i != 1'b0) begin
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