`timescale 1ns / 1ps


module processingElement
#(parameter NETWORK_SIZE=256, SOURCE_ADDRESS=8'b00000000)
(input clk,
input rst,
input NI_PE_valid,
input [PACKET_SIZE-1:0] NI_PE_packet,
output NI_PE_ready,
input PE_NI_ready,
output [PACKET_SIZE-1:0] PE_NI_packet,
output PE_NI_valid
);

localparam PAYLOAD_WIDTH=32, SOURCE_START=PAYLOAD_WIDTH, SOURCE_WIDTH=$clog2(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH, DEST_WIDTH=$clog2(NETWORK_SIZE),
SEQ_START=DEST_START+DEST_WIDTH,SEQ_WIDTH=$clog2($sqrt(NETWORK_SIZE)*2),
TYPE_START=SEQ_START+SEQ_WIDTH, TYPE_WIDTH=3,
PACKET_SIZE=TYPE_START+TYPE_WIDTH;

wire SNC_MUL_halt;
wire SNC_MUL_valid;
wire [TYPE_WIDTH-1:0] SNC_MUL_type;
wire [SEQ_WIDTH-1:0] SNC_MUL_seqNum;
wire [PAYLOAD_WIDTH+SOURCE_WIDTH-1:0] SNC_MUL_data;
 
seqNumCheck
 #(.NETWORK_SIZE(NETWORK_SIZE)) 
snc
(.clk(clk),
 .rst(rst),
 .NI_SNC_valid(NI_PE_valid),
 .NI_SNC_packet(NI_PE_packet),
 .SNC_MUL_halt(SNC_MUL_halt),
 .SNC_MUL_valid(SNC_MUL_valid),
 .SNC_MUL_type(SNC_MUL_type),
 .SNC_MUL_seqNum(SNC_MUL_seqNum),
 .SNC_MUL_data(SNC_MUL_data)
);

wire MUL_ACC_valid;
wire [TYPE_WIDTH-1:0] MUL_ACC_type;
wire [SEQ_WIDTH-1:0] MUL_ACC_seqNum;
wire [$clog(NETWORK_SIZE)-1:0] MUL_ACC_inputNum;
wire [PAYLOAD_WIDTH-1:0] MUL_ACC_data;
wire MUL_ACC_halt;

multiplier
 #(.NETWORK_SIZE(NETWORK_SIZE)) 
mul
(.clk(clk),
 .rst(rst),
 .SNC_MUL_valid(SNC_MUL_valid),
 .SNC_MUL_type(SNC_MUL_type),
 .SNC_MUL_seqNum(SNC_MUL_seqNum),
 .SNC_MUL_data(SNC_MUL_data),
 .SNC_MUL_halt(SNC_MUL_halt),
 .MUL_ACC_halt(MUL_ACC_halt),
 .MUL_ACC_valid(MUL_ACC_valid),
 .MUL_ACC_type(MUL_ACC_type),
 .MUL_ACC_seqNum(MUL_ACC_seqNum),
 .MUL_ACC_inputNum(MUL_ACC_inputNum),
 .MUL_ACC_data(MUL_ACC_data)
);

wire ACC_AF_halt;
wire ACC_AF_valid;
wire [TYPE_WIDTH-1:0] ACC_AF_type;
wire [SEQ_WIDTH-1:0] ACC_AF_seqNum;
wire [$clog2(NETWORK_SIZE)+PAYLOAD_WIDTH-1:0] ACC_AF_data;

accumulator
 #(.NETWORK_SIZE(NETWORK_SIZE), .PAYLOAD_WIDTH(PAYLOAD_WIDTH), 
.RADIX_POINT(RADIX_POINT),.LUT_DEPTH(LUT_DEPTH), .SOURCE_ADDRESS(SOURCE_ADDRESS)) 
acc
(.clk(clk),
 .rst(rst),
 .MUL_ACC_halt(MUL_ACC_halt),
 .MUL_ACC_valid(MUL_ACC_valid),
 .MUL_ACC_type(MUL_ACC_type),
 .MUL_ACC_seqNum(MUL_ACC_seqNum),
 .MUL_ACC_inputNum(MUL_ACC_inputNum),
 .ACC_AF_halt(ACC_AF_halt),
 .ACC_AF_valid(ACC_AF_valid),
 .ACC_AF_type(ACC_AF_type),
 .ACC_AF_seqNum(ACC_AF_seqNum),
 .ACC_AF_data(ACC_AF_data),
 
);

activationFunction
 #(.NETWORK_SIZE(NETWORK_SIZE), .SOURCE_ADDRESS(SOURCE_ADDRESS)) 
af
(.clk(clk),
 .rst(rst),
 .ACC_AF_halt(ACC_AF_halt),
 .ACC_AF_valid(ACC_AF_valid),
 .ACC_AF_type(ACC_AF_type),
 .ACC_AF_seqNum(ACC_AF_seqNum),
 .ACC_AF_data(ACC_AF_data),
 .AF_NI_packet(PE_NI_packet),
 .AF_NI_valid(PE_NI_valid),
 .AF_NI_ready(PE_NI_ready)
);

assign NI_PE_ready=1'b1;

endmodule
