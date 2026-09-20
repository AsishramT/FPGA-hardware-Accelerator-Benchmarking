module ParallelMatrixMultiplierSynth #(
    parameter integer N = 4,
    parameter integer LANES = 4
)(
    input  wire clk,
    input  wire reset,
    input  wire start,

    input  wire [(8*N*N)-1:0] A_flat,
    input  wire [(8*N*N)-1:0] B_flat,

    output reg  [(32*N*N)-1:0] C_flat,

    output reg done,
    output reg [31:0] cycle_count
);

    localparam integer INDEX_WIDTH =
        (N <= 1) ? 1 : $clog2(N);

    localparam integer K_WIDTH =
        (N + LANES <= 2) ? 1 : $clog2(N + LANES);


    reg [INDEX_WIDTH-1:0] row;
    reg [INDEX_WIDTH-1:0] col;
    reg [K_WIDTH-1:0] k;

    reg [31:0] accumulator;
    reg [31:0] parallel_sum;

    integer lane;
    integer i;


    localparam [1:0]
        IDLE      = 2'b00,
        CALCULATE = 2'b01,
        FINISHED  = 2'b10;

    reg [1:0] state;


    // ------------------------------------------
    // Temporary values selected from flat buses
    // ------------------------------------------

    reg [7:0] a_value;
    reg [7:0] b_value;


    // ------------------------------------------
    // Parallel datapath
    // ------------------------------------------

    always @(*) begin

        parallel_sum = 0;

        a_value = 0;
        b_value = 0;

        for (lane = 0; lane < LANES; lane = lane + 1) begin

            if ((k + lane) < N) begin

                a_value =
                    A_flat[
                        (((row * N) + (k + lane)) * 8)
                        +: 8
                    ];

                b_value =
                    B_flat[
                        ((((k + lane) * N) + col) * 8)
                        +: 8
                    ];

                parallel_sum =
                    parallel_sum +
                    (a_value * b_value);

            end

        end

    end


    // ------------------------------------------
    // FSM + sequential logic
    // ------------------------------------------

    always @(posedge clk) begin

        if (reset) begin

            state <= IDLE;

            row <= 0;
            col <= 0;
            k <= 0;

            accumulator <= 0;

            done <= 0;
            cycle_count <= 0;

            C_flat <= 0;

        end

        else begin

            case (state)

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


                CALCULATE: begin

                    cycle_count <= cycle_count + 1;


                    // More chunks remain after this one
                    if ((k + LANES) < N) begin

                        accumulator <=
                            accumulator + parallel_sum;

                        k <= k + LANES;

                    end


                    // Final chunk for current output
                    else begin

                        C_flat[
                            (((row * N) + col) * 32)
                            +: 32
                        ] <= accumulator + parallel_sum;

                        accumulator <= 0;
                        k <= 0;


                        // Move to next output element
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