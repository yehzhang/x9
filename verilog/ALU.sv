import ALU_def::*;
module ALU(
  // input cin,
  input ALU_CTRL ctrl_input,
  input [7:0] a, b,
  output logic [7:0] out,
  // output logic cout,
  output logic zero
);
  logic alu_carry_bit;

  always @(*) begin
    unique case (ctrl_input)
      ALU_ADD:  {alu_carry_bit, out} = a + b;
      ALU_ADDC: {alu_carry_bit, out} = a + b + alu_carry_bit;
      ALU_SUB:  out = a - b;
      ALU_SLL:  out = $signed(b) >= 0 ? a << b : a >> $unsigned(-$signed(b));
      // Max shamt 16
      ALU_SRA:  out = $signed(b) >= 0 ? {{16{a[7]}}, a} >> b : a << $unsigned(-$signed(b));
      ALU_SRL:  out = $signed(b) >= 0 ? a >> b : a << $unsigned(-$signed(b));
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
