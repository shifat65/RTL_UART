
baud:
	iverilog -o out_baud.vvp tb_baud_gen_16x.v counter.v baud_gen_16x.v
	vvp out_baud.vvp
tx:	
	iverilog -o out_tx.vvp tb_tx.v counter.v baud_gen_16x.v uart_tx.v
	vvp out_tx.vvp
rx:
	iverilog -o out_rx.vvp tb_rx.v counter.v baud_gen_16x.v uart_rx.v
	vvp out_rx.vvp
top:
	iverilog -o out_top.vvp top.v tb_top.v counter.v baud_gen_16x.v uart_tx.v uart_rx.v
	vvp out_top.vvp

g_baud:
	gtkwave --autosave tb_baud_gen_16x.vcd
g_tx:
	gtkwave --autosave tb_tx.vcd
g_rx:
	gtkwave --autosave tb_rx.vcd
g_top:
	gtkwave --autosave tb_top.vcd

clean:
	rm -f out_baud.vvp out_tx.vvp out_baud.vcd out_tx.vcd
	rm -f *.vvp *.vcd *.out