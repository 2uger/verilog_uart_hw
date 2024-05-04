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
    (* mark_debug = "true" *) reg [$clog2(CLKS_PER_BIT):0] timer_cnt;
    (* mark_debug = "true" *) reg load_timer_cnt;

    (* mark_debug = "true" *) reg [2:0]  state;
    (* mark_debug = "true" *) reg [2:0]  next_state;
    localparam IDLE    = 3'b001;
    localparam START   = 3'b011;
    localparam DATA    = 3'b010;
    localparam STOP    = 3'b110;
    localparam CLEANUP = 3'b100;

    reg [2:0] bit_idx;
    reg shift_bit_idx;

    always @ (posedge clk) begin
        if (!resetn) begin
            state     <= IDLE;
            timer_cnt <= CLKS_PER_BIT;
            bit_idx   <= 0;
        end else begin
            state     <= next_state;
            timer_cnt <= load_timer_cnt ? CLKS_PER_BIT : timer_cnt - 1;
            bit_idx   <= shift_bit_idx ? bit_idx + 1 : bit_idx;
        end
    end

    always @ (posedge clk) begin
        if (!resetn) begin
            d_o <= 0;
        end else begin
            if (state == DATA) d_o[bit_idx] <= rx_i;
        end
    end

    always @(*) begin
        busy_o         = 1;
        done_o         = 0;
        shift_bit_idx  = 0;
        case (state)
            IDLE: begin
                load_timer_cnt = 1;
                busy_o         = 0;
                next_state     = (rx_i == 0) ? START : IDLE;
            end
            START: begin
                load_timer_cnt = 0;
                /* Check in the middle of the byte. */
                if (timer_cnt <= (CLKS_PER_BIT-1) / 2) begin
                    if (rx_i == 0) begin
                        load_timer_cnt = 1;
                        next_state     = DATA;
                    end else begin
                        next_state = IDLE;
                    end
                end else begin
                    next_state = START;
                end
            end
            DATA: begin
                load_timer_cnt = 0;
                if (timer_cnt == 0) begin
                    load_timer_cnt = 1;
                    shift_bit_idx  = 1;
                    next_state     = (bit_idx < 7) ? DATA : STOP;
                end else begin
                    next_state = DATA;
                end
            end
            STOP: begin
                load_timer_cnt = 0;
                busy_o         = 1;
                /* Wait for stop bit to finish */
                if (timer_cnt == 0) begin
                    load_timer_cnt = 1;
                    done_o         = 1;
                    next_state     = IDLE;
                end else begin
                    next_state = STOP;
                end
            end
            default: begin
                load_timer_cnt = 0;
                next_state     = IDLE;
            end
        endcase
    end
endmodule

