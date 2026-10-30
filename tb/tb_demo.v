`timescale 1ns/1ps
// Waveform demo for the panel: runs Fibonacci(n) and records the key signals.
// Choose n when you run it:  vvp sim\demo.out +N=7   (default n = 10); optional +VCD=path
module tb_demo;
    reg clk = 0, rst = 1;
    reg [15:0] sw_in = 16'd10;
    integer n;
    reg [8*200:1] vcdfile;
    wire [31:0] dbg_x1, dbg_pc;
    cpu_single dut (.clk(clk), .rst(rst), .sw_in(sw_in), .dbg_x1(dbg_x1), .dbg_pc(dbg_pc));
    always #5 clk = ~clk;                 // 100 MHz in simulation

    // Signals shown in GTKWave (copied out of the CPU so they sit at the top level)
    wire [31:0] pc        = dut.pc;
    wire [31:0] instr     = dut.instr;
    wire [31:0] alu_y     = dut.alu_y;
    wire [31:0] x1_result = dbg_x1;

    initial begin
        if (!$value$plusargs("N=%d", n)) n = 10;
        sw_in = n;
        if (!$value$plusargs("VCD=%s", vcdfile)) vcdfile = "sim/demo.vcd";
        $dumpfile(vcdfile);
        $dumpvars(1, tb_demo);            // level 1 only: just the signals above
        #22 rst = 0;
        // run until the program reaches its final 'done' loop (PC = 0x34), with a timeout
        begin : wait_done
            integer t;
            for (t = 0; t < 20000 && pc !== 32'h34; t = t + 1) #10;
        end
        #100;
        $display("n = %0d  ->  Fibonacci(%0d) = %0d  (LEDs would show 0x%h)", n, n, dbg_x1, dbg_x1[15:0]);
        $finish;
    end
endmodule
