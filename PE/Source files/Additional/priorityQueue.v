module priorityQueue #(parameter PACKET_SIZE=32,QUEUE_DEPTH=32, SEQ_START=4, SEQ_WIDTH=4)(
input   clk,
input   rst,
input   wrEn,
input   rdEn,
input [PACKET_SIZE-1:0] wrData,
input  [SEQ_WIDTH-1:0] currentSeqNum,
output [PACKET_SIZE-1:0] rdData,
output  full,
output  empty,
output  busy
);

localparam NORMAL=0, BUSY=1;

reg [PACKET_SIZE-1:0] myRam [QUEUE_DEPTH-1:0];
reg [$clog2(QUEUE_DEPTH):0] counter; 
reg [$clog2(QUEUE_DEPTH)-1:0] temp; 
reg [$clog2(QUEUE_DEPTH)-1:0] wrPntr;
reg [$clog2(QUEUE_DEPTH)-1:0] rdPntr;


assign empty = (count == 0) ? 1'b1 : 1'b0;
assign full = (count == QUEUE_DEPTH) ? 1'b1 : 1'b0;
assign rdData= myRam[rdPntr];
assign busy= (currentState == BUSY) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
case(currentState)
NORMAL: 
    if(rst)
    begin
       wrPntr <= {$clog2(QUEUE_DEPTH){1'b0}};
       rdPntr <= {$clog2(QUEUE_DEPTH){1'b0}};
    end
    else
    begin
        if(wrEn & !full)
        begin
            wrPntr <= wrPntr + 1;            
            myRam[wrPntr] <= wrData;
            if(counter>0)
            begin
            temp<=wrPntr;
            currentState<=BUSY;
            end
        end
        if(rdEn & !empty)
            rdPntr <= rdPntr + 1;
        if(wrEn & !full & !(rdEn & !empty))
            counter=counter+1;
        else if (rdEn & !empty & !(wrEn & !full))
            counter=counter-1;
    end
BUSY:
    if((myRam[temp][SEQ_START+:SEQ_WIDTH]-currentSeqNum)<(myRam[temp-1][SEQ_START+:SEQ_WIDTH]-currentSeqNum))
    begin
        myRam[temp]<=myRam[temp-1];
        myRam[temp-1]<=myRam[temp]; 
        temp<=temp-1;  
        if(temp-1==rdPntr) 
        currentState<=NORMAL;
    end   
    else 
        currentState<=NORMAL;

endcase
end

endmodule