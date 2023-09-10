TOP_DIR := ../../
all:
	# Create C++ file from verilog design
	verilator -Wall --trace --cc $(TOP_DIR)/uart_tx.v --exe vuart_tx.cpp
	# Build object file for linking, create executable
	make -C obj_dir -f Vuart_tx.mk Vuart_tx
	./obj_dir/Vuart_tx
clean:
	rm -rf obj_dir/

