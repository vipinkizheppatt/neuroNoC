`timescale 1ns / 1ns

module testbench_neuronoc();
`include "header.vh"

integer widthLayer=10;
integer heightFirst =3;
integer heightSecond =4;
integer heightThird =5;
integer width = Y_SIZE;

reg [9:0] dataWeight1 [0:783];
reg [9:0] dataWeight2 [0:29];
reg [9:0] dataWeight3 [0:9];
reg [9:0] dataBias [0:0];
reg [9:0] testData [0:783];
reg clk, rst, input_valid, input_ready;
reg [PACKET_SIZE-1:0] input_packet;
wire [PACKET_SIZE-1:0] output_packet;
wire output_valid, output_ready;
integer i,j,u,k;
integer n = 3;
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
	@(posedge clk)
    input_valid<=0;
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
	@(posedge clk)
    input_valid<=0;
    disable FT;
end
input_valid<=0;
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
    @(posedge clk)
     rst<=0;
end



initial
begin: block
    integer counter;
   	@(posedge clk) 
   	@(posedge clk) 
	//pwesn
    
	//CONFIGURE FORWARDIING TABLE
    
	
	//first row
	for(i = 0; i < widthLayer-1; i = i + 1) 
	begin
		sendpacketFT(CONF_FT, i , 0, 0, 5'b00101);
		
	end
	sendpacketFT(CONF_FT, widthLayer-1, 0, 0, 5'b00001);
	
	//next 3 rows
	for(j = 1; j < heightFirst; j = j + 1)
	begin
		for(i = width*j; i < j*Y_SIZE+widthLayer; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, i , 0, 0, 5'b10001);
		end
	end
			
	
	for(i = 3*width; i < 3*width+widthLayer; i = i + 1)
	begin            
	   sendpacketFT(CONF_FT, i , 0, 0, 5'b10000);
    end
	
	// first layer
	//sources are first and last columns with 3 rows 1-3 
	
	for(j = 1; j < heightFirst+1; j = j + 1)
	begin
		sendpacketFT(CONF_FT, width*j, j*width+widthLayer-1, 0, 5'b00001);
		sendpacketFT(CONF_FT, width*j, j*width, 0, 5'b00101);
		sendpacketFT(CONF_FT, width*j+widthLayer-1, j*width+widthLayer-1, 0, 5'b01001);
		sendpacketFT(CONF_FT, width*j+widthLayer-1, j*width, 0, 5'b00001);
		for(i = width*j+1; i < j*width+widthLayer-1; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, i, j*width, 0, 5'b00101);
			sendpacketFT(CONF_FT, i, j*width+widthLayer-1, 0, 5'b01001);
		end		
		for(k = j+1; k < heightFirst+1; k = k + 1)
		begin
			for(i = width*k; i < k*width+widthLayer; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*width, 0, 5'b00001);
				sendpacketFT(CONF_FT, i, j*width + widthLayer-1, 0, 5'b00001);
			end
		end
		for(k = heightFirst+1; k < heightSecond; k = k + 1)
		begin
			for(i = width*k; i < k*width+widthLayer; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*width, 0, 5'b10001);
				sendpacketFT(CONF_FT, i, j*width + widthLayer-1, 0, 5'b10001);
			end
		end
		for(i = Y_SIZE*4; i < Y_SIZE*4+widthLayer; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, j*width, 0, 5'b10000);
			sendpacketFT(CONF_FT, i, j*width + widthLayer-1, 0, 5'b10000);
		end
	end
	// source are all middle located switches
	for(j = 1; j < heightFirst+1; j = j + 1)
	begin
		
		for(i = width*j+1; i < j*width+widthLayer-1; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, j*width, i, 0, 5'b00001);
			for(k = j*width+1; k < i; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b01001);
			end
			sendpacketFT(CONF_FT, i, i, 0, 5 'b01101);
			for(k = i+1; k < j*width+widthLayer-1; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b00101);
			end
			sendpacketFT(CONF_FT, k, i, 0, 5'b00001);
			for(k = j+1; k < heightFirst+1; k = k + 1)
				for(u = width*k; u < k*width+widthLayer; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b00001);
			for(k = heightFirst+1; k < heightSecond; k = k + 1)
				for(u = width*k; u < k*width+widthLayer; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b10001);
			for(u = 4*width; u < 4*width+widthLayer; u = u + 1)
				sendpacketFT(CONF_FT, u, i, 0, 5'b10000);
		end		
	end	
	
	//second layer
	//sources are first and last columns with 1 rows 4
	
	for(j = heightFirst+1; j < heightSecond+1; j = j + 1)
	begin
		sendpacketFT(CONF_FT, width*j, j*width+widthLayer-1, 0, 5'b00001);
		sendpacketFT(CONF_FT, width*j, j*width, 0, 5'b00101);
		sendpacketFT(CONF_FT, width*j+widthLayer-1, j*width+widthLayer-1, 0, 5'b01001);
		sendpacketFT(CONF_FT, width*j+widthLayer-1, j*width, 0, 5'b00001);
		for(i = width*j+1; i < j*width+widthLayer-1; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, i, j*width, 0, 5'b00101);
			sendpacketFT(CONF_FT, i, j*width+widthLayer-1, 0, 5'b01001);
		end		
		for(k = j+1; k < heightSecond+1; k = k + 1)
		begin
			for(i = width*k; i < k*width+widthLayer; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*width, 0, 5'b00001);
				sendpacketFT(CONF_FT, i, j*width + widthLayer-1, 0, 5'b00001);
			end
		end
		for(k = heightSecond+1; k < heightThird; k = k + 1)
		begin
			for(i = width*k; i < k*width+widthLayer; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*width, 0, 5'b10001);
				sendpacketFT(CONF_FT, i, j*width + widthLayer-1, 0, 5'b10001);
			end
		end
		for(i = 5*width; i < width*5 + widthLayer; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, j*width, 0, 5'b10000);
			sendpacketFT(CONF_FT, i, j*width + widthLayer-1, 0, 5'b10000);
		end
	end
	// source are all middle located switches
	for(j = heightFirst+1; j < heightSecond+1; j = j + 1)
	begin
		for(i = width*j+1; i < j*width+widthLayer-1; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, j*width, i, 0, 5'b00001);
			for(k = j*width+1; k < i; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b01001);
			end
			sendpacketFT(CONF_FT, i, i, 0, 5 'b01101);
			for(k = i+1; k < j*width+widthLayer-1; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b00101);
			end
			sendpacketFT(CONF_FT, k, i, 0, 5'b00001);
			for(k = j+1; k < heightSecond+1; k = k + 1)
				for(u = width*k; u < k*width+widthLayer; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b00001);
			for(k = heightSecond+1; k < heightThird; k = k + 1)
				for(u = width*k; u < k*width+widthLayer; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b10001);
			for(u = width*5; u < width*5+10; u = u + 1)
				sendpacketFT(CONF_FT, u, i, 0, 5'b10000);
				
		end		
	end		
	
	
	
	//output layer
	
	for(j = heightSecond+1; j < heightThird+1; j = j + 1)
	begin
		for(i = j*Y_SIZE; i < j*Y_SIZE+widthLayer; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, i, 0, 5'b00010);
			//if(j < 15) 	sendpacketFT(CONF_FT, i, i+16, 0, 5'b00010);
			//if(j < 14)	sendpacketFT(CONF_FT, i, i+32, 0, 5'b00010);
		end
	end
	
	for(j = 1; j < heightSecond+1; j = j + 1)
	begin
		for(i = j*Y_SIZE; i < j*Y_SIZE+widthLayer; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, heightThird*Y_SIZE+(i%Y_SIZE), 0, 5'b00010);
			//sendpacketFT(CONF_FT, i, 224+(i%16), 0, 5'b00010);
			//sendpacketFT(CONF_FT, i, 240+(i%16), 0, 5'b00010);
		end
	end
	
	for(i = 0; i < widthLayer; i = i + 1) 
	begin
		for(k = Y_SIZE*5; k < Y_SIZE*5+widthLayer; k = k+1)
		begin
			if(i == 0)
				sendpacketFT(CONF_FT, i, k,  0, 5'b10000);
			else 
				sendpacketFT(CONF_FT, i, k,  0, 5'b01000);
			
		end
	end
	
    //END
			
    	//CONFIGURE INPUT NUMBER and BIAS
		
	
	
	
    counter=0;
	//conf bias
	k=0;
	for(j = 1; j < heightFirst+1; j = j + 1)
	begin
		for(i = j*Y_SIZE; i < j*Y_SIZE+widthLayer; i = i + 1)
		begin
			if(k<10) $readmemb({"C:\\Users\\Baisyn\\research\\neuroNoCScripts\\neuroNoCScripts\\b_1_", k+"0",".mif"},dataBias);
			else $readmemb({"C:\\Users\\Baisyn\\research\\neuroNoCScripts\\neuroNoCScripts\\b_1_", (k/10)+"0",(k%10)+"0",".mif"},dataBias);
			sendpacket(CONF_INB, counter, i, 783, dataBias[0]);	
			$display("%b", dataBias[0]);

			k=k+1;
		end
	end
	k=0;
	for(j = heightFirst+1; j < heightSecond+1; j = j + 1)
	begin
		for(i = j*Y_SIZE; i < j*Y_SIZE+widthLayer; i = i + 1)
		begin
			$readmemb({"C:\\Users\\Baisyn\\research\\neuroNoCScripts\\neuroNoCScripts\\b_2_", k+"0",".mif"},dataBias);
			sendpacket(CONF_INB, counter, i, 29, dataBias[0]);	
			k=k+1;
		end
	end
	k=0;
	for(j = heightSecond+1; j < heightThird+1; j = j + 1)
	begin
		for(i = j*Y_SIZE; i < j*Y_SIZE+widthLayer; i = i + 1)
		begin
			$readmemb({"C:\\Users\\Baisyn\\research\\neuroNoCScripts\\neuroNoCScripts\\b_3_", k+"0",".mif"},dataBias);
			sendpacket(CONF_INB, counter, i, 9, dataBias[0]);	
			k=k+1;
		end
	end
    	
	//END
	//4
    
    //CONFIGURE WEIGHTS
		
		
	counter=counter+1;
	//weight input and first layer
	k=0;
	for(u = 1; u <heightFirst+1; u = u+1)
	begin
		for(i = Y_SIZE*u; i < u*Y_SIZE+widthLayer; i = i + 1)
		begin
			if(k<10) $readmemb({"C:\\Users\\Baisyn\\research\\neuroNoCScripts\\neuroNoCScripts\\w_1_", k+"0", ".mif"}, dataWeight1);
			else $readmemb({"C:\\Users\\Baisyn\\research\\neuroNoCScripts\\neuroNoCScripts\\w_1_", (k/10)+"0",(k%10)+"0", ".mif"}, dataWeight1);
			for(j = 0; j < 783; j=j+1) 
			begin
				sendpacket(CONF_W, counter, i, j, dataWeight1[j]);
			end
			
			k = k + 1;
		end
	end
	//weight first and second layer
	k = 0;
	for(i = Y_SIZE*4; i < Y_SIZE*4+widthLayer; i = i + 1)
	begin
		$readmemb({"C:\\Users\\Baisyn\\research\\neuroNoCScripts\\neuroNoCScripts\\w_2_", k+"0", ".mif"}, dataWeight2);
		for(j = Y_SIZE; j < Y_SIZE+widthLayer; j=j+1) 
		begin
			sendpacket(CONF_W, counter, i, j, dataWeight2[j-Y_SIZE]);
		end
		for(j = Y_SIZE*2; j < Y_SIZE*2+widthLayer; j=j+1) 
		begin
			sendpacket(CONF_W, counter, i, j, dataWeight2[j-Y_SIZE*2]);
		end
		for(j = Y_SIZE*3; j < Y_SIZE*3+widthLayer; j=j+1) 
		begin
			sendpacket(CONF_W, counter, i, j, dataWeight2[j-Y_SIZE*3]);
		end
		k = k+1;
	end
	
	//weight second and output layers
	k = 0;
	for(i = Y_SIZE*5; i < Y_SIZE*5+widthLayer; i = i + 1)
	begin
		$readmemb({"C:\\Users\\Baisyn\\research\\neuroNoCScripts\\neuroNoCScripts\\w_3_", k+"0", ".mif"}, dataWeight3);
		for(j = Y_SIZE*4; j < Y_SIZE*4+widthLayer; j=j+1) 
		begin
			sendpacket(CONF_W, counter, i, j, dataWeight3[j-Y_SIZE*4]);
		end
		k = k + 1;
	end
	
	//end
	
	//SEND INPUTS
	
	input_ready<=1;
	repeat(1)
	begin
		counter=counter+1;
		$readmemb({"C:\\Users\\Baisyn\\research\\neuroNoCScripts\\neuroNoCScripts\\validation_data.txt"}, testData);
		for(k = 0; k < 783; k=k+1)
            sendpacket(DATA, counter, k, 0, testData[k]);
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

