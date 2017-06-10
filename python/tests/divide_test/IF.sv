module IF #(parameter A=4, INSTS_CNT=200)(
    input clk,
    input reset,
    input [A-1:0] inst_addr_reset, // used by reset
    input ctrl_branch,
    input take_branch,
    input [A-1:0] inst_addr_in, // used by branch
    output logic halt,
    output logic[A-1:0] inst_addr_out
);

    always_ff @(posedge clk) begin
        if(reset) begin
            halt <= 0;
            inst_addr_out <= inst_addr_reset;
        end
        else if(ctrl_branch && take_branch) begin
            inst_addr_out <= inst_addr_in;
        end
        else if (inst_addr_out < INSTS_CNT) begin
            inst_addr_out <= inst_addr_out + 1'b1;
        end
        else begin
            halt <= 1;
        end
    end

endmodule
