module stringsearch_tb;

bit  [511:0] string1;      // data_mem[32:95]
bit  [  3:0] sequence1;      // data_mem[9][3:0]
wire [  7:0] count_beh;
logic[  7:0] count_DUT;
bit          clk, start;
wire         done;
bit  [  7:0] score;            // how many correct trials
// be sure to substitute the name of your top_level module here
// also, substitute names of your ports, as needed
// top_level DUT(           // your top-level Verilog module
TopLevel DUT(          // your top-level Verilog module
  .clk   (clk),
  .start (start),
  .halt  (done)
  );

// purely behavioral model to match
// its output(s) = benchmark for your design
stringsearch DUT1(
  .string1 ,
  .sequence1,
  .count (count_beh)
   );

initial begin
  #10ns  start = 1'b1;
  #10ns for (int i=0; i<256; i++)    // clear data memory
        DUT.data_mem1.my_memory[i] = 8'b0;
// you may preload any desired constants into your data_mem here
//    ...
// now declare the searchable string and the 4-bit pattern itself
   string1   = {{102{5'b01001}},2'b0};//{128{4'b1001}};
   sequence1 = 4'b1001;
// load 4-bit pattern into memory address 9, LSBs
  DUT.data_mem1.my_memory[9] = {4'b0,sequence1};  // load "Waldo"
// load string to be searched -- watch Endianness
  for(int i=0; i<64; i++)
    DUT.data_mem1.my_memory[i+32] = string1[8*i+:8];
// clear reg. file -- you may load any constants you wish here
  for(int i=0; i<16; i++)
  DUT.reg_file1.registers[i] = 8'b0;
// load instruction ROM -- unfilled elements will get x's -- should be harmless
  $readmemb("./lab4/verilog/tests/stringsearch/machine_code.txt",DUT.instr_ROM1.instructions);
//  $monitor ("string=%b,sequence=%b,count=%d\n",string1, sequence1, count);
  #10ns start = 1'b0;
  #100ns wait(done);
  #10ns  count_DUT = DUT.data_mem1.my_memory[10];
  #10ns  $display(count_beh,,,count_DUT);
  if(count_beh == count_DUT)   // score another successful trial
    score++;
  #10ns;
// shall we have another go?
  #10ns start = 1'b1;
   string1   = {{102{5'b01101}},2'b0};//{128{4'b1001}};
   sequence1 = 4'b1101;
// load 4-bit pattern into memory address 9, LSBs
  DUT.data_mem1.my_memory[9] = {4'b0,sequence1};  // load "Waldo"
// load string to be searched -- watch Endianness
  for(int i=0; i<64; i++)
    DUT.data_mem1.my_memory[i+32] = string1[8*i+:8];
// clear reg. file -- you may load any constants you wish here
  for(int i=0; i<16; i++)
  DUT.reg_file1.registers[i] = 8'b0;
// load instruction ROM -- unfilled elements will get x's -- should be harmless
  $readmemb("./lab4/verilog/tests/stringsearch/machine_code.txt",DUT.instr_ROM1.instructions);
//  $monitor ("string=%b,sequence=%b,count=%d\n",string1, sequence1, count);
  #10ns start = 1'b0;
  #100ns wait(done);
  #10ns  count_DUT = DUT.data_mem1.my_memory[10];
  #10ns  $display(count_beh,,,count_DUT);
  if(count_beh == count_DUT)   // score another successful trial
    score++;
  #10ns;

// one more time!
   start = 1'b1;
   string1   = '1;//{{102{5'b01001}},2'b0};//{128{4'b1001}};
   sequence1 = 4'b1111;
// load 4-bit pattern into memory address 9, LSBs
  DUT.data_mem1.my_memory[9] = {4'b0,sequence1};  // load "Waldo"
// load string to be searched -- watch Endianness
  for(int i=0; i<64; i++)
    DUT.data_mem1.my_memory[i+32] = string1[8*i+:8];
// clear reg. file -- you may load any constants you wish here
  for(int i=0; i<16; i++)
  DUT.reg_file1.registers[i] = 8'b0;
// load instruction ROM -- unfilled elements will get x's -- should be harmless
  $readmemb("./lab4/verilog/tests/stringsearch/machine_code.txt",DUT.instr_ROM1.instructions);
//  $monitor ("string=%b,sequence=%b,count=%d\n",string1, sequence1, count);
  #10ns start = 1'b0;
  #100ns wait(done);
  #10ns  count_DUT = DUT.data_mem1.my_memory[10];
  #10ns  $display(count_beh,,,count_DUT);
  if(count_beh == count_DUT)   // score another successful trial
    score++;
  #10ns      $stop;
end

always begin
  #5ns  clk = 1'b1;
  #5ns  clk = 1'b0;
end

endmodule
