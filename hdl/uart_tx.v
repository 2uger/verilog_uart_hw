// Generator : SpinalHDL v1.10.2a    git head : a348a60b7e8b6a455c72e1536ec3d74a2ea16935
// Component : UartTx
// Git hash  : 979bc248ed5ada4589c24995801dbe70a1be69cb

`timescale 1ns/1ps

module uart_tx (
  input  wire          e_i,
  input  wire [7:0]    d_i,
  output reg           tx_o,
  output reg           busy_o,
  output reg           done_o,
  input  wire          clk,
  input  wire          reset
);
  localparam UartState_idle = 2'd0;
  localparam UartState_start = 2'd1;
  localparam UartState_data = 2'd2;
  localparam UartState_stop = 2'd3;

  reg        [1:0]    state;
  reg        [7:0]    data;
  reg        [2:0]    bitIdx;
  reg                 shiftBitIdx;
  wire                when_UartTx_l34;
  wire                when_UartTx_l37;
  reg        [9:0]    timerCnt_counter;
  wire                when_UartTx_l48;
  wire                when_UartTx_l51;
  wire                when_UartTx_l50;
  wire                when_UartTx_l74;
  wire                when_UartTx_l79;
  wire                when_UartTx_l81;
  wire                when_UartTx_l89;
  `ifndef SYNTHESIS
  reg [39:0] state_string;
  `endif


  `ifndef SYNTHESIS
  always @(*) begin
    case(state)
      UartState_idle : state_string = "idle ";
      UartState_start : state_string = "start";
      UartState_data : state_string = "data ";
      UartState_stop : state_string = "stop ";
      default : state_string = "?????";
    endcase
  end
  `endif

  assign when_UartTx_l34 = (state == UartState_data);
  always @(*) begin
    if(when_UartTx_l34) begin
      tx_o = data[bitIdx];
    end else begin
      if(when_UartTx_l37) begin
        tx_o = 1'b0;
      end else begin
        tx_o = 1'b1;
      end
    end
  end

  assign when_UartTx_l37 = (state == UartState_start);
  assign when_UartTx_l48 = (state == UartState_idle);
  assign when_UartTx_l51 = (timerCnt_counter == 10'h0);
  assign when_UartTx_l50 = ((state == UartState_start) || (state == UartState_data));
  always @(*) begin
    done_o = 1'b1;
    case(state)
      UartState_idle : begin
        done_o = 1'b1;
      end
      UartState_start : begin
      end
      UartState_data : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    busy_o = 1'b0;
    case(state)
      UartState_idle : begin
        busy_o = 1'b0;
      end
      UartState_start : begin
      end
      UartState_data : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UartTx_l74 = (timerCnt_counter == 10'h0);
  assign when_UartTx_l79 = (timerCnt_counter == 10'h0);
  assign when_UartTx_l81 = (3'b111 <= bitIdx);
  assign when_UartTx_l89 = (timerCnt_counter == 10'h0);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      state <= UartState_idle;
      data <= 8'h0;
      bitIdx <= 3'b000;
      shiftBitIdx <= 1'b0;
      timerCnt_counter <= 10'h364;
    end else begin
      if(shiftBitIdx) begin
        bitIdx <= (bitIdx + 3'b001);
      end
      timerCnt_counter <= (timerCnt_counter - 10'h001);
      if(when_UartTx_l48) begin
        timerCnt_counter <= 10'h364;
      end else begin
        if(when_UartTx_l50) begin
          if(when_UartTx_l51) begin
            timerCnt_counter <= 10'h364;
          end
        end
      end
      case(state)
        UartState_idle : begin
          if(e_i) begin
            data <= d_i;
            state <= UartState_start;
          end
        end
        UartState_start : begin
          if(when_UartTx_l74) begin
            state <= UartState_data;
          end
        end
        UartState_data : begin
          if(when_UartTx_l79) begin
            shiftBitIdx <= 1'b1;
            if(when_UartTx_l81) begin
              state <= UartState_stop;
            end
          end else begin
            shiftBitIdx <= 1'b0;
          end
        end
        default : begin
          if(when_UartTx_l89) begin
            state <= UartState_idle;
          end
        end
      endcase
    end
  end


endmodule
