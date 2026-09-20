module ParallelMatrixMultiplier #(
    parameter int N = 4,
    parameter int LANES = 4
)(
    input logic clk,
    input logic reset,
    input logic start,

    input logic [7:0] A [0:N-1][0:N-1],
    input logic [7:0] B [0:N-1][0:N-1],

    output logic [31:0] C [0:N-1][0:N-1],

    output logic done,
    output logic [31:0] cycle_count
);

    localparam int INDEX_WIDTH =
        (N <= 1) ? 1 : $clog2(N);

    localparam int K_WIDTH =
        (N + LANES <= 2) ? 1 : $clog2(N + LANES);


    logic [INDEX_WIDTH-1:0] row;
    logic [INDEX_WIDTH-1:0] col;
    logic [K_WIDTH-1:0] k;

    logic [31:0] accumulator;
    logic [31:0] parallel_sum;

    integer lane;
    integer i;
    integer j;


    typedef enum logic [1:0] {
        IDLE,
        CALCULATE,
        FINISHED
    } state_t;

    state_t state;


    // ============================================
    // Parallel multiplier section
    //
    // Computes LANES products in parallel
    // ============================================

    always_comb begin

        parallel_sum = 0;

        for (lane = 0; lane < LANES; lane = lane + 1) begin

            if ((k + lane) < N) begin

                parallel_sum =
                    parallel_sum +
                    (A[row][k + lane] *
                     B[k + lane][col]);

            end

        end

    end


    // ============================================
    // Controller
    // ============================================

    always_ff @(posedge clk) begin

        if (reset) begin

            state <= IDLE;

            row <= 0;
            col <= 0;
            k <= 0;

            accumulator <= 0;

            done <= 0;
            cycle_count <= 0;


            for (i = 0; i < N; i = i + 1) begin
                for (j = 0; j < N; j = j + 1) begin

                    C[i][j] <= 0;

                end
            end

        end

        else begin

            case (state)

                // ==================================
                // IDLE
                // ==================================
                IDLE: begin

                    done <= 0;

                    if (start) begin

                        row <= 0;
                        col <= 0;
                        k <= 0;

                        accumulator <= 0;
                        cycle_count <= 0;

                        state <= CALCULATE;

                    end

                end


                // ==================================
                // CALCULATE
                // ==================================
                CALCULATE: begin

                    cycle_count <= cycle_count + 1;


                    // More chunks remain after this one
                    if ((k + LANES) < N) begin

                        accumulator <=
                            accumulator + parallel_sum;

                        k <= k + LANES;

                    end


                    // This is the final chunk
                    else begin

                        // Store final value immediately
                        C[row][col] <=
                            accumulator + parallel_sum;

                        accumulator <= 0;
                        k <= 0;


                        // Move through output matrix
                        if (col == N - 1) begin

                            col <= 0;

                            if (row == N - 1) begin

                                state <= FINISHED;

                            end

                            else begin

                                row <= row + 1;

                            end

                        end

                        else begin

                            col <= col + 1;

                        end

                    end

                end


                // ==================================
                // FINISHED
                // ==================================
                FINISHED: begin

                    done <= 1;

                    if (!start) begin
                        state <= IDLE;
                    end

                end


                default: begin

                    state <= IDLE;
                    done <= 0;

                end

            endcase

        end

    end

endmodule