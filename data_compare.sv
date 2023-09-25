
// Used to compare the input and output streams 
task data_compare
(
    input [32] in_queue [$],    // Contains entire input stream
    input [7] out_queue [$],    // Contains entire output stream
    input eop_queue[$]          // Contains eop history (for comparison)
);

logic [31:0] logic_in_single;   // A single instance of the input stream
logic [6:0] logic_out_single;   // A single instance of the output stream
logic       eop_single;         // A signal instance of the eop history

integer in_count;   // Counter for bit within input stream
integer out_count;  // COunter for bit within output stream

in_count = 32; //Initial values
out_count = 7;

// Loop while output stream exists
while (out_queue.size() > 0) 
begin : COMPARE
    // If the last bit of input instance has been reach, retrieve next
    if( (in_count == 32) || eop_single) begin
        in_count = 0;
        logic_in_single = in_queue.pop_front();
    end
    // If the last bit of output instance has been reach, retrieve next
    if((out_count == 7) || eop_single) begin
        eop_single = eop_queue.pop_front();
        out_count = 0;
        logic_out_single = out_queue.pop_front();
    end
    // Checked that the bits are equal
    assert(logic_in_single[in_count] == logic_out_single[out_count]);
    // For debugging: if bits are not equal, print comparison to console
    if(logic_in_single[in_count] != logic_out_single[out_count]) begin
        $display("ERROR: in[%d] = %b vs. out[%d] = %b", in_count, logic_in_single[in_count], out_count, logic_out_single[out_count]);
    end

    // Increment each count
    in_count++;
    out_count++;
end
    

endtask