`timescale 1ns / 1ns

module testbench_neuronoc();
`include "header.vh"

reg clk, rst, input_valid, input_ready;
reg [PACKET_SIZE-1:0] input_packet;
wire [PACKET_SIZE-1:0] output_packet;
wire output_valid, output_ready;

task sendpacket;
input [TYPE_WIDTH-1:0] packetType;
input [SEQ_WIDTH-1:0] seqNum;
input [DEST_WIDTH-1:0] destAddress;
input [SOURCE_WIDTH-1:0] sourceAddress;
input [PAYLOAD_WIDTH-1:0] payload;

begin: F

forever 
begin
@(posedge clk)
if(output_ready) begin
    input_valid<=1;
    input_packet <={packetType, seqNum, destAddress, sourceAddress,  payload};
    disable F;
end
end


end


endtask

task sendpacketFT;
input [TYPE_WIDTH-1:0] packetType;
input [SWITCHNUMBER_WIDTH-1:0] switchNumber;
input [ENTRYNUMBER_WIDTH-1:0] entryNumber;
input [OPTIONAL_WIDTH-1:0] optional;
input [DATA_WIDTH-1:0] data;

begin: FT

forever 
begin
@(posedge clk)
if(output_ready) begin
    input_valid<=1;
    input_packet <={packetType, switchNumber, entryNumber, optional,  data};
    disable FT;
end
end

end
endtask


initial
begin
    clk=1;
    forever
        #5 clk=~clk;    
end

initial
begin
    rst<=1; 
    @(posedge clk)
     rst<=0;
end



