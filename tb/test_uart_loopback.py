from random import randint

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

CLKS_PER_BIT = 120

@cocotb.test()
async def uart_tx_test(dut):
    global CLKS_PER_BIT
    CLKS_PER_BIT = dut.CLKS_PER_BIT.value
    cocotb.start_soon(Clock(dut.clk, 2, units='ns').start())

    dut.tx_d_i.value = 102
    dut.tx_e_i.value = 1
    await reset_dut(dut)

    # Check reset works
    for _ in range(1000):
        await RisingEdge(dut.clk)

async def wait_one_bit(dut):
    for _ in range(CLKS_PER_BIT):
        await RisingEdge(dut.clk)

async def reset_dut(dut):
    dut.resetn.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.resetn.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

