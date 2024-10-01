import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

from cocotbext.uart import UartSource, UartSink

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

async def uart_recv(uart_sink):
    while True:
        d = await uart_sink.read()
        print(f"Uart data: {d}")


@cocotb.test()
async def uart_tx_test(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units='ns').start())
    await reset_dut(dut)

    uart_sink = UartSink(dut.tx_o, baud=50000000, bits=8)

    for s in "Hello world from UART!":
        dut.d_i.value = ord(s)
        dut.e_i.value = 1
        d = await uart_sink.read()
        print(f"Uart data: {d}")

    return

    for d in "Hello":
        await uart_source.write(d.encode())

        await uart_source.wait()

        while not dut.rx_done_o.value:
            await RisingEdge(dut.clk)

        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)

        # Wait for transmitter
        while dut.tx_busy.value:
            await RisingEdge(dut.clk)

        #await Timer(1000, "ns")

    return


    
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

