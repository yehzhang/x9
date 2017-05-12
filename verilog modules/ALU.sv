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
      ADD:  {cout, out} = a + b;
      ADDC: {cout, out} = a + b + cin;
      SUB:  out = a - b;
      SLL:  out = a << b;
      SRA:  out = a >> b;
      AND:  out = a & b;
      OR:   out = a | b;
      NEG:  out = ~a;
      default: out = 0;
    endcase
    zero = out == 0;
  end

endmodule
