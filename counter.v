module counter (
    input wire clk,
    input wire rst_n,
    input wire rst_c,

    output reg [15:0] count  // 16-bit counter output
);

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        count <= 16'b0;  // Reset counter to zero
    end else begin
        count <= (rst_c)? 0 : count + 1;  // Increment counter on each clock cycle
    end
    
end
    
endmodule