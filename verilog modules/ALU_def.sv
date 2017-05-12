// This file defines the parameters used in the alu
package ALU_def;
    typedef enum logic[2:0] {
        ADD  = 3'b000,
        ADDC = 3'b001,
        SUB  = 3'b010,
        SLL  = 3'b011,
        SRA  = 3'b100,
        OR   = 3'b101,
        NEG  = 3'b110,
        AND  = 3'b111
    } ALU_CTRL;

endpackage
