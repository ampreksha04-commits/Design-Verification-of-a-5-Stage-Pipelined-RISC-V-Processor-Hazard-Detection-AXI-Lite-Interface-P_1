`timescale 1ns/1ps
// Simulates the board with the VIO stub:
//   "typing" n in the Tcl console = writing dut.u_vio.v ; checks LEDs and the 7-segment display
module tb_fpga_top;
    reg clk = 0, btnc = 0;
    reg [15:0] sw = 16'd0;                  // all switches down -> n comes from the Tcl console (VIO)
    wire [15:0] led;
    wire [6:0] seg; wire dp; wire [7:0] an;
    integer errors = 0;
    fpga_top #(.IMEM_FILE("sw/fib.hex"), .SCAN(3)) dut (.clk(clk), .btnc(btnc), .sw(sw), .led(led), .seg(seg), .dp(dp), .an(an));
    always #5 clk = ~clk;                   // 100 MHz

    // capture what each 7-segment digit shows (digits are scanned one at a time)
    reg [6:0] cap [0:7];
    integer q;
    initial for (q = 0; q < 8; q = q + 1) cap[q] = 7'h7F;
    always @(an or seg) begin
        for (q = 0; q < 8; q = q + 1) if (an == ~(8'b1 << q)) cap[q] = seg;
    end

    function [6:0] pat(input integer d);
        case (d)
            0: pat = 7'b1000000; 1: pat = 7'b1111001; 2: pat = 7'b0100100; 3: pat = 7'b0110000;
            4: pat = 7'b0011001; 5: pat = 7'b0010010; 6: pat = 7'b0000010; 7: pat = 7'b1111000;
            8: pat = 7'b0000000; 9: pat = 7'b0010000; default: pat = 7'b1111111;
        endcase
    endfunction
    function [31:0] fib(input integer n);
        integer j; reg [31:0] a, b, t;
        begin a = 0; b = 1; for (j = 0; j < n; j = j + 1) begin t = a + b; a = b; b = t; end fib = a; end
    endfunction

    // expected digit (or blank) at position p of a number with leading zeros blanked
    function [6:0] exp_digit(input integer val, input integer p);
        integer pw, d;
        begin
            pw = 1; for (d = 0; d < p; d = d + 1) pw = pw * 10;
            if (p > 0 && val < pw) exp_digit = 7'b1111111; else exp_digit = pat((val / pw) % 10);
        end
    endfunction

    task set_n_and_check(input integer n);
        integer f, ok;
        begin
            f = fib(n);
            dut.u_vio.v = n;                    // like "run_fib n" in the Tcl console
            #50000;                             // 50 us: restart + run + several display scans
            ok = 1;
            if (led !== f[15:0]) begin ok = 0; $display("  LEDs = %0d, expected %0d", led, f); end
            if (cap[0] !== exp_digit(f,0) || cap[1] !== exp_digit(f,1) || cap[2] !== exp_digit(f,2) ||
                cap[3] !== exp_digit(f,3) || cap[4] !== exp_digit(f,4)) begin ok = 0; $display("  result digits wrong"); end
            if (cap[7] !== pat(n % 10) || cap[6] !== exp_digit(n,1)) begin ok = 0; $display("  n digits wrong"); end
            if (ok) $display("PASS n=%0d -> LEDs=%0d, 7-segment shows n=%0d result=%0d", n, led, n, f);
            else begin $display("FAIL n=%0d", n); errors = errors + 1; end
        end
    endtask

    initial begin
        $dumpfile("sim/fpga_top.vcd"); $dumpvars(0, tb_fpga_top);
        #20000;
        set_n_and_check(10);
        set_n_and_check(7);
        set_n_and_check(0);
        set_n_and_check(24);
        set_n_and_check(5);
        // switch mode: SW14 up, SW0..SW4 = 12
        sw = 16'h4000 | 16'd12; #50000;
        if (led === 16'd144) $display("PASS switch mode n=12 -> LEDs = 144");
        else begin $display("FAIL switch mode: LEDs = %0d", led); errors = errors + 1; end
        // SW15 up shows the program counter (done loop = 0x34)
        sw = 16'hC000 | 16'd12; #200;
        if (led === 16'h0034) $display("PASS SW15 up -> LEDs show PC = 0x0034");
        else begin $display("FAIL PC LEDs = %h", led); errors = errors + 1; end
        if (errors == 0) $display("ALL FPGA_TOP TESTS PASSED"); else $display("%0d FPGA_TOP TESTS FAILED", errors);
        $finish;
    end
endmodule
