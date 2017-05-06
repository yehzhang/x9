module reg_file #(parameter W=8, D=4)(
  input           clk,
                  write_en,
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
assign      data_outA = raddrA? registers[raddrA] : '0;	   // can't read from addr 0, just like MIPS
always_comb data_outB = raddrB? registers[raddrB] : 'b0;

// sequential (clocked) writes	(likewise, can't write to addr 0)
always_ff @ (posedge clk)
  if (write_en && waddr)
    registers[waddr] <= data_in;

endmodule
