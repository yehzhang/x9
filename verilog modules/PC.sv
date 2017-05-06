module PC(
  input init,
        jump_en,
		branch_en,
		CLK,
  output logic halt,
  output logic[15:0] PC);

always @(posedge CLK)
  if(init) begin
    PC <= 0;
	halt <= 0;
  end
  else begin
    if(PC<31)
      PC <= PC + 1;
	else 
	  halt <= 1;
  end
endmodule
        