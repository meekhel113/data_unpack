// Code your design here
module data_unpack
(
  input wire clk,
  input wire rst,     // Assuming active high reset
  
  output logic ready_out, // Can be used to back pressure the input data stream
  input wire valid_in,
  input wire [31:0] data_in,
  input wire sop_in,
  input wire eop_in,

  output logic valid_out,
  output logic [6:0] data_out,
  output logic sop_out,
  output logic eop_out
);
  
  logic first_packet;
  logic last_packet;
  logic eop_reg;
  logic sop_reg;
  logic valid_ready;

  assign sop_out = first_packet & sop_reg;
  assign eop_out = last_packet & eop_reg;
  assign valid_ready = valid_in & ready_out;

  gearbox gearbox_inst 
  #(
    IN_WIDTH = 32;
    OUT_WIDTH = 7;
  ) (
    .valid_in (valid_ready)
    .*
  );

  assign ready_out = !valid_out;

  always_ff@(posedge clk)
  begin
    if(rst)
      eop_reg = 'd0;
      sop_reg = 'd0;
    else
      if(valid_ready)
      begin
        eop_reg = eop_in;
        sop_reg = sop_in;
      end
  end
  
endmodule