module DotProduct_tb;

    logic clk;
    logic reset;
    logic start;

    logic [31:0] result;
    logic done;

    DotProduct dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .result(result),
        .done(done)
    );
    initial begin
        clk = 0;

        forever begin
            #5;
            clk = ~clk;
        end
    end

    initial begin
        reset=1;
        start=0;
        @(posedge clk);

        @(negedge clk);
        reset = 0;
        start = 1;

        @(posedge clk);

        @(negedge clk);
        start = 0;

        wait(done == 1);

        #1;
        $display("Result = %d", result);

        if (result == 19) begin
            $display("PASS");
        end
        else begin
            $display("FAIL");
        end

    $finish;
    end
endmodule