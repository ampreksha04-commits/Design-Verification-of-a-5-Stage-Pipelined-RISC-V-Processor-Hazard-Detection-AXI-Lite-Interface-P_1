`timescale 1ns/1ps
module tb_regfile;
    reg clk = 0, we = 0;
    reg  [4:0]  rs1, rs2, rd;
    reg  [31:0] wd;
    wire [31:0] rdata1, rdata2;
    integer errors = 0;

    regfile dut (.clk(clk), .we(we), .rs1(rs1), .rs2(rs2), .rd(rd), .wd(wd),
                 .rdata1(rdata1), .rdata2(rdata2));

    always #5 clk = ~clk;

    task write(input [4:0] r, input [31:0] d);
        begin
            @(posedge clk); #1;
            rd = r; wd = d; we = 1;
            @(negedge clk); #1;          // write happens on this falling edge
            we = 0;
        end
    endtask

    task expect1(input [31:0] got, input [31:0] exp, input [8*16-1:0] name);
        begin
            if (got !== exp) begin
                $display("FAIL %0s: got %h expected %h", name, got, exp);
                errors = errors + 1;
            end else $display("PASS %0s", name);
        end
    endtask

    initial begin
        $dumpfile("sim/regfile.vcd"); $dumpvars(0, tb_regfile);
        rs1 = 0; rs2 = 0; rd = 0; wd = 0;
        #12;
        write(5'd5, 32'hDEADBEEF);
        rs1 = 5'd5; #2;
        expect1(rdata1, 32'hDEADBEEF, "write/read x5");

        write(5'd0, 32'hFFFFFFFF);       // must be ignored
        rs1 = 5'd0; #2;
        expect1(rdata1, 32'h0, "x0 stays zero");

        write(5'd7,  32'h11111111);
        write(5'd9,  32'h22222222);
        rs1 = 5'd7; rs2 = 5'd9; #2;
        expect1(rdata1, 32'h11111111, "dual read port1");
        expect1(rdata2, 32'h22222222, "dual read port2");

        if (errors == 0) $display("ALL REGFILE TESTS PASSED");
        else             $display("%0d REGFILE TESTS FAILED", errors);
        $finish;
    end
endmodule
