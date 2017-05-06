// Resizing the components of your microcode
// default -- two-operand operations

{ALU[2:0], RS[2:0], RT[2:0]};  
// (reserve ALU / MSB field combination 010 for shifts, per below) 

// for one-operand operations

// want effectively ALU[4:0], RT[3:0] 
//  use {ALU[2:0], RS[2:1]} as the new 5-bit ALU
//  use {RS[0], RT[2:0]} as the new 4-bit reg_file address/pointer/index

//for example, 1-bit shift of a single operand: 
//010XX: shift operators
01000:   LSL;
01001:   LSM;
01010:   RSL;
01011:   RSM;


// no-operand operations

// interpret whole thing as ALU[8:0]
// for exmaple, reserve 3 leading bits 111
// now: 
111_11111: halt; // for example
111_00001: ___; // some other no-operand operation
// ...    etc. if any others