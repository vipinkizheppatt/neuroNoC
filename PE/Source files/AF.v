`timescale 1ns / 1ps


module activationFunction
#(parameter NETWORK_SIZE=256, SOURCE_ADDRESS=8'b00000000)
(input clk,
input rst,
input ACC_AF_valid,
input [TYPE_WIDTH-1:0] ACC_AF_type,
input [SEQ_WIDTH-1:0] ACC_AF_seqNum,
input [$clog2(NETWORK_SIZE)+PAYLOAD_WIDTH-1:0] ACC_AF_data, 
output ACC_AF_halt,
input AF_NI_ready,
output [PACKET_SIZE-1:0] AF_NI_packet,
output AF_NI_valid
);

localparam PAYLOAD_WIDTH=32,SOURCE_START=PAYLOAD_WIDTH, SOURCE_WIDTH=$clog2(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH, DEST_WIDTH=$clog2(NETWORK_SIZE),
SEQ_START=DEST_START+DEST_WIDTH,SEQ_WIDTH=$clog2($sqrt(NETWORK_SIZE)*2),
TYPE_START=SEQ_START+SEQ_WIDTH, TYPE_WIDTH=3,
PACKET_SIZE=TYPE_START+TYPE_WIDTH;

localparam DATA=000, CONF_INB=001, CONF_AFUB=110, CONF_AFLB=101, CONF_AFLUT=100, CONF_W=010;

localparam UPPER_BOUND=8, LOWER_BOUND=-8, LUT_DEPTH=1024, RADIX_POINT=29;

reg registered_valid;
reg [TYPE_WIDTH-1:0] registered_type;
reg [SEQ_WIDTH-1:0] registered_seqNum;
reg [$clog2(NETWORK_SIZE)+PAYLOAD_WIDTH-1:0] registered_data;


reg [PAYLOAD_WIDTH-1:0] upperBoundValue, lowerBoundValue;
reg [$clog(LUT_DEPTH)-1:0] lut_writeAddress;

wire lut_writeEnable, lut_readEnable;
wire [$clog(LUT_DEPTH)-1:0] lut_writeAddress, lut_readAddress;
wire [PAYLOAD_WIDTH-1:0] lut_writeData, lut_readData, payload;


blockedRAM_simpleDualPort #(.BRAM_WIDTH(PAYLOAD_WIDTH), .BRAM_DEPTH(LUT_DEPTH)) lut(
.din(lut_writeData),
.addrin(lut_writeAddress),
.addrout(lut_readAddress),
.we(lut_writeEnable), .re(lut_readEnable), .clk(clk),
.dout(lut_readData)
);

//port assignments
assign AF_NI_valid=registered_valid&registered_type==DATA?1'b1:1'b0;
assign AF_NI_packet={registered_type, registered_seqNum,{$clog2(NETWORK_SIZE){0}},SOURCE_ADDRESS,payload};
assign MUL_AF_halt=AF_NI_ready?1'b0:1'b1;

//lut port assignments
assign lut_writeEnable=(registered_type==CONF_AFLUT)&registered_valid?1'b1:1'b0;
assign lut_writeData=registered_data[PAYLOAD_WIDTH-1:0];
assign lut_readEnable=AF_NI_ready;
assign lut_readAddress={~MUL_AF_data[$clog2(NETWORK_SIZE)+PAYLOAD_WIDTH-1],MUL_AF_data[(RADIX_POINT+$clog2(UPPER_BOUND)-1)-:($clog(LUT_DEPTH)-1)]};

//internal assignments
assign payload=($signed(registered_data[RADIX_POINT+:($clog2(NETWORK_SIZE)+PAYLOAD_WIDTH-RADIX_POINT)])>=UPPER_BOUND)?upperBoundValue:($signed(registered_data[RADIX_POINT+:($clog2(NETWORK_SIZE)+PAYLOAD_WIDTH-RADIX_POINT)])<LOWER_BOUND)?lowerBoundValue:lut_readData;



always @(posedge clk)
begin
    if(rst)
    begin
        registered_type<=0;
        registered_seqNum<=0; 	
        registered_data<=0;
        registered_valid<=0;
    end
    else if(AF_NI_ready)
    begin
        registered_type<=MUL_AF_type;
        registered_seqNum<=MUL_AF_seqNum;
        registered_data<=MUL_AF_data;
        registered_valid<=MUL_AF_valid;
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        upperBoundValue<=0;
        lowerBoundValue<=0;
        lut_writeAddress<=0;
    end
    else if (registered_valid&AF_NI_ready) 
    begin
	case(registered_type)
	CONF_AFLUT: 
		lut_writeAddress<=lut_writeAddress+1;
	CONF_AFUB:
		upperBoundValue<=registered_data[PAYLOAD_WIDTH-1:0];
	CONF_AFLB:
		lowerBoundValue<=registered_data[PAYLOAD_WIDTH-1:0];
    endcase
    end
end

endmodule

