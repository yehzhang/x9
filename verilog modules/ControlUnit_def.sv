package ControlUnit_def;
    typedef enum {
        R_ADD = 0,
        I_LW = 1,
        I_SW = 2,
        B_BEQ = 3,
        M_MOV = 4,
        R_SLL = 5,
        R_NEG = 6,
        I_SET = 7
    } Opcode;

    parameter FUN_BEQ = 0;
    parameter FUN_BNE = 1;
    parameter FUN_BLTS = 2;
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
