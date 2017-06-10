module cordic(
  input        signed [11:0] x,
  input        signed [11:0] y,
  output logic        [15:0] r,
  output logic signed [11:0] t);

logic signed [15:0] x_temp;
logic signed [15:0] y_temp;
logic signed [15:0] x_new;
logic signed [15:0] y_new;
logic [11:0] t_temp;
logic [11:0] t_new;

always_comb begin
  x_temp = {x,4'b0};
  y_temp = {y,4'b0};
  t_temp = 12'h000;
	for(int i=0;i<12;i++) begin
	  if(y_temp>=0) begin
		x_new  = x_temp + (y_temp>>>i);
		y_new  = y_temp + ((-x_temp)>>>i);
		t_new  = t_temp + (1<<(11-i));//angle(i);
	  end
	  else begin
		x_new  = x_temp + ((-y_temp)>>>i);
		y_new  = y_temp + (x_temp>>>i);
		t_new  = t_temp - (1<<(11-i));//angle(i);
	  end
	  x_temp = x_new;
	  y_temp = y_new;
	  t_temp = t_new;
	  //$display("%d  %h  %h  %h  %d",13-i,x_temp,y_temp,t_temp,t_temp);
	end
	r = x_temp;
	//if(t_temp > 2047)
	//  t_temp = t_temp - 4096;
	//else if(t_temp < -2048)
	//  t_temp = t_temp + 4096;
	t = t_temp; 
end

/*function [15:0] angle;
  input [3:0] i;
  begin
    case (i)
    4'b0000: angle = 16'd16383;    //  45 degrees
    4'b0001: angle = 16'd9671;     //  26.56 degress
    4'b0010: angle = 16'd5110;     //  14.04 degrees
    4'b0011: angle = 16'd2594;     //  7.125 degress
    4'b0100: angle = 16'd1302;     //  3.576 degrees
    4'b0101: angle = 16'd652;      //  1.7899 degrees
    4'b0110: angle = 16'd326;      //  0.895 degrees
    4'b0111: angle = 16'd163;      //  0.4476 degrees
    4'b1000: angle = 16'd81;       //  0.2238 degrees
    4'b1001: angle = 16'd41;       //  0.1119 degrees
    4'b1010: angle = 16'd20;       //  0.05 degrees
    4'b1011: angle = 16'd10;
    endcase
  end
endfunction
*/
endmodule


