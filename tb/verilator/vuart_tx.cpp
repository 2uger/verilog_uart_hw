#include <stdio.h>
#include <stdlib.h>

#include "Vuart_tx.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "vuart_tx.h"

#define CLK_PER_BAUD 5

enum State {IDLE, FBIT, RECV, SBIT};
enum State rx_state = IDLE;
uint32_t clk_cnt = 0;
uint32_t bit_idx = 0;
char rx_val = 0;

void uart_rx(char rx)
{
    switch (rx_state) {
        case IDLE:
            if (rx == 0) {
                rx_state = FBIT;
                bit_idx = 0;
            }
            break;
        case FBIT:
            clk_cnt++;
            if (clk_cnt >= (CLK_PER_BAUD * 3 / 2)) {
                rx_val |= (rx << bit_idx);
                bit_idx++;
                rx_state = RECV;
                clk_cnt = 0;
            }
            break;
        case RECV:
            if (bit_idx >= 8) {
                rx_state = SBIT;
                clk_cnt = 0;
            } else {
                clk_cnt++;
                if (clk_cnt == CLK_PER_BAUD) {
                    rx_val |= (rx << bit_idx);
                    bit_idx++;
                    clk_cnt = 0;
                }
            }
            break;
        case SBIT:
            clk_cnt++;
            if (clk_cnt > CLK_PER_BAUD) {
                printf("Received data: %c\n", rx_val);
                rx_val = 0;
                rx_state = IDLE;
                clk_cnt = 0;
            }
            break;
    }
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    TESTB<Vuart_tx> *tb = new TESTB<Vuart_tx>;
    tb->opentrace("uart_tx_trace.vcd");

    int symbols_count = 0;
    tb->reset();
    tb->m_core->start_i = 1;
    char to_send[] = "Hello world!";
    for (int i = 0; i < sizeof(to_send) - 1; i++) {
        tb->m_core->send_data_i = to_send[i];
        tb->tick();
        while (!tb->m_core->done_o) {
            tb->tick();
            uart_rx(tb->m_core->d_o);
        }
    }
    printf("Simulation completed!\n");
    delete tb;
}
