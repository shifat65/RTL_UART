module uart_tx (
    input wire clk,                // System clock
    input wire rst_n,              // Active low reset
    input wire baud_tick_1x,          // Baud rate tick signal
    input wire tx_start,          // Signal to start transmission
    input wire [7:0] tx_data,      // 8-bit data input
    
    output reg tx_line,             // UART transmit output
    output reg tx_busy             // Transmission done signal
);

reg [3:0] bit_index;          // Bit index for transmission
reg [9:0] tx_shift_reg;       // Shift register for data transmission

always @(posedge clk, negedge rst_n) begin

    if(!rst_n) begin
        tx_line <= 1'b1;          // Idle state for UART line (high)
        tx_busy <= 1'b0;
        bit_index <= 4'b0;        // Reset bit index
        tx_shift_reg <= 10'b1111111111; // Reset shift register to idle
    end 
    else if(tx_start && !tx_busy) begin
        //loading 10 bit frame: start(0) + data(8) + stop(1)
        tx_shift_reg <= {1'b1, tx_data, 1'b0}; // Load data into shift register
        tx_busy <= 1'b1;          // Set busy flag
        bit_index <= 4'b0;        // Reset bit index for transmission
    end
    else if(baud_tick_1x && tx_busy) begin
        if(bit_index < 9) begin
            tx_line <= tx_shift_reg[0]; // Transmit the least significant bit
            tx_shift_reg <= tx_shift_reg >>1; // Shift right to prepare for next bit
            bit_index <= bit_index +1; // Increment bit index
        end
        else begin
            tx_line <=1'b1;
            tx_busy <= 1'b0;
            bit_index <= 4'b0; // Reset bit index after transmission
            tx_shift_reg <= 10'b1111111111; // Reset shift register to idle 
        end
    end
end


endmodule