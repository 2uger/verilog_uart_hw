`timescale 1ns / 1ps

module uart_loopback #(
    parameter CLKS_PER_BIT = 868
) (
    input clk,
    input resetn,

    output tx_o,
    input  rx_i
);
    wire tx_busy;
    wire [7:0] data;

    wire rx_busy;
    wire rx_done_o;
    wire [7:0] rx_d_o;

    uart_tx uart_tx (
        .clk(clk),
        .reset(!resetn),

        .e_i(rx_done_o),
        .d_i(data),

        .tx_o(tx_o),
        .busy_o(tx_busy)
    );

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_rx (
        .clk(clk),
        .resetn(resetn),

        .rx_i(rx_i),

        .d_o(data),
        .busy_o(rx_busy),
        .done_o(rx_done_o)
    );
endmodule
