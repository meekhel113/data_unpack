

module data_unpack_basic_tb;

logic clk;
logic rst;
  
wire ready_out;
logic valid_in;
logic [31:0] data_in;
logic sop_in;
logic eop_in;

wire valid_out;
wire [6:0] data_out;
wire sop_out;
wire eop_out;

data_unpack DUT(.*);

always
#5 clk = ~clk;

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, DUT);

$monitor( "t = %3d, rst = %b, data_in = %h, ready_out = %b, sop_out = %b, eop_out = %b, valid_out = %b, data_out = %h", 
            $time, rst, data_in, ready_out, sop_out, eop_out, valid_out, data_out); 

clk = 'b0;
rst = 'b0;
#50 rst = 'b1;
sop_in = 'b0;
eop_in = 'b0;
data_in = 32'b0;
valid_in = 'b0;
#10

sop_in = 1'b1;
wait(ready_out);
data_in = 32'h12345678;
valid_in = 1'b1;

wait(!ready_out);
valid_in = 'b0;

wait(ready_out);
sop_in = 1'b0;
data_in = 32'h9abcdef0;
valid_in = 1'b1;

wait(!ready_out);
valid_in = 'b0;

wait(ready_out);
data_in = 32'h0fedcba9;
valid_in = 1'b1;

wait(!ready_out);
valid_in = 'b0;

wait(ready_out);
data_in = 32'h87654321;
valid_in = 1'b1;

wait(!ready_out);
valid_in = 'b0;

wait(ready_out);
data_in = 32'h56781234;
valid_in = 1'b1;

wait(!ready_out);
valid_in = 'b0;

wait(ready_out);
data_in = 32'hdef09abc;
valid_in = 1'b1;

wait(!ready_out);
valid_in = 'b0;

wait(ready_out);
data_in = 32'h55555555;
valid_in = 1'b1;

wait(!ready_out);
valid_in = 'b0;

wait(ready_out);
data_in = 32'hAAAAAAAA;
valid_in = 1'b1;
eop_in = 1'b1;

wait(!ready_out);
valid_in = 'b0;

wait(ready_out);
valid_in = 1'b0;

#100

$finish;

end


endmodule