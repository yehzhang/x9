module reg_file (
  input           clk,
                  RegWrite,
  input  [3:0] raddrA,
               raddrB,
              write_register,
  input  [7:0] data_in,
  output logic [7:0] data_outA,
  output logic [7:0] data_outB
);

logic [7:0] registers[16];

always_comb begin
  data_outA = registers[raddrA];
  data_outB = registers[raddrB];
end

always_ff @ (posedge clk) begin
  if (RegWrite)
    registers[write_register] <= data_in;
end

endmodule
