module divison(
input  signed [15:0] dividend,
input  signed [ 7:0] divisor,
output logic signed [15:0] quotient);
logic [15:0] div;
logic dividend_neg;
logic divisor_neg;
logic [15:0] dividend_temp;
logic [7:0]  divisor_temp;

always_comb 
begin
  quotient =16'b0;
  if(divisor!=8'b0) begin
    div=16'h0000;
    if(dividend[15]==1'b1) begin
      dividend_neg = 1'b1;
      dividend_temp = ~dividend + 1'b1;
    end
    else begin
      dividend_neg = 1'b0;
      dividend_temp = dividend;
    end
    if(divisor[7]==1'b1) begin
      divisor_neg = 1'b1;
      divisor_temp = ~divisor + 1'b1;
    end
    else begin
      divisor_neg = 1'b0;
      divisor_temp = divisor;      
    end
    for(int i=0;i<16;i++) begin
       div = {div[14:0],dividend_temp[15-i]}; 
       if(div>=divisor_temp) begin
         div = div - divisor_temp;
         quotient = {quotient[14:0],1'b1};
       end
       else
         quotient = {quotient[14:0],1'b0};
    end
    if(dividend_neg!=divisor_neg)
      quotient = ~quotient +1'b1; 
  end
end
endmodule
