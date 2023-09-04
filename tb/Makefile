# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
WAVES=1

VERILOG_SOURCES += $(PWD)/../uart_tx.v
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = uart_tx

# MODULE is the basename of the Python test file
MODULE = test_uart_tx

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
