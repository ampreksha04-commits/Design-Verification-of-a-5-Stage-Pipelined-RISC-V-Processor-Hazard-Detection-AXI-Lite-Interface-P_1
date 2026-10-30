@echo off
REM One-click waveform demo.   Usage:  demo_wave.bat 7      (n = 7; default n = 10, allowed 0..24)
REM If gtkwave is not found, first run in this window:
REM   set PATH=C:\iverilog\bin;C:\iverilog\gtkwave\bin;%PATH%
set N=%1
if "%N%"=="" set N=10
if not exist sim mkdir sim
iverilog -g2012 -o sim\demo.out rtl\alu.v rtl\regfile.v rtl\imm_gen.v rtl\control.v rtl\imem.v rtl\dmem.v rtl\cpu_single.v tb\tb_demo.v
vvp sim\demo.out +N=%N%
gtkwave sim\demo.vcd -S docs\demo_wave.tcl
