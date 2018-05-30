`timescale 1ns / 1ps

module multiplier
#(parameter NETWORK_SIZE=256, PAYLOAD_WIDTH=22, 
SEQ_START=PAYLOAD_WIDTH, SEQ_WIDTH=4, 
SOURCE_START=SEQ_START+SEQ_WIDTH, SOURCE_WIDTH=$clog(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH,DEST_WIDTH=$clog(NETWORK_SIZE),
TYPE_START=DEST_START+DEST_WIDTH, TYPE_WIDTH=2,
PACKET_SIZE=TYPE_START+TYPE_WIDTH)
(input clk,
input SNC_MUL_valid,
input [PACKET_SIZE-1:0] SNC_MUL_packet,
output SNC_MUL_ready,
input MUL_SADD_ready,
output MUL_SADD_valid,
output [$clog(NETWORK_SIZE)-1:0] MUL_SADD_inputNumber,
output [PAYLOAD_WIDTH^2-1:0] MUL_SADD_partialProduct
);

reg [PACKET_SIZE-1:0]  registered_packet;
reg registered_valid;

always @(posedge clk)
begin
registered_packet<=SNC_MUL_packet;
registered_valid<=SNC_MUL_valid;
end



endmodule
