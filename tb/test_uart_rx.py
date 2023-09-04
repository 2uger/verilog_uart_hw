from random import randint

import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.clock import Clock

CLOCKS_PER_BIT = 4


@cocotb.test()
async def uart_rx_test(dut):
    cocotb.start_soon(Clock(dut.clk, 2, units='ns').start())

    await reset_dut(dut)
    # Check reset works
    for _ in range(100):
        data = ''.join([str(randint(0, 1)) for _ in range(8)])
        #data = '01100110'
        await recv_rx_byte(dut, data)


async def wait_one_bit(dut):
    for _ in range(CLOCKS_PER_BIT):
        await RisingEdge(dut.clk)


async def reset_dut(dut):
    # Reset dut
    dut.resetn.value = 0;
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.resetn.value = 1;
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def recv_rx_byte(dut, input_data):
    dut.serial_i.value = 1
    # IDLE state
    while True:
        if dut.busy_o.value == 0:
            break

    # Start bit
    dut.serial_i.value = 0
    await wait_one_bit(dut)

    for v in input_data:
        dut.serial_i.value = int(v)
        await wait_one_bit(dut)

    # Stop bit
    dut.serial_i.value = 1
    await wait_one_bit(dut)

    assert dut.data_o.value == int(input_data[::-1], base=2)
