module uart_test(
    input clk,
    input resetn,

    output tx_o,
    input rx_i
);
    wire tx_enable;
    wire tx_busy;
    wire [7:0] data;

    wire rx_busy;

    uart_tx uart_tx (
        .clk(clk),
        .resetn(resetn),

        .e_i(tx_enable),
        .d_i(data),

        .tx_o(tx_o),
        .busy_o(tx_busy)
    );

    uart_rx uart_rx (
        .clk(clk),
        .resetn(resetn),

        .rx_i(rx_i),

        .d_o(data),
        .busy_o(rx_busy),
        .done_o(tx_done)
    );
endmodule
