/******************************************************************************
 *
 * Module: FIFO Reciever
 *
 * Description: First in First out buffer used to save the data from the Tx to be sent to the UART Tx
 *
 * Author: Mohamed Mostafa
 *******************************************************************************************/

module FIFO_Tx
#(parameter DBits = 8
)
(
input [DBits-1:0]Input_Data_bits,
input clk ,
input areset ,
input Read_Enable,
input Write_Enable,
output reg [DBits-1:0]Output_Data_bits,
output  Empty,
output  Full
);

reg [DBits-1:0]FIFO_MEM[31:0];
reg [$clog2(32-1):0]rd_ptr,wr_ptr;
reg [5:0]FIFO_Count;

initial 
begin
           Output_Data_bits = 0;
           rd_ptr = 0;
           wr_ptr = 0;
           FIFO_Count = 0;
end

assign Empty = (FIFO_Count == 0);
assign Full = (FIFO_Count == 31);

always@(negedge areset)
begin 
         if(~areset)
           begin
           Output_Data_bits = 0;
           rd_ptr = 0;
           wr_ptr = 0;
           FIFO_Count = 0;
           end
end
always@(posedge clk)
begin
             if(Write_Enable && ~Full)
                begin
                FIFO_MEM[wr_ptr] <= Input_Data_bits ;
                wr_ptr <= wr_ptr + 1;
                end
             else if (Write_Enable && Read_Enable)
                begin
                FIFO_MEM[wr_ptr] <= Input_Data_bits ; 
                wr_ptr <= wr_ptr + 1;
                end
end
always@(posedge clk)
begin 
             if(Read_Enable && ~Empty)
                begin
                Output_Data_bits <= FIFO_MEM[rd_ptr] ;
                rd_ptr <= rd_ptr + 1;
                end
             else if (Write_Enable && Read_Enable)
                begin
                Output_Data_bits <= FIFO_MEM[rd_ptr] ;
                rd_ptr <= rd_ptr + 1;
                end
end
always @(posedge clk)
begin 
             case ({Write_Enable,Read_Enable})
                                              2'b00 : FIFO_Count <=FIFO_Count ;
                                              2'b01 : FIFO_Count <= FIFO_Count == 0 ?  0 :FIFO_Count - 1 ;
                                              2'b10 : FIFO_Count <= FIFO_Count == 31 ? 31 :FIFO_Count + 1 ;
                                              2'b11 : FIFO_Count <=FIFO_Count ;
                                              default : FIFO_Count <=FIFO_Count ;
             endcase
end


endmodule