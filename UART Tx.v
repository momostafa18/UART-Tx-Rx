/******************************************************************************
 *
 * Module: UART Transmitter
 *
 * Description: Transmitter UART where data is recieved in parallel from the FIFO Tx and kept in the shift register where it shifts the data out 
 * then it's sent bit by bit as it's a serial protcol 
 *
 * Author: Mohamed Mostafa
 *******************************************************************************************/
 
 /* First all the variables are initialized to 0 if the Asynchronous rest is low then the we have 2 states the current state and the next one 
 *  The current state is equalled to the next state each clock 
 *  The next state changes with the change of the states where we have 4 states as shown below
 *  The UART Tx gets it's data from the FIFO Tx where the transmitting system transmits it's data to that FIFO 
 *  When the Tx is Done with transmitting the data it go again to the idle state where the Tx is kept at 1 (idle)
 */
 
module UART_Tx 
#(parameter DBits = 8,                //data bits
            SB_Ticks = 16             // stop bits
)

(
input clk ,
input areset ,
input S_tick ,
input [DBits-1:0]Tx_din,
input Tx_start,
output reg Tx_Done_Tick,
output Tx_Output
);

localparam idle = 0, start = 1 , 
            data = 2 , stop = 3 ;

reg [1:0]state_reg,state_next;                    //need 2 bits as there are 4 states
reg [3:0]s_reg,s_next;                            //keep tracking of no of ticks (16 tick)
reg [$clog2(DBits)-1:0]n_reg,n_next;              //Keep tracking of no of shifted bits
reg [DBits-1:0]b_reg,b_next;                      //Shift register to store the data 
reg tx_reg,tx_next ;

// Sequential logic for state machine and registers

always @(posedge clk or negedge areset)
begin 
          if(~areset)
                   begin
                       state_reg <= idle;
                       s_reg <= 0;
                       n_reg <= 0;
                       b_reg <= 0; 
                       tx_reg <= 1'b1 ;               // 1 marks idle state 
                   end
           else
                   begin
                     state_reg <=  state_next ;
                     s_reg <= s_next ;
                     n_reg <= n_next ;
                     b_reg <= b_next ; 
                     tx_reg <= tx_next ;
                   end
end

// Combinational logic for state transitions and outputs
always @(*)
begin
          state_next =  state_reg ;
          s_next = s_reg ;
          n_next = n_reg ;
          b_next = b_reg ; 
          Tx_Done_Tick = 1'b0;
           case (state_reg)
                            idle: 
                               begin
                                tx_next = 1'b1;
                                 if(Tx_start == 1)
                                  begin
                                      s_next = 0;
                                      b_next = Tx_din ;
                                      state_next = start ;
                                  end 
                                end
                            start :
                               begin
                                 tx_next = 1'b0; 
                                 if(S_tick == 1)
                                  begin
                                   if(s_reg == 15)
                                      begin
                                       s_next = 0;
                                       n_next = 0;
                                       state_next = data ;
                                      end
                                   else 
                                       s_next = s_reg +1 ;
                                  end
                                end
                             data :
                               begin
                                  tx_next = b_reg[0];
                                  if(S_tick)
                                   begin
                                   if(s_reg == 15) 
                                   begin
                                      s_next = 0;
                                      b_next = {1'b0,b_reg[DBits-1:1]} ;    //shift to right
                                      if(n_reg == DBits-1)
                                       state_next = stop ;
                                      else
                                       n_next = n_reg +1 ;
                                   end
                                   else 
                                        s_next = s_reg +1;
                                   end
                                end
                              stop :
                               begin
                                    tx_reg = 1'b1;
                                     if(S_tick)
                                      begin
                                       if(s_reg == SB_Ticks-1)
                                         begin
                                        Tx_Done_Tick = 1;
                                        state_next = idle ;
                                         end
                                       else 
                                         s_next = s_reg +1 ;
                                      end
                                end
                              default :
                                    state_next = idle ;  
           endcase

end
                            assign Tx_Output = tx_reg ; 
endmodule
