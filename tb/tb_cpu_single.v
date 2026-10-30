`timescale 1ns/1ps
// Runs sw/fib.hex on the single-cycle CPU for several switch values n and checks Fibonacci(n)
module tb_cpu_single;
    reg clk = 0, rst = 1;
    reg [15:0] sw_in = 16'd10;
    wire [31:0] x1, pc;
    integer errors = 0, k;
    cpu_single dut (.clk(clk), .rst(rst), .sw_in(sw_in), .dbg_x1(x1), .dbg_pc(pc));
    always #5 clk = ~clk;

    function [31:0] fib(input integer n);
        integer j; reg [31:0] a, b, t;
        begin a = 0; b = 1; for (j = 0; j < n; j = j + 1) begin t = a + b; a = b; b = t; end fib = a; end
    endfunction

    task run(input [15:0] n);
        begin
            sw_in = n; rst = 1; #22 rst = 0;
            #3000;                                    // plenty of cycles
            if (dut.rf.regs[1] !== fib(n & 31) || dut.rf.regs[6] !== fib(n & 31)) begin
                $display("FAIL n=%0d: x1=%0d x6=%0d expected %0d", n, dut.rf.regs[1], dut.rf.regs[6], fib(n & 31));
                errors = errors + 1;
            end else $display("PASS n=%0d -> Fibonacci = %0d (stored and read back)", n, dut.rf.regs[1]);
        end
    endtask

    initial begin
        $dumpfile("sim/cpu_single.vcd"); $dumpvars(0, tb_cpu_single);
        run(10); run(0); run(1); run(2); run(7); run(12); run(24);
        if (errors == 0) $display("ALL CPU TESTS PASSED"); else $display("%0d CPU TESTS FAILED", errors);
        $finish;
    end
endmodule
