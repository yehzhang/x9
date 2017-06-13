module IF #(parameter A=4)(
    input clk,
    input reset,
    input halt,
    input [A-1:0] inst_addr_reset, // used by reset
    input ctrl_branch,
    input take_branch,
    input [A-1:0] inst_addr_in, // used by branch
    output logic[A-1:0] inst_addr_out
);

    always_ff @(posedge clk) begin
        if(reset) begin
            inst_addr_out <= inst_addr_reset;
        end
        else if(halt) begin
            ;
        end
        else if(ctrl_branch && take_branch) begin
            inst_addr_out <= inst_addr_in;
        end
        else begin
            inst_addr_out <= inst_addr_out + 1'b1;
        end
    end

endmodule
