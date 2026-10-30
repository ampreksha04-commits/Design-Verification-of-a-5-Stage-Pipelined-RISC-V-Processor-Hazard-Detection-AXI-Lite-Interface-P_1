# Nexys A7-100T demo: Fibonacci(n), n typed in the Vivado Tcl Console

## How it works
- A VIO block (Vivado debug IP) inside the FPGA lets the Tcl Console set n while the board runs.
- The CPU restarts by itself whenever n changes. Result = Fibonacci(n).
- 7-segment display: left two digits = n, right five digits = result. LEDs show the result in binary.
- SW14 down = n from Tcl (normal demo).  SW14 up = n from switches SW0..SW4 (backup, no laptop needed).
- SW15 up = LEDs show the program counter instead of the result.  BTNC restarts the program.

## One-time setup (Vivado Tcl Console)
1. Copy docs/fibtools.tcl, docs/vio_setup.tcl, docs/demo_wave.tcl, tb/tb_demo.v into C:/Projects/demo/
2. Copy fpga/fpga_top.v and fpga/nexys_a7.xdc into the Vivado source folder.
   Do NOT add sim_models/vio_0_stub.v to Vivado (simulation only).
3. source C:/Projects/demo/vio_setup.tcl          (creates vio_0)
4. reset_run synth_1 ; launch_runs impl_1 -to_step write_bitstream -jobs 4 ; wait_on_run impl_1

## Every demo
    source C:/Projects/demo/fibtools.tcl
    prog_board
    run_fib 7        ;# any n = 0..24 -> board 7-segment + LEDs, and the GTKWave waveform

## Reports for the results slides
    file mkdir C:/Projects/reports
    open_run impl_1
    report_utilization -file C:/Projects/reports/utilization.txt
    report_timing_summary -file C:/Projects/reports/timing.txt
    report_power -file C:/Projects/reports/power.txt
