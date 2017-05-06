module reg_file #(parameter W=8, D=4)(
  input           clk,
                  ctrl_reg_write, //control reg write 
  input  [ D-1:0] raddrA,
                  raddrB,
                  waddr,
  input  [ W-1:0] data_in,
  output [ W-1:0] data_outA,
  output logic [W-1:0] data_outB
    );

// W bits wide [W-1:0] and 2**4 registers deep
logic [W-1:0] registers[2**D];	  // or just registers[16] if we know D=4 always

// combinational reads w/ blanking of address 0
assign      data_outA = registers[raddrA];
always_comb data_outB = registers[raddrB];

// sequential (clocked) writes	(likewise, can't write to addr 0)
always_ff @ (posedge clk)
  if (ctrl_reg_write)
    registers[waddr] <= data_in;

endmodule
