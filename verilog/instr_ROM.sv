module instr_ROM #(parameter A=4, W=9) (
  input       [A-1:0] inst_addr,
  output logic[W-1:0] inst_out
  );

  // need $readmemh or $readmemb to initialize all of the elements
  logic[W-1:0] instructions[2**(A)];

  always_comb inst_out = instructions[inst_addr];

endmodule
