module MatrixMultiplier_tb;

    logic clk;
    logic reset;
    logic start;

    logic done;
    logic [31:0] cycle_count;

    // Input matrices
    logic [7:0] A [0:1][0:1];
    logic [7:0] B [0:1][0:1];

    // Output matrix
    // DUT drives C, so use wire
    wire [31:0] C [0:1][0:1];


    MatrixMultiplier dut (
        .clk(clk),
        .reset(reset),
        .start(start),

        .A(A),
        .B(B),
        .C(C),

        .done(done),
        .cycle_count(cycle_count)
    );


    // Clock generation
    initial begin

        clk = 0;

        forever begin
            #5;
            clk = ~clk;
        end

    end


    // Test
    initial begin

        reset = 1;
        start = 0;


        // Matrix A
        //
        // [1 2]
        // [3 4]

        A[0][0] = 1;
        A[0][1] = 2;

        A[1][0] = 3;
        A[1][1] = 4;


        // Matrix B
        //
        // [5 6]
        // [7 8]

        B[0][0] = 5;
        B[0][1] = 6;

        B[1][0] = 7;
        B[1][1] = 8;


        // Reset accelerator
        @(posedge clk);

        @(negedge clk);
        reset = 0;


        // Send one-cycle start pulse
        @(negedge clk);
        start = 1;

        @(posedge clk);

        @(negedge clk);
        start = 0;


        // Wait for accelerator to finish
        wait(done == 1);

        #1;


        // Display result
        $display("");
        $display("Result Matrix:");

        $display("%d  %d",
                 C[0][0],
                 C[0][1]);

        $display("%d  %d",
                 C[1][0],
                 C[1][1]);

        $display("");

        $display(
            "Accelerator cycles = %d",
            cycle_count
        );


        // Verify result
        if (
            C[0][0] == 19 &&
            C[0][1] == 22 &&
            C[1][0] == 43 &&
            C[1][1] == 50
        ) begin

            $display("PASS");

        end

        else begin

            $display("FAIL");

        end


        $finish;

    end

endmodule