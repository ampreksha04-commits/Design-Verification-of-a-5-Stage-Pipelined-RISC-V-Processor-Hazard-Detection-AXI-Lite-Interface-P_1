// Data memory (word access only for now: lw / sw)
module dmem (
    input         clk, we,
    input  [31:0] addr, wdata,
    output [31:0] rdata
);
    reg [31:0] mem [0:255];
    integer i;
    initial for (i = 0; i < 256; i = i + 1) mem[i] = 32'b0;
    always @(posedge clk) if (we) mem[addr[9:2]] <= wdata;
    assign rdata = mem[addr[9:2]];
endmodule
