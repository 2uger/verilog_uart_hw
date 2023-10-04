module uart_test(
    input clk,
    input rst,
    
    output serial_o,
    input serial_i,

    input [7:0] buttons,
    output [7:0] leds
);

    reg [1:0] fsm_state;
    localparam START = 1;
    localparam WAIT  = 2;

    reg [7:0] t_data_to_send;
    wire      t_active, t_done;
    reg       t_start_send;

    wire [7:0] r_data;
    wire       r_busy, r_done;

    reg [15:0] wait_cnt;

    always @(posedge clk) begin
        if (rst) begin
            fsm_state      <= START;
            t_start_send   <= 0;
            t_data_to_send <= 0;
        end else begin
            case (fsm_state)
                START: begin
                    if (!t_active) begin
                        t_start_send   <= 1;
                        t_data_to_send <= buttons;
                        fsm_state      <= WAIT;
                        wait_cnt       <= 555;
                    end
                end
                WAIT: begin
                    t_start_send <= 0;
                    wait_cnt     <= wait_cnt - 1;
                    fsm_state    <= wait_cnt ? WAIT : START;
                end
            endcase
        end
    end

    uart_tx uart_tx (
        .clk(clk),
        .resetn(~rst),

        .start_i(t_start_send),
        .data_to_send_i(t_data_to_send),

        .serial_o(serial_o),
        .active_o(t_active),
        .done_o(t_done)
    );

    assign leds = r_done ? ~r_data : leds;

    uart_rx uart_rx (
        .clk(clk),
        .resetn(~rst),
        
        .serial_i(serial_i),
        
        .recv_data_o(r_data),
        .busy_o(r_busy),
        .done_o(r_done)
    );
endmodule
