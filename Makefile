# Usage: make test | make wave_cpu | make clean
IVFLAGS = -g2012

test: alu regfile imm_gen cpu fpga_top

alu:
	@mkdir -p sim
	iverilog $(IVFLAGS) -o sim/alu.out rtl/alu.v tb/tb_alu.v
	vvp sim/alu.out

regfile:
	@mkdir -p sim
	iverilog $(IVFLAGS) -o sim/regfile.out rtl/regfile.v tb/tb_regfile.v
	vvp sim/regfile.out

imm_gen:
	@mkdir -p sim
	iverilog $(IVFLAGS) -o sim/imm_gen.out rtl/imm_gen.v tb/tb_imm_gen.v
	vvp sim/imm_gen.out

cpu:
	@mkdir -p sim
	iverilog $(IVFLAGS) -o sim/cpu.out rtl/alu.v rtl/regfile.v rtl/imm_gen.v rtl/control.v rtl/imem.v rtl/dmem.v rtl/cpu_single.v tb/tb_cpu_single.v
	vvp sim/cpu.out

fpga_top:
	@mkdir -p sim
	iverilog $(IVFLAGS) -o sim/fpga_top.out rtl/alu.v rtl/regfile.v rtl/imm_gen.v rtl/control.v rtl/imem.v rtl/dmem.v rtl/cpu_single.v sim_models/vio_0_stub.v fpga/fpga_top.v tb/tb_fpga_top.v
	vvp sim/fpga_top.out

wave_alu: alu
	gtkwave sim/alu.vcd
wave_cpu: cpu
	gtkwave sim/cpu_single.vcd

clean:
	rm -f sim/*.out sim/*.vcd

wave_demo:
	@mkdir -p sim
	iverilog $(IVFLAGS) -o sim/demo.out rtl/alu.v rtl/regfile.v rtl/imm_gen.v rtl/control.v rtl/imem.v rtl/dmem.v rtl/cpu_single.v tb/tb_demo.v
	vvp sim/demo.out +N=$(or $(N),10)
	gtkwave sim/demo.vcd -S docs/demo_wave.tcl
