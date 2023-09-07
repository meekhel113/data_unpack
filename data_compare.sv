

task data_compare
(
    input [32] in_queue [$],
    input [7] out_queue [$]
);

logic [32] local_in [$];
logic [7] local_out [$];

logic [31:0] logic_in_single;
logic [6:0] logic_out_single;

integer in_count;
integer out_count;

in_count = 32;
out_count = 7;

while (local_out.size() > 0) 
begin
    if(in_count == 32) begin
        in_count = 0;
        logic_in_single = in_queue.pop_front();
    end
    if(out_count == 7) begin
        out_count = 0;
        logic_out_single = out_queue.pop_front();
    end
    assert(logic_in_single[in_count] == logic_out_single[out_count]);
    if(logic_in_single[in_count] != logic_out_single[out_count]) begin
        $display("ERROR: in[%d] = %b vs. out[%d] = %b", in_count, logic_in_single[in_count], out_count, logic_out_single[out_count]);
    end
    in_count++;
    out_count++;
end
    

endtask