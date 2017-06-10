import LUT_def::*;
module LUT (
  input LUT_TYPE ctrl_lut_type,
  input logic[4:0] key,
  output logic[7:0] data_out
);

  always_comb begin
    data_out = kLookupTable[ctrl_lut_type][key];
  end

endmodule
