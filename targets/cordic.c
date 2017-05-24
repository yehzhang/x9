/*
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
*/
#include <stdio.h>
int main(){
    int x = 300; //store in location 1(MSW), 2(LSW)
    int y = 400; //store in location 3(MSW), 4(LSW)
    int x_new, y_new, t_new;

    int t = 0<<11; //12 bits

    int i;
    for(i=0;i<12;i++){
        if(y>=0){
            x_new = x + (y>>i);
            y_new = y + ((-x)>>i);
            t_new = t + (1<<(11-i));
        }
        else{
            x_new = x + ((-y)>>i);
            y_new = y + (x>>i);
            t_new = t - (1<<(11-i));
        }
        x = x_new;
        y = y_new;
        t = t_new;
    }

    float radian = x; //store to location 5(MSW), 6(LSW)
    float theta = t; //store to location 7(MSW), 8(LSW)
    printf("%f\n", radian);
    printf("%f\n", theta);

}