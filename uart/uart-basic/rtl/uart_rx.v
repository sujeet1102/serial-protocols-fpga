/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/*
    File                :   uart_rx.v
    Top-level entity    :   uart_rx
    Function            :   UART receiver module; Works on 50MHz internal clock
                            By default baud rate set to 115200; Two-bit flip-flop synchronizer used
    
    Ports   : Inputs    :   clk_50M - 50MHz internal clock from the FPGA
                        :   i_Rx - receiver data line
            : Outputs   :   o_data_avail - when 1 (high) data is valid
                        :   o_data_byte - 8-bit data bus outputing the data
    
    Author  :   Sujeet Jagtap
    Date    :   09/08/2024
    
*/
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

module uart_rx #(parameter CLKS_PER_BIT = 434) (
  input i_Rx,
  input clk_50M,
  output [7:0] o_data_byte,
  output o_data_avail
);
  
  /* Addressing CDC issues; Two flip-flop synchronizer */
  reg rx_buffer = 1'b1, rx = 1'b1;
  always @ (posedge clk_50M) begin
    rx_buffer <= i_Rx;
    rx <= rx_buffer;
  end
  
  /* State Declaration */
  localparam IDLE_STATE = 2'b00, START_STATE = 2'b01, GET_BIT_STATE = 2'b10, STOP_STATE = 2'b11; 
  
  /* Register Declaration */
  reg [1:0] state = IDLE_STATE;
  reg [15:0] counter = 0;
  reg [2:0] bit_index = 0;
  reg data_avail = 0;
  reg [7:0] data_byte;
  
  /* Assign outputs */
  assign o_data_byte = data_byte;
  assign o_data_avail = data_avail;

  
  /* STATE Transition & Controls (Synchronous) */
  always @ (posedge clk_50M) begin
    
    case(state)
      
      IDLE_STATE: begin // Wait until the rx goes low and decide next state
        data_avail <= 0;
        counter <= 0;
        bit_index <= 0;
        data_byte <= 8'bxxxxxxxx;
        if (rx == 0) state <= START_STATE;
        else state <= IDLE_STATE;
      end
      
      START_STATE: begin    // Start the counter; Wait until middle of start bit; Check if still 0 and move next state;
        if (counter == (CLKS_PER_BIT-1)/2) begin
          if (rx == 0) begin
            counter <= 0;
            state <= GET_BIT_STATE;
          end
          else state <= IDLE_STATE; // Bad ending; Go back to idle state;
        end
        else begin  // Loop here; increment counter;
          counter <= counter + 1;
          state <= START_STATE;
        end
      end
      
      GET_BIT_STATE: begin
        if (counter < CLKS_PER_BIT-1) begin // Loop here to get middle of data bit;
          counter <= counter + 1;
          state = GET_BIT_STATE;
        end
        else begin  // Reached the middle of data bit;
          counter <= 0;
          data_byte[bit_index] <= rx;   // Load value into the data register;
          if (bit_index < 7) begin  // Data payload not complete yet; Input the remaining bit indices;
            bit_index <= bit_index + 1;
            state <= GET_BIT_STATE;
          end
          else begin    // Data payload complete move to stop bit state;
            bit_index <= 0;
            state <= STOP_STATE;
          end
        end
      end
      
      STOP_STATE: begin
        if (counter < CLKS_PER_BIT-1) begin // Reach the middle of stop bit;
          counter <= counter + 1;
          state <= STOP_STATE;
        end
        else begin  // Verify stop bit is high & set data_avail; Move to idle state;
          if (rx == 1) data_avail <= 1;
          state <= IDLE_STATE;
        end
      end
      
      default: state <= IDLE_STATE; // default idle state;
      
    endcase
  
  end

  
endmodule

//--------------------------------------------------------------------------------