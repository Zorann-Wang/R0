`include "../riscv_core/define.sv"

module soc_top (
    input   wire                        clk_i,
    input   wire                        rst_n_i,

    input   wire                        uart_debug,
    input   wire                        uart_rx,
    output  wire                        uart_tx,

    output  wire [3:0]                  gpio_pins
);

wire [`INST_ADDR_BUS]       core_pc;
wire                        core_mem_wreq;
wire                        core_mem_wen;
wire [`INST_ADDR_BUS]       core_mem_waddr;
wire [`INST_DATA_BUS]       core_mem_wdata;
wire                        core_mem_rreq;
wire [`INST_ADDR_BUS]       core_mem_raddr;
wire [`INST_DATA_BUS]       core_mem_rdata;

wire                        uart_mem_wreq;
wire                        uart_mem_wen;  
wire [`INST_ADDR_BUS]       uart_mem_waddr; 
wire [`INST_DATA_BUS]       uart_mem_wdata; 

wire                        rom_wen;  
wire [`INST_ADDR_BUS]       rom_waddr;  
wire [`INST_DATA_BUS]       rom_wdata; 
wire [`INST_ADDR_BUS]       rom_raddr;  
wire [`INST_DATA_BUS]       rom_rdata; 
wire [`INST_ADDR_BUS]       rom_pc; 
wire [`INST_DATA_BUS]       rom_inst;
wire [`INST_ADDR_BUS]       rom_inst_addr; 

wire                        ram_wen;  
wire [`INST_ADDR_BUS]       ram_waddr;  
wire [`INST_DATA_BUS]       ram_wdata; 
wire [`INST_ADDR_BUS]       ram_raddr;  
wire [`INST_DATA_BUS]       ram_rdata; 
 
wire                        uart_wen; 
wire [`INST_ADDR_BUS]       uart_waddr;  
wire [`INST_DATA_BUS]       uart_wdata; 
wire [`INST_ADDR_BUS]       uart_raddr;  
wire [`INST_DATA_BUS]       uart_rdata; 

wire                        gpio_wen; 
wire [`INST_ADDR_BUS]       gpio_waddr;  
wire [`INST_DATA_BUS]       gpio_wdata; 
wire [`INST_ADDR_BUS]       gpio_raddr;  
wire [`INST_DATA_BUS]       gpio_rdata; 

wire                        timer_wen; 
wire [`INST_ADDR_BUS]       timer_waddr;  
wire [`INST_DATA_BUS]       timer_wdata; 
wire [`INST_ADDR_BUS]       timer_raddr;  
wire [`INST_DATA_BUS]       timer_rdata; 
wire                        timer_int_flag;

logic[`INT_BUS]             int_flag;

