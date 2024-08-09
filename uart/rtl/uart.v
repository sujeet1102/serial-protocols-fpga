/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/*
    File                :   uart.v
    Top-level entity    :   uart
    Function            :   Top-level module for uart_rx & uart_tx
    
    Ports   : Inputs    :   clk_50M - 50MHz internal clock from the FPGA
                        :   rx - receiver data line
            : Outputs   :   tx - transmitter data line
                        :   led - 8-bit data bus connected to on-board LEDs of FPGA
    
    Author  :   Sujeet Jagtap
    Date    :   09/08/2024
    
*/
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

module uart (
    input clk_50M,
    output tx,
    input rx,
    output [7:0] led
);

    wire data_avail_interconn;

    uart_tx #(.CLKS_PER_BIT(434)) M1(.clk_50M(clk_50M),
                                                .i_data_byte(25),
                                                .i_data_avail(data_avail_interconn),
                                                .o_Tx(tx),
                                                .o_busy(),
                                                .o_done()
    );
    
    uart_rx #(.CLKS_PER_BIT(434)) M2(.clk_50M(clk_50M),
                                                .o_data_byte(led),
                                                .o_data_avail(data_avail_interconn),
                                                .i_Rx(rx)
    );

    

endmodule

//--------------------------------------------------------------------------------