`include "../riscv_core/define.sv"

module gpio(
    input   wire                        clk_i,
    input   wire                        rst_n_i,
    
    input   wire                        wen_i,
    input   wire [`INST_ADDR_BUS]       waddr_i,
    input   wire [`INST_DATA_BUS]       wdata_i, 
    input   wire [`INST_ADDR_BUS]       raddr_i, 
    output  reg  [`INST_DATA_BUS]       rdata_o, 
    
    output  logic[3:0]                  gpio_pins          
);

localparam GPIO_CTRL = 4'h0;
localparam GPIO_DATA = 4'h4;

reg [31:0]                  gpio_ctrl;
reg [31:0]                  gpio_data;
reg [`INST_ADDR_BUS]        raddr_reg;

always_comb begin
    gpio_pins = ~ gpio_data[3:0];
end

always_ff @( posedge clk_i ) begin 
    if(!rst_n_i) begin
        gpio_ctrl   <= 32'b0;
        gpio_data   <= 32'b0;
        raddr_reg   <= 32'b0;
    end
    else if(wen_i) begin
        raddr_reg <= raddr_i;
        case(waddr_i[3:0])
            GPIO_CTRL: begin
                gpio_ctrl   <= wdata_i;
                gpio_data   <= 32'b0;
            end
            GPIO_DATA: begin
                gpio_ctrl   <= 32'b0;
                gpio_data   <= wdata_i;
            end
            default: begin
                gpio_ctrl   <= 32'b0;
                gpio_data   <= 32'b0;
            end
        endcase
    end
    else begin
        gpio_ctrl   <= gpio_ctrl;
        gpio_data   <= gpio_data;
        raddr_reg   <= raddr_reg;
    end 
end

always_comb begin
    case(raddr_reg[3:0])
        GPIO_CTRL: begin
            rdata_o = gpio_ctrl;
        end
        GPIO_DATA: begin
            rdata_o = gpio_data;
        end
        default: begin
            rdata_o = 32'b0;
        end
    endcase
end

endmodule