`timescale 1ns / 1ps

module uart_rx #(
    parameter CLKS_PER_BIT = 868
) (input clk,
   input resetn,

   input rx_i,

   output reg [7:0] d_o,
   output reg       busy_o,
   output reg       done_o
);
    reg [$clog2(CLKS_PER_BIT)-1:0] timer_cnt;

    reg [2:0]  fsm_state;
    localparam IDLE    = 1;
    localparam START   = 2;
    localparam DATA    = 3;
    localparam STOP    = 4;
    localparam CLEANUP = 5;

    reg [2:0] bit_idx;

    always @ (posedge clk) begin
        if (!resetn) begin
            fsm_state <= IDLE;
            timer_cnt <= CLKS_PER_BIT;
            bit_idx   <= 0;

            d_o    <= 0;
            busy_o <= 0;
            done_o <= 0;
        end else begin
            case (fsm_state)
                IDLE: begin
                    busy_o <= 0;
                    done_o <= 0;
                    if (rx_i == 0) begin
                        fsm_state <= START;
                        timer_cnt <= CLKS_PER_BIT;
                        busy_o    <= 1;
                    end
                end
                START: begin
                    /* Check in the middle of the byte. */
                    if (timer_cnt <= (CLKS_PER_BIT-1) / 2) begin
                        if (rx_i == 0) begin
                            timer_cnt <= CLKS_PER_BIT;
                            fsm_state <= DATA;
                        end else
                            fsm_state <= IDLE;
                        end
                    else begin
                        timer_cnt <= timer_cnt - 1;
                    end
                end
                DATA: begin
                    timer_cnt <= timer_cnt - 1;
                    if (!timer_cnt) begin
                        d_o[bit_idx] <= rx_i;
                        timer_cnt    <= CLKS_PER_BIT;

                        if (bit_idx < 7) begin
                            fsm_state <= DATA;
                            bit_idx   <= bit_idx + 1;
                        end else begin
                            fsm_state <= STOP;
                            bit_idx   <= 0;
                        end
                    end
                end
                STOP: begin
                    busy_o <= 0;
                    /* Wait for stop bit to finish */
                    timer_cnt <= timer_cnt - 1;
                    if (!timer_cnt) begin
                        timer_cnt <= CLKS_PER_BIT;
                        done_o    <= 1;
                        fsm_state <= IDLE;
                    end
                end
                default: begin
                    fsm_state <= IDLE;
                end
            endcase
        end
    end
endmodule

