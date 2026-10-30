`timescale 1ns/1ps
module tb_imm_gen;
    reg  [31:0] instr;
    wire [31:0] imm;
    integer errors = 0;
    imm_gen dut (.instr(instr), .imm(imm));

    task check(input [31:0] i, input [31:0] exp, input [8*10-1:0] name);
        begin
            instr = i; #1;
            if (imm !== exp) begin $display("FAIL %0s: got %h expected %h", name, imm, exp); errors = errors + 1; end
            else $display("PASS %0s", name);
        end
    endtask

    initial begin
        $dumpfile("sim/imm_gen.vcd"); $dumpvars(0, tb_imm_gen);
        check(32'h00500093, 32'd5,         "addi +5");
        check(32'hfff00093, 32'hFFFFFFFF,  "addi -1");
        check(32'h0021a423, 32'd8,         "sw +8");
        check(32'h00208463, 32'd8,         "beq +8");
        check(32'hfe0198e3, 32'hFFFFFFF0,  "bne -16");
        check(32'h123452b7, 32'h12345000,  "lui");
        check(32'h001000ef, 32'd2048,      "jal +2048");
        check(32'hffdff0ef, 32'hFFFFFFFC,  "jal -4");
        if (errors == 0) $display("ALL IMM_GEN TESTS PASSED"); else $display("%0d IMM_GEN TESTS FAILED", errors);
        $finish;
    end
endmodule
