module next_pc #(parameter INST_WIDTH=9, OV=31)(
    input clk,
    input reset,
    input ctrl_branch,
    input take_branch,
    input [INST_WIDTH-1:0] inst_addr_in, // used by branch or reset
    output logic[INST_WIDTH-1:0] inst_addr_out,
    output logic halt
    );

    always_ff @(posedge clk) begin
        if(reset) begin
            inst_addr_out <= inst_addr_in;
            halt <= 0;
        end else begin
            if(ctrl_branch) begin
                if(take_branch) begin
                    inst_addr_out = inst_addr_in;
                end
            end else begin
                inst_addr_out <= inst_addr_out + 1;
            end

            if(inst_addr_out >= OV) begin
                halt <= 1;
            end
        end
    end

endmodule
