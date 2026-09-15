module mac_tb;

    logic clk;
    logic reset;
    logic [7:0] a;
    logic [7:0] b;
    logic [31:0] accumulator;

    MAC dut (
    .clk(clk),
    .reset(reset),
    .a(a),
    .b(b),
    .accumulator(accumulator)
    );

    initial begin
        clk = 0;

        forever begin
            #5;
            clk = ~clk;
        end
    end
    
    initial begin

        reset = 1;
        a = 0;
        b = 0;

        @(posedge clk);

        @(negedge clk);
        reset = 0;

        a = 1;
        b = 5;

        @(posedge clk);

        @(negedge clk);
        a = 2;
        b = 7;

        @(posedge clk);

        #1;
        $display("Accumulator = %d", accumulator);

        $finish;
    end

endmodule