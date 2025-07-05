module top(
    input wire clk,
    input wire rst_n,
    input wire [7:0] send_data,
    input wire tx_start,
    input wire rx,
    input wire [15:0] baud_div,

    output wire tx,
    output wire [7:0] rec_data,
    output wire tx_busy,
    output wire rx_done,
    output wire tx_done
);

wire rst_c;
wire [15:0] count;
wire baud_tick_16x, baud_tick_1x;

counter uut_counter (
    .clk(clk),
    .rst_n(rst_n),
    .rst_c(rst_c),
    .count(count)
);

baud_gen_16x uut_baud_gen(
    .clk(clk),
    .rst_n(rst_n),
    .count(count),
    .baud_div(baud_div), // Example baud divisor for 9600 baud at 16x clock

    .baud_tick_16x(baud_tick_16x), 
    .baud_tick_1x(baud_tick_1x), 
    .rst_c(rst_c)
);

uart_tx uut_uart_tx(
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick_1x(baud_tick_1x),
    .tx_start(tx_start),
    .tx_data(send_data),
    .tx_line(tx),
    .tx_busy(tx_busy),
    .tx_done(tx_done)

);

uart_rx uut_uart_rx(
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick_16x(baud_tick_16x),
    .rx(rx),

    .rx_data(rec_data),
    .rx_done(rx_done)
);

endmodule