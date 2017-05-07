// Create Date:    2017.01.25
// Design Name:
// Module Name:    InstROM
// Description: Verilog module -- instruction ROM
//
module instr_ROM #(parameter A=4, W=9) (
  input       [A-1:0] inst_addr,
  output logic[W-1:0] inst_out
  );

// need $readmemh or $readmemb to initialize all of the elements
// declare ROM array
  logic[W-1:0] inst_rom[2**(A)];
// read from it
  always_comb inst_out = inst_rom[inst_addr];

endmodule
