import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

CLKS_PER_BIT = 120

async def wait_one_bit(dut):
    clks = CLKS_PER_BIT
    while clks:
        await RisingEdge(dut.clk)
        clks -= 1

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
    cocotb.start_soon(Clock(dut.clk, 2, units='ns').start())

    await reset_dut(dut)
    
    for d in "Hello":
        # Start bit
        dut.rx_i.value = 0
        await wait_one_bit(dut)

        # Data
        for b in (bin(ord(d))[2:])[::-1]:
            dut.rx_i.value = int(b)
            await wait_one_bit(dut)

        # Stop bit
        dut.rx_i.value = 1
        await wait_one_bit(dut)

        # Wait for receiver
        while not dut.rx_done_o.value:
            await RisingEdge(dut.clk)

        assert dut.uart_rx.d_o.value == ord(d)
    
    while not dut.tx_busy.value:
        await RisingEdge(dut.clk)

    while dut.tx_busy.value:
        await RisingEdge(dut.clk)

