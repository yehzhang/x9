//This file defines the parameters used in the alu
package definitions;

// Instruction map
    const logic [2:0] kAdd  = 3'b000;
    const logic [2:0] kAddC = 3'b001;
    const logic [2:0] kSub  = 3'b010;
    const logic [2:0] kSll  = 3'b011;
    const logic [2:0] kSra  = 3'b100;
    const logic [2:0] kOr   = 3'b100;
    const logic [2:0] kNeg  = 3'b101;
    const logic [2:0] kAnd  = 3'b111;

    // typedef enum logic[3:0] {
    //     kAdd  = 4'b0000;
    //     kAddC = 4'b0001;
    //     kSub  = 4'b0010;
    //     kSll  = 4'b0011;
    //     kSra  = 4'b0100;
    //     kSllC = 4'b0101;
    //     kSrlC = 4'b0110;
    //     kAnd  = 4'b0111;
    //     kOr   = 4'b1000;
    //     kNeg  = 4'b1001;
    // } alu_ctrl;

endpackage // defintions
