`timescale 1ns / 1ps


module accumulator
#(parameter NETWORK_SIZE=256)
(input clk,
input rst,
input MUL_ACC_valid,
input [TYPE_WIDTH-1:0] MUL_ACC_type,
input [SEQ_WIDTH-1:0] MUL_ACC_seqNum,
input [$clog(NETWORK_SIZE)-1:0] MUL_ACC_inputNum,
input [PAYLOAD_WIDTH-1:0] MUL_ACC_data,
output MUL_ACC_halt,
input ACC_AF_halt,
output ACC_AF_valid,
output [TYPE_WIDTH-1:0] ACC_AF_type,
output [SEQ_WIDTH-1:0] ACC_AF_seqNum,
output [$clog2(NETWORK_SIZE)+PAYLOAD_WIDTH-1:0] ACC_AF_data
);

localparam PAYLOAD_WIDTH=32, 
SOURCE_START=PAYLOAD_WIDTH, SOURCE_WIDTH=$clog2(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH, DEST_WIDTH=$clog2(NETWORK_SIZE),
SEQ_START=DEST_START+DEST_WIDTH,SEQ_WIDTH=$clog2($sqrt(NETWORK_SIZE)*2),
TYPE_START=SEQ_START+SEQ_WIDTH, TYPE_WIDTH=3,
PACKET_SIZE=TYPE_START+TYPE_WIDTH;

localparam DATA=000, CONF_INB=001, CONF_AFUB=110, CONF_AFLB=101, CONF_AFLUT=100, CONF_W=010;

reg registered_valid;
reg [TYPE_WIDTH-1:0] registered_type;
reg [SEQ_WIDTH-1:0] registered_seqNum;
reg [$clog(NETWORK_SIZE)-1:0] registered_inputNum;
reg [PAYLOAD_WIDTH-1:0] registered_data;


reg signed [PAYLOAD_WIDTH-1:0] bias;
reg signed [$clog2(NETWORK_SIZE)+PAYLOAD_WIDTH-1:0] result;
reg [$clog(NETWORK_SIZE)-1:0] inputNum, counter;

wire [$clog2(NETWORK_SIZE)+PAYLOAD_WIDTH-1:0] summand[1:0], sum;

wire nextSum;

//Port assignemnts
assign ACC_AF_valid=registered_valid&(nextSum|registered_type!=DATA);
assign ACC_AF_type=registered_type;
assign ACC_AF_data=(registered_type==DATA)?sum:{registered_inputNum, registered_data};
assign MUL_ACC_halt=ACC_AF_halt&registered_valid;

//Internal assignments
assign summand[0]=(counter==0)?bias:result;
assign summand[1]=$signed(registered_data);
assign nextSum=registered_type==DATA&(counter+1)==inputNum?1'b1:1'b0;
assign sum=summand[0]+summand[1];

always @(posedge clk)
begin
if(rst)
begin
    registered_data<=0;
    registered_inputNum<=0;
    registered_type<=0;
    registered_valid<=0;
end
else if(!MUL_ACC_halt)
begin
    registered_data<=MUL_ACC_data;
    registered_inputNum<=MUL_ACC_inputNum;
    registered_type<=MUL_ACC_type;
    registered_valid<=MUL_ACC_valid;
end
end

always @(posedge clk)
begin
if(rst)
begin
    bias<=0;
    result<=0;
    inputNum<=0;
    counter<=0;
end
else if(registered_valid&!ACC_AF_halt)
begin
     case(registered_type) 
 	CONF_INB:
 	  begin
        bias<=registered_bias;
        inputNum<=registered_inputNum;
      end	
    DATA:
      if(!MUL_ACC_halt)
      begin
        if(nextSum)
		  counter<=0;
        else
        begin
	       result<=sum;
           counter<=counter+1; 
        end
       end       
    endcase
end
end


endmodule
