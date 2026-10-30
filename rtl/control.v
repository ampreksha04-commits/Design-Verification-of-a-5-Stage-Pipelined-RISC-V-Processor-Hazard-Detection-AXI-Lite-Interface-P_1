// Main control unit + ALU control (decodes opcode/funct3/funct7)
module control (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input        funct7_5,        // instr[30]
    output reg   reg_write,
    output reg   alu_src_b,       // 1 = immediate, 0 = rs2
    output reg   alu_a_pc,        // 1 = PC (auipc)
    output reg   alu_a_zero,      // 1 = zero (lui)
    output reg   mem_read,
    output reg   mem_write,
    output reg   mem_to_reg,
    output reg   branch,
    output reg   jal,
    output reg   jalr,
    output reg [3:0] alu_ctrl
);
    // ALU codes (must match alu.v)
    localparam ADD=4'b0000, SUB=4'b0001, AND_=4'b0010, OR_=4'b0011, XOR_=4'b0100,
               SLL=4'b0101, SRL=4'b0110, SRA=4'b0111, SLT=4'b1000, SLTU=4'b1001;

    reg [3:0] alu_fn;   // operation selected by funct3/funct7
    always @* begin
        case (funct3)
            3'b000: alu_fn = (opcode == 7'b0110011 && funct7_5) ? SUB : ADD;
            3'b001: alu_fn = SLL;
            3'b010: alu_fn = SLT;
            3'b011: alu_fn = SLTU;
            3'b100: alu_fn = XOR_;
            3'b101: alu_fn = funct7_5 ? SRA : SRL;
            3'b110: alu_fn = OR_;
            3'b111: alu_fn = AND_;
        endcase
    end

    always @* begin
        reg_write=0; alu_src_b=0; alu_a_pc=0; alu_a_zero=0; mem_read=0; mem_write=0;
        mem_to_reg=0; branch=0; jal=0; jalr=0; alu_ctrl=ADD;
        case (opcode)
            7'b0110011: begin reg_write=1; alu_ctrl=alu_fn; end                 // R-type
            7'b0010011: begin reg_write=1; alu_src_b=1; alu_ctrl=alu_fn; end    // I-type ALU
            7'b0000011: begin reg_write=1; alu_src_b=1; mem_read=1; mem_to_reg=1; end // lw
            7'b0100011: begin alu_src_b=1; mem_write=1; end                     // sw
            7'b1100011: begin branch=1; end                                     // branches
            7'b1101111: begin reg_write=1; jal=1; end                           // jal
            7'b1100111: begin reg_write=1; alu_src_b=1; jalr=1; end             // jalr
            7'b0110111: begin reg_write=1; alu_src_b=1; alu_a_zero=1; end       // lui
            7'b0010111: begin reg_write=1; alu_src_b=1; alu_a_pc=1; end         // auipc
            default: ;
        endcase
    end
endmodule
