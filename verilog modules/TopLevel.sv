// Create Date:    2017.01.25
// Design Name:
// Module Name:    TopLevel
// partial only
import TopLevel_def::*;
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
    wire[15:0] next_pc;

    wire ctrl_reg_write;
    wire[3:0] reg_i_a, reg_i_b, reg_i_write; // register indices
    wire[7:0] reg_write_in; // register input
    wire[7:0] reg_a, reg_b; // register outputs

    logic alu_carry_bit;
    wire alu_zero;
    wire[7:0] alu_out;
    wire ALU_CTRL ctrl_alu_input;

    LUT_TYPE ctrl_lut_type;
    wire[7:0] lut_out;
    wire[4:0] immediate;

    logic cycle_ct;


    initial begin
        alu_carry_bit = 0;
    end

    // Assign control signals
    always_comb
        Opcode opcode = 'Opcode(instruction[8:6]);
        wire[1:0] funct = instruction[1:0];
        InstType inst_type = instruction[1:0];

        // Decode instruction type
        unique if(opcode == I_LW || opcode == I_SW || opcode == I_SET) begin
            inst_type = I;
        end
        else if(opcode == R_ADD || opcode == R_SHF || opcode == R_NEG) begin
            inst_type = R;
        end
        else if(opcode == B_BEQ) begin
            inst_type = B;
        end
        else if(opcode == M_MOV) begin
            inst_type = M;
        end

        // reg_file logic
        unique case (inst_type)
            I: begin
                wire[3:0] ext_rt = {3'b0, instruction[5:5]};
                unique if(opcode == I_LW) begin
                    reg_i_a = ext_rt
                    ctrl_reg_write = 0;
                end
                else if(opcode == I_SW) begin
                    reg_i_write = ext_rt;
                    reg_write_in = mem_out;
                    ctrl_reg_write = 1;
                end
                else if(opcode == I_SET) begin
                    reg_i_write = ext_rt;
                    reg_write_in = {3'b0, immediate};
                    ctrl_reg_write = 1;
                end
            end
            B: begin
                reg_i_a = 4'b0;
                reg_i_b = 4'b1;
                ctrl_reg_write = 0;
            end
            M: begin
                reg_i_a = instruction[5:2];
                reg_i_write = {3'b0, instruction[1:1]};
                reg_write_in = reg_a;
                ctrl_reg_write = 1;
            end
            R: begin
                reg_i_a = 4'b0;
                reg_i_b = 4'b1;
                reg_i_write = instruction[5:2];
                reg_write_in = alu_out;
                ctrl_reg_write = 1;
            end
        endcase

        // Memory logic
        ctrl_mem_read = ctrl_mem_write = 0;
        if(opcode == I_LW) begin
            ctrl_mem_read = 1;
            mem_addr_in = lut_out;
        end
        else if(opcode == I_SW) begin
            ctrl_mem_write = 1;
        end
        else if(opcode == R_ADD && funct == FUN_LWR) begin
            ctrl_mem_read = 1;
            mem_addr_in = reg_a; // R[0]
        end

        // LUT logic
        case (opcode)
            I_LW: ctrl_lut_type = LUT_LW;
            I_SW: ctrl_lut_type = LUT_SW;
            B_BEQ: unique case (funct)
                FUN_BEQ: ctrl_lut_type = LUT_BEQ;
                FUN_BNE: ctrl_lut_type = LUT_BNE;
                FUN_BGT: ctrl_lut_type = LUT_BGT;
                FUN_BLT: ctrl_lut_type = LUT_BLT;
            endcase
        endcase
        case (inst_type)
            I: immediate = instruction[4:0];
            B: immediate = {0, instruction[5:2]};
        endcase

        // ALU logic
        case (opcode)
            R_ADD: unique case (funct)
                FUN_ADD: ctrl_alu_input = ALU_ADD;
                FUN_ADDC: ctrl_alu_input = ALU_ADDC;
                FUN_SUB: ctrl_alu_input = ALU_SUB;
                FUN_LWR:;
            endcase
            R_SHF: unique case (funct)
                FUN_SLL: ctrl_alu_input = ALU_SLL;
                FUN_SRA: ctrl_alu_input = ALU_SRA;
                default:; // nothing
            endcase
            R_NEG: unique case (funct)
                FUN_NEG: ctrl_alu_input = ALU_NEG;
                FUN_AND: ctrl_alu_input = ALU_AND;
                FUN_OR: ctrl_alu_input = ALU_OR;
                FUN_HALT:; // TODO
            endcase
            B_BEQ: unique case (funct)
                FUN_BEQ: ctrl_alu_input = ALU_SUB;
                FUN_BNE: ctrl_alu_input = ALU_SUB;
                FUN_BGT: ctrl_alu_input = ALU_GT;
                FUN_BLT: ctrl_alu_input = ALU_LT;
            endcase
        endcase

        // Branch taking logic
        if(inst_type == B) begin
            ctrl_branch = 1;
            unique case (funct)
                FUN_BEQ: take_branch = alu_zero;
                FUN_BNE: take_branch = ~alu_zero;
                FUN_BGT: take_branch = alu_out;
                FUN_BLT: take_branch = alu_out;
            endcase
        end
        else ctrl_branch = 0;
    end

// Fetch = Program Counter + Instruction ROM
// Program Counter
    IF #(.OV(1000)) PC1(
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
        .data_out(lut_out),
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

    reg_file #(.W(8),.D(16)) reg_file1(
        .clk,
        .RegWrite(ctrl_reg_write),
        .raddrA(reg_i_a),
        .data_outA(reg_a),
        .raddrB(reg_i_b),
        .data_outB(reg_b),
        .waddr(reg_i_write),
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
    cycle_ct <= cycle_ct+1;

endmodule
