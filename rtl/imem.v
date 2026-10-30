// Instruction memory (word addressed).
// A built-in copy of the Fibonacci program (same as sw/fib.hex) is loaded so the FPGA build
// works without any file. In simulation the hex file then overrides it, so other programs can be tested.
module imem #(parameter FILE = "sw/fib.hex") (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) mem[i] = 32'h00000013;  // NOP (addi x0,x0,0)
        mem[0] = 32'h200002b7;
        mem[1] = 32'h0002a183;
        mem[2] = 32'h01f1f193;
        mem[3] = 32'h00000093;
        mem[4] = 32'h00100113;
        mem[5] = 32'h00018c63;
        mem[6] = 32'h00208233;
        mem[7] = 32'h000100b3;
        mem[8] = 32'h00020133;
        mem[9] = 32'hfff18193;
        mem[10] = 32'hfe0198e3;
        mem[11] = 32'h00102023;
        mem[12] = 32'h00002303;
        mem[13] = 32'h00000063;
`ifndef SYNTHESIS
        $readmemh(FILE, mem);    // simulation only: load the hex file
`endif
    end
    assign instr = mem[addr[9:2]];
endmodule
