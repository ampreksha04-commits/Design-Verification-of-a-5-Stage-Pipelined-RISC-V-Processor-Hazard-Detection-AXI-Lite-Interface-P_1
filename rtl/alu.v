// 32-bit ALU for the RV32I pipeline
module alu (
    input  [31:0] a, b,
    input  [3:0]  ctrl,
    output reg [31:0] y,
    output zero
);
    always @* begin
        case (ctrl)
            4'b0000: y = a + b;                               // ADD
            4'b0001: y = a - b;                               // SUB
            4'b0010: y = a & b;                               // AND
            4'b0011: y = a | b;                               // OR
            4'b0100: y = a ^ b;                               // XOR
            4'b0101: y = a << b[4:0];                         // SLL
            4'b0110: y = a >> b[4:0];                         // SRL
            4'b0111: y = $signed(a) >>> b[4:0];               // SRA
            4'b1000: y = {31'b0, ($signed(a) < $signed(b))};  // SLT
            4'b1001: y = {31'b0, (a < b)};                    // SLTU
            default: y = 32'b0;
        endcase
    end
    assign zero = (y == 32'b0);
endmodule
