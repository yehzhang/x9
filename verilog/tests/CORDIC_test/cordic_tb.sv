// Revised 3 June 2017 to match spec in assignment sheet.
// Specifically, loads x and y into memory 1:4 and reads from 5:8.

module cordic_tb;

bit  signed  [11:0] x;
bit  signed  [11:0] y;
wire signed  [15:0] r_beh;
wire         [11:0] t_beh;
logic signed [15:0] r_DUT;
logic        [11:0] t_DUT;
bit                 clk, start;
wire                done;
bit          [ 7:0] scoreR,            // how many correct trials of radius
          scoreT;            // how many correct angles
// be sure to substitute the name of your top_level module here
// also, substitute names of your ports, as needed
TopLevel DUT(
  .clk   (clk),
  .start (start),
  .halt  (done)
  );

// behavioral model to match
cordic DUT1(
  x,y,r_beh,t_beh
   );

initial begin
  #10ns  start = 1'b1;
  #10ns for (int i=0; i<256; i++)    // clear data memory
        DUT.data_mem1.my_memory[i] = 8'b0;
// you may preload any desired constants into your data_mem1 here
//    ...
// case 1
  x = 12'h100;
  y = 12'h100;
  // DUT.data_mem1.core[1] = x[11:4];
  // DUT.data_mem1.core[2] = {x[3:0],4'h0};
  // DUT.data_mem1.core[3] = y[11:4];
  // DUT.data_mem1.core[4] = {y[3:0],4'h0};
  DUT.data_mem1.my_memory[1] = x[11:4];
  DUT.data_mem1.my_memory[2] = {x[3:0],4'h0};
  DUT.data_mem1.my_memory[3] = y[11:4];
  DUT.data_mem1.my_memory[4] = {y[3:0],4'h0};

// clear reg. file -- you may load any constants you wish here
  for(int i=0; i<16; i++)
  DUT.reg_file1.registers[i] = 8'b0;
// load instruction ROM -- unfilled elements will get x's -- should be harmless
  $readmemb("//Mac/Home/Desktop/cse141l-interpreter/verilog/tests/CORDIC_test/cordic.txt",DUT.instr_ROM1.instructions);
//  monitor ("x%d,y=%d,r=%f, t=%f", x,y,r_beh*0.6074/16.0,lookup[t_beh]);
  #10ns start = 1'b0;
  #100ns wait(done);
  #10ns  r_DUT = {DUT.data_mem1.my_memory[5],DUT.data_mem1.my_memory[6]};
         t_DUT = {DUT.data_mem1.my_memory[7],DUT.data_mem1.my_memory[8][7:4]};
  #10ns  $display(r_beh,,,t_beh,,,,,r_DUT,,,t_DUT);
  if(r_beh >= (r_DUT-1) && r_beh <= (r_DUT+1))   // score another successful trial
    scoreR++;
  if(t_beh >= (t_DUT-1) && t_beh <= (t_DUT+1))   // score another successful trial
    scoreR++;

// case 2
  #10ns  start = 1'b1;
  #10ns x = 12'h100;
        y = 12'h050;
  DUT.data_mem1.my_memory[1] = x[11:4];
  DUT.data_mem1.my_memory[2] = {x[3:0],4'h0};
  DUT.data_mem1.my_memory[3] = y[11:4];
  DUT.data_mem1.my_memory[4] = {y[3:0],4'h0};

// clear reg. file -- you may load any constants you wish here
  for(int i=0; i<16; i++)
  DUT.reg_file1.registers[i] = 8'b0;
// load instruction ROM -- unfilled elements will get x's -- should be harmless
  $readmemb("//Mac/Home/Desktop/cse141l-interpreter/verilog/tests/CORDIC_test/cordic.txt",DUT.instr_ROM1.instructions);
//  monitor ("x%d,y=%d,r=%f, t=%f", x,y,r_beh*0.6074/16.0,lookup[t_beh]);
  #10ns start = 1'b0;
  #100ns wait(done);
  #10ns  r_DUT = {DUT.data_mem1.my_memory[5],DUT.data_mem1.my_memory[6]};
         t_DUT = {DUT.data_mem1.my_memory[7],DUT.data_mem1.my_memory[8][7:4]};
  #10ns  $display(r_beh,,,t_beh,,,,,r_DUT,,,t_DUT);
  if(r_beh >= (r_DUT-1) && r_beh <= (r_DUT+1))   // score another successful trial
    scoreR++;
  if(t_beh >= (t_DUT-1) && t_beh <= (t_DUT+1))   // score another successful trial
    scoreR++;

// case 3
  #10ns  start = 1'b1;
  #10ns x = 12'h050;
        y = 12'h100;
  DUT.data_mem1.my_memory[1] = x[11:4];
  DUT.data_mem1.my_memory[2] = {x[3:0],4'h0};
  DUT.data_mem1.my_memory[3] = y[11:4];
  DUT.data_mem1.my_memory[4] = {y[3:0],4'h0};

// clear reg. file -- you may load any constants you wish here
  for(int i=0; i<16; i++)
  DUT.reg_file1.registers[i] = 8'b0;
// load instruction ROM -- unfilled elements will get x's -- should be harmless
  $readmemb("//Mac/Home/Desktop/cse141l-interpreter/verilog/tests/CORDIC_test/cordic.txt",DUT.instr_ROM1.instructions);
//  monitor ("x%d,y=%d,r=%f, t=%f", x,y,r_beh*0.6074/16.0,lookup[t_beh]);
  #10ns start = 1'b0;
  #100ns wait(done);
  #10ns  r_DUT = {DUT.data_mem1.my_memory[5],DUT.data_mem1.my_memory[6]};
         t_DUT = {DUT.data_mem1.my_memory[7],DUT.data_mem1.my_memory[8][7:4]};
  #10ns  $display(r_beh,,,t_beh,,,,,r_DUT,,,t_DUT);
  if(r_beh >= (r_DUT-1) && r_beh <= (r_DUT+1))   // score another successful trial
    scoreR++;
  if(t_beh >= (t_DUT-1) && t_beh <= (t_DUT+1))   // score another successful trial
    scoreR++;

  // case 4
  #10ns  start = 1'b1;
  #10ns x = 12'h100;
        y = 12'h000;
  DUT.data_mem1.my_memory[1] = x[11:4];
  DUT.data_mem1.my_memory[2] = {x[3:0],4'h0};
  DUT.data_mem1.my_memory[3] = y[11:4];
  DUT.data_mem1.my_memory[4] = {y[3:0],4'h0};

// clear reg. file -- you may load any constants you wish here
  for(int i=0; i<16; i++)
  DUT.reg_file1.registers[i] = 8'b0;
// load instruction ROM -- unfilled elements will get x's -- should be harmless
  $readmemb("//Mac/Home/Desktop/cse141l-interpreter/verilog/tests/CORDIC_test/cordic.txt",DUT.instr_ROM1.instructions);
//  monitor ("x%d,y=%d,r=%f, t=%f", x,y,r_beh*0.6074/16.0,lookup[t_beh]);
  #10ns start = 1'b0;
  #100ns wait(done);
  #10ns  r_DUT = {DUT.data_mem1.my_memory[5],DUT.data_mem1.my_memory[6]};
         t_DUT = {DUT.data_mem1.my_memory[7],DUT.data_mem1.my_memory[8][7:4]};
  #10ns  $display(r_beh,,,t_beh,,,,,r_DUT,,,t_DUT);
  if(r_beh >= (r_DUT-1) && r_beh <= (r_DUT+1))   // score another successful trial
    scoreR++;
  if(t_beh >= (t_DUT-1) && t_beh <= (t_DUT+1))   // score another successful trial
    scoreR++;


  #10ns $stop;
end

always begin
  #5ns  clk = 1'b1;
  #5ns  clk = 1'b0;
end

endmodule
