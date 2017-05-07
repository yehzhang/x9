// Create Date:    2017.01.25
// Design Name:
// Module Name:    TopLevel
// partial only
module TopLevel(
    input     start,
    input     clk,
    output    halt
    );

wire[15:0] program_count;           // program count
wire[ 8:0] instruction;  // our 9-bit opcode
wire[ 7:0] reg_a, reg_b; // reg_file outputs
wire[ 7:0] regWriteValue,
           memWriteValue,
           mem_out;
wire       ctrl_mem_read,
           ctrl_mem_write,
           ctrl_branch;
wire       alu_zero;
wire       take_branch;
logic      cycle_ct;

// Fetch = Program Counter + Instruction ROM
// Program Counter
    next_pc #(.OV(1000)) PC1(
        .reset(start),
        .halt,
        .clk,
        .ctrl_branch,
        .take_branch,
        .inst_addr_in(0),
        .inst_addr_out(program_count)
    );

// instruction ROM
    instr_ROM #(.A(16)) instr_ROM1( // 1024 instructions
        .inst_addr(program_count),
        .inst_out(instruction)
    );

// reg file
    reg_file #(.W(8),.D(16)) reg_file1(
        .clk,
        .raddrA({1'b0,instruction[5:3]}), //concatenate with 0 to give us 4 bits
        .raddrB({1'b0,instruction[2:0]}),
        .waddr(write_register),       // TODO mux above
        .data_in(regWriteValue),
        .data_outA(reg_a),
        .data_outB(reg_b)
    );

    data_mem data_mem1(
        .addr,
        .ctrl_mem_read(ctrl_mem_read),
        .ctrl_mem_write(ctrl_mem_write),
        .data_in(memWriteValue),
        .data_out(mem_out),
        .clk
    );

// count number of instructions executed
always@(posedge clk)
  if (start == 1)
    cycle_ct <= 0;
  else if(halt == 0)
    cycle_ct <= cycle_ct+1;

endmodule
