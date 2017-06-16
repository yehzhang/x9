import ControlUnit_def::*;
import LUT_def::*;
import ALU_def::*;
module ControlUnit(
    input wire[8:0] instruction,

    input [7:0] mem_out,
    output logic[7:0] mem_in,
    output logic[7:0] mem_addr_in,
    output logic ctrl_mem_read,
    output logic ctrl_mem_write,

    output logic ctrl_branch,
    output logic take_branch,

    output logic ctrl_reg_write,
    // register indices
    output logic[3:0] reg_i_a, reg_i_b, reg_i_write,
    // register write value
    output logic[7:0] reg_write_in,
    // register read values
    input [7:0] reg_a, reg_b,

    output ALU_CTRL ctrl_alu_input,
    input alu_zero,
    input [7:0] alu_out,

    output LUT_TYPE ctrl_lut_type,
    input [7:0] lut_out,
    output logic[4:0] immediate
);

    Opcode opcode;
    logic[1:0] funct;
    InstType inst_type;


    always_comb begin
        // Decode instruction
        opcode = Opcode'(instruction[8:6]);
        funct = instruction[1:0];
        if(opcode == I_LW || opcode == I_SW || opcode == I_SET)
            inst_type = I;
        else if(opcode == R_ADD || opcode == R_SLL || opcode == R_NEG)
            inst_type = R;
        else if(opcode == B_BEQ)
            inst_type = B;
        else // if(opcode == M_MOV)
            inst_type = M;

        // LUT logic
        unique case (opcode)
            I_LW: ctrl_lut_type = LUT_LW;
            I_SW: ctrl_lut_type = LUT_SW;
            B_BEQ: unique case (funct)
                FUN_BEQ: ctrl_lut_type = LUT_BEQ;
                FUN_BNE: ctrl_lut_type = LUT_BNE;
                FUN_BLTS: ctrl_lut_type = LUT_BLTS;
                FUN_BLT: ctrl_lut_type = LUT_BLT;
            endcase
            default: ctrl_lut_type = LUT_LW;
        endcase
        unique case (inst_type)
            I: immediate = instruction[4:0];
            B: immediate = {1'b0, instruction[5:2]};
            default: immediate = 0;
        endcase

        // reg_file logic
        ctrl_reg_write = 0;
        reg_i_a = 0;
        reg_i_b = 0;
        reg_i_write = 0;
        reg_write_in = 0;
        unique case (inst_type)
            I: begin
                if(opcode == I_LW) begin
                    reg_i_a = {3'b0, instruction[5:5]};
                    reg_write_in = mem_out;
                    ctrl_reg_write = 1;
                end
                else if(opcode == I_SW) begin
                    reg_i_a = {3'b0, instruction[5:5]};
                    ctrl_reg_write = 0;
                end
                else if(opcode == I_SET) begin
                    reg_i_write = {3'b0, instruction[5:5]};
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
        mem_in = alu_out;
        if(opcode == I_LW) begin
            ctrl_mem_read = 1;
            ctrl_mem_write = 0;
            mem_addr_in = lut_out;
        end
        else if(opcode == R_ADD && funct == FUN_LWR) begin
            ctrl_mem_read = 1;
            ctrl_mem_write = 0;
            mem_addr_in = reg_a; // R[0]
        end
        else if(opcode == I_SW) begin
            ctrl_mem_read = 0;
            ctrl_mem_write = 1;
            mem_addr_in = lut_out;
            mem_in = reg_a;
        end
        else begin
            ctrl_mem_read = 0;
            ctrl_mem_write = 0;
            mem_addr_in = 0;
        end

        // ALU logic
        ctrl_alu_input = ALU_ADD;
        unique case (opcode)
            R_ADD: unique case (funct)
                FUN_ADD: ctrl_alu_input = ALU_ADD;
                FUN_ADDC: ctrl_alu_input = ALU_ADDC;
                FUN_SUB: ctrl_alu_input = ALU_SUB;
                // FUN_LWR:;
                default:; // nothing
            endcase
            R_SLL: unique case (funct)
                FUN_SLL: ctrl_alu_input = ALU_SLL;
                FUN_SRA: ctrl_alu_input = ALU_SRA;
                FUN_SRL: ctrl_alu_input = ALU_SRL;
                default:; // nothing
            endcase
            R_NEG: unique case (funct)
                FUN_NEG: ctrl_alu_input = ALU_NEG;
                FUN_AND: ctrl_alu_input = ALU_AND;
                FUN_OR: ctrl_alu_input = ALU_OR;
                // FUN_HALT:;
                default:; // nothing
            endcase
            B_BEQ: unique case (funct)
                FUN_BEQ: ctrl_alu_input = ALU_SUB;
                FUN_BNE: ctrl_alu_input = ALU_SUB;
                FUN_BLTS: ctrl_alu_input = ALU_LTS;
                FUN_BLT: ctrl_alu_input = ALU_LT;
            endcase
            default:;
        endcase

        // Branch taking logic
        if(inst_type == B) begin
            ctrl_branch = 1;
            unique case (funct)
                FUN_BEQ: take_branch = alu_zero;
                FUN_BNE: take_branch = ~alu_zero;
                FUN_BLTS: take_branch = alu_out[0];
                FUN_BLT: take_branch = alu_out[0];
            endcase
        end
        else begin
            ctrl_branch = 0;
            take_branch = 0;
        end
    end

endmodule
