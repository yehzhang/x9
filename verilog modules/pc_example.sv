// program counter example
module pc (
  input	clk,
  input reset,
  input abs_jump_en,
//  input jump_back_14,
//  input jump_ahead_7,
  input [1:0] rel_jump_en,
  input[9:0] abs_jump,
  input signed[7:0] rel_jump,
  output logic[9:0] p_ct);

  always_ff @(posedge clk) 
    if(reset)
	  p_ct <= 0;
	else
    case({abs_jump_en, rel_jump_en})
      'b000: p_ct <= p_ct + 1;
	  'b001: p_ct <= p_ct + rel_jump;
	  'b010: p_ct <= p_ct + 7;
	  'b011: p_ct <= p_ct - 14;
	  'b10x: p_ct <= abs_jump;
//	  11: 
	endcase
 
 endmodule