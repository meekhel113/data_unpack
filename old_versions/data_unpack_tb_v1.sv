module data_unpack_tb;

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
integer EX_LOOPS = 10;
integer LOOPS = 1000;
integer out_counts;
logic eop_delay;
integer END_LOOP = $urandom_range(0,1000);

logic [223:0] data_in_source;
logic [223:0] data_out_source;

data_unpack DUT(.*);

always
#5 clk = ~clk;

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, DUT);

    $display("Running %d loops, ending at loop %d", LOOPS, END_LOOP);

    clk = 'b0;
    rst = 'b0;
    #50 rst = 'b1;

    for(integer i=0; i<EX_LOOPS; i++) begin

        wait(ready_out);
    
        for(integer j=0; j<LOOPS; j++) begin

            if(j % 7 == 0) begin
                data_in_source = {32{$urandom(seed)}};
                data_out_source = data_in_source;
            
            end

            if(j == 0) sop_in = 1;
            else sop_in = 0;

            if(j == END_LOOP-1) eop_in = 1;
            else eop_in = 0;
            
            data_in = data_in_source[31:0];
            
            if(j < END_LOOP) begin
                valid_in = 1;

                out_counts = 0;

                wait(!ready_out);
                valid_in = 0;

                while(ready_out == 0) begin
                    wait(valid_out); 
                    @(posedge clk);

                    if(valid_out) begin
                        if(sop_in & (out_counts == 0)) begin
                            assert(sop_out);
                        end

                        assert(data_out == data_out_source[6:0]);

                        out_counts++;

                        data_out_source = data_out_source >> 7;
                    end
                    assert(out_counts < 6);
                    if(ready_out == 0) 
                        eop_delay = eop_out;
                end
                if(eop_in) begin
                    assert(eop_delay);
                end
                
                data_in_source = data_in_source >> 32;

            end
            else assert(!valid_out);

            // WAIT random time period before next
            #($urandom_range(0,100));
            
        end

    #($urandom_range(0,100));
    end
    
    #100;
$finish;

end



endmodule