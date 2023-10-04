module uart_tx
#(parameter
    CLOCKS_PER_BIT = 128
)
(
    input clk, resetn,
    // Start transmitting
    input start_i,
    input [7:0] data_to_send_i,

    output reg serial_o,
    output reg active_o,
    output reg done_o
); 
        
    // Count time between bits
    reg [$clog2(CLOCKS_PER_BIT)-1:0] timer_cnt;
        
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
            timer_cnt <= {$clog2(CLOCKS_PER_BIT){1'b1}};

            serial_o <= 1;
            active_o <= 0;
            done_o   <= 0;
        end else begin
            case (fsm_state)
                IDLE: begin
                    serial_o  <= 1;
                    done_o    <= 0;
                    bit_idx   <= 0;
                    timer_cnt <= {$clog2(CLOCKS_PER_BIT){1'b1}};
                    
                    if (start_i) begin
                        active_o  <= 1'b1;
                        data      <= data_to_send_i;
                        fsm_state <= START;
                    end
                end
                // Start bit recieved, start transmit data
                START: begin
                    // Start bit
                    serial_o <= 0;
                    
                    // Wait till start bit finish
                    timer_cnt <= timer_cnt - 1;
                    if (timer_cnt == 0) begin
                        timer_cnt <= {$clog2(CLOCKS_PER_BIT){1'b1}};
                        fsm_state <= DATA;
                    end
                end
                DATA: begin
                    serial_o <= data[bit_idx];
                    
                    timer_cnt <= timer_cnt - 1;
                    if (timer_cnt == 0) begin
                        timer_cnt <= {$clog2(CLOCKS_PER_BIT){1'b1}};
                        fsm_state <= bit_idx < 7 ? DATA : STOP;
                        bit_idx   <= bit_idx < 7 ? bit_idx + 1 : 0;
                    end
                end
                STOP: begin
                    serial_o <= 1;
                    // Wait till stop bit finish
                    timer_cnt <= timer_cnt - 1;
                    if (timer_cnt == 0) begin
                        done_o    <= 1;
                        fsm_state <= IDLE;
                        active_o  <= 0;
                    end
                end
                default:
                    fsm_state <= IDLE;
            endcase					
        end
    end
endmodule 
