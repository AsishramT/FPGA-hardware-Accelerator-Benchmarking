module multiplier_tb;

    logic [7:0] a;
    logic [7:0] b;

    logic [15:0] result;


    multiplier dut (
        .a(a),
        .b(b),
        .result(result)
    );


    initial begin

        a = 2;
        b = 3;

        #10;

        if(result == 6)begin
            $display("PASS: 2 x 3 = %d", result);
        end
        else begin
            $display("FAIL: Expected 6, got %d", result);
        end

        a = 5;
        b = 7;

        #10;

        if(result == 35)begin
            $display("PASS: 5 x 7 = %d", result);
        end
        else begin
            $display("FAIL: Expected 35, got %d", result);
        end

        a = 9;
        b = 8;

        #10;

        if(result == 72)begin
            $display("PASS: 9 x 8 = %d", result);
        end
        else begin
            $display("FAIL: Expected 72, got %d", result);
        end


        $finish;

    end

endmodule