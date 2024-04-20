Tiny verilog UART implementation and scripts to run it on real hardware.
#### Real hardware(Xilinx Artix-35T FPGA):
Make sure Vivado in your $PATH variable and just run **make build**.  
You will find your **bit file** in ``vivado_build/build/products``.
After programming device, just connect cable to on-board micro-usb port.
#### Run tests:
```sh
python3 -m venv .venv
source .venv/bin/activate
pip install cocotb
make test
deactivate
```
