
/******************************************************************************
 *
 * Module: Baud Rate Generator 
 *
 * Description: it's a timer that counts tell the final value to achieve the desired BR where the Final Value = (ClockFreq/(16*baudrate))-1
 *
 * Author: Mohamed Mostafa
 *******************************************************************************************/

module Baud_Rate_Generator(
input clk,
input areset,

output Done);

reg enable ;

parameter Final_Value = 255;
parameter Bits = $clog2(Final_Value);  //$clog = ceil log 

reg [Bits-1 : 0]Q_reg,Q_next;

always @(posedge clk or negedge areset)
begin

if(~areset)
      Q_reg <= 0;
else if (enable)
      Q_reg <= Q_next;
else
      Q_reg	<= Q_reg ;  

end

//this line will assign 1  to done if the Q_reg is equal to Final_value else it will assign zero (Better than if else)
   assign Done =  Q_reg == Final_Value;


always @(*)
begin
     if(Done == 1)
	  Q_next = 0;
	  else 
	  Q_next = Q_reg + 1;
	  enable = 1;
end

endmodule