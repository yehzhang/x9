// Create Date:    2017.01.25
// Design Name:
// Module Name:    DataRAM
//
module data_mem #(parameter SIZE=256)(
  input             clk,
  input [7:0]       addr,
  input             ctrl_mem_read,
  input             ctrl_mem_write,
  input [7:0]       data_in,
  output logic[7:0] data_out);

  logic [7:0] my_memory [SIZE];

//  initial
//    $readmemh("dataram_init.list", my_memory);
  always_comb
    if(ctrl_mem_read) begin
      data_out = my_memory[addr];
    // $display("Memory read M[%d] = %d",addr,data_out);
    end else
      data_out = 'bZ;

  always_ff @ (posedge clk)
    if(ctrl_mem_write) begin
      my_memory[addr] = data_in;
    // $display("Memory write M[%d] = %d",addr,data_in);
    end

endmodule
