
module gearbox
# (
    parameter IN_WIDTH = 32,
    parameter OUT_WIDTH = 7
)
(
  input   wire            clk,
  input   wire            rst,     // Assuming active high reset
  
  input   wire                      valid_in,
  input   wire    [IN_WIDTH-1:0]    data_in,

  output  logic                     valid_out,
  output  logic   [OUT_WIDTH-1:0]   data_out,

  output  logic                     first_packet,
  output  logic                     last_packet
);

logic   [IN_WIDTH+OUT_WIDTH-1:0]          build_reg;
logic   [$clog2(IN_WIDTH+OUT_WIDTH)-1:0]  valid_bits;

// FOR MONITORING DATA
/*
initial
  $monitor("GEARBOX: time = %t, rst = %d, valid_in = %d, valid_bits = %d, valid_out = %d, build_reg = %h, data_out = %h, first_packet = %h, last_packet = %h", 
            $time, rst, valid_in, valid_bits, valid_out, build_reg, data_out, first_packet, last_packet);
*/

assign valid_out = valid_bits <= IN_WIDTH;
assign first_packet = (valid_bits <= OUT_WIDTH);
assign last_packet = (valid_bits <= IN_WIDTH) && (valid_bits > (IN_WIDTH - OUT_WIDTH));

always_ff@(posedge clk)
begin
  if(rst)
    valid_bits <= $size(build_reg);
  else
    case({valid_out, valid_in})
    2'b01: valid_bits <= valid_bits - IN_WIDTH;
    2'b10: valid_bits <= valid_bits + OUT_WIDTH;
    2'b11: valid_bits <= valid_bits - IN_WIDTH + OUT_WIDTH;
    endcase
end

always_ff@(posedge clk)
begin
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

assign data_out = build_reg[(valid_bits) +: OUT_WIDTH];


endmodule