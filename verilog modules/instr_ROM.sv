// Create Date:    2017.01.25 
// Design Name: 
// Module Name:    InstROM 
// Description: Verilog module -- instruction ROM 	
//
module instr_ROM #(parameter A=4, W=9) (
  input       [A-1:0] InstAddress,
  output logic[W-1:0] InstrOut);
	 
// need $readmemh or $readmemb to initialize all of the elements
// declare ROM array
  logic[W-1:0] inst_rom[2**(A)];
// read from it
  always_comb InstrOut = inst_rom[InstAddress];

endmodule
