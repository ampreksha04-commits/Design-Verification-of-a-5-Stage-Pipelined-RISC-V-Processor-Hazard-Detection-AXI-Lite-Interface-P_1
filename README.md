# 5-Stage Pipelined RISC-V Processor with Hazard Detection and AXI-Lite Interface

REVA University - Major Project Phase 1 | Team ECE_47 | Guide: Dr. Dilna U

Team: R23EN001 A M Preksha, R23EN013 Aditya S K, R23EN147 Shrisai Aski, R23EN148 Shrishail G Biradar

## Folder structure
| Folder | Purpose |
|---|---|
| `rtl/` | Verilog source (ALU, register file, later: pipeline, hazard unit, AXI-Lite) |
| `tb/`  | Testbenches |
| `sw/`  | RISC-V assembly programs (run in RARS) |
| `fpga/`| XDC constraints and Vivado notes |
| `docs/`| Report, waveforms, screenshots |
| `sim/` | Simulation outputs (ignored by git) |

## Run the tests (Icarus Verilog + GTKWave)
Linux/WSL/macOS: `make test`, then `make wave_alu` or `make wave_regfile`
Windows: double-click `run_tests.bat`, then `gtkwave sim\alu.vcd`

Expected: `ALL ALU TESTS PASSED` and `ALL REGFILE TESTS PASSED`.

## GTKWave tip
Left panel: expand `tb_alu` -> select `a`, `b`, `ctrl`, `y`, `zero` -> Append. Then Zoom Fit.

## Status
- [x] ALU + testbench
- [x] Register file + testbench
- [x] Immediate generator + testbench
- [x] Control unit, instruction memory, data memory
- [x] Single-cycle CPU (runs sw/fib.hex, checks x1 = 55)
- [x] FPGA top level + constraints; Fibonacci(n) on the Nexys A7-100T (n from switches; verified on the board)
- [x] n typed in Vivado Tcl (VIO) + 7-segment display + GTKWave (tested in simulation; see fpga/VIVADO_STEPS.md)
- [ ] 5-stage pipeline registers
- [ ] Forwarding unit + hazard detection unit
- [ ] AXI4-Lite master + slaves
- [ ] Verification, benchmarks, FPGA

Note: the line `WARNING: ... Not enough words in the file` when running the CPU test is harmless
(the program is shorter than the 256-word memory).