initial
begin: block
    integer counter;	
	//CONFIGURE FORWARDIING TABLE
    sendpacketFT(CONF_FT, 0 , 0, 0, 5'b00100);
	sendpacketFT(CONF_FT, 0 , Y_SIZE, 0, 5'b10000);
	sendpacketFT(CONF_FT, 1 , 0, 0, 5'b10001);
	sendpacketFT(CONF_FT, 1 , 1, 0, 5'b00001);
	sendpacketFT(CONF_FT, Y_SIZE+1 , 0, 0, 5'b10001);
	sendpacketFT(CONF_FT, Y_SIZE+1 , 1, 0, 5'b01000);
	sendpacketFT(CONF_FT, Y_SIZE+1 , Y_SIZE+1, 0, 5'b01000);
    sendpacketFT(CONF_FT, Y_SIZE+1 , Y_SIZE*2+1, 0, 5'b01000);
	sendpacketFT(CONF_FT, Y_SIZE*2+1 , 0, 0, 5'b10000);
	sendpacketFT(CONF_FT, Y_SIZE*2+1 , Y_SIZE*2+1, 0, 5'b00010);
	sendpacketFT(CONF_FT, Y_SIZE , 1, 0, 5'b10000);
	sendpacketFT(CONF_FT, Y_SIZE , Y_SIZE, 0, 5'b00010);
	sendpacketFT(CONF_FT, Y_SIZE , Y_SIZE+1, 0, 5'b10000);
	sendpacketFT(CONF_FT, Y_SIZE , Y_SIZE*2+1, 0, 5'b10000);

    	//END
		
    	//CONFIGURE INPUT NUMBER and BIAS
    counter=0;
    sendpacket(CONF_INB, counter, 1, 1, d(0.69, BIAS_WIDTH, BFRACTION, BINT));
	sendpacket(CONF_INB, counter, Y_SIZE+1, 1, d(0.77, BIAS_WIDTH, BFRACTION, BINT));
	sendpacket(CONF_INB, counter, Y_SIZE*2+1, 1, d(-0.68, BIAS_WIDTH, BFRACTION, BINT));
	sendpacket(CONF_INB, counter, Y_SIZE, 2, d(0.81, BIAS_WIDTH, BFRACTION, BINT));
    	//END

    
    	//CONFIGURE WEIGHTS
	counter=counter+1;
    sendpacket(CONF_W, counter, 1, 0, d(0.258, WEIGHT_WIDTH, WFRACTION, WINT));
	sendpacket(CONF_W, counter, 1, 1, d(0.468, WEIGHT_WIDTH, WFRACTION, WINT));
    sendpacket(CONF_W, counter, Y_SIZE+1, 0, d(0.355, WEIGHT_WIDTH, WFRACTION, WINT));
	sendpacket(CONF_W, counter, Y_SIZE+1, 1, d(0.855, WEIGHT_WIDTH, WFRACTION, WINT));
	sendpacket(CONF_W, counter, Y_SIZE*2+1, 0, d(0.712, WEIGHT_WIDTH, WFRACTION, WINT));
	sendpacket(CONF_W, counter, Y_SIZE*2+1, 1, d(0.112, WEIGHT_WIDTH, WFRACTION, WINT));
	sendpacket(CONF_W, counter, Y_SIZE, 1, d(0.708, WEIGHT_WIDTH, WFRACTION, WINT));
	sendpacket(CONF_W, counter, Y_SIZE, Y_SIZE+1, d(0.329, WEIGHT_WIDTH, WFRACTION, WINT));
	sendpacket(CONF_W, counter, Y_SIZE, Y_SIZE*2+1, d(-0.116, WEIGHT_WIDTH, WFRACTION, WINT));
	//END

	//SEND INPUTS
	input_ready<=1;
	
	
	counter=counter+1;
	sendpacket(DATA, counter, 0, 0, d(0.123, INPUT_WIDTH, IFRACTION, IINT));
	sendpacket(DATA, counter, 1, 0, d(0.455, INPUT_WIDTH, IFRACTION, IINT));
	counter=counter+1;
	sendpacket(DATA, counter, 0, 0, d(0.760, INPUT_WIDTH, IFRACTION, IINT));
	sendpacket(DATA, counter, 1, 0, d(0.07, INPUT_WIDTH, IFRACTION, IINT));
	//END
	
	//CONFIGURE INPUT NUMBER and BIAS
        counter=counter+1;
        sendpacket(CONF_INB, counter, 1, 1, d(-1.3, BIAS_WIDTH, BFRACTION, BINT));
        sendpacket(CONF_INB, counter, Y_SIZE+1, 1, d(0.9, BIAS_WIDTH, BFRACTION, BINT));
        sendpacket(CONF_INB, counter, Y_SIZE*2+1, 1, d(0.633, BIAS_WIDTH, BFRACTION, BINT));
        sendpacket(CONF_INB, counter, Y_SIZE, 2, d(-0.898, BIAS_WIDTH, BFRACTION, BINT));
     //END
     //CONFIGURE WEIGHTS
         counter=counter+1;
         sendpacket(CONF_W, counter, 1, 0, d(0.532, WEIGHT_WIDTH, WFRACTION, WINT));
         sendpacket(CONF_W, counter, 1, 1, d(-0.298, WEIGHT_WIDTH, WFRACTION, WINT));
         sendpacket(CONF_W, counter, Y_SIZE+1, 0, d(0.755, WEIGHT_WIDTH, WFRACTION, WINT));
         sendpacket(CONF_W, counter, Y_SIZE+1, 1, d(0.1, WEIGHT_WIDTH, WFRACTION, WINT));
         sendpacket(CONF_W, counter, Y_SIZE*2+1, 0, d(-0.9, WEIGHT_WIDTH, WFRACTION, WINT));
         sendpacket(CONF_W, counter, Y_SIZE*2+1, 1, d(0.345, WEIGHT_WIDTH, WFRACTION, WINT));
         sendpacket(CONF_W, counter, Y_SIZE, 1, d(0.2, WEIGHT_WIDTH, WFRACTION, WINT));
         sendpacket(CONF_W, counter, Y_SIZE, Y_SIZE+1, d(0.1, WEIGHT_WIDTH, WFRACTION, WINT));
         sendpacket(CONF_W, counter, Y_SIZE, Y_SIZE*2+1, d(-0.56, WEIGHT_WIDTH, WFRACTION, WINT));
         //END
         counter=counter+1;
             sendpacket(DATA, counter, 0, 0, d(1.5, INPUT_WIDTH, IFRACTION, IINT));
             sendpacket(DATA, counter, 1, 0, d(-1.9, INPUT_WIDTH, IFRACTION, IINT));
             counter=counter+1;
             sendpacket(DATA, counter, 0, 0, d(0.07, INPUT_WIDTH, IFRACTION, IINT));
             sendpacket(DATA, counter, 1, 0, d(1.5, INPUT_WIDTH, IFRACTION, IINT));
	forever 
    begin
    @(posedge clk)
    if(output_ready) begin
        input_valid<=0;
        disable block;
    end
    end
	
	//END
end



neuroNoC nn(
.i_clk(clk), 
.i_rst(rst),

.i_nn_valid(input_valid), 
.o_nn_ready(output_ready), 
.i_nn_data(input_packet), 
 
.o_nn_valid(output_valid), 
.i_nn_ready(input_ready),
.o_nn_data(output_packet) 

);



endmodule

