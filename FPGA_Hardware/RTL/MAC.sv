module MAC(
    input logic clk,
    input logic reset,
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [31:0] accumulator
);

    always_ff @(posedge clk) begin
        if(reset)begin
            accumulator<=0;
        end
        else begin
            accumulator<=accumulator + (a*b);
        end
        
    end

endmodule