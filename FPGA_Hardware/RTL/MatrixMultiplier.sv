module MatrixMultiplier (
    input logic clk,
    input logic reset,
    input logic start,

    input logic [7:0] A [0:1][0:1],
    input logic [7:0] B [0:1][0:1],

    output logic [31:0] C [0:1][0:1],

    output logic done,
    output logic [31:0] cycle_count
);

    // Matrix indices
    logic [1:0] row;
    logic [1:0] col;
    logic [1:0] k;

    // Running sum for C[row][col]
    logic [31:0] accumulator;

    // FSM states
    typedef enum logic [1:0] {
        IDLE,
        CALCULATE,
        FINISHED
    } state_t;

    state_t state;


    always_ff @(posedge clk) begin

        if (reset) begin

            state <= IDLE;

            row <= 0;
            col <= 0;
            k <= 0;

            accumulator <= 0;

            done <= 0;
            cycle_count <= 0;

            C[0][0] <= 0;
            C[0][1] <= 0;
            C[1][0] <= 0;
            C[1][1] <= 0;

        end

        else begin

            case (state)

                // Wait for start signal
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


                // Perform matrix multiplication
                CALCULATE: begin

                    cycle_count <= cycle_count + 1;

                    // Calculate one part of the dot product
                    if (k < 2) begin

                        accumulator <=
                            accumulator +
                            (A[row][k] * B[k][col]);

                        k <= k + 1;

                    end

                    // Dot product finished
                    else begin

                        C[row][col] <= accumulator;

                        accumulator <= 0;
                        k <= 0;


                        // Move to next output element
                        if (col == 1) begin

                            col <= 0;

                            if (row == 1) begin

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


                // Calculation finished
                FINISHED: begin

                    done <= 1;

                    if (!start) begin
                        state <= IDLE;
                    end

                end


                // Safety
                default: begin

                    state <= IDLE;
                    done <= 0;

                end

            endcase

        end

    end

endmodule