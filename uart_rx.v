module uart_rx(
    input wire clk,
    input wire rst_n,

    input wire rx,
    input wire baud_tick_16x,

    output reg [7:0] rx_data,
    output reg rx_done
);

// internal registers
reg [3:0] bit_index;
reg [3:0] tick_count;
reg [7:0] rx_shift_reg;

reg receiving; // Flag to indicate if receiving is in progress
reg start_detected; // Flag to indicate if start bit is detected

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin 
        bit_index <= 4'b0;
        tick_count <= 4'b0;
        rx_data <= 8'b0;
        rx_done <= 1'b0;
        receiving <= 1'b0;
        start_detected <= 1'b0;
        rx_shift_reg <= 8'b11111111; // Reset shift register to idle
    end
    else begin 
        rx_done <= 1'b0; // Reset rx_done at the start of each clock cycle
        if(baud_tick_16x) begin 
            if(!receiving) begin //not receiving data
                //loocking for start bit
                if(rx == 1'b0 && !start_detected) begin 
                    // Start bit detected
                    start_detected <= 1'b1;
                    tick_count <= 4'b0; // Reset tick count
                end
                else if(start_detected) begin 
                    tick_count <=tick_count + 1; // Increment tick count
                    if(tick_count == 4'd7) begin 
                        if(rx==1'b0)begin 
                            receiving <=1'b1; // Start receiving data
                            start_detected <= 1'b0; // Reset start detected flag
                            tick_count <= 4'b0; // Reset tick count
                            bit_index <= 4'b0; // Reset bit index
                        end
                        else begin 
                            start_detected <= 1'b0; // Reset start detected flag if no start bit
                        end
                        
                    end
                end
            end
            else begin // receiving data 
                tick_count <= tick_count + 1; // Increment tick count

                if(tick_count == 4'd15) begin 
                    tick_count <= 1'b0;
                    rx_shift_reg <= rx_shift_reg >> 1; // Shift right to prepare for next bit
                    rx_shift_reg[7] <= rx; // Load the current bit into the shift register
                    bit_index <= bit_index + 1; // Increment bit index

                    if(bit_index == 8) begin 
                        receiving <= 1'b0; // Stop receiving data
                        rx_data <= rx_shift_reg;
                    end                    
                end
            end
        end

    end

end

endmodule