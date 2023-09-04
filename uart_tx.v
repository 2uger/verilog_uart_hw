module uart_tx # (parameter CLOCKS_PER_BIT = 4)
                 (input clk, resetn,
                  // Start transmitting
                  input start_i,
                  input [7:0] send_data_i,

                  output reg d_o,
                  output reg active_o,
                  output reg done_o); 
        
    reg [31:0] timer_cnt; // Count time between bits
        
    // States
    localparam IDLE = 1;
    localparam START = 2;
    localparam DATA = 3;
    localparam STOP = 4;

    reg [2:0] fsm_state = 3'b0;
    reg [7:0] data      = 8'b0;
    reg [2:0] bit_idx   = 3'b0;

    always @(posedge clk) begin
        if (!resetn) begin
            fsm_state <= IDLE;
            data      <= 0;
            bit_idx   <= 0;
            timer_cnt <= 0;

            d_o      <= 1;
            active_o <= 0;
            done_o   <= 0;
        end else begin
            case (fsm_state)
                IDLE: begin
                    d_o       <= 1;
                    done_o    <= 0;
                    bit_idx   <= 0;
                    timer_cnt <= 0;
                    
                    if (start_i) begin
                        active_o  <= 1'b1;
                        data      <= send_data_i;
                        fsm_state <= START;
                    end
                end
                // Start bit recieved, start transmit data
                START: begin
                    // Start bit
                    d_o <= 1'b0;
                    
                    // Wait till start bit finish
                    if (timer_cnt < CLOCKS_PER_BIT) begin
                        timer_cnt <= timer_cnt + 1;
                    end else begin
                        timer_cnt <= 0;
                        fsm_state <= DATA;
                    end
                end
                DATA: begin
                    d_o <= data[bit_idx];
                    
                    if (timer_cnt < CLOCKS_PER_BIT) begin
                        timer_cnt <= timer_cnt + 1;
                    end else begin
                        timer_cnt <= 0;
                        fsm_state <= bit_idx < 7 ? DATA : STOP;
                        bit_idx <= bit_idx < 7 ? bit_idx + 1 : 0;
                    end
                end
                STOP: begin
                    d_o <= 1;
                    // Wait till stop bit finish
                    if (timer_cnt < CLOCKS_PER_BIT) begin
                        timer_cnt <= timer_cnt + 1;
                    end else begin
                        done_o    <= 1;
                        timer_cnt <= 0;
                        fsm_state     <= IDLE;
                        active_o    <= 0;
                    end
                end
                default:
                    fsm_state <= IDLE;
            endcase					
        end
    end
endmodule 
