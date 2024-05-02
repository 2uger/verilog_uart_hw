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
    reg [$clog2(CLKS_PER_BIT):0] timer_cnt;
    reg load_timer_cnt;

    reg [2:0] state = 3'b0;
    reg [2:0] next_state = 3'b0;
    localparam IDLE  = 3'b001;
    localparam START = 3'b011;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b110;

    reg [7:0] data      = 8'b0;
    reg [2:0] bit_idx   = 3'b0;

    always @(posedge clk) begin
        if (!resetn) begin
            state <= IDLE;
            timer_cnt <= CLKS_PER_BIT;
        end else begin
            state <= next_state;
            timer_cnt <= load_timer_cnt ? CLKS_PER_BIT : (timer_cnt - 1);
        end
    end

    always @* begin
        busy_o = 1'b1;
        tx_o   = 1'b1;

        case (state)
            IDLE: begin
                busy_o = 1'b0;
                tx_o      = 1;
                bit_idx   = 0;
                load_timer_cnt = 1;
                if (e_i) begin
                    tx_o = 0;
                    busy_o    = 1'b1;
                    data      = d_i;
                    next_state = START;
                end
            end
            START: begin
                load_timer_cnt = 0;
                /* Start bit. */
                tx_o = 0;
                /* Wait till start bit finish. */
                if (timer_cnt == 1) begin
                    load_timer_cnt = 1;
                    next_state = DATA;
                end
            end
            DATA: begin
                load_timer_cnt = 0;
                tx_o = data[bit_idx];
                if (timer_cnt == 0) begin
                    load_timer_cnt = 1;

                    next_state = bit_idx < 7 ? DATA : STOP;
                    bit_idx   = bit_idx < 7 ? bit_idx + 1 : 0;
                end
            end
            STOP: begin
                load_timer_cnt = 0;
                tx_o = 1;
                /* Wait till stop bit finish. */
                if (timer_cnt == 0) begin
                    next_state = IDLE;
                end
            end
            default:
                next_state = IDLE;
        endcase
    end
endmodule

