// 32 x 32-bit register file, 2 read ports, 1 write port, x0 hardwired to 0
module regfile (
    input         clk, we,
    input  [4:0]  rs1, rs2, rd,
    input  [31:0] wd,
    output [31:0] rdata1, rdata2,
    output [31:0] x1_out          // debug: value of x1 (shown on FPGA LEDs)
);
    reg [31:0] regs [0:31];
    integer i;
    initial for (i = 0; i < 32; i = i + 1) regs[i] = 32'b0;

    // Write on the falling edge so WB can write while ID reads in the same cycle
    always @(negedge clk)
        if (we && rd != 5'd0) regs[rd] <= wd;

    assign x1_out = regs[1];
    assign rdata1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
    assign rdata2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];
endmodule
