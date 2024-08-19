`include "../riscv_core/define.sv"

module ram (
    input   wire                        clk_i,
    input   wire                        rst_n_i,
    
    input   wire                        wen_i,    // write enable
    input   wire [`INST_ADDR_BUS]       waddr_i,  // write address
    input   wire [`INST_DATA_BUS]       wdata_i,  // write data
    
    input   wire [`INST_ADDR_BUS]       raddr_i,  // read address
    output  reg  [`INST_DATA_BUS]       rdata_o   // read data
);

reg [`INST_ADDR_BUS]    raddr_reg;
reg [`INST_DATA_BUS]    _ram [0:`RAM_DEPTH - 1];

always_ff @( posedge clk_i ) begin
    if (wen_i) begin
        _ram[waddr_i[31:2]]   <= wdata_i;
        raddr_reg             <= raddr_reg;
    end
    else begin
        _ram                  <= _ram;
        raddr_reg             <= raddr_i;
    end
end

always_comb begin 
    if (!rst_n_i) begin
        rdata_o   = 32'b0;
    end
    else begin
        rdata_o   = _ram[raddr_reg[31:2]];
    end
end

endmodule