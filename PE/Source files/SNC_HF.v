`timescale 1ns / 1ps
`define DATA 000
`define CONF_INB 001
`define CONF_AFUB 110
`define CONF_AFLB 101
`define CONF_AFLUT 100
`define CONF_W 010

module seqNumCheck
#(parameter NETWORK_SIZE=256)

(input clk,
input rst,
input NI_SNC_valid,
input [PACKET_SIZE-1:0] NI_SNC_packet,
input SNC_MUL_halt,
output SNC_MUL_valid,
output [TYPE_WIDTH-1:0] SNC_MUL_type,
output [SEQ_WIDTH-1:0] SNC_MUL_seqNum,
output [PAYLOAD_WIDTH+SOURCE_WIDTH-1:0] SNC_MUL_data
);

localparam PAYLOAD_WIDTH=32,SOURCE_START=PAYLOAD_WIDTH, SOURCE_WIDTH=$clog2(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH, DEST_WIDTH=$clog2(NETWORK_SIZE),
SEQ_START=DEST_START+DEST_WIDTH,SEQ_WIDTH=$clog2($sqrt(NETWORK_SIZE)*2),
TYPE_START=SEQ_START+SEQ_WIDTH, TYPE_WIDTH=3,
PACKET_SIZE=TYPE_START+TYPE_WIDTH;

localparam DATA=000, CONF_INB=001, CONF_AFUB=110, CONF_AFLB=101, CONF_AFLUT=100, CONF_W=010;
   
reg [SEQ_WIDTH-1:0] currentSeqNum;
reg [$clog2(NETWORK_SIZE)-1:0] counter[2^(SEQ_WIDTH)-1:0], currentCounter;
reg [$clog2(NETWORK_SIZE)-1:0] inputNum;   
   
wire [PACKET_SIZE-1:0] currentPacket;
wire  hashTable_writeEnable;
wire  [$clog2(NETWORK_SIZE*2^(SEQ_WIDTH))-1:0] hashTable_readIndex, hashTable_writeIndex;
wire nextSeqNum;


distributedRAM_simpleDualPort #(.DRAM_DEPTH(NETWORK_SIZE*2^SEQ_WIDTH), .DRAM_WIDTH(PACKET_SIZE)) 
hashTable(
.clk(clk),
.we(hashTable_writeEnable),
.a(hashTable_writeIndex),
.dpra(hashTable_readIndex),
.d(NI_SNC_packet),
.dpo(currentPacket)
); 

//port assingments 
assign SNC_MUL_valid=(currentCounter==counter[currentSeqNum])?1'b0:1'b1;
assign SNC_MUL_type=currentPacket[TYPE_START+:TYPE_WIDTH];
assign SNC_MUL_seqNum=currentPacket[SEQ_START+:SEQ_WIDTH];
assign SNC_MUL_data=currentPacket[0+:SOURCE_WIDTH+PAYLOAD_WIDTH];


//hash table assignemnts
assign hashTable_writeEnable=NI_SNC_valid;
assign hashTable_writeIndex=hashFunction(NI_SNC_packet[SEQ_START+:SEQ_WIDTH], counter[NI_SNC_packet[SEQ_START+:SEQ_WIDTH]]);
assign hashTable_readIndex=hashFunction(currentSeqNum, currentCounter);

//internal assignemnts
assign nextSeqNum=((currentCounter+1)==inputNum|currentPacket[TYPE_START+:TYPE_WIDTH]!=DATA|currentPacket[TYPE_START+:TYPE_WIDTH])&SNC_MUL_valid&!SNC_MUL_halt!=CONF_W?1'b1:1'b0;


always @(posedge clk) 
begin
  if(rst)
  begin
   for(i=0;i<2^SEQ_WIDTH;i=i+1)
    counter[i]<=0;
  end  
  else 
  begin
    if(NI_SNC_valid)
    counter[NI_SNC_packet[SEQ_START+:SEQ_WIDTH]]<=counter[NI_SNC_packet[SEQ_START+:SEQ_WIDTH]]+1;
    if((currentSeqNum!=NI_SNC_packet[SEQ_START+:SEQ_WIDTH]))
        if(nextSeqNum)
            counter[currentSeqNum]<=0;
  end    
end


always @(posedge clk)
begin
  if(rst)
    begin
    currentCounter<=0;
    currentSeqNum<=0;
    inputNum<=0;
    end
  else if (SNC_MUL_valid&!SNC_MUL_halt)
    begin  
        if (nextSeqNum)
        begin
        currentCounter<=0;
        currentSeqNum<=currentSeqNum+1;
            if(packetType==CONF_INB)
                inputNum<=currentPacket[SOURCE_START+:SOURCE_WIDTH];
        end
        else
        currentCounter<=currentCounter+1;
    end
end

function [$clog2(NETWORK_SIZE*2^(SEQ_WIDTH))-1:0] hashFunction(input [SEQ_WIDTH-1:0] key1, input [$clog2(NETWORK_SIZE)-1:0] key2);
begin
hashFunction=key1*2^($clog2(NETWORK_SIZE))+key2;
end
endfunction   
endmodule
