from random import randint

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

CLOCKS_PER_BIT = 4


@cocotb.test()
async def uart_tx_test(dut):
    """Try accessing the design."""

    cocotb.start_soon(Clock(dut.clk, 2, units='ns').start())

    await reset_dut(dut)

    for _ in range(100):
        data = ''.join([str(randint(0, 1)) for _ in range(8)])
        await send_tx_byte(dut, data)


async def wait_one_bit(dut):
    for _ in range(CLOCKS_PER_BIT):
        await RisingEdge(dut.clk)


async def reset_dut(dut):
    dut.resetn.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.resetn.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def send_tx_byte(dut, input_data):
    # IDLE state
    while True:
        if dut.active_o.value == 0:
            break
    assert dut.d_o.value == 1

    dut.start_i.value = 1
    dut.send_data_i.value = int(input_data[::-1], base=2)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.start_i.value = 0
    dut.send_data_i.value = 0

    # DATA state
    await wait_one_bit(dut)
    await RisingEdge(dut.clk)
    assert dut.d_o.value == 0

    output_data = ''
    for _ in range(len(input_data)):
        await RisingEdge(dut.clk)
        output_data += str(dut.d_o.value)
        await wait_one_bit(dut)

    assert output_data == input_data

    # STOP state
    await RisingEdge(dut.clk)
    assert dut.d_o.value == 1
    await wait_one_bit(dut)
    assert dut.done_o.value == 1

