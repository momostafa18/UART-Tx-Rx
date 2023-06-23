/******************************************************************************
 *
 * Module: UART Top Module
 *
 * Description: The program for running the UART Tx and Rx 
 *
 * Author: Mohamed Mostafa
 *******************************************************************************************/


module UART_Program(
input CLK,
input Areset
);

// Baud_Rate_Generator signals
wire Done;                  //S_Tick for both Tx and Rx

// Tx Signals
wire Write_Enable;
wire Tx_Done_Tick ;
wire empty ;
wire [7:0]Tx_Din ;
wire Tx_Data ;
wire [7:0]FIFO_Tx_Input ;
wire FIFO_Tx_Full ;

// Rx Signals 
wire Rx_FIFO_Empty ;
wire Rx_FIFO_Full ;
wire [7:0]Rx_Data ;
wire [7:0]Rx_Dout ;
wire Rx_Done_Tick ;
wire Read_Enable;

Baud_Rate_Generator         BRG(CLK,Areset,Done);
UART_Tx                     Tx(CLK,Areset,Done,Tx_Din,~empty,Tx_Done_Tick,Tx_Data);
FIFO_Tx                     FTx(FIFO_Tx_Input,CLK,Areset,Tx_Done_Tick,Write_Enable,Tx_Din,empty,FIFO_Tx_Full);


UART_Rx                     Rx(CLK,Areset,Tx_Data,Done,Rx_Dout,Rx_Done_Tick);
FIFO_Rx                     FRx(Rx_Dout,CLK,Areset,Read_Enable,Rx_Done_Tick,Rx_Data,Rx_FIFO_Empty,Rx_FIFO_Full);
endmodule