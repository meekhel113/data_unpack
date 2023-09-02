// Code your design here
module data_unpack
(
  input wire clk,
  input wire rst,     // Assuming active high reset
  
  output logic ready_out, // Can be used to back pressure the input data stream
  input wire valid_in,
  input wire [31:0] data_in,
  input wire sop_in,
  input wire eop_in,

  output logic valid_out,
  output logic [6:0] data_out,
  output logic sop_out,
  output logic eop_out
);
  
  typedef enum logic [1:0] {
    IDLE,
    LOAD,
    RUN,
    WAIT
  } STATES;
  
  STATES state;
  STATES next_state;
  logic [31:0] data_in_reg;
  logic [2:0] packet_num;
  logic [2:0] shift_counts;
  logic data_done;
  logic eop_reg;
  logic [6:0] residual_bits;

  assign ready_out = (state == IDLE) | (state == WAIT);

  always_ff@(posedge clk)
    begin
      if(rst)
        eop_reg = 'd0;
      else
        if(state == LOAD)
          eop_reg = eop_in;
    end
          
  always_ff@(posedge clk)
    begin
      if(rst)
        sop_out = 'd0;
      else
        if(state == LOAD)
          sop_out = sop_in;
        else
          sop_out = 1'b0;
    end

  assign eop_out = (state == RUN) & data_done & eop_reg;
  
  always_ff@(posedge clk)
    begin
      if(rst)
        state <= IDLE;
      else
        state <= next_state;
    end
  
  always_comb@(*)
    begin
      case(state)
        IDLE: 
          begin
            if(ready_out & valid_in)
              next_state = LOAD;
            else 
              next_state = IDLE;
          end
        LOAD:
          next_state = RUN;
        RUN:
          begin
            if(data_done)
              if(eop_reg)
                next_state = IDLE;
              else
                next_state = WAIT;
            else
              next_state = RUN;
          end
        WAIT:
          begin
            if(ready_out & valid_in)
              next_state = LOAD;
            else 
              next_state = WAIT;
          end
        default:
          next_state = IDLE;
      endcase
    end
  
  always_ff@(posedge clk)
    begin
      if(rst)
        packet_num <= 3'd0;
      else
        case(state)
          IDLE: 
            packet_num <= 3'd0;
          WAIT: 
            begin
              if(ready_out & valid_in) begin
                packet_num <= packet_num + 1;
                if(packet_num == 3'd6)
                  packet_num <= 3'd0;
              end
            end
        endcase
    end
  
  always_ff@(posedge clk)
    begin
      if(rst)
        data_in_reg = 'd0;
      else
        begin
          case(state)
            LOAD:
              begin
                case(packet_num)
                    3'd0: data_in_reg <= data_in[31:7];
                    3'd1: data_in_reg <= data_in[31:3];
                    3'd2: data_in_reg <= data_in[31:6];
                    3'd3: data_in_reg <= data_in[31:2];
                    3'd4: data_in_reg <= data_in[31:5];
                    3'd5: data_in_reg <= data_in[31:1];
                    3'd6: data_in_reg <= data_in[31:4];
                  default: data_in_reg = 'd0;
                endcase
              end
            RUN:
              begin
                data_in_reg[6:0] <= data_in_reg[13:7];
                data_in_reg[13:7] <= data_in_reg[20:14];
                data_in_reg[20:14] <= data_in_reg[27:21];
                data_in_reg[27:21] <= data_in_reg[31:28];
              end
            default:
              data_in_reg = 'd0;
          endcase
        end
    end
  
  always_ff@(posedge clk)
    begin
      if(rst)
        residual_bits <= 'd0;
      else
        if( (state == RUN) && (data_done))
          residual_bits <= data_in_reg[6:0];
    end

  always_ff@(posedge clk)
    begin
      if(rst)
        data_out <= 'd0;
      else
        case(state)
          LOAD:
            case(packet_num)
              3'd0: data_out <= data_in[6:0];
              3'd1: data_out <= {data_in[2:0], residual_bits[3:0]};
              3'd2: data_out <= {data_in[5:0], residual_bits[0:0]};
              3'd3: data_out <= {data_in[1:0], residual_bits[4:0]};
              3'd4: data_out <= {data_in[4:0], residual_bits[1:0]};
              3'd5: data_out <= {data_in[0:0], residual_bits[5:0]};
              3'd6: data_out <= {data_in[3:0], residual_bits[2:0]};
              default: data_out = 'd0;
            endcase
          RUN:
            data_out <= data_in_reg[6:0];
          default:
            data_out <= 'd0;
        endcase
    end
  
  assign valid_out = ( (state == RUN) );
  
  always_ff@(posedge clk)
    begin
      if(rst)
        shift_counts <= 3'b0;
      else
        case(state)
          LOAD:
            case(packet_num)
              3'd0: shift_counts <= 3'd3;
              3'd1: shift_counts <= 3'd4;
              3'd2: shift_counts <= 3'd3;
              3'd3: shift_counts <= 3'd4;
              3'd4: shift_counts <= 3'd3;
              3'd5: shift_counts <= 3'd4;
              3'd6: shift_counts <= 3'd4;
              default: shift_counts <= 3'd0;
            endcase
          RUN:
            shift_counts <= shift_counts - 1;
        endcase
    end
  
  assign data_done = (shift_counts == 3'd0);
  
  
  
endmodule