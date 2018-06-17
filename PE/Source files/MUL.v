`timescale 1ns / 1ps



module multiplier
#(parameter NETWORK_SIZE=256)
(input clk,
input rst,
input SNC_MUL_valid,
input [TYPE_WIDTH-1:0] SNC_MUL_type,
input [SEQ_WIDTH-1:0] SNC_MUL_seqNum,
input [PAYLOAD_WIDTH+SOURCE_WIDTH_SIZE-1:0] SNC_MUL_data,
output SNC_MUL_halt,
input MUL_ACC_halt,
output MUL_ACC_valid,
output [TYPE_WIDTH-1:0] MUL_ACC_type,
input [SEQ_WIDTH-1:0] MUL_ACC_seqNum,
output [$clog2(NETWORK_SIZE)-1:0] MUL_ACC_inputNum,
output [PAYLOAD_WIDTH-1:0] MUL_ACC_data
);

localparam PAYLOAD_WIDTH=32, SOURCE_START=PAYLOAD_WIDTH, SOURCE_WIDTH=$clog2(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH, DEST_WIDTH=$clog2(NETWORK_SIZE),
SEQ_START=DEST_START+DEST_WIDTH,SEQ_WIDTH=$clog2($sqrt(NETWORK_SIZE)*2),
TYPE_START=SEQ_START+SEQ_WIDTH, TYPE_WIDTH=3,
PACKET_SIZE=TYPE_START+TYPE_WIDTH;

localparam DATA=000, CONF_INB=001, CONF_AFUB=110, CONF_AFLB=101, CONF_AFLUT=100, CONF_W=010;

reg registered_valid;
reg [TYPE_WIDTH-1:0]  registered_type;
reg [SEQ_WIDTH-1:0] registered_seqNum;
reg [PAYLOAD_WIDTH+SOURCE_WIDTH-1:0] registered_data;


wire bram_writeEnable, bram_readEnable;
wire [SOURCE_WIDTH-1:0] bram_writeAddress, bram_readAddress;
wire [PAYLOAD_WIDTH-1:0] bram_writeData, bram_readData;
wire [PAYLOAD_WIDTH^2-1:0] partialProduct;

blockedRAM_simpleDualPort #(.BRAM_WIDTH(PAYLOAD_WIDTH), .BRAM_DEPTH($clog2(NETWORK_SIZE))) bram(
.din(bram_writeData),
.addrin(bram_writeAddress),
.addrout(bram_readAddress),
.we(bram_writeEnable), .re(bram_readEnable), .clk(clk),
.dout(bram_readData)
);

//port assignments
assign MUL_ACC_valid=registered_valid;
assign MUL_ACC_type=registered_type;
assign MUL_ACC_seqNum=registered_seqNum;
assign MUL_ACC_inputNum=registered_data[SOURCE_START+:SOURCE_WIDTH];
assign MUL_ACC_data=(registered_type==DATA)?partialProduct[(PAYLOAD_WIDTH^2-1)-:PAYLOAD_WIDTH]:registered_data[0+:PAYLOAD_WIDTH];
assign SNC_MUL_halt=MUL_ACC_halt;

//internal assignments
assign bram_writeEnable=(registered_type==CONF_W)&registered_valid?1'b1:1'b0;
assign bram_writeAddress=registered_data[PAYLOAD_WIDTH+:SOURCE_WIDTH];
assign bram_writeData=registered_data[0+:PAYLOAD_WIDTH];
assign bram_readEnable=SNC_MUL_halt?1'b0:1'b1;
assign bram_readAddress=SNC_MUL_data[SOURCE_START+:SOURCE_WIDTH];
assign partialProduct=$signed(bram_readData)*$signed(registered_data[0+:PAYLOAD_WIDTH]);


always @(posedge clk)
begin
    if(rst)
    begin
        registered_type<=0; 
        registered_seqNum<=0;	
        registered_data<=0;
        registered_valid<=0;
    end
    else if(!SNC_MUL_halt)
    begin
        registered_type<=SNC_MUL_type;
        registered_seqNum<=SNC_MUL_seqNum;
        registered_data<=SNC_MUL_data;
        registered_valid<=SNC_MUL_valid;
    end
end

endmodule
