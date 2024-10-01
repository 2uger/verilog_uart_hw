`timescale 1ns / 1ps

module uart_tx #(
    parameter CLKS_PER_BIT = 20
) (
    input clk,
    input resetn,

    input       e_i,
    input [7:0] d_i,

    output wire tx_o,
    output reg busy_o,
    output reg done_o
);
    /* Count time between bits. */
    reg [$clog2(CLKS_PER_BIT):0] timer_cnt;

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
            bit_idx   <= 0;
        end else begin
            state     <= next_state;
            bit_idx   <= shift_bit_idx ? bit_idx + 1 : bit_idx;
            data      <= e_i ? d_i : data;
        end
    end

    assign tx_o = (state == DATA) ? data[bit_idx] : (state == START) ? 0 : 1;

    always @(posedge clk) begin
        if (!resetn) begin
            timer_cnt <= CLKS_PER_BIT;
        end else begin
            case (state)
                IDLE:    timer_cnt <= CLKS_PER_BIT;
                START:   timer_cnt <= (timer_cnt == 1) ? CLKS_PER_BIT : timer_cnt - 1;
                DATA:    timer_cnt <= (timer_cnt == 0) ? CLKS_PER_BIT : timer_cnt - 1;
                STOP:    timer_cnt <= timer_cnt - 1;
                default: timer_cnt <= CLKS_PER_BIT;
            endcase
        end
    end

    always @(*) begin
        busy_o        = 1;
        done_o        = 0;
        shift_bit_idx = 0;
        case (state)
            IDLE: begin
                done_o     = 1;
                busy_o     = 0;
                next_state = e_i ? START : IDLE;
            end
            /* Start bit. */
            START: begin
                next_state = (timer_cnt == 1) ? DATA : START;
            end
            DATA: begin
                shift_bit_idx = (timer_cnt == 0) ? 1 : 0;
                next_state    = (timer_cnt == 0) ? ((bit_idx < 7) ? DATA : STOP) : DATA;
            end
            /* Stop bit. */
            STOP: begin
                next_state = (timer_cnt == 0) ? IDLE : STOP;
            end
            default:
                next_state = IDLE;
        endcase
    end
endmodule
