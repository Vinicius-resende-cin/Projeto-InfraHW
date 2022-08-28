
module Multiplicador(clk,rst,start,A,B,high,low);

input clk;
input rst;
input start;
input signed [31:0]A,B;
output [31:0] high,low;



reg signed [63:0] Z,next_Z,Z_temp;
reg next_state, pres_state;
reg [1:0] temp,next_temp;
reg [5:0] count,next_count;
reg valid, next_valid;

assign high = Z[63:32];
assign low = Z[31:0];


parameter IDLE = 1'b0;
parameter START = 1'b1;

always @ (posedge clk or posedge rst)
begin
if(rst)
begin
  Z    	  <= 64'd0;
  valid      <= 1'b0;
  pres_state <= 1'b0;
  temp       <= 2'd0;
  count      <= 6'd0;
end
else
begin
  Z    	  <= (count == 6'd32)? Z : next_Z;
  valid      <= next_valid;
  pres_state <= next_state;
  temp       <= next_temp;
  count      <= next_count;
end
end

always @ (*)
begin 
case(pres_state)
IDLE:
begin
next_count = 6'd0;
next_valid = 1'b0;
if(start)
begin
    next_state = START;
    next_temp  = {A[0],1'b0};
    next_Z     = {32'd0,A};
end
else
begin
    next_state = pres_state;
    next_temp  = 2'd0;
    next_Z     = 64'd0;
end
end

START:
begin
    case(temp)
    2'b10:   Z_temp = {Z[63:32]-B,Z[31:0]};
    2'b01:   Z_temp = {Z[63:32]+B,Z[31:0]};
    default: Z_temp = {Z[63:32],Z[31:0]};
    endcase

next_temp  = {A[count+1],A[count]};
next_count = count + 6'd1;
next_Z     = Z_temp >>> 1;
next_valid = (count == 6'd32) ? 1'b1 : 1'b0;
next_state = (count == 6'd32) ? IDLE : pres_state;	
end
endcase
end
endmodule
