`timescale 1ns/1ps
module tb_tx;
//clock and reset signals
reg clk=0;
reg rst_n;

//baudrate generation signals
wire [15:0] count;
reg [15:0] baud_div;
wire baud_tick_1x;
wire rst_c; // Reset signal for baud tick

//uart tx signals
reg tx_start;
reg [7:0] tx_data;
wire tx_line;
wire tx_busy;

// Instantiate the counter module
counter uut_counter (
    .clk(clk),
    .rst_n(rst_c),
    .count(count)
);

// Instantiate the baud rate generator module
baud_gen_16x uut (
    .clk(clk),
    .rst_n(rst_n),
    .count(count),
    .baud_div(baud_div),

    .baud_tick_16x(baud_tick_16x),
    .baud_tick_1x(baud_tick_1x), // Baud tick for 1x clock
    .rst_c(rst_c)
);

// Instantiate the UART transmitter module
uart_tx uut_uart_tx (
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick_1x(baud_tick_1x),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_line(tx_line),
    .tx_busy(tx_busy)
);

always begin
    #5 clk = ~clk;
end

// Testbench initial block
initial begin 

    $dumpfile("tb_tx.vcd");
    $dumpvars(0, tb_tx);

    //initialize signals
    rst_n <=0;
    baud_div <= 16'h05; // Set baud divisor to 10
    tx_data <= 8'hA5; // Example data to transmit
    tx_start <= 0;

    //wait for clock to stabilize
    @(negedge clk);
    //reset pulse
    rst_n <=1;  
  
    //
    repeat(5)@(negedge clk);
    //start transmission
    tx_start <=1 ; // Start transmission
    
    repeat(2)@(negedge clk);
    tx_start <=0; // Stop transmission
    @(negedge clk);

    repeat(2000)@(negedge clk);

    $finish; // End simulation
end

endmodule
// End of tb_tx module
