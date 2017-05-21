// TODO refactor cin and cout as an internal register?
import ALU_def::*;
module ALU(
  input cin,
  input ALU_CTRL ctrl_input,
  input [7:0] a, b,
  output logic [7:0] out,
  output logic cout,
  output logic zero
);

  always_comb begin
    cout = 0;
    unique case (ctrl_input)
      ALU_ADD:  {cout, out} = a + b;
      ALU_ADDC: {cout, out} = a + b + cin;
      ALU_SUB:  out = a - b;
      ALU_SLL:  out = a << b;
      ALU_SRA:  out = a >> b;
      ALU_SRL:  out = a >>> b;
      ALU_AND:  out = a & b;
      ALU_OR:   out = a | b;
      ALU_NEG:  out = ~a;
      ALU_LTS:  out = $signed(a) < $signed(b);
      ALU_LT:   out = a < b;
      default: out = 0;
    endcase
    zero = out == 0;
  end

endmodule
