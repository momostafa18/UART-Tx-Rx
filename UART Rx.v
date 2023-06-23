/******************************************************************************
 *
 * Module: UART Reciever
 *
 * Description: Reciever UART where data is recieved bit by bit as it's a serial protcol then the data is saved in a shift register 
 * then moved in parallel to a FIFO to be saved till the system uses it
 *
 * Author: Mohamed Mostafa
 *******************************************************************************************/
 
  /* First all the variables are initialized to 0 if the Asynchronous rest is low then the we have 2 states the current state and the next one 
 *  The current state is equalled to the next state each clock 
 *  The next state changes with the change of the states where we have 4 states as shown below
 *  The UART Rx passes it's data to the FIFO Rx where it keeps this data till the Recieveing system reads this data
 *  When the Rx is Done with Recieveing the data it go again to the idle state 
 */

module UART_Rx
#(parameter DBits = 8,                //data bits
            SB_Ticks = 16             // stop bits
)
(
input clk,
input areset,
input Rx_input,
input S_tick,
output [DBits-1:0] Rx_Dout,
output reg Rx_done_Tick	
);

localparam idle = 0, start = 1 , 
            data = 2 , stop = 3 ;

reg [1:0]state_reg,state_next;                    //need 2 bits as there are 4 states
reg [3:0]s_reg,s_next;                            //keep tracking of no of ticks (16 tick)
reg [$clog2(DBits)-1:0]n_reg,n_next;              //Keep tracking of no of shifted bits
reg [DBits-1:0]b_reg,b_next;                      //Shift register to store the data 

always @(posedge clk or negedge areset)
begin 
          if(~areset)
                   begin
                       state_reg <= idle;
                       s_reg <= 0;
                       n_reg <= 0;
                       b_reg <= 0; 
                   end
           else
                   begin
                     state_reg <=  state_next ;
                     s_reg <= s_next ;
                     n_reg <= n_next ;
                     b_reg <= b_next ; 
                   end
end

always @(*)
begin
          state_next =  state_reg ;
          s_next = s_reg ;
          n_next = n_reg ;
          b_next = b_reg ; 
          case (state_reg)
                         idle :
                               begin
                              if(~Rx_input) 
                               begin
                                s_next = 0;
                                state_next = start;
                               end
                                end
                          start :
                               begin
                               if(S_tick)
                                begin
                                 if(s_reg == 7)
                                  begin 
                                   s_next = 0;
                                   n_next = 0;
                                   state_next = data;
                                  end
                                  else
                                   s_next = s_reg +1;
                                end
                                end
                           data : 
                               begin
                                 if(S_tick)
                                  begin
                                   if(s_reg == 15)
                                     begin
                                     s_next = 0;
                                     b_next = {Rx_input , b_reg[DBits-1:1]};
                                     if(n_reg == DBits-1)
                                      state_next = stop;
                                     else 
                                      n_next = n_reg +1;
                                     end
                                    else
                                      s_next = s_reg +1 ;
                                  end
                                end
                            stop :
                               begin
                                   if(S_tick == 1)
                                      begin
                                         if(s_reg == SB_Ticks - 1)
                                             begin
                                           Rx_done_Tick = 1; 
                                           state_next = idle ;
                                             end
                                          else 
                                            s_next = s_reg +1;
                                       end
                                end
                            default : 
                                      state_next = idle ;
endcase 
end

                                       assign Rx_Dout = b_reg ;


endmodule
