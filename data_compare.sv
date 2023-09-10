

task data_compare
(
    input [32] in_queue [$],
    input [7] out_queue [$],
    input eop_queue[$]
);

logic [31:0] logic_in_single;
logic [6:0] logic_out_single;
logic       eop_single;

integer in_count;
integer out_count;

in_count = 32;
out_count = 7;

while (out_queue.size() > 0) 
begin
    if( (in_count == 32) || eop_single) begin
        in_count = 0;
        logic_in_single = in_queue.pop_front();
    end
    if((out_count == 7) || eop_single) begin
        eop_single = eop_queue.pop_front();
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