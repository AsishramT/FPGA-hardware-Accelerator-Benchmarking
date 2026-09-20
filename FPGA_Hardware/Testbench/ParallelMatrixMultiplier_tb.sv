module ParallelMatrixMultiplier_tb;

    parameter int N = 64;
    parameter int LANES = 64;

    logic clk;
    logic reset;
    logic start;

    logic done;
    logic [31:0] cycle_count;

    logic [7:0] A [0:N-1][0:N-1];
    logic [7:0] B [0:N-1][0:N-1];

    wire [31:0] C [0:N-1][0:N-1];

    logic [31:0] expected [0:N-1][0:N-1];

    integer i;
    integer j;
    integer k;

    integer errors;


    ParallelMatrixMultiplier #(
        .N(N),
        .LANES(LANES)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),

        .A(A),
        .B(B),
        .C(C),

        .done(done),
        .cycle_count(cycle_count)
    );


    // Clock
    initial begin

        clk = 0;

        forever begin
            #5;
            clk = ~clk;
        end

    end


    initial begin

        reset = 1;
        start = 0;
        errors = 0;


        // ========================================
        // Generate matrices
        // ========================================

        for (i = 0; i < N; i = i + 1) begin

            for (j = 0; j < N; j = j + 1) begin

                A[i][j] = (i * N + j + 1) % 10;
                B[i][j] = (i + j + 1) % 10;

            end

        end


        // ========================================
        // Software reference result
        // ========================================

        for (i = 0; i < N; i = i + 1) begin

            for (j = 0; j < N; j = j + 1) begin

                expected[i][j] = 0;

                for (k = 0; k < N; k = k + 1) begin

                    expected[i][j] =
                        expected[i][j] +
                        (A[i][k] * B[k][j]);

                end

            end

        end


        // Reset
        @(posedge clk);

        @(negedge clk);
        reset = 0;


        // Start
        @(negedge clk);
        start = 1;

        @(posedge clk);

        @(negedge clk);
        start = 0;


        // Wait for result
        wait(done == 1);

        #1;


        // ========================================
        // Compare results
        // ========================================

        for (i = 0; i < N; i = i + 1) begin

            for (j = 0; j < N; j = j + 1) begin

                if (C[i][j] != expected[i][j]) begin

                    errors = errors + 1;

                    $display(
                        "Mismatch C[%0d][%0d]: got %0d expected %0d",
                        i,
                        j,
                        C[i][j],
                        expected[i][j]
                    );

                end

            end

        end


        $display("");
        $display("Matrix size = %0dx%0d", N, N);
        $display("Parallel lanes = %0d", LANES);
        $display("Accelerator cycles = %0d", cycle_count);


        if (errors == 0)
            $display("PASS");
        else
            $display("FAIL - %0d errors", errors);


        $finish;

    end

endmodule