// Top level for Nexys A7-100T: single-cycle CPU computing Fibonacci(n)
//   n comes from the Vivado Tcl Console (VIO block)   when SW14 = 0   <- normal demo
//   n comes from switches SW0..SW4                      when SW14 = 1
//   7-segment display: left two digits = n, right five digits = result in decimal
//   LEDs: result in binary (SW15 = 1 shows the program counter instead)
//   BTNC restarts the program; the program also restarts by itself whenever n changes
module fpga_top #(parameter IMEM_FILE = "sw/fib.hex",
                  parameter SCAN = 17) (       // display scan speed: 17 on the board (about 95 Hz); smaller = faster (simulation)
    input         clk,        // 100 MHz board clock
    input         btnc,
    input  [15:0] sw,
    output [15:0] led,
    output [6:0]  seg,        // CA..CG (a..g), active low
    output        dp,
    output [7:0]  an          // digit enables, active low
);
    // ---------------- CPU clock (12.5 MHz) ----------------
    reg [2:0] div = 3'b0;
    always @(posedge clk) div <= div + 1'b1;
    wire cpu_clk = div[2];

    // ---------------- inputs ----------------
    wire [4:0] vio_n;                                   // number typed in the Vivado Tcl Console
    vio_0 u_vio (.clk(clk), .probe_out0(vio_n));

    reg [1:0]  rs = 2'b0;
    reg [15:0] sw_s1 = 16'b0, sw_s2 = 16'b0;
    reg [4:0]  vio_s1 = 5'b0, vio_s2 = 5'b0;
    always @(posedge cpu_clk) begin
        rs <= {rs[0], btnc};
        sw_s1 <= sw;    sw_s2 <= sw_s1;
        vio_s1 <= vio_n; vio_s2 <= vio_s1;
    end
    wire [4:0] n_sel = sw_s2[14] ? sw_s2[4:0] : vio_s2;

    // ---------------- reset: power-on, button, and "n changed" ----------------
    reg [3:0] por = 4'b0;
    always @(posedge cpu_clk) if (por != 4'hF) por <= por + 1'b1;
    reg [4:0] n_prev = 5'b0;
    reg [3:0] hold = 4'b0;
    always @(posedge cpu_clk) begin
        n_prev <= n_sel;
        if (n_sel != n_prev) hold <= 4'd15;
        else if (hold != 4'd0) hold <= hold - 1'b1;
    end
    wire rst = rs[1] | (por != 4'hF) | (hold != 4'd0);

    // ---------------- CPU ----------------
    wire [31:0] x1, pc;
    cpu_single #(.IMEM_FILE(IMEM_FILE)) u_cpu (.clk(cpu_clk), .rst(rst), .sw_in({11'b0, n_sel}),
                                                .dbg_x1(x1), .dbg_pc(pc));
    assign led = sw_s2[15] ? pc[15:0] : x1[15:0];

    // ---------------- 7-segment display ----------------
    wire [15:0] v = x1[15:0];
    wire [3:0] r4 = v / 10000;
    wire [3:0] r3 = (v / 1000) % 10;
    wire [3:0] r2 = (v / 100) % 10;
    wire [3:0] r1 = (v / 10) % 10;
    wire [3:0] r0 = v % 10;
    wire [3:0] n1 = n_sel / 10;
    wire [3:0] n0 = n_sel % 10;

    reg [23:0] refcnt = 24'b0;                          // SCAN = 17: about 95 Hz full scan of 8 digits
    always @(posedge clk) refcnt <= refcnt + 1'b1;
    wire [2:0] sel = refcnt[SCAN +: 3];

    reg [3:0] digit;
    reg       show;
    always @* begin
        digit = 4'd0; show = 1'b0;
        case (sel)
            3'd0: begin digit = r0; show = 1'b1; end
            3'd1: begin digit = r1; show = (v >= 10);    end
            3'd2: begin digit = r2; show = (v >= 100);   end
            3'd3: begin digit = r3; show = (v >= 1000);  end
            3'd4: begin digit = r4; show = (v >= 10000); end
            3'd5: begin digit = 4'd0; show = 1'b0; end
            3'd6: begin digit = n1; show = (n_sel >= 10); end
            3'd7: begin digit = n0; show = 1'b1; end
        endcase
    end

    reg [6:0] pat;                                      // {g,f,e,d,c,b,a}, 0 = lit
    always @* begin
        case (digit)
            4'd0: pat = 7'b1000000;
            4'd1: pat = 7'b1111001;
            4'd2: pat = 7'b0100100;
            4'd3: pat = 7'b0110000;
            4'd4: pat = 7'b0011001;
            4'd5: pat = 7'b0010010;
            4'd6: pat = 7'b0000010;
            4'd7: pat = 7'b1111000;
            4'd8: pat = 7'b0000000;
            4'd9: pat = 7'b0010000;
            default: pat = 7'b1111111;
        endcase
    end
    assign seg = show ? pat : 7'b1111111;
    assign an  = ~(8'b00000001 << sel);
    assign dp  = 1'b1;
endmodule
