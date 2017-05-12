module reg_file_tb;
	bit          clk;	      // bit can be only 0, 1 (no x or z)
  bit          RegWrite;   // bit self-initializes to 0, not x (handy)
	bit [3:0] 		raddrA;
	bit [3:0]			raddrB;
	bit [3:0] 	  write_register;
	bit [7:0] data_in;
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
	  write_register   =  4'b1110;
	  data_in = 8'd255;
	  RegWrite   =  1;

	  #20ns;
	  write_register   =  4'b1001;
	  data_in = 8'd200;
	  RegWrite   =  1;

	  #20ns;
//verify writing without RegWrite has no impact
	  RegWrite   =  0;
	  write_register   =  4'b0011;
	  data_in = 8'd155;

	  #20ns $stop;
	end

always begin
  #10ns clk = 1;
  #10ns clk = 0;
end

endmodule
