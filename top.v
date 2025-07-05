module top(
    input wire clk,
    input wire rst_n,
    input wire [7:0] send_data,
    input wire tx_start,
    input wire rx,

    output reg tx,
    output reg rec_data,
    output reg tx_done,
    output reg rx_done
);

counter uut_counter (
    .clk(clk),
    .rst_n(rst_n),

);

endmodule