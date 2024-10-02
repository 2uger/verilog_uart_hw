import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge 

from uart_model.uart import UartSource

CLKS_PER_BIT = None

async def reset_dut(dut):
    dut.resetn.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.resetn.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

@cocotb.test()
async def uart_rx_test(dut):
    global CLKS_PER_BIT
    CLKS_PER_BIT = dut.CLKS_PER_BIT.value

    cocotb.start_soon(Clock(dut.clk, 1, units='ns').start())
    await reset_dut(dut)

    uart_source = UartSource(dut.rx_i, baud=1e9 / CLKS_PER_BIT, bits=8)

    for s in "Hello world from UART!":
        await uart_source.write([ord(s)])
        await uart_source.wait()
        assert s == chr(dut.d_o.value.integer)

