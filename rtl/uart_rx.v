module uart_rx
#(parameter
    CLOCKS_PER_BIT = 256
)
(
    input clk, resetn,
    input serial_i,

    output reg [7:0] recv_data_o,
    output reg busy_o,
    output reg done_o
);
    
    reg [2:0]  fsm_state;
    localparam IDLE    = 1;
    localparam START   = 2;
    localparam DATA    = 3;
    localparam STOP    = 4;
    localparam CLEANUP = 5;

    reg [2:0]  bit_idx;
    reg [$clog2(CLOCKS_PER_BIT)-1:0] timer_cnt;
    
    always @ (posedge clk) begin
        if (!resetn) begin
            fsm_state <= IDLE;
            timer_cnt <= {$clog2(CLOCKS_PER_BIT){1'b1}};
            bit_idx   <= 0;

            recv_data_o <= 0;
            busy_o      <= 0;
            done_o      <= 0;
        end else begin
            case (fsm_state)
                IDLE: begin
                    busy_o <= 0;
                    done_o <= 0;
                    if (!serial_i) begin
                        fsm_state <= START;
                        timer_cnt <= {$clog2(CLOCKS_PER_BIT){1'b1}};
                    end 
                end
                START: begin
                    busy_o <= 1;
                    // Check in the middle of byte
                    if (timer_cnt <= (CLOCKS_PER_BIT-1) / 2) begin
                        if (serial_i == 0) begin
                            timer_cnt <= {$clog2(CLOCKS_PER_BIT){1'b1}};
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
                        recv_data_o[bit_idx] <= serial_i;
                        timer_cnt            <= {$clog2(CLOCKS_PER_BIT){1'b1}};

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
                    // Wait for stop bit to finish
                    timer_cnt <= timer_cnt - 1;
                    if (!timer_cnt) begin
                        timer_cnt <= {$clog2(CLOCKS_PER_BIT){1'b1}};
                        done_o    <= 1;
                        fsm_state <= IDLE;
                    end
                end
            endcase							
        end
    end	
endmodule 
