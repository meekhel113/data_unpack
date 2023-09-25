// Code your design here
module data_unpack
(
  input wire clk,     // System block
  input wire rst,     // Assuming active high reset
  
  output logic ready_out,     // Can be used to back pressure the input data stream
  input wire valid_in,        // Signals when data_in is valid and ready to be accepted
  input wire [31:0] data_in,  // Input data stream, 32 bits
  input wire sop_in,          // Signals start of packet for input stream
  input wire eop_in,          // Signals end of packet for input stream

  output logic valid_out,       // Raised when data_out is valid
  output logic [6:0] data_out,  // Output data_stream (7 bits)
  output logic sop_out,         // Raised on the first packet 
  output logic eop_out          // Raised on the last packet
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
  assign valid_ready = valid_in & ready_out;    // Ready if the data is valid and gearbox is ready


  // Instantiation of gearbox, input 32 and output 7
  gearbox # (
    .IN_WIDTH  (32 ),
    .OUT_WIDTH (7  )
  ) 
  gearbox_inst (
    .rst( rst | restart),
    .valid_in (valid_ready),
    .*
  );

  // Module is ready when the gearbox is not outputting data, or an eop is not in effect
  assign ready_out = ~valid_out & ~restart;

  // Register sop and eop in signals for output usage
  always_ff@(posedge clk)
  begin : PACKET_FLAGS
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

  // If an eop is received, the gearbox is reset to initial state
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