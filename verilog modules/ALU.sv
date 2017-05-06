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
  input        cin,             // carry in
  input [3:0]  ctrl_input,				  // ALU opcode, part of microcode
  input [7:0]  a,			  // data inputs
               b,
  output logic [7:0] out,		  // or:  output reg [7:0] OUT,
  output logic cout			  // carry out
    );

  always_comb begin
    cout = 0;
    case (ctrl_input)
        kAdd:  {cout, out} = a + b;
        kAddC: {cout, out} = a + b + cin;
        kSub:  out = a - b;
        kSll:  out = a >> b;
        kSra:  out = a >>> b;
        kAnd:  out = a & b;
        kOr:   out = a | b;
        kNeg:  out = ~a;
        default: out = 0;
    endcase

endmodule
