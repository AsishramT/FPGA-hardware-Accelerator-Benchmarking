module DotProduct (
    input  logic clk,
    input  logic reset,
    input  logic start,

    output logic [31:0] result,
    output logic done
);

    logic [7:0] Arow [0:1];
    logic [7:0] Bcol [0:1];

    logic [1:0] k;

    initial begin
        Arow[0] = 1;
        Arow[1] = 2;

        Bcol[0] = 5;
        Bcol[1] = 7;
    end

    always_ff @(posedge clk) begin

        if (reset) begin
            result <= 0;
            k <= 0;
            done <= 0;
        end

        else if (start) begin
            result <= 0;
            k <= 0;
            done <= 0;
        end

        else if (k < 2) begin
            result <= result + (Arow[k] * Bcol[k]);
            k <= k + 1;
        end
        
        else begin
            done <= 1;
        end
    end

endmodule