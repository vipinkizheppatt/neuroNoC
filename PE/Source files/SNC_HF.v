`timescale 1ns / 1ps
`define CONF_INPUTNUM 01

module seqNumCheck_HashFunction
#(parameter NETWORK_SIZE=256, PAYLOAD_WIDTH=22, 
SEQ_START=PAYLOAD_WIDTH, SEQ_WIDTH=4, 
SOURCE_START=SEQ_START+SEQ_WIDTH, SOURCE_WIDTH=$clog(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH,DEST_WIDTH=$clog(NETWORK_SIZE),
TYPE_START=DEST_START+DEST_WIDTH, TYPE_WIDTH=2,
PACKET_SIZE=TYPE_START+TYPE_WIDTH)
(input clk,
input rst,
input NI_SNC_valid,
input [PACKET_SIZE-1:0] NI_SNC_packet,
output NI_SNC_ready,
output SNC_MUL_valid,
output [PACKET_SIZE-1:0] SNC_MUL_packet
);

   
reg [SEQ_WIDTH-1:0] currentSeqNum;
reg [$clog(NETWORK_SIZE)-1:0] counter[2^(SEQ_WIDTH)-1:0], currentCounter;
reg [$clog(NETWORK_SIZE)-1:0] inputNum;   
   
wire [PACKET_SIZE-1:0] dram_writeData, dram_readData;
wire  dram_writeEnable;
wire  [$clog(NETWORK_SIZE*2^(SEQ_WIDTH))-1:0] dram_readAddress, dram_writeAddress;

distributedRAM_simpleDualPort #(.DRAM_DEPTH(NETWORK_SIZE*2^SEQ_WIDTH), .DRAM_WIDTH(PACKET_SIZE)) dram(
.clk(clk),
.we(dram_writeEnable),
.a(dram_writeAddress),
.dpra(dram_readAddress),
.d(dram_writeData),
.dpo(dram_readData)
); 
 
assign dram_writeEnable=NI_SNC_valid&NI_SNC_ready;
assign dram_writeAddress=NI_SNC_packet[SEQ_START+:SEQ_WIDTH]*2^($clog(NETWORK_SIZE))+counter[NI_SNC_packet[SEQ_START+:SEQ_WIDTH]];
assign NI_SNC_ready=((currentCounter+1)==inputNum|dram_readData[TYPE_START+:TYPE_WIDTH]==`CONF_INPUTNUM|rst)?1'b0:1'b1;

always @(posedge clk) 
begin
  if(rst)
  begin
   for(i=0;i<2^SEQ_WIDTH;i=i+1)
    counter[i]<=0;
  end
  else if(!NI_SNC_ready)
    counter[currentSeqNum]<=0;
  else if(NI_SNC_valid)
    counter[NI_SNC_packet[SEQ_START+:SEQ_WIDTH]]<=counter[NI_SNC_packet[SEQ_START+:SEQ_WIDTH]]+1;
end

assign dram_readAddress=currentSeqNum*2^($clog(NETWORK_SIZE))+currentCounter;
assign SNC_MUL_valid=(currentCounter==counter[currentSeqNum]|rst)?1'b0:1'b1;
assign SNC_MUL_packet=dram_readData;


always @(posedge clk)
begin
  if(rst)
    begin
    currentCounter<=0;
    currentSeqNum<=0;
    end
  else if (SNC_MUL_valid)
    begin  
        if ((currentCounter+1)==inputNum|dram_readData[TYPE_START+:TYPE_WIDTH]==`CONF_INPUTNUM)
        begin
        currentCounter<=0;
        currentSeqNum<=currentSeqNum+1;
        if(dram_readData[TYPE_START+:TYPE_WIDTH]==`CONF_INPUTNUM)
        inputNum<=dram_readData[PAYLOAD_START+:PAYLOAD_WIDTH];
        end
        else
        currentCounter<=currentCounter+1;
    end
end


   
endmodule
