// Engineer: 
// 
// Create Date:    2016.10.15
// Design Name: 
// Module Name:    ALU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//   combinational (unclocked) ALU

import definitions::*;			  // includes package "definitions"
module ALU(
  input        SC_IN,             // shift in/carry in 
  input [ 3:0] OP,				  // ALU opcode, part of microcode
  input [ 7:0] INPUTA,			  // data inputs
               INPUTB,
  output logic [7:0] OUT,		  // or:  output reg [7:0] OUT,
  output logic SC_OUT			  // shift out/carry out
    );
	 
  op_mne op_mnemonic;			  // type enum: used for convenient waveform viewing
	
  always_comb begin
// option 1 -- single instruction for both LSW & MSW
	case(OP[3:2])
	  kADD : case(OP[1:0])
	    00: {SC_OUT,INPUTA} << 1;
		01: (INPUTA << 1) + SC_IN;
	  
	  {SC_OUT,OUT} = INPUTA + INPUTB + SC_IN;    // universal add operation
	  kLSA : {SC_OUT,OUT} = (INPUTA<<1) + SC_IN;  	// universal shift instruction
//	  kXOR : OUT = INPUTA^INPUTB;
	  default: {SC_OUT,OUT} = 0;
	endcase
// option 2 -- separate LSW and MSW instructions
    case(OP)
	  kADDL : {SC_OUT,OUT} = INPUTA + INPUTB ;    // universal add operation
	  kLSAL : {SC_OUT,OUT} = (INPUTA<<1) ;  	// universal shift instruction
	  kADDU : begin
	            OUT = INPUTA + INPUTB + SC_IN;    // universal add operation
                SC_OUT = 0;   
              end
	  kLSAU : begin
	            OUT = (INPUTA<<1) + SC_IN;  	// universal shift instruction
                SC_OUT = 0;
               end
      kXOR  : OUT = INPUTA ^ INPUTB;
	  kBRNE : OUT = INPUTA - INPUTB;   // use in conjunction w/ instruction decode 
    endcase
	case(OUT)
	  16'b0 :   ZERO = 1'b1;
	  default : ZERO = 1'b0;
	endcase
//$display("ALU Out %d \n",OUT);
    op_mnemonic = op_mne'(OP);
  end

endmodule
