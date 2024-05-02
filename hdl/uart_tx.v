`timescale 1ns / 1ps

module uart_tx #(
    parameter CLKS_PER_BIT = 4
) (
    input clk,
    input resetn,

    input       e_i,
    input [7:0] d_i,

    output reg tx_o,
    output reg busy_o
);
    /* Count time between bits. */
    reg [$clog2(CLKS_PER_BIT)-1:0] timer_cnt;

    reg [2:0] fsm_state = 3'b0;
    localparam IDLE = 1;
    localparam START = 2;
    localparam DATA = 3;
    localparam STOP = 4;

    reg [7:0] data      = 8'b0;
    reg [2:0] bit_idx   = 3'b0;

    always @(posedge clk) begin
        if (!resetn) begin
            fsm_state <= IDLE;
            data      <= 0;
            bit_idx   <= 0;
            timer_cnt <= CLKS_PER_BIT;

            tx_o   <= 1;
            busy_o <= 0;
        end else begin
            case (fsm_state)
                IDLE: begin
                    tx_o      <= 1;
                    bit_idx   <= 0;
                    timer_cnt <= CLKS_PER_BIT;
                    if (e_i) begin
                        busy_o    <= 1'b1;
                        data      <= d_i;
                        fsm_state <= START;
                    end
                end
                START: begin
                    /* Start bit. */
                    tx_o <= 0;
                    /* Wait till start bit finish. */
                    timer_cnt <= timer_cnt - 1;
                    if (timer_cnt == 0) begin
                        timer_cnt <= CLKS_PER_BIT;
                        fsm_state <= DATA;
                    end
                end
                DATA: begin
                    tx_o <= data[bit_idx];
                    timer_cnt <= timer_cnt - 1;
                    if (timer_cnt == 0) begin
                        timer_cnt <= CLKS_PER_BIT;
                        fsm_state <= bit_idx < 7 ? DATA : STOP;
                        bit_idx   <= bit_idx < 7 ? bit_idx + 1 : 0;
                    end
                end
                STOP: begin
                    tx_o <= 1;
                    /* Wait till stop bit finish. */
                    timer_cnt <= timer_cnt - 1;
                    if (timer_cnt == 0) begin
                        fsm_state <= IDLE;
                        busy_o    <= 0;
                    end
                end
                default:
                    fsm_state <= IDLE;
            endcase
        end
    end
endmodule

