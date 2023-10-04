#include <stdio.h>
#include <stdlib.h>

#include "Vuart_tx.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "vuart_tx.h"

#define CLK_PER_BAUD 16

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
        tb->m_core->data_to_send_i = to_send[i];
        tb->tick();
        while (!tb->m_core->done_o) {
            tb->tick();
        }
    }
    printf("\n*****************\n");
    printf("All tests passed!\n");
    printf("Simulation completed!\n");
    printf("*****************\n");
    delete tb;
}
