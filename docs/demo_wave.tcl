# GTKWave script: adds the demo signals and zooms to fit the whole run
set sigs [list tb_demo.clk tb_demo.rst tb_demo.sw_in tb_demo.pc tb_demo.instr tb_demo.alu_y tb_demo.x1_result]
gtkwave::addSignalsFromList $sigs
gtkwave::/Time/Zoom/Zoom_Full
