# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
WAVES=1

VERILOG_SOURCES += $(PWD)/../hdl/uart_loopback.v
VERILOG_SOURCES += $(PWD)/../hdl/uart_tx.v
VERILOG_SOURCES += $(PWD)/../hdl/uart_rx.v
TOPLEVEL = uart_loopback
MODULE = test_uart_loopback

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