always_comb begin
    int_flag = {7'h0,  timer_int_flag};
end

rib         u_rib(
    .clk_i              (clk_i),
    .rst_n_i            (rst_n_i),

    .m0_wreq_i          (core_mem_wreq), 
    .m0_wen_i           (core_mem_wen), 
    .m0_waddr_i         (core_mem_waddr),
    .m0_wdata_i         (core_mem_wdata), 
    .m0_rreq_i          (core_mem_rreq), 
    .m0_raddr_i         (core_mem_raddr), 
    .m0_rdata_o         (core_mem_rdata), 
    
    .m1_wreq_i          (uart_mem_wreq), 
    .m1_wen_i           (uart_mem_wen), 
    .m1_waddr_i         (uart_mem_waddr),
    .m1_wdata_i         (uart_mem_wdata), 
    .m1_rreq_i          (), 
    .m1_raddr_i         (), 
    .m1_rdata_o         (), 

    .s0_rdata_i         (rom_rdata), 
    .s0_raddr_o         (rom_raddr),
    .s0_wen_o           (rom_wen), 
    .s0_waddr_o         (rom_waddr), 
    .s0_wdata_o         (rom_wdata), 
     
    .s1_rdata_i         (ram_rdata), 
    .s1_raddr_o         (ram_raddr),
    .s1_wen_o           (ram_wen), 
    .s1_waddr_o         (ram_waddr), 
    .s1_wdata_o         (ram_wdata),  
    
    .s2_rdata_i         (uart_rdata), 
    .s2_raddr_o         (uart_raddr),
    .s2_wen_o           (uart_wen), 
    .s2_waddr_o         (uart_waddr), 
    .s2_wdata_o         (uart_wdata), 

    .s3_rdata_i         (gpio_rdata), 
    .s3_raddr_o         (gpio_raddr),
    .s3_wen_o           (gpio_wen), 
    .s3_waddr_o         (gpio_waddr), 
    .s3_wdata_o         (gpio_wdata),  

    .s4_rdata_i         (timer_rdata), 
    .s4_raddr_o         (timer_raddr),
    .s4_wen_o           (timer_wen), 
    .s4_waddr_o         (timer_waddr), 
    .s4_wdata_o         (timer_wdata),  
    
    .hold_flag_rib_o    (hold_flag_rib)
);

core_top    u_core(
    .clk_i              (clk_i),
    .rst_n_i            (rst_n_i),

    .pc_addr_o          (rom_pc),
    .rib_inst_i         (rom_inst),           
    .rib_inst_addr_i    (rom_inst_addr), 

    .jtag_en_i          (),
    .jtag_addr_i        (),
    .jtag_data_i        (),
    .jtag_data_o        (),
    .int_flag_i         (),
    .mem_rdata_i        (core_mem_rdata),
    .mem_rib_rreq_o     (core_mem_rreq),
    .mem_raddr_o        (core_mem_raddr),
    .mem_rib_wreq_o     (core_mem_wreq),
    .mem_wen_o          (core_mem_wen), 
    .mem_waddr_o        (core_mem_waddr),
    .mem_wdata_o        (core_mem_wdata),
    .rib_hold_flag_i    (hold_flag_rib),                
    .jtag_halt_flag_i   (),             
    .jtag_reset_flag_i  ()
);

uart_debug  u_debug(
    .clk_i              (clk_i),
    .rst_n_i            (rst_n_i),

    .debug_en_i         (~uart_debug), 
    .uart_rx            (uart_rx),

    .rib_wreq_o       	(uart_mem_wreq), 
    .mem_wen_o        	(uart_mem_wen), 
    .mem_waddr_o      	(uart_mem_waddr), 
    .mem_wdata_o      	(uart_mem_wdata)        
);

rom         u_rom(
    .clk_i              (clk_i),
    .rst_n_i            (rst_n_i),
    
    .wen_i              (rom_wen),    
    .waddr_i            (rom_waddr),  
    .wdata_i            (rom_wdata),  
    
    .raddr_i            (rom_raddr),  
    .rdata_o            (rom_rdata),  
    
    .pc_addr_i          (rom_pc),  
    .inst_o             (rom_inst),
    .inst_addr_o        (rom_inst_addr)     
);

ram         u_ram(
    .clk_i              (clk_i),
    .rst_n_i            (rst_n_i),
    
    .wen_i              (ram_wen),    
    .waddr_i            (ram_waddr),  
    .wdata_i            (ram_wdata),  
    
    .raddr_i            (ram_raddr),  
    .rdata_o            (ram_rdata)  
);

 uart       u_uart(
    .clk_i              (clk_i),
    .rst_n_i            (rst_n_i),

    .uart_rx            (uart_rx),
    .uart_tx            (uart_tx),

    .wen_i              (uart_wen),
    .waddr_i            (uart_waddr), 
    .wdata_i            (uart_wdata), 
    .raddr_i            (uart_raddr), 
    .rdata_o            (uart_rdata)
);

gpio        u_gpio(
    .clk_i              (clk_i),
    .rst_n_i            (rst_n_i),

    .wen_i              (gpio_wen),
    .waddr_i            (gpio_waddr),
    .wdata_i            (gpio_wdata), 
    .raddr_i            (gpio_raddr), 
    .rdata_o            (gpio_rdata), 
    .gpio_pins          (gpio_pins)
);

timer       u_timer(
    .clk_i              (clk_i),
    .rst_n_i            (rst_n_i),
    
    .wen_i              (timer_wen),
    .waddr_i            (timer_waddr),
    .wdata_i            (timer_wdata), 
    .raddr_i            (timer_raddr), 
    .rdata_o            (timer_rdata), 
    .timer_int_flag_o   (timer_int_flag)
);

endmodule