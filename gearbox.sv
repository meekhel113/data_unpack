
module data_unpack
# (
    IN_WIDTH = 32;
    OUT_WIDTH = 7;
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

assign valid_out = valid_bits > OUT_WIDTH;
assign first_packet = valid_bits > IN_WIDTH;
assign last_packet = (valid_bits > OUT_WIDTH) && (valid_bits < 2*OUT_WIDTH);

always_ff@(posedge clk)
begin
  if(rst)
    valid_bits <= 0;
  else
    case({valid_out, valid_in})
    2'b01: valid_bits <= valid_bits + IN_WIDTH;
    2'b10: valid_bits <= valid_bits - OUT_WIDTH;
    2'b11: valid_bits <= valid_bits + IN_WIDTH - OUT_WIDTH;
    endcase
end

always_ff@(posedge clk)
begin
  if(rst)
    build_reg <= 0;
    data_out <= 0;
  else
    if(valid_in)
      build_reg <= {(build_reg << IN_WIDTH), data_in};
    else if(valid_out)
      {data_out, build_reg} <= build_reg << OUT_WIDTH;
end


endmodule