module baud_gen_16x(
    input wire clk,                 // 16x clock input
    input wire rst_n,               // Active low reset
    input wire [15:0] count,           // 16-bit counter input
    input wire [15:0] baud_div, 
    
    output reg baud_tick_1x,
    output reg baud_tick_16x,            // Baud tick output
    output reg rst_c
);

reg [3:0] baud_count; // 4-bit counter for baud rate generation

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        baud_tick_16x <= 1'b0;
        baud_tick_1x <= 1'b0; // Reset baud tick to low
        baud_count <= 4'b0;    // Reset baud count
        rst_c <= 1'b1;  // Reset baud tick to low
    end 
    else if (count == baud_div-2) begin
        rst_c <= 1'b1;
        baud_tick_16x <= 1'b1;  

        if ( baud_count == 4'd15)begin 
            baud_tick_1x <= 1'b1;
            rst_c <=1'b1; 
            baud_count <= 4'b0;
        end
        else begin
                
            baud_count <= baud_count + 1; 
            baud_tick_1x <= 1'b0; 
        end          
    end else begin
        rst_c <= 1'b0;          // Keep reset signal low when not generating baud tic
        baud_tick_16x <= 1'b0;  // Otherwise, keep baud tick low
        baud_tick_1x <= 1'b0; // Keep baud tick for 1x clock low
    end
end

endmodule
// End of baud_gen_16x module