// Create Date:    2017.01.25
// Design Name:
// Module Name:    TopLevel
// partial only
import ControlUnit_def::*;
import LUT_def::*;
import ALU_def::*;
module TopLevel(
    input     start,
    input     clk,
    output    halt
    );


    wire[7:0] mem_out;
    wire[7:0] mem_addr_in;
    wire ctrl_mem_read;
    wire ctrl_mem_write;

    wire ctrl_branch;
    wire take_branch;
    wire[8:0] instruction;
    wire[15:0] pc;

    wire ctrl_reg_write;
    // register indices
    wire[3:0] reg_i_a, reg_i_b, reg_i_write;
    // register input
    wire[7:0] reg_write_in;
    // register outputs
    wire[7:0] reg_a, reg_b;

    logic alu_carry_bit;
    wire alu_zero;
    wire[7:0] alu_out;
    ALU_CTRL ctrl_alu_input;

    LUT_TYPE ctrl_lut_type;
    wire[7:0] lut_out;
    wire[4:0] immediate;

    logic cycle_ct;


    initial begin
        alu_carry_bit = 0;
    end


    ControlUnit CU(
        .instruction,
        .mem_out,
        .mem_addr_in,
        .ctrl_mem_read,
        .ctrl_mem_write,
        .ctrl_branch,
        .take_branch,
        .ctrl_reg_write,
        .reg_i_a,
        .reg_i_b,
        .reg_i_write,
        .reg_write_in,
        .reg_a,
        .reg_b,
        .alu_zero,
        .alu_out,
        .ctrl_alu_input,
        .ctrl_lut_type,
        .lut_out,
        .immediate
    );


// Fetch = Program Counter + Instruction ROM
// Program Counter
    // TODO INSTS_CNT = ?
    // IF #(.INSTS_CNT(1000)) PC1(
    IF PC1(
        .reset(start),
        .inst_addr_reset(0),
        .halt,
        .clk,
        .ctrl_branch,
        .take_branch,
        .inst_addr_in(lut_out),
        .inst_addr_out(pc)
    );

// instruction ROM
    instr_ROM #(.A(16)) instr_ROM1(
        .inst_addr(pc),
        .inst_out(instruction)
    );

    // LUT
    LUT lut(
        .ctrl_lut_type,
        .key(immediate),
        .data_out(lut_out)
    );

    ALU alu(
        .cin(alu_carry_bit),
        .ctrl_input(ctrl_alu_input),
        .a(reg_a),
        .b(reg_b),
        .out(alu_out),
        .cout(alu_carry_bit),
        .zero(alu_zero)
    );

    reg_file reg_file1(
        .clk,
        .RegWrite(ctrl_reg_write),
        .raddrA(reg_i_a),
        .data_outA(reg_a),
        .raddrB(reg_i_b),
        .data_outB(reg_b),
        .write_register(reg_i_write),
        .data_in(reg_write_in)
    );

    data_mem data_mem1(
        .addr(mem_addr_in),
        .ctrl_mem_read(ctrl_mem_read),
        .ctrl_mem_write(ctrl_mem_write),
        .data_in(alu_out),
        .data_out(mem_out),
        .clk
    );

// count number of instructions executed
always@(posedge clk)
  if (start == 1)
    cycle_ct <= 0;
  else if(halt == 0)
    cycle_ct <= cycle_ct + 1'b1;

endmodule
