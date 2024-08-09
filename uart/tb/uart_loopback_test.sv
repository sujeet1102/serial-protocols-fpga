/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/*
	File				:	uart_loopback_test.sv
	Top-level entity	:	uart_loopback_test
	Function			:	UART test module; Generates 50MHz clock
							Basic loopback test
							Dumps all vars; Dumpfile - dump.vcd
	
	Author	:	Sujeet Jagtap
	Date	:	09/08/2024
	
*/
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module uart_loopback_test;
  
  reg clk_50M, i_data_avail;
  reg [7:0] i_data_byte;
  wire o_Tx, o_busy, o_done;
  wire [7:0] o_data_byte;
  wire o_data_avail;
  
  uart_tx #(.CLKS_PER_BIT(434)) UART_TX_DUT (clk_50M, i_data_byte, i_data_avail, o_Tx, o_busy, o_done);
  
  uart_rx #(.CLKS_PER_BIT(434)) UART_RX_DUT (o_Tx, clk_50M, o_data_byte, o_data_avail);
  
  initial begin
    clk_50M = 0; i_data_avail = 0;
    $dumpvars(0, uart_loopback_test);
    $dumpfile("dump.vcd");
    #225000 $finish;
  end
  
  always #10 clk_50M = ~clk_50M;	// Generates 50MHz clock
  
  /* Basic Loopback Test` */
  
  initial begin
    #5 i_data_avail = 1; i_data_byte = 25;
    #10 i_data_avail = 0; i_data_byte = 99;
    #86830 i_data_avail = 1;
    #20 i_data_avail = 0;
  end
  
endmodule