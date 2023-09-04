module tb;
    
    reg clk = 0;
    always #5 clk = !clk;

    reg serial;
    wire [7:0] data;

    wire done;

    uart_rx rx(.clk(clk),
               .serial(serial),
               .o_data(data),
               .o_done(done));

    reg [7:0] i_data;
    reg [2:0] index = 3'b0;
    reg [31:0] clk_counter = 0;

    //always @(posedge clk) begin
    //    if (start_send) begin
    //        serial <= i_data[index];
    //        if (clk_counter < 3) begin
    //            clk_counter <= clk_counter + 1;
    //        end
    //        else begin
    //            if (index < 7) begin
    //                $display("Sending: %b", i_data[index]);
    //                index <= index + 1;
    //            end
    //            else begin
    //                index <= 3'b0;
    //                clk_counter <= 0;
    //            end
    //        end
    //    end
    //end

    initial begin
        // Bullshit method to test uart reciever, need actually to understand
        // how clocks counters will work inside
        i_data = 8'b10111011;
        $display("Data to send %b", i_data);
        serial = 0;
        # 65 
        serial = 1;
        $display("Send %b", serial);
        # 30 
        serial = 1;
        $display("Send %b", serial);
        # 30
        serial = 0;
        $display("Send %b", serial);
        # 30
        serial = 1;
        $display("Send %b", serial);
        # 30
        serial = 1;
        $display("Send %b", serial);
        # 30
        serial = 1;
        $display("Send %b", serial);
        # 30
        serial = 0;
        $display("Send %b", serial);
        # 30
        serial = 1;
        $display("Send %b", serial);
        # 50
        $display("Actually what we got after sending whole data: %b", data);
        $stop;
    end

endmodule
