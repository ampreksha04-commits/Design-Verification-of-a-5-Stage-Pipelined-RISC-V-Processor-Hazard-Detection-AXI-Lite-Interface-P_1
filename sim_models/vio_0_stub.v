// SIMULATION ONLY. In Vivado the real vio_0 IP is used (do NOT add this file to the Vivado project).
module vio_0 (input clk, output [4:0] probe_out0);
    reg [4:0] v = 5'd0;           // the testbench writes this register to imitate typing a number in Tcl
    assign probe_out0 = v;
endmodule
