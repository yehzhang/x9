module reg_file_tb;
	logic          clk;
  logic          RegWrite;
	logic [3:0] 		raddrA;
	logic [3:0]			raddrB;
	logic [3:0] 	  write_register;
	logic [7:0] data_in;
	wire [7:0] data_outA;
  wire [7:0] data_outB;
// Instantiate the Unit Under Test (UUT)
	reg_file  regFile_UUT(
	  .clk,     // .clk(clk),
	  .RegWrite,
	  .raddrA,
	  .raddrB ,
	  .write_register,
	  .data_in,
	  .data_outA,
	  .data_outB
	);
	initial begin
// Initialize Inputs done for us by "bit"

// Wait 100 ns for global reset to finish
	  #100ns;

// check if writing works
		RegWrite   =  1;
	  write_register   =  4'b1110;
	  data_in = 8'd255;
	  raddrA = 4'b1110;

// check if writing works
	  #20ns;
	  RegWrite   =  1;
	  write_register   =  4'b1001;
	  data_in = 8'd200;
	  raddrB = 4'b1001;


	  #20ns;
//verify writing without RegWrite has no impact
	  RegWrite   =  0;
	  write_register   =  4'b0011;
	  data_in = 8'd155;
	  raddrA = 4'b0011;


	  #20ns
	  RegWrite = 1;
	  write_register = 4'b0100;
	  data_in = 2;

	  #20ns
	  RegWrite = 1;
	  write_register = 4'b0011;
	  data_in = 1;

	  #20ns;
	  RegWrite = 0;
	  raddrA = 4'b0100;
	  raddrB = 4'b0011;

	  #20ns $stop;
	end

always begin
  #10ns clk = 1;
  #10ns clk = 0;
end

endmodule
