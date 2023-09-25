
// Testbench for checking data unpacker
module data_unpack_tb;

localparam LOOPS = 10000;  // Total amount of inputs to be sent

logic clk;  // System clock
logic rst;  // System reset, active high

// Input Module signals
wire ready_out;
logic valid_in;
logic [31:0] data_in;
logic sop_in;
logic eop_in;

// Output Module signals
wire valid_out;
wire [6:0] data_out;
wire sop_out;
wire eop_out;

// Seed for random use
integer seed = 1;

// Used to check sop and eop outputs
logic eop_delay;
logic sop_check;
logic eop_check;

// Queues for recording input stream, output stream, and eop history
logic [7] out_queue [$];
logic [32] in_queue [$];
logic [1] eop_queue [$];


// DUT Instantiatin
data_unpack DUT(.*);

// Highlevel System TB Contrl
initial
begin : CLOCK_RESET_CONTROL

    clk = 'b0;
    rst = 'b1;
    #50 rst = 'b0; // Hold Reset for 50 ns

    repeat(LOOPS) 
    begin
        @(posedge clk);
        wait(valid_in); // Send input signal for LOOP times
    end
    data_compare(in_queue, out_queue, eop_queue); // Compare after all LOOPs have completed
    $finish;
end

// Generate clock signal
always
#5 clk = ~clk;

// Record output stream if valid
always @(posedge clk)
begin : OUTPUT_MONITOR
    if(valid_out) begin
        out_queue.push_back(data_out);
        eop_queue.push_back(eop_out);
    end
end

// Control input signals
always @(posedge clk)
begin : INPUT_CONTROL
    if(ready_out) 
    begin
        #($urandom_range(0,100));
        valid_in = 1;                   // Set input valid
        data_in = $urandom(seed);       // Generate a random input, 32 bit
        in_queue.push_back(data_in);    // Record input
        if(10 > $urandom_range(0,100))  // Randomly generate sop (10%)
            sop_in = 1;
        if(10 > $urandom_range(0,100))  // Randomly generate eop (10%)
            eop_in = 1;
        wait(~ready_out);               // Wait until DUT is ready for next input
    end 
    else        // Do not hold flags for longer than 1 cycle
    begin
        valid_in = 0;
        sop_in = 0;
        eop_in = 0;
    end
end

// Register sop and eop flags for checker
always @(posedge clk)
begin : SOP_EOP_SAVED
    if(valid_in)
    begin
        sop_check = sop_in;
        eop_check = eop_in;
    end
end

// First packet after sop_in should have sop_out
always
begin : SOP_CHECKER
    wait(valid_in)
    @(posedge clk)
    wait(valid_out)
    if(sop_out)
        assert(sop_check);
end

// Last packet after eop_in should have eop_out
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

// For Debugging: Print input and output data after finish
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