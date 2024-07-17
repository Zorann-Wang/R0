module inst_decode(
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
    

always_ff @(posedge clk_i) begin
    
end
endmodule