import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge 

from uart_model.uart import UartSink

CLKS_PER_BIT = None

async def reset_dut(dut):
    dut.resetn.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.resetn.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

@cocotb.test()
async def uart_tx_test(dut):
    global CLKS_PER_BIT
    CLKS_PER_BIT = dut.CLKS_PER_BIT.value

    cocotb.start_soon(Clock(dut.clk, 1, units='ns').start())
    await reset_dut(dut)

    uart_sink = UartSink(dut.tx_o, baud=1e9 / CLKS_PER_BIT, bits=8)

    for s in "Hello world from UART!":
        dut.d_i.value = ord(s)
        dut.e_i.value = 1
        res = await uart_sink.read()
        print(res)
        #assert res.decode() == s

