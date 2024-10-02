# Makefile
export PYTHONPATH := $(PWD)/../:$(PYTHONPATH) 
# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
WAVES=1

VERILOG_SOURCES += $(PWD)/../../hdl/uart_rx.v
TOPLEVEL = uart_rx
MODULE = test_uart_rx

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
