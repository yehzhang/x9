module PC #(parameter INST_WIDTH=9, OV=31)(
    input clk,
    input reset,
    input ctrl_branch,
    input alu_zero,
    input [INST_WIDTH-1:0] inst_addr_in,
    output logic[INST_WIDTH-1:0] inst_addr_out,
    output logic halt
    );

    always_ff @(posedge clk) begin
        if(reset) begin
            inst_addr_out <= 0;
            halt <= 0;
        end else begin
            if(ctrl_branch) begin
                if(alu_zero) begin
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
