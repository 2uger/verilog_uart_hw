`timescale 1ns / 1ps

module uart_loopback #(
    parameter CLKS_PER_BIT = 868
) (
    input clk,
    input resetn,

    (* mark_debug = "true" *) output tx_o,
    (* mark_debug = "true" *) input  rx_i
);
    (* mark_debug = "true" *) wire rx_done;
    (* mark_debug = "true" *) wire tx_busy;
    (* mark_debug = "true" *) wire [7:0] data;

    (* mark_debug = "true" *) wire rx_busy;

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_tx (
        .clk(clk),
        .resetn(resetn),

        .e_i(rx_done),
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
        .done_o(rx_done)
    );
endmodule
