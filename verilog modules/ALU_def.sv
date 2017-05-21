// This file defines the parameters used in the alu
package ALU_def;
    typedef enum logic[3:0] {
        ALU_ADD  = 4'b0000,
        ALU_ADDC = 4'b0001,
        ALU_SUB  = 4'b0010,
        ALU_SLL  = 4'b0011,
        ALU_SRA  = 4'b0100,
        ALU_OR   = 4'b0101,
        ALU_NEG  = 4'b0110,
        ALU_AND  = 4'b0111,
        ALU_GT   = 4'b1000,
        ALU_LT   = 4'b1001,
    } ALU_CTRL;

endpackage
