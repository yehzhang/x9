// This file defines the parameters used in the TopLevel
package TopLevel_def;
    // Generated
    typedef enum logic[2:0] {
        R_ADD = 0,
        I_LW = 0,
        I_SW = 0,
        B_BEQ = 0,
        M_MOV = 0,
        R_SHF = 3'b001,
        R_NEG = 0,
        I_SET = 0,
    } Opcode;

    parameter FUN_BEQ = 0;
    parameter FUN_BNE = 1;
    parameter FUN_BGT = 2;
    parameter FUN_BLT = 3;

    parameter FUN_ADD = 0;
    parameter FUN_ADDC = 1;
    parameter FUN_SUB = 2;
    parameter FUN_LWR = 3;

    parameter FUN_SLL = 0;
    parameter FUN_SRA = 1;
    parameter FUN_SRL = 2;

    parameter FUN_NEG = 0;
    parameter FUN_AND = 1;
    parameter FUN_OR = 2;
    parameter FUN_HALT = 3;

    typedef enum logic[1:0] {
        I, M, B, R
    } InstType;

endpackage
