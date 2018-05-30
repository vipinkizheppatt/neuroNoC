`timescale 1ns / 1ps

module seqNumCheck_PriorityQueue #(parameter NETWORK_SIZE=256, PAYLOAD_WIDTH=22, 
SEQ_START=PAYLOAD_WIDTH, SEQ_WIDTH=4, 
SOURCE_START=SEQ_START+SEQ_WIDTH, SOURCE_WIDTH=$clog(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH,DEST_WIDTH=$clog(NETWORK_SIZE),
TYPE_START=DEST_START+DEST_WIDTH, TYPE_WIDTH=2,
PACKET_SIZE=TYPE_START+TYPE_WIDTH)
(
input clk,
input NI_SNC_valid,
input [PACKET_SIZE-1:0] NI_SNC_packet,
output NI_SNC_ready,
input SNC_MUL_ready,
output SNC_MUL_valid,
output [PACKET_SIZE-1:0] SNC_MUL_packet
);

reg [SEQ_WIDTH-1:0] currentSeqNum;
reg [$clog(NETWORK_SIZE)-1:0] counter;
reg [$clog(NETWORK_SIZE)-1:0] inputNum;

wire [PACKET_SIZE-1:0] pqOut;
wire pqEmpty, pqFull, pqBusy, pqwrEn, pqrdEn;
wire packetSeqMatch =(currentSeqNum==NI_SNC_packet[SEQ_START+:SEQ_WIDTH]&NI_SNC_valid);
wire pqOutSeqMatch =(currentSeqNum==pqOut[SEQ_START+:SEQ_WIDTH]&~pqEmpty&~pqBusy);


assign NI_SNC_ready=(((packetSeqMatch&SNC_MUL_ready)|((~packetSeqMatch&NI_SNC_valid&~pqFull)|(~packetSeqMatch&~SNC_valid)&~pqBusy))&~pqOutSeqMatch)?1'b1:1'b0;
assign SNC_MUL_valid=(packetSeqMatch|(pqOutSeqMatch))?1'b1:1'b0;
assign SNC_MUL_packet=pqOutSeqMatch?pqOut:NI_SNC_packet;
assign pqwrEn=(~packetSeqMatch&~pqOutSeqMatch&NI_SNC_valid&~pqBusy)?1'b1:1'b0;
assign pqrdEn=(pqOutSeqMatch&SNC_MUL_ready)?1'b1:1'b0;

always @(posedge clk)
begin
    if (SNC_MUL_valid&SNC_MUL_ready)
    begin
        if (counter==inputNum)
        begin
        counter<=1;
        currentSeqNum<=currentSeqNum+1;
        end
        else
        counter<=counter+1;
    end
end


priorityQueue #(
.PACKET_SIZE(PACKET_SIZE),
.QUEUE_DEPTH(32),
.SEQ_START(SEQ_START), 
.SEQ_WIDTH(SEQ_WIDTH)
)
pq(
.clk(clk),
.rst(1'b0),
.wrEn(pqwrEn),
.rdEn(pqrdEn),
.wrData(NI/SNC_packet),
.currentSeqNum(currentSeqNum),
.rdData(pqOut),
.full(pqFull),
.empty(pqEmpty),
.busy(pqBusy)
);


endmodule
