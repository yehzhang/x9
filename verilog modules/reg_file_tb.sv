// Engineer:
//
// Create Date:   13:31:49 10/17/2016
// Design Name:   reg_file
// Module Name:   reg_file_tb.v
// Project Name:  lab_basics
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: reg_file
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 

module reg_file_tb;
	parameter DT = 5,
	          WT = 32;
// DUT Input Drivers
	bit          clk;	      // bit can be only 0, 1 (no x or z)
    bit          RegWrite;   // bit self-initializes to 0, not x (handy)
	bit [ DT-1:0] srcA,
	              srcB,
	              writeReg;
	bit [ WT-1:0] writeValue;
	typedef enum {hold, write} mne; 
	mne op_mne;
// DUT Outputs
	wire [WT-1:0] ReadA,
                  ReadB;

// Instantiate the Unit Under Test (UUT)
	reg_file #(.W(WT),.D(DT)) uut(
	  .clk        ,     // .clk(clk),
	  .write_en (RegWrite  )  , 
	  .raddrA   (srcA      )  , 
	  .raddrB   (srcB      )  , 
	  .waddr    (writeReg  )  , 
	  .data_in  (writeValue)  , 
	  .data_outA(ReadA     )  , 
	  .data_outB(ReadB     ) 
	);
	assign op_mne = mne'(RegWrite);
	initial begin
// Initialize Inputs done for us by "bit"

// Wait 100 ns for global reset to finish
	  #100ns;
        
// Add stimulus here
// check if writing works
	  srcA       =  'h1;
	  writeReg   =  'h1;
	  writeValue = 'h6789ABCD;
	  RegWrite   =  1;
		
	  #20ns;
// verify writing to reg 0 does not work
	  writeReg   = 'h0;
	  writeValue = 32'hFEDC2030;
	  srcB       = 'b0;	
	  #20ns;
//verify writing without RegWrite has no impact
	  RegWrite   =  0;
	  writeReg   =  'h2;
	  writeValue = 'h0000_ABCD;
	  srcA       =  'h2;
	  #20ns $stop;	
	end
always begin
  #10ns clk = 1;
  #10ns clk = 0;
end      
endmodule

