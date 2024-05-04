`timescale 1ns / 1ps

module uart_tx #(
    parameter CLKS_PER_BIT = 868
) (
    input clk,
    input resetn,

    input       e_i,
    input [7:0] d_i,

    output reg tx_o,
    output reg busy_o
);
    /* Count time between bits. */
    reg [$clog2(CLKS_PER_BIT):0] timer_cnt;
    reg load_timer_cnt;

    reg [2:0] state;
    reg [2:0] next_state;
    localparam IDLE  = 3'b001;
    localparam START = 3'b011;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b110;

    reg [7:0] data    = 8'b0;
    reg [2:0] bit_idx = 3'b0;
    reg shift_bit_idx;

    always @(posedge clk) begin
        if (!resetn) begin
            state     <= IDLE;
            timer_cnt <= CLKS_PER_BIT;
            bit_idx   <= 0;
        end else begin
            state     <= next_state;
            timer_cnt <= load_timer_cnt ? CLKS_PER_BIT : (timer_cnt - 1);
            bit_idx   <= shift_bit_idx ? bit_idx + 1 : bit_idx;
            data      <= e_i ? d_i : data;
        end
    end

    always @(*) begin
        load_timer_cnt = 0;
        busy_o        = 1;
        tx_o          = 1;
        shift_bit_idx = 0;
        case (state)
            IDLE: begin
                busy_o         = 0;
                tx_o           = 1;
                load_timer_cnt = 1;
                if (e_i) begin
                    tx_o       = 0;
                    next_state = START;
                end else begin
                    next_state = IDLE;
                end
            end
            /* Start bit. */
            START: begin
                load_timer_cnt = 0;
                tx_o           = 0;
                if (timer_cnt == 1) begin
                    load_timer_cnt = 1;
                    next_state     = DATA;
                end else begin
                    next_state = START;
                end
            end
            DATA: begin
                load_timer_cnt = 0;
                tx_o           = data[bit_idx];
                if (timer_cnt == 0) begin
                    load_timer_cnt = 1;
                    shift_bit_idx  = 1;
                    next_state     = (bit_idx < 7) ? DATA : STOP;
                end else begin
                    next_state = DATA;
                end
            end
            /* Stop bit. */
            STOP: begin
                load_timer_cnt = 0;
                tx_o           = 1;
                next_state     = (timer_cnt == 0) ? IDLE : STOP;
            end
            default:
                next_state = IDLE;
        endcase
    end
endmodule

