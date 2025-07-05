`timescale 1ns/1ps
module tb_top;
reg clk=0;
reg rst_n;
reg [7:0] send_data;
reg tx_start;
reg rx = 1'b1;
reg [15:0] baud_div; 

wire  tx;
wire  [7:0] rec_data;
wire  tx_busy;
wire  rx_done;
wire  tx_done;

top uut_top (
    .clk(clk),
    .rst_n(rst_n),
    .send_data(send_data),
    .tx_start(tx_start),
    .rx(rx),
    .baud_div(baud_div), 

    .tx(tx),
    .rec_data(rec_data),
    .tx_busy(tx_busy),
    .rx_done(rx_done),
    .tx_done(tx_done)
);

always begin
    #5 clk = ~clk; //
    
end

// task to send one UART frame
task send_uart_byte;
    input [7:0] data;
    integer i;
    begin 
        //start bit (0)
        rx = 1'b0; // Set RX line low for start bit
        repeat(80)@(posedge clk); // Wait for 16 baud ticks

        //data bits(lsb first)
        for (i=0; i<8; i=i+1) begin 
            rx = data[i];
            repeat(80) @(posedge clk); // Wait for 16 baud ticks for each data bit    
        end

        //stop bit (1)
        rx = 1'b1;
        repeat(80) @(posedge clk); // Wait for 16 baud ticks for stop bit
    end
endtask

initial begin 
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);

    rst_n <= 0;
    baud_div <= 16'h05;
    send_data <= 8'hA5;
    tx_start <= 0;
    @(negedge clk);

    rst_n <= 1;
    repeat(5) @(negedge clk);


    tx_start <= 1;
    @(negedge clk);
    tx_start <= 0;

    repeat(900) @(negedge clk);

    send_uart_byte(8'hAA);

    repeat(1000) @(negedge clk); 



    $finish;
end


endmodule