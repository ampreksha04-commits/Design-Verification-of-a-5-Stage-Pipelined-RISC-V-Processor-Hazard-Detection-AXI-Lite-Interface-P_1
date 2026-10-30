`timescale 1ns/1ps
module tb_alu;
    reg  [31:0] a, b;
    reg  [3:0]  ctrl;
    wire [31:0] y;
    wire zero;
    integer errors = 0;

    alu dut (.a(a), .b(b), .ctrl(ctrl), .y(y), .zero(zero));

    task check(input [31:0] ia, ib, input [3:0] ic, input [31:0] exp, input [8*8-1:0] name);
        begin
            a = ia; b = ib; ctrl = ic; #5;
            if (y !== exp) begin
                $display("FAIL %0s: got %h expected %h", name, y, exp);
                errors = errors + 1;
            end else
                $display("PASS %0s", name);
            #5;
        end
    endtask

    initial begin
        $dumpfile("sim/alu.vcd"); $dumpvars(0, tb_alu);
        check(5, 3, 4'b0000, 8,                    "ADD");
        check(5, 3, 4'b0001, 2,                    "SUB");
        check(32'hF0F0F0F0, 32'hFFFF0000, 4'b0010, 32'hF0F00000, "AND");
        check(32'h0F, 32'hF0, 4'b0011, 32'hFF,     "OR");
        check(32'hFF, 32'h0F, 4'b0100, 32'hF0,     "XOR");
        check(1, 4, 4'b0101, 16,                   "SLL");
        check(32'h80000000, 4, 4'b0110, 32'h08000000, "SRL");
        check(32'h80000000, 4, 4'b0111, 32'hF8000000, "SRA");
        check(32'hFFFFFFFF, 1, 4'b1000, 1,         "SLT");
        check(32'hFFFFFFFF, 1, 4'b1001, 0,         "SLTU");
        if (errors == 0) $display("ALL ALU TESTS PASSED");
        else             $display("%0d ALU TESTS FAILED", errors);
        $finish;
    end
endmodule
