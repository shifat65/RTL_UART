`timescale 1ns/1ps
module tb_rx;
//clock and reset signals
reg clk=0;
reg rst_n;

//baudrate generation signals
wire [15:0] count;
reg [15:0] baud_div;
wire baud_tick_16x;
wire baud_tick_1x; // Baud tick for 1x clock
wire rst_c; // Reset signal for baud tick

//uart tx signals
reg rx;
wire [7:0] rx_data;
wire rx_done;

// Instantiate the counter module
counter uut_counter (
    .clk(clk),
    .rst_n(rst_n),
    .rst_c(rst_c),
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
// Instantiate the UART receiver module
uart_rx uut_uart_rx (
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick_16x(baud_tick_16x),
    .rx(rx),
    
    .rx_data(rx_data),
    .rx_done(rx_done)
);

always begin
    #5 clk = ~clk; // Generate clock with a period of 10 time units
end

// task to send one UART frame
task send_uart_byte;
    input [7:0] data;
    integer i;
    begin 
        //start bit (0)
        rx = 1'b0; // Set RX line low for start bit
        repeat(16)@(posedge baud_tick_16x); // Wait for 16 baud ticks

        //data bits(lsb first)
        for (i=0; i<8; i=i+1) begin 
            rx = data[i];
            repeat(16) @(posedge baud_tick_16x); // Wait for 16 baud ticks for each data bit    
        end

        //stop bit (1)
        rx = 1'b1;
        repeat(16) @(posedge baud_tick_16x); // Wait for 16 baud ticks for stop bit
    end
endtask

initial begin 
    $dumpfile("tb_rx.vcd");
    $dumpvars(0, tb_rx);

    //initialize signals
    rst_n <=0;
    baud_div <= 16'h05; // Set baud divisor to 10
    rx<= 1'b1; // Idle state for RX line (high)
    @(negedge clk);

    //reset pulse
    rst_n <=1;
    repeat(5)@(negedge clk);

    //send a byte : 10101011
    send_uart_byte(8'b10101011);

    repeat(500)@(negedge clk); // Wait for a few clock cycles

    $finish;
end

endmodule
// End of tb_rx module
