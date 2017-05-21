// This file defines the parameters used in the alu
package ALU_def;
    typedef enum logic[3:0] {
        ALU_ADD,
        ALU_ADDC,
        ALU_SUB,
        ALU_SLL,
        ALU_SRA,
        ALU_OR,
        ALU_NEG,
        ALU_AND,
        ALU_LTS,
        ALU_LT,
        ALU_SRL
    } ALU_CTRL;

endpackage
