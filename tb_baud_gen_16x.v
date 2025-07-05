`timescale 1ns/1ps

module tb_baud_gen_16x;
reg clk=0;
reg rst_n;
wire [15:0] count;
reg [15:0] baud_div;
wire rst_c; // Reset signal for baud tick
wire baud_tick_16x;
wire baud_tick_1x; // Baud tick for 1x clock

counter uut_counter (
    .clk(clk),
    //.rst_n(rst_n),
    .rst_n(rst_c),
    .count(count)
);

baud_gen_16x uut (
    .clk(clk),
    .rst_n(rst_n),
    .count(count),
    .baud_div(baud_div),

    .baud_tick_16x(baud_tick_16x),
    .baud_tick_1x(baud_tick_1x), // Baud tick for 1x clock
    .rst_c(rst_c)
);

always begin
    #5 clk = ~clk; // Generate clock with a period of 10 time units
end
// for gtkwave
initial begin
    $dumpfile("tb_baud_gen_16x.vcd");
    $dumpvars(0, tb_baud_gen_16x);

    rst_n <= 0; // Assert reset
    baud_div <= 16'h05;
    @(negedge clk);

    rst_n <= 1; // Deassert reset
    // Set baud divisor to 10
    //count <= 16'h0000; // Initialize count to 
    @(negedge clk);

    repeat (500) @(negedge clk); // Wait for 20 clock cycles
    $finish; // End simulation
end

endmodule