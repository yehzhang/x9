module IF_tb #(parameter A=4);
    // Input
    logic clk;
    logic start;
    logic ctrl_branch;
    logic take_branch;
    logic [A-1:0] inst_addr_reset; // used by reset
    logic [A-1:0] inst_addr_in; // used by branch or reset
    logic halt;

    // Output
    logic[A-1:0] pc;
    logic[8:0] inst;

    IF #(.A(A)) IF_DUT(
        .clk,
        .reset(start),
        .ctrl_branch,
        .take_branch,
        .halt,
        .inst_addr_in,
        .inst_addr_out(pc)
    );

    instr_ROM #(.A(A)) instr_ROM_DUT(
        .inst_addr(pc),
        .inst_out(inst)
    );

    initial begin
        // Global init
        $readmemb("instructions.txt", instr_ROM_DUT.instructions);
        #100ns;

        // Local init
        start = 1;
        inst_addr_reset = 0;
        inst_addr_in = 0;
        #10ns;
        start = 0;
        ctrl_branch = 0;
        take_branch = 0;
        inst_addr_in = 0;

        #70ns ctrl_branch = 1;
        #20ns;
        inst_addr_in = 1;
        take_branch = 1;
        #20ns;
        ctrl_branch = 0;
        take_branch = 0;
        #60ns;
        halt = 1;
        #20ns;

        $stop;
    end

    always begin
        #5ns clk = 0;
        #5ns clk = 1;
    end

endmodule