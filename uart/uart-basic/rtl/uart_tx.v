/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/*
    File                :   uart_tx.v
    Top-level entity    :   uart_tx
    Function            :   UART transmitter module; Works on 50MHz internal clock
                            By default baud rate set to 115200;
    
    Ports   : Inputs    :   clk_50M - 50MHz internal clock from the FPGA
                        :   i_data_avail - when 1 (high) signifies data is valid on input data line
                        :   i_data_byte - 8-bit data bus
            : Outputs   :   o_Tx - transmitter output line
                        :   o_busy - signifies data transmission in progress; transmitter busy
                        :   o_done - signifies data transmission complete; ready to send next byte
    
    Author  :   Sujeet Jagtap
    Date    :   09/08/2024
    
*/
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

module uart_tx #(parameter CLKS_PER_BIT = 434) (
  input clk_50M,
  input [7:0] i_data_byte,
  input i_data_avail,
  output o_Tx,
  output o_busy,
  output o_done
);
  
  /* State Declaration */
  localparam IDLE_STATE = 2'b00, START_STATE = 2'b01, SEND_BIT_STATE = 2'b10, STOP_STATE = 2'b11;
  
  /* Register Declaration */
  reg [1:0] state = IDLE_STATE;
  reg [15:0] counter = 0;
  reg [2:0] bit_index = 0;
  reg [7:0] data_byte = 0;
  reg tx = 1;
  reg busy = 0;
  reg done = 0;
  
  /* Assign outputs */
  assign o_Tx = tx;
  assign o_busy = busy;
  assign o_done = done;
  
  /* STATE Transition & Controls (Synchronous) */
  always @ (posedge clk_50M) begin
    
    case (state)
      
      IDLE_STATE: begin // Keep the Tx high as this is active low protocol;
        tx <= 1;
        done = 0;
        counter <= 0;
        busy <= 0;
        bit_index <= 0;
        if (i_data_avail == 1) begin //when data is available assert Busy signal;
          busy <= 1;
          data_byte <= i_data_byte; // and latch the data in register;
          state <= START_STATE;
        end
        else state <= IDLE_STATE;
      end
      
      START_STATE: begin
        tx <= 0;    // drive Tx low for sending start bit;
        if (counter < CLKS_PER_BIT) begin
          counter <= counter + 1;
          state <= START_STATE;
        end
        else begin
          counter <= 0;
          state <= SEND_BIT_STATE;
        end
      end
      
      SEND_BIT_STATE: begin
        tx <= data_byte[bit_index]; // drive Tx line with data; 
        if (counter < CLKS_PER_BIT-1) begin
          counter <= counter + 1;
          state <= SEND_BIT_STATE;
        end
        else begin
          counter <= 0;
          if (bit_index < 7) begin  // if data bits are remaining; increment index;
            bit_index <= bit_index + 1;
            state <= SEND_BIT_STATE;
          end
          else begin
            bit_index <= 0; // when done sending all data; goto next state;
            state <= STOP_STATE;
          end
        end
      end
      
      STOP_STATE: begin
        tx <= 1;    // drive Tx line high as stop bit;
        if (counter < CLKS_PER_BIT-1) begin
          counter <= counter + 1;
          state <= STOP_STATE;
        end
        else begin
          done <= 1; // drive done high;
          busy <= 0; // clear the busy line;
          state <= IDLE_STATE;
        end
      end
      
      default: state <= IDLE_STATE;
      
    endcase
    
  end
  
endmodule

//--------------------------------------------------------------------------------