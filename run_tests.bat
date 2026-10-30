@echo off
REM Run from the project folder. First time in a new window run:
REM   set PATH=C:\iverilog\bin;C:\iverilog\gtkwave\bin;%PATH%
if not exist sim mkdir sim
iverilog -g2012 -o sim\alu.out rtl\alu.v tb\tb_alu.v && vvp sim\alu.out
iverilog -g2012 -o sim\regfile.out rtl\regfile.v tb\tb_regfile.v && vvp sim\regfile.out
iverilog -g2012 -o sim\imm_gen.out rtl\imm_gen.v tb\tb_imm_gen.v && vvp sim\imm_gen.out
iverilog -g2012 -o sim\cpu.out rtl\alu.v rtl\regfile.v rtl\imm_gen.v rtl\control.v rtl\imem.v rtl\dmem.v rtl\cpu_single.v tb\tb_cpu_single.v && vvp sim\cpu.out
iverilog -g2012 -o sim\fpga_top.out rtl\alu.v rtl\regfile.v rtl\imm_gen.v rtl\control.v rtl\imem.v rtl\dmem.v rtl\cpu_single.v sim_models\vio_0_stub.v fpga\fpga_top.v tb\tb_fpga_top.v && vvp sim\fpga_top.out
echo.
echo Waveforms:  gtkwave sim\alu.vcd  /  sim\regfile.vcd  /  sim\imm_gen.vcd  /  sim\cpu_single.vcd
pause
