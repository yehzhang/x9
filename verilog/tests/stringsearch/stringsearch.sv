module stringsearch(
  input       [511:0] string1,
  input       [  3:0] sequence1,
  output logic[  7:0] count);

  logic[8:0] count1;
  always_comb begin
    count1=0;
    for(int i=0;i<509;i++) begin
	  if(string1[i +:4]==sequence1)
	    count1++;
    end
	if(count1>255)
	  count = 255;
	else
	  count = count1;
  end
endmodule
