// Create Date:    2017.01.25
// Design Name:
// Module Name:    DataRAM
//
module data_mem(
  input              CLK,
  input [7:0]        DataAddress,
  input              ReadMem,
  input              WriteMem,
  input [7:0]       DataIn,
  output logic[7:0] DataOut);

  logic [7:0] my_memory [256];

//  initial 
//    $readmemh("dataram_init.list", my_memory);
  always_comb
    if(ReadMem) begin
      DataOut = my_memory[DataAddress];
	  $display("Memory read M[%d] = %d",DataAddress,DataOut);
    end else 
      DataOut = 16'bZ;

  always_ff @ (posedge CLK)
    if(WriteMem) begin
      my_memory[DataAddress] = DataIn;
	  $display("Memory write M[%d] = %d",DataAddress,DataIn);
    end

endmodule
