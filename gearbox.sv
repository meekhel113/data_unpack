
module data_unpack
# (
    IN_WIDTH = 32;
    OUT_WIDTH = 7;
)
(
  input wire clk,
  input wire rst,     // Assuming active high reset
  
  input wire valid_in,
  input wire [31:0] data_in,

  output logic valid_out,
  output logic [6:0] data_out,
);

logic   [32+7-1:0]          build_reg;
logic   [$clog2(32+7)-1:0]  valid_bits;

assign valid_out = valid_bits > 7;

always_ff@(posedge clk)
begin
  if(rst)
    valid_bits <= 0;
  else
    case({valid_out, valid_in})
    2'b01: valid_bits <= valid_bits + 32;
    2'b10: valid_bits <= valid_bits - 7;
    2'b11: valid_bits <= valid_bits + 32 - 7;
    endcase
end

always_ff@(posedge clk)
begin
  if(rst)
    build_reg <= 0;
  else
    if(valid_in)
      build_reg <= 0; //FILL THIS IN
    else if(valid_out)
      build_reg <= build_reg << 7;
end


endmodule