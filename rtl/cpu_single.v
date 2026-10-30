// Single-cycle RV32I CPU (stepping stone before the pipelined version)
module cpu_single #(parameter IMEM_FILE = "sw/fib.hex") (
    input clk, rst,
    input [15:0] sw_in,               // board switches (memory-mapped input at 0x2000_0000)
    output [31:0] dbg_x1, dbg_pc      // debug outputs for the FPGA LEDs
);
    reg  [31:0] pc;
    initial pc = 32'b0;
    assign dbg_pc = pc;
    wire [31:0] instr, imm, rd1, rd2, alu_a, alu_b, alu_y, mem_rdata, wb_data, pc4, pc_target;
    wire reg_write, alu_src_b, alu_a_pc, alu_a_zero, mem_read, mem_write, mem_to_reg;
    wire branch, jal, jalr, zero;
    wire io_sel;
    wire [31:0] dmem_rdata;
    wire [3:0] alu_ctrl;

    imem #(.FILE(IMEM_FILE)) u_imem (.addr(pc), .instr(instr));
    imm_gen u_imm (.instr(instr), .imm(imm));
    control u_ctl (.opcode(instr[6:0]), .funct3(instr[14:12]), .funct7_5(instr[30]),
        .reg_write(reg_write), .alu_src_b(alu_src_b), .alu_a_pc(alu_a_pc), .alu_a_zero(alu_a_zero),
        .mem_read(mem_read), .mem_write(mem_write), .mem_to_reg(mem_to_reg),
        .branch(branch), .jal(jal), .jalr(jalr), .alu_ctrl(alu_ctrl));

    regfile rf (.clk(clk), .we(reg_write), .rs1(instr[19:15]), .rs2(instr[24:20]),
                .rd(instr[11:7]), .wd(wb_data), .rdata1(rd1), .rdata2(rd2), .x1_out(dbg_x1));

    assign alu_a = alu_a_zero ? 32'b0 : (alu_a_pc ? pc : rd1);
    assign alu_b = alu_src_b ? imm : rd2;
    alu u_alu (.a(alu_a), .b(alu_b), .ctrl(alu_ctrl), .y(alu_y), .zero(zero));

    // Address 0x2xxx_xxxx is the switch input; everything else is normal data memory
    assign io_sel    = (alu_y[31:28] == 4'h2);
    dmem u_dmem (.clk(clk), .we(mem_write & ~io_sel), .addr(alu_y), .wdata(rd2), .rdata(dmem_rdata));
    assign mem_rdata = io_sel ? {16'b0, sw_in} : dmem_rdata;

    // branch comparator
    reg take;
    always @* begin
        case (instr[14:12])
            3'b000: take = (rd1 == rd2);                              // beq
            3'b001: take = (rd1 != rd2);                              // bne
            3'b100: take = ($signed(rd1) <  $signed(rd2));            // blt
            3'b101: take = ($signed(rd1) >= $signed(rd2));            // bge
            3'b110: take = (rd1 <  rd2);                              // bltu
            3'b111: take = (rd1 >= rd2);                              // bgeu
            default: take = 1'b0;
        endcase
    end

    assign pc4       = pc + 32'd4;
    assign pc_target = pc + imm;
    assign wb_data   = (jal | jalr) ? pc4 : (mem_to_reg ? mem_rdata : alu_y);

    always @(posedge clk) begin
        if (rst) pc <= 32'b0;
        else if (jalr)               pc <= {alu_y[31:1], 1'b0};
        else if (jal)                pc <= pc_target;
        else if (branch && take)     pc <= pc_target;
        else                         pc <= pc4;
    end
endmodule
