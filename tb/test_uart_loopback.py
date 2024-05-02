import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

CLKS_PER_BIT = 120
TEST_VALUE = 102

@cocotb.test()
async def uart_tx_test(dut):
    global CLKS_PER_BIT
    CLKS_PER_BIT = dut.CLKS_PER_BIT.value
    cocotb.start_soon(Clock(dut.clk, 2, units='ns').start())

    dut.tx_d_i.value = TEST_VALUE
    dut.tx_e_i.value = 1
    await reset_dut(dut)

    while not dut.rx_done_o.value:
        await RisingEdge(dut.clk)

    assert dut.rx_d_o.value == TEST_VALUE

async def reset_dut(dut):
    dut.resetn.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.resetn.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

