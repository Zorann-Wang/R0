`include "../riscv_core/define.sv"

module uart (
    input   wire                        clk_i,
    input   wire                        rst_n_i,

    input   wire                        uart_rx,
    output  reg                         uart_tx,

    input   wire                        wen_i,
    input   wire [`INST_ADDR_BUS]       waddr_i, 
    input   wire [`INST_DATA_BUS]       wdata_i, 
    input   wire [`INST_ADDR_BUS]       raddr_i, 
    output  reg  [`INST_DATA_BUS]       rdata_o
);

localparam  BAUD_CNT        = `CLK_FREQ / `UART_BPS;
localparam  UART_CTRL       = 4'h0x00;
localparam  UART_STATUS     = 4'h0x04;
localparam  UART_BAUD       = 4'h0x08;
localparam  UART_TX         = 4'h0x0C;
localparam  UART_RX         = 4'h0x10;
localparam  IDLE            = 4'h0x00;
localparam  START           = 4'h0x01;
localparam  RX_BYTE         = 4'h0x02;
localparam  TX_BYTE         = 4'h0x03;
localparam  STOP            = 4'h0x04;

reg [31:0]  uart_ctrl;
reg [31:0]  uart_status;
reg [31:0]  uart_baud;
reg [31:0]  uart_tx_reg;
reg [31:0]  uart_rx_reg;

reg         tx_data_valid;
reg         tx_data_end;
reg [3:0]   tx_state;
reg [3:0]   tx_next_state;
reg [15:0]  tx_baud_cnt;
reg [3:0]   tx_bit_cnt;
wire        tx_baud_cnt_flag;
wire        tx_bit_cnt_flag;
wire        tx_next_start;
wire        tx_next_stop;
//reg [7:0]   tx_byte_data;

reg [7:0]   rx_byte_data;
reg [3:0]   rx_state;
reg [3:0]   rx_next_state;
reg         rx_reg0;
reg         rx_reg1;
wire        rx_negedge;
reg [3:0]   rx_clk_edge_cnt;         
reg         rx_clk_edge_flag;
reg			rx_start;           
reg         rx_done;
reg [15:0]  rx_clk_cnt;
reg [15:0]  rx_div_cnt;

always_comb begin
    tx_baud_cnt_flag    = (tx_baud_cnt == (uart_baud[15:0]-1)) ? 1'b1 : 1'b0;
    tx_bit_cnt_flag     = (tx_bit_cnt == 4'd8) ? 1'b1 : 1'b0;
    tx_next_start       = (tx_next_state == START) ? 1'b1 : 1'b0;  
    tx_next_stop        = (tx_next_state == STOP) ? 1'b1 : 1'b0;    
    rx_negedge          = rx_reg0 && rx_reg1;
end
// write regs
always_ff @( posedge clk_i ) begin
    if (!rst_n_i) begin
        uart_ctrl       <= 32'h0;
        uart_status     <= 32'h0;
        uart_baud       <= BAUD_CNT;
        uart_tx_reg     <= 32'h0;
        tx_data_valid   <= 1'b0;
    end
    else begin
        if (wen_i) begin
            priority case (waddr_i[7:0])
                UART_CTRL: begin
                    uart_ctrl       <= wdata_i;
                end
                
                UART_STATUS: begin
                    uart_status[1]  <= wdata_i[1];
                end

                UART_BAUD: begin
                    uart_baud       <= wdata_i;
                end

                UART_TX: begin
                    if (uart_ctrl[0] && uart_status[0]) begin
                        uart_tx_reg     <= wdata_i;
                        uart_status[0]  <= 1'b1;
                        tx_data_valid   <= 1'b1;
                    end
                end

                default: begin
                    uart_ctrl       <= uart_ctrl;
                    uart_status     <= uart_status;
                    uart_baud       <= uart_baud;
                    uart_tx_reg     <= uart_tx_reg;
                    tx_data_valid   <= 1'b0;
                end
            endcase
        end 
        else begin
            tx_data_valid   <= 1'b0;
            uart_status[0]  <= (tx_data_end) ? 1'b0 : uart_status[0];
            uart_status[1]  <= (uart_ctrl[1] & rx_done) ? 1'b1 : uart_status[1];
            uart_rx_reg     <= (uart_ctrl[1] & rx_done) ? {24'h0, rx_byte_data} : uart_rx_reg;
        end
    end
end

// read regs
always_comb begin 
    if (!rst_n_i) begin
        rdata_o = 32'b0;
    end
    else begin
        priority case (raddr_i[7:0])
            UART_CTRL: begin
                rdata_o       <= uart_ctrl;
            end
            
            UART_STATUS: begin
                rdata_o       <= uart_status;
            end

            UART_BAUD: begin
                rdata_o       <= uart_baud;
            end

            UART_RX: begin
                rdata_o       <= uart_rx_reg;
            end

            default: begin
                rdata_o       <= 32'b0;
            end
        endcase
    end
end

// tx send
always_ff @( posedge clk_i ) begin 
     if (!rst_n_i)
        tx_state <= IDLE;
    else
        tx_state <= tx_next_state;
end

always_comb begin 
    priority case (tx_state)
        IDLE: begin
            tx_next_state = (tx_data_valid) ? START : IDLE;
        end

        START: begin
            tx_next_state = (tx_baud_cnt_flag) ? TX_BYTE : START;
        end

        TX_BYTE: begin
            tx_next_state = (tx_baud_cnt_flag && tx_bit_cnt_flag) ? STOP : TX_BYTE;
        end

        STOP: begin
            tx_next_state = (tx_baud_cnt_flag) ? IDLE : STOP;
        end

        default: begin
            tx_next_state = IDLE;
        end
    endcase
end

always @ ( posedge clk_i ) begin
    if(!rst_n_i) begin 
        tx_baud_cnt <= 16'd0;
    end
    else if(tx_next_start || tx_baud_cnt_flag) begin
        tx_baud_cnt <= 16'd0;
    end
    else begin
        tx_baud_cnt <= tx_baud_cnt + 1'b1;
    end
end

always_ff @( posedge clk_i ) begin 
    if (!rst_n_i) begin
        uart_tx     <= 1'b1;
        tx_bit_cnt  <= 4'b0;
        tx_data_end <= 1'b0;
    end
    else begin
        priority case (tx_state)
            IDLE: begin
                uart_tx     <= (tx_next_start) ? 1'b0 : 1'b1;
                tx_bit_cnt  <= (tx_next_start) ? 1'b0 : tx_bit_cnt;
                tx_data_end <= 1'b0;
            end

            START: begin
                uart_tx     <= uart_tx_reg[tx_bit_cnt];
                tx_bit_cnt  <= tx_bit_cnt + 1'b1;
                tx_data_end <= 1'b0;
            end

            TX_BYTE: begin
                uart_tx     <= uart_tx_reg[tx_bit_cnt];
                tx_bit_cnt  <= (tx_next_stop) ? tx_bit_cnt + 1'b1 : 4'd0;
                tx_data_end <= 1'b0;
            end

            STOP: begin
                uart_tx     <= 1'b1;
                tx_bit_cnt  <= 4'd0;
                tx_data_end <= 1'b1;
            end

            default: begin
                uart_tx     <= 1'b1;
                tx_bit_cnt  <= 4'd0;
                tx_data_end <= 1'b0;
            end
        endcase
    end
end

// rx receive
always_ff @( posedge clk_i ) begin
    if (!rst_n_i) begin
        rx_reg0 <= 1'b0;
        rx_reg1 <= 1'b0;	
    end 
    else begin
        rx_reg0 <= uart_rx;
        rx_reg1 <= rx_reg0;
    end
end

always_ff @( posedge clk_i ) begin
    if (!rst_n_i) begin
        rx_start <= 1'b0;	
    end 
    else if (uart_ctrl[1]) begin
        if (rx_negedge) begin
            rx_start <= 1'b1;
        end
        else if (rx_clk_edge_cnt == 4'd9) begin
            rx_start <= 1'b0;
        end
        else begin
            rx_start <= rx_start;
        end
    end
    else begin
        rx_start <= 1'b0;
    end
end

always_ff @( posedge clk_i ) begin
    if (!rst_n_i) begin
        rx_div_cnt <= 16'h0;
    end 
    else begin
        if (rx_start && rx_clk_edge_cnt == 4'h0) begin
            rx_div_cnt <= {1'b0, uart_baud[15:1]};
        end 
        else begin
            rx_div_cnt <= uart_baud[15:0];
        end
    end
end

always_ff @( posedge clk_i ) begin
    if (!rst_n_i) begin
        rx_clk_cnt <= 16'h0;
    end 
    else if (rx_start) begin
        rx_clk_cnt <= (rx_clk_cnt == rx_div_cnt) ? 16'h0 : rx_clk_cnt + 1'b1;
    end 
    else begin
        rx_clk_cnt <= 16'h0;
    end
end

always_ff @( posedge clk_i ) begin
    if (!rst_n_i) begin
        rx_clk_edge_cnt     <= 4'h0;
        rx_clk_edge_flag   <= 1'b0;
    end 
    else if (rx_start) begin
        if (rx_clk_cnt == rx_div_cnt) begin
            if (rx_clk_edge_cnt == 4'd9) begin
                rx_clk_edge_cnt     <= 4'h0;
                rx_clk_edge_flag   <= 1'b0;
            end 
            else begin
                rx_clk_edge_cnt     <= rx_clk_edge_cnt + 1'b1;
                rx_clk_edge_flag   <= 1'b1;
            end
        end 
        else begin
            rx_clk_edge_cnt     <= rx_clk_edge_cnt;
            rx_clk_edge_flag   <= 1'b0;
        end
    end 
    else begin
        rx_clk_edge_cnt     <= 4'h0;
        rx_clk_edge_flag   <= 1'b0;
    end
end

always_ff @( posedge clk_i ) begin
    if (!rst_n_i) begin
        rx_byte_data    <= 8'h0;
        rx_done         <= 1'b0;
    end 
    else begin
        if (rx_start & rx_clk_edge_flag) begin
            priority case (rx_clk_edge_cnt)
                2, 3, 4, 5, 6, 7, 8, 9: begin
                    rx_byte_data    <= rx_byte_data | (uart_rx << (rx_clk_edge_cnt - 2));
                    rx_done         <= (rx_clk_edge_cnt == 4'h9) ? 1'b1 : 1'b0;
                end
            default: begin
                rx_byte_data        <= 8'h0;
                rx_done             <= 1'b0;
            end
            endcase
        end 
        else begin
            rx_byte_data    <= 8'h0;
            rx_done         <= 1'b0;
        end
    end
end

endmodule