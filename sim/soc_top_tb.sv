`timescale 1ns / 1ps

module soc_top_tb; 

reg     clk;
reg     rst_n;

always #10      clk <= ~clk; // 50MHz

wire [31:0]     ex_end_flag = u_soc.u_ram._ram[4];
wire [31:0]     start = u_soc.u_ram._ram[2];
wire [31:0]     stop = u_soc.u_ram._ram[3];

integer r;
integer fd;

// read mem data
initial begin
    $readmemh("C:/intelFPGA/RiscV/v3/tests/test_case/rv32i/I-ADDI-01.elf.data", u_soc.u_rom._rom);
end

initial begin
    clk = 1'b1;
    rst_n <= 1'b0;
    #17
    rst_n <= 1'b1;
    
    wait(ex_end_flag == 32'h1); //wait sim end
        $display("End flag detected!");

    fd = $fopen("C:/intelFPGA/RiscV/v3/tests/output/rv32i/I-ADDI-01.elf.out");
    for (r = start; r < stop; r = r + 4) begin
        $fdisplay(fd, "%x", u_soc.u_rom._rom[r[31:2]]);
    end
    $fclose(fd);
end

// sim timeout
initial begin
    #500000
    $display("Time out...");
    $finish;
end



soc_top u_soc(
    .clk_i              (clk),
    .rst_n_i            (rst_n),

    .uart_debug         (1'b1),
    .uart_rx            (),
    .uart_tx            (),

    .gpio_pins          ()
);

endmodule