`timescale 1ns / 1ps

module uart_loopback #(
    parameter CLKS_PER_BIT = 9
) (
    input clk,
    input resetn,

    input [7:0] tx_d_i,
    input tx_e_i,
    output tx_busy_o,

    output [7:0] rx_d_o,
    output rx_busy_o,
    output rx_done_o
);
    wire tx_o;

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_tx (
        .clk(clk),
        .resetn(resetn),

        .e_i(tx_e_i),
        .d_i(tx_d_i),

        .tx_o(tx_o),
        .busy_o(tx_busy_o)
    );

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_rx (
        .clk(clk),
        .resetn(resetn),

        .rx_i(tx_o),

        .d_o(rx_d_o),
        .busy_o(rx_busy_o),
        .done_o(rx_done_o)
    );
endmodule

