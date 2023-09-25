
module gearbox
# (
    parameter IN_WIDTH = 32,    // Width of input stream, must be larger than out
    parameter OUT_WIDTH = 7     // Width of output stream, must be larger than in
)
(
  input   wire            clk,    // System Clock
  input   wire            rst,     // Assuming active high reset
  
  input   wire                      valid_in,   // Signals when data_in is valid
  input   wire    [IN_WIDTH-1:0]    data_in,    // Input data stream

  output  logic                     valid_out,  // Raised when data_out is valid
  output  logic   [OUT_WIDTH-1:0]   data_out,   // Output data stream

  output  logic                     first_packet, // Signals if first packet of data_out
  output  logic                     last_packet   // Signals if last packet of data_out
);

logic   [IN_WIDTH+OUT_WIDTH-1:0]          build_reg;  // Shifts register to hold the concatenation of old and new data
logic   [$clog2(IN_WIDTH+OUT_WIDTH)-1:0]  valid_bits;   // The amount of bits in build_reg that hold valid data (little endian)

// FOR MONITORING DATA
/*
initial
  $monitor("GEARBOX: time = %t, rst = %d, valid_in = %d, valid_bits = %d, valid_out = %d, build_reg = %h, data_out = %h, first_packet = %h, last_packet = %h", 
            $time, rst, valid_in, valid_bits, valid_out, build_reg, data_out, first_packet, last_packet);
*/

assign valid_out = valid_bits <= IN_WIDTH;
assign first_packet = (valid_bits <= OUT_WIDTH);
assign last_packet = (valid_bits <= IN_WIDTH) && (valid_bits > (IN_WIDTH - OUT_WIDTH));


// Block chnges the value of valid_bits based on the valid signals
// Increases if data coming in (valid_in) and decreases if data coming out (valid_out)
always_ff@(posedge clk)
begin : VALID_DELTA
  if(rst)
    valid_bits <= $size(build_reg);
  else
    case({valid_out, valid_in})
    2'b01: valid_bits <= valid_bits - IN_WIDTH;
    2'b10: valid_bits <= valid_bits + OUT_WIDTH;
    2'b11: valid_bits <= valid_bits - IN_WIDTH + OUT_WIDTH;
    endcase
end

// Shifts old data when new data is ready to be accepted and puts new data in upper bits
always_ff@(posedge clk)
begin : BUILD_SHIFT
  if(rst) 
  begin
    build_reg <= 0;
  end
  else
    if(valid_in)
      build_reg <= {data_in, (build_reg[$size(build_reg)-1 -: OUT_WIDTH])};
    else if(valid_out) 
      begin
        //build_reg <= build_reg << OUT_WIDTH;
      end

end

// Output multiplexer that extracts the data output based on the number of valid bits
// which indicates the starting position of the build_reg
assign data_out = build_reg[(valid_bits) +: OUT_WIDTH];


endmodule