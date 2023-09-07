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
  logic restart;

  // FOR MONITORING DATA
  /*
  initial
    $monitor("DATA UNPACK: time = %t, valid_in = %d, ready_out = %d, valid_out = %d, data_in = %h, data_out = %h, sop_out = %h, eop_out = %h, restart = %b", 
              $time, valid_in, ready_out, valid_out, data_in, data_out, sop_out, eop_out, restart);
  */

  assign sop_out = first_packet & sop_reg;
  assign eop_out = last_packet & eop_reg;
  assign valid_ready = valid_in & ready_out;

  gearbox # (
    .IN_WIDTH  (32 ),
    .OUT_WIDTH (7  )
  ) 
  gearbox_inst (
    .rst( rst | restart),
    .valid_in (valid_ready),
    .*
  );

  assign ready_out = ~valid_out & ~restart;

  always_ff@(posedge clk)
  begin
    if(rst) 
    begin
      eop_reg = '0;
      sop_reg = '0;
    end
    else
      if(valid_ready)
      begin
        eop_reg = eop_in;
        sop_reg = sop_in;
      end
  end

  always_ff@(posedge clk)
  begin
    if(rst)
      restart <= '0;
    else
      if(eop_out)
        restart <= 1;
      else
        restart <= 0;
  end
  
endmodule