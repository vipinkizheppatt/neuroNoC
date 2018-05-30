`define CONF_WEIGHT 10
`define CONF_INPUTNUM 01

`timescale 1ns / 1ps

module multiplier
#(parameter NETWORK_SIZE=256, PAYLOAD_WIDTH=22, 
SEQ_START=PAYLOAD_WIDTH, SEQ_WIDTH=4, 
SOURCE_START=SEQ_START+SEQ_WIDTH, SOURCE_WIDTH=$clog(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH,DEST_WIDTH=$clog(NETWORK_SIZE),
TYPE_START=DEST_START+DEST_WIDTH, TYPE_WIDTH=2,
PACKET_SIZE=TYPE_START+TYPE_WIDTH)
(input clk,
input rst,
input SNC_MUL_valid,
input [PACKET_SIZE-1:0] SNC_MUL_packet,
output MUL_SADD_valid,
output [$clog(NETWORK_SIZE)-1:0] MUL_SADD_inputNumber,
output [PAYLOAD_WIDTH^2-1:0] MUL_SADD_partialProduct
);

reg [PACKET_SIZE-1:0]  registered_packet;
reg registered_valid;

wire bram_writeEnable;
wire [SOURCE_START+:SOURCE_WDITH] bram_writeAddress, bram_readAddress;
wire [PAYLOAD-1:0] bram_writeData, bram_readData;

blockedRAM_simpleDualPort #(.BRAM_WIDTH(PAYLOAD_WIDTH), .BRAM_DEPTH($clog(NETWORK_SIZE))) bram(
.din(bram_writeData),
.addrin(bram_writeAddress),
.addrout(bram_readAddress),
.we(bram_writeEnable), .clk(clk),
.dout(bram_readData)
);

assign bram_writeEnable=(registered_packet[TYPE_START+:TYPE_WIDTH]==`CONF_WEIGHT);
assign bram_writeAddress=registered_packet[SOURCE_START+:SOURCE_WDITH];
assign bram_readAddress=SNC_MUL_packet[SOURCE_START+:SOURCE_WDITH];
assign bram_writeData=registered_packet[0+:PAYLOAD_WIDTH];
assign MUL_SADD_partialProduct=$signed(bram_readData)*$signed(registered_packet[PAYLOAD-1:0]);
assign MUL_SADD_valid=registered_valid;
assign MUL_SADD_inputNumber=registered_packet[TYPE_START+:TYPE_WIDTH]==`CONF_INPUTNUM?registered_packet[PAYLOAD_START-1:0]:{$clog(NETWORK_SIZE){0}};

always @(posedge clk)
begin
    if(rst)
    begin
        registered_packet<=0;
        registered_valid<=0;
    end
    else
    begin
        registered_packet<=SNC_MUL_packet;
        registered_valid<=SNC_MUL_valid;
    end
end

endmodule
