

module data_unpack_tb;

localparam LOOPS = 10000;

typedef logic [$ceil(32*LOOPS/7):0][6:0] packed_8;

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

integer seed = 1;

logic eop_delay;
logic sop_check;
logic eop_check;

logic [7] out_queue [$];
logic [32] in_queue [$];

packed_8 compare_array;

data_unpack DUT(.*);

initial
begin : CLOCK_RESET_CONTROL

    clk = 'b0;
    rst = 'b1;
    #50 rst = 'b0;

    repeat(LOOPS) 
    begin
        @(posedge clk);
        wait(valid_in);
    end
    data_compare(in_queue, out_queue);
    $finish;
end

always
#5 clk = ~clk;

always @(posedge clk)
begin : OUTPUT_MONITOR
    if(valid_out)
        out_queue.push_back(data_out);
end

always @(posedge clk)
begin : INPUT_CONTROL
    if(ready_out) 
    begin
        #($urandom_range(0,100));
        valid_in = 1;
        data_in = $urandom(seed);
        in_queue.push_back(data_in);
        if(10 > $urandom_range(0,100))
            sop_in = 1;
        if(10 > $urandom_range(0,100))
            eop_in = 1;
        wait(~ready_out);
    end 
    else 
    begin
        valid_in = 0;
        sop_in = 0;
        eop_in = 0;
    end
end

always @(posedge clk)
begin : SOP_EOP_SAVED
    if(valid_in)
    begin
        sop_check = sop_in;
        eop_check = eop_in;
    end
end

always
begin : SOP_CHECKER
    wait(valid_in)
    @(posedge clk)
    wait(valid_out)
    if(sop_out)
        assert(sop_check);
end

always
begin : EOP_CHECKER
    wait(valid_in)
    @(posedge clk)
    while(!ready_out)
    begin
        if(valid_out)
            eop_delay = eop_out;
        @(posedge clk);
    end
    if(eop_delay)
        assert(eop_check);
end

final
begin : PRINT_DATA
    /*
    $display("inputs: ");
    while (in_queue.size()) begin
        $write("%b ", in_queue.pop_front());
    end
    $display("");
    $displayb("outputs: ");
    while (out_queue.size()) begin
        $write("%b ", out_queue.pop_front());
    end
    $display("");
    */
end

endmodule