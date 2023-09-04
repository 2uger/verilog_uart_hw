module tb;
    reg [31:0] clk_counter = 0;
    reg clk = 0;

    always  begin
        #10 clk = !clk;
    end

    reg [7:0] data;
    reg start = 0;

    wire q;
    wire active;
    wire done;

    always @(posedge clk) begin
        if (clk_counter == 1) begin
            $display("Output is %b, is active: %b, done: %b", q, active, done);
            clk_counter <= 0;
        end
        else begin
            clk_counter <= clk_counter + 1;
        end
    end

    initial begin
        data = 8'b10111010;
        $display("Data to transmit %b", data);
        start = 1;
        $display("Make start bit %b", start);
        # 31
        start = 0;

        # 500
        $stop;
    end

    uart_tx tx(.clk(clk),
               .start_bit(start),
               .extern_data(data),
               .out(q),
               .o_active(active),
               .o_done(done));

endmodule
