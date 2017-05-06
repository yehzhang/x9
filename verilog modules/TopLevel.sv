// Create Date:    2017.01.25
// Design Name: 
// Module Name:    TopLevel 
// partial only
module TopLevel(
    input     start,
	input     CLK,
    output    halt
    );

wire[15:0] PC;           // program count
wire[ 8:0] Instruction;  // our 9-bit opcode
wire[ 7:0] ReadA, ReadB; // reg_file outputs
wire[ 7:0] regWriteValue,
           memWriteValue,
		   Mem_Out;
wire       MEM_READ,
		   MEM_WRITE,
           jump_en,
           branch_en;
logic      cycle_ct;

// Fetch = Program Counter + Instruction ROM
// Program Counter
  PC PC1 (
	.init    (start), 
	.halt    (halt) , 
	.jump_en        ,
	.branch_en		, 
	.CLK            , 
	.PC             
	);
// instruction ROM
  instr_ROM instr_ROM1(
	.InstrAddress   (PC), 
	.InstrOut       (Instruction)
	);

// reg file
	reg_file #(.W(8),.D(16)) reg_file1 (
		.CLK                  , 
		.srcA      ({1'b0,Instruction[5:3]}), //concatenate with 0 to give us 4 bits
		.srcB      ({1'b0,Instruction[2:0]}), 
		.writeReg  (write_register), 	  // mux above
		.writeValue(regWriteValue) , 
		.ReadA                     , 
		.ReadB
	);
	
	data_mem data_mem1(
		.DataAddress  (ReadA), 
		.ReadMem      (MEM_READ), 
		.WriteMem     (MEM_WRITE), 
		.DataIn       (memWriteValue), 
		.DataOut      (MemOut), 
		.CLK 
	);
	
// count number of instructions executed
always@(posedge CLK)
  if (start == 1)
  	cycle_ct <= 0;
  else if(halt == 0)
  	cycle_ct <= cycle_ct+1;

endmodule
