`timescale 1ns / 1ns

module testbench();

localparam t=10;

localparam NETWORK_SIZE=256;

localparam PAYLOAD_WIDTH=32,SOURCE_START=PAYLOAD_WIDTH, SOURCE_WIDTH=$clog2(NETWORK_SIZE),
DEST_START=SOURCE_START+SOURCE_WIDTH, DEST_WIDTH=$clog2(NETWORK_SIZE),
SEQ_START=DEST_START+DEST_WIDTH,SEQ_WIDTH=$clog2($sqrt(NETWORK_SIZE)*2),
TYPE_START=SEQ_START+SEQ_WIDTH, TYPE_WIDTH=3,
PACKET_SIZE=TYPE_START+TYPE_WIDTH;

localparam UPPER_BOUND=8, LOWER_BOUND=-8, LUT_DEPTH=1024, RADIX_POINT=29;

localparam DATA=000, CONF_INB=001, CONF_AFUB=110, CONF_AFLB=101, CONF_AFLUT=100, CONF_W=010, CONF_FT=111;

reg clk, rst, valid_out, ready_out;
wire valid_in, ready_in;

reg  [TYPE_WIDTH-1:0] packetType;
reg [SEQ_WIDTH-1:0] seqNum;
reg [SEQ_WIDTH:0] windowWidth;
reg  [SOURCE_WIDTH:0] destAddress, sourceAddress;
reg [PAYLOAD_WIDTH-1:0] payload;
wire [PACKET_SIZE] outputPacket={packetType,seqNum,destAddress, sourceAddress, payload}, inputPacket;


initial
begin
clk=0;
forever
#t clk=~clk;
end


initial
begin
valid_out=0; seqNum=0; windowWidth=0; rst=1;
@(posedge clk) rst=0;
configureActivationFunction($fopen("sigmoid.txt","r"));
configureNeuralNetwork($fopen("config","r"),$fopen("forwardingTable","r"));
startNeuralNetwork($fopen("input.txt","r"));
end

initial
begin: displayResults
integer file;

ready_out=1;
file= $fopen("output.txt","w");

    forever
    begin
        @(posedge clk)
        #0 if(valid_in)
        begin
             $fstrobe(file, "%d  %f(%b)", ($stime/(2*t)), binarytoreal(inputPacket[PAYLOAD_WIDTH-1:0],30), inputPacket[PAYLOAD_WIDTH-1:0]);
             if(windowWidth!=0)
             windowWidth=windowWidth-1;
        end
    end    
end

//Send inputs to the network from the file
task startNeuralNetwork(input integer inputFile);
real r;
integer index=0;
reg [7:0] char;

valid_out=1;

packetType=DATA;
sourceAddress=0;

forever
begin: loop0SNN
$fscanf(inputFile, "%f%[\n\s]",r, char);
    if($feof(inputFile))
        disable loop0SNN;
payload=realtobinary(r, 30);
destAddress=index;
    forever
    begin: loop1SNN
     #1 if(ready_in==1&windowWidth<=2^SEQ_WIDTH)
        begin
            @(posedge clk);
            disable loop1SNN;
        end
        else  @(posedge clk);  
    end

case(char)
"\s": index=index+1;
"\n": 
    begin
    index=0;
    seqNum=seqNum+1;
    end
endcase
end

$fclose(file);
valid_out=0;
endtask

//configure activation function from file
task configureActivationFunction(input integer file);
real r;
valid_out=1;

packetType=CONF_AFLB;
$fscanf(file,"%f\n",r);
payload=realtobinary(r, 30);
sendPacket();
seqNum=seqNum+1;


packetType=CONF_AFLUT;
repeat(LUT_DEPTH)
begin
$fscanf(file,"%f\n",r);
payload=realtobinary(r, 30);
sendPacket();
seqNum=seqNum+1;
end

packetType=CONF_AFUB;
$fscanf(file,"%f\n",r );
payload=realtobinary(r, 30);
sendPacket();
seqNum=seqNum+1;

$fclose(file);
valid_out=0;
endtask


//Send control packets to configure weights, bias, input number and forwarding tables
task configureNeuralNetwork(input integer configFile, input integer ftFile);
real bias, weight;
integer inputNum, savedSeqNum, peIndex, source;
integer rowNumber, fractionalNumber;

valid_out=1;
savedSeqNum=seqNum;

forever
begin: loop0CNN
$fscanf(configFile, "%d %d %f ",peIndex, inputNum, bias);
    if($feof(inputFile))
        disable loop0CNN;

packetType=CONF_INB;        
payload=realtobinary(bias, RADIX_POINT);
destAddress=peIndex;
sourceAddress=inputNum;
seqNum=savedSeqNum;
sendPacket();

seqNum=seqNum+1;
packetType=CONF_W;

    repeat(inputNum)
    begin
        $fscanf(configFile, "%d %f[\n\s]",source, weight);
        payload=realtobinary(weight, RADIX_POINT);
        sourceAddress=source;
        sendPacket();
    end
seqNum=seqNum+1;

end

packetType=CONF_FT;

for(rowNumber=0;rowNumber<NETWORK_SIZE;rowNumber=rowNumber+1)
begin
    for(fractionalNumber=0;fractionalNumber<NETWORK_SIZE/PAYLOAD_WIDTH;fractionalNumber=fractionalNumber+1)
    begin
        $fscanf(ftFile, "%b",payload);
        {seqNum,destAddress[(DEST_WIDTH-1)-:$clog2(NETWORK_SIZE^2/PAYLOAD_WIDTH)-SEQ_WIDTH]}={rowNumber,fractionalNumber};
        sendPacket;
    end
end    


$fclose(configFile);
$fclose(ftFile);
valid_out=0;
endtask


function integer realtobinary (input real r, input integer n);
realtobinary=rtoi(r*2^n);
endfunction

function real binarytoreal (input integer i, input integer n);
binarytoreal=itor(i)/2^n;
endfunction

task sendPacket();
 forever
 begin: loop
         #1 if(ready_in)
            begin
            @(posedge clk);
            disable loop;
            end
            else  @(posedge clk);  
 end
endtask 
        
endmodule