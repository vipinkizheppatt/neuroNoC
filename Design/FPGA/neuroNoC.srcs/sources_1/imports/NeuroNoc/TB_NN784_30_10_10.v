`timescale 1ns / 1ns

module testbench_neuronoc();
`include "header.vh"

integer widthLayer=10;
integer heightFirst =3;
integer heightSecond =4;
integer heightThird =5;
integer klimit=0;
integer jlimit=0;
integer ilimit=0;

integer file1;
integer file2;
real dataWeight [0:3][0:30][0:784];
real dataBias [0:3][0:30];

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
		for(u = 80; u < 90; u = u + 1)
		begin 
			sendpacketFT(CONF_FT, i, u, 0, 5'b01000);	
		end
	end
	sendpacketFT(CONF_FT, widthLayer-1, 0, 0, 5'b00001);
	
	//next 6 rows
	for(j = 1; j < heightFirst; j = j + 1)
	begin
		for(i = 16*j; i < j*16+widthLayer; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, i , 0, 0, 5'b10001);
		end
	end
			
	
	for(i = 48; i < 58; i = i + 1)
	begin            
	   sendpacketFT(CONF_FT, i , 0, 0, 5'b10000);
    end
	
	// first layer
	//sources are first and last columns with 3 rows 1-3 
	
	for(j = 1; j < heightFirst+1; j = j + 1)
	begin
		sendpacketFT(CONF_FT, 16*j, j*16+widthLayer-1, 0, 5'b00001);
		sendpacketFT(CONF_FT, 16*j, j*16, 0, 5'b00101);
		sendpacketFT(CONF_FT, 16*j+widthLayer-1, j*16+widthLayer-1, 0, 5'b01001);
		sendpacketFT(CONF_FT, 16*j+widthLayer-1, j*16, 0, 5'b00001);
		for(i = 16*j+1; i < j*16+widthLayer-1; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, i, j*16, 0, 5'b00101);
			sendpacketFT(CONF_FT, i, j*16+widthLayer-1, 0, 5'b01001);
		end		
		for(k = j+1; k < heightFirst+1; k = k + 1)
		begin
			for(i = 16*k; i < k*16+widthLayer; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*16, 0, 5'b00001);
				sendpacketFT(CONF_FT, i, j*16 + widthLayer-1, 0, 5'b00001);
			end
		end
		for(k = heightFirst+1; k < heightSecond; k = k + 1)
		begin
			for(i = 16*k; i < k*16+widthLayer; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*16, 0, 5'b10001);
				sendpacketFT(CONF_FT, i, j*16 + widthLayer-1, 0, 5'b10001);
			end
		end
		for(i = 64; i < 74; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, j*16, 0, 5'b10000);
			sendpacketFT(CONF_FT, i, j*16 + widthLayer-1, 0, 5'b10000);
		end
	end
	// source are all middle located switches
	for(j = 1; j < heightFirst+1; j = j + 1)
	begin
		
		for(i = 16*j+1; i < j*16+widthLayer-1; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, j*16, i, 0, 5'b00001);
			for(k = j*16+1; k < i; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b01001);
			end
			sendpacketFT(CONF_FT, i, i, 0, 5 'b01101);
			for(k = i+1; k < j*16+widthLayer-1; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b00101);
			end
			sendpacketFT(CONF_FT, k, i, 0, 5'b00001);
			for(k = j+1; k < heightFirst+1; k = k + 1)
				for(u = 16*k; u < k*16+widthLayer; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b00001);
			for(k = heightFirst+1; k < heightSecond; k = k + 1)
				for(u = 16*k; u < k*16+widthLayer; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b10001);
			for(u = 64; u < 74; u = u + 1)
				sendpacketFT(CONF_FT, u, i, 0, 5'b10000);
		end		
	end	
	
	//second layer
	//sources are first and last columns with 1 rows 4
	
	for(j = heightFirst+1; j < heightSecond+1; j = j + 1)
	begin
		sendpacketFT(CONF_FT, 16*j, j*16+widthLayer-1, 0, 5'b00001);
		sendpacketFT(CONF_FT, 16*j, j*16, 0, 5'b00101);
		sendpacketFT(CONF_FT, 16*j+widthLayer-1, j*16+widthLayer-1, 0, 5'b01001);
		sendpacketFT(CONF_FT, 16*j+widthLayer-1, j*16, 0, 5'b00001);
		for(i = 16*j+1; i < j*16+widthLayer-1; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, i, j*16, 0, 5'b00101);
			sendpacketFT(CONF_FT, i, j*16+widthLayer-1, 0, 5'b01001);
		end		
		for(k = j+1; k < heightSecond+1; k = k + 1)
		begin
			for(i = 16*k; i < k*16+widthLayer; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*16, 0, 5'b00001);
				sendpacketFT(CONF_FT, i, j*16 + widthLayer-1, 0, 5'b00001);
			end
		end
		for(k = heightSecond+1; k < heightThird; k = k + 1)
		begin
			for(i = 16*k; i < k*16+widthLayer; i = i + 1)
			begin
				sendpacketFT(CONF_FT, i, j*16, 0, 5'b10001);
				sendpacketFT(CONF_FT, i, j*16 + widthLayer-1, 0, 5'b10001);
			end
		end
		for(i = 80; i < 90; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, j*16, 0, 5'b10000);
			sendpacketFT(CONF_FT, i, j*16 + widthLayer-1, 0, 5'b10000);
		end
	end
	// source are all middle located switches
	for(j = heightFirst+1; j < heightSecond+1; j = j + 1)
	begin
		for(i = 16*j+1; i < j*16+widthLayer-1; i = i + 1) 
		begin
			sendpacketFT(CONF_FT, j*16, i, 0, 5'b00001);
			for(k = j*16+1; k < i; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b01001);
			end
			sendpacketFT(CONF_FT, i, i, 0, 5 'b01101);
			for(k = i+1; k < j*16+widthLayer-1; k = k + 1)
			begin
				sendpacketFT(CONF_FT, k, i, 0, 5'b00101);
			end
			sendpacketFT(CONF_FT, k, i, 0, 5'b00001);
			for(k = j+1; k < heightSecond+1; k = k + 1)
				for(u = 16*k; u < k*16+widthLayer; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b00001);
			for(k = heightSecond+1; k < heightThird; k = k + 1)
				for(u = 16*k; u < k*16+widthLayer; u = u + 1)
					sendpacketFT(CONF_FT, u, i, 0, 5'b10001);
			for(u = 80; u < 90; u = u + 1)
				sendpacketFT(CONF_FT, u, i, 0, 5'b10000);
				
		end		
	end		
	
	
	
	//output layer
	
	for(j = heightSecond+1; j < heightThird+1; j = j + 1)
	begin
		for(i = j*16; i < j*16+widthLayer; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, i, 0, 5'b00010);
			//if(j < 15) 	sendpacketFT(CONF_FT, i, i+16, 0, 5'b00010);
			//if(j < 14)	sendpacketFT(CONF_FT, i, i+32, 0, 5'b00010);
		end
	end
	
	for(j = 1; j < heightSecond+1; j = j + 1)
	begin
		for(i = j*16; i < j*16+widthLayer; i = i + 1)
		begin
			sendpacketFT(CONF_FT, i, heightThird*16+(i%16), 0, 5'b00010);
			//sendpacketFT(CONF_FT, i, 224+(i%16), 0, 5'b00010);
			//sendpacketFT(CONF_FT, i, 240+(i%16), 0, 5'b00010);
		end
	end
	
	for(i = 0; i < widthLayer; i = i + 1) 
	begin
		for(j = 13; j < widthLayer; j = j + 1)
		begin
			for(k = j*16; k < j*16 + widthLayer; k = k+1)
			begin
				if(i == 0)
					sendpacketFT(CONF_FT, i, k,  0, 5'b10000);
				else 
					sendpacketFT(CONF_FT, i, k,  0, 5'b01000);
				
			end
		end	
	end
	
    //END
			
    	//CONFIGURE INPUT NUMBER and BIAS
		
	//read weights
	file1=$fopen("weight.txt","r");
	k = 0;
	i = 0;
	j = 0;
	klimit = 784;
	jlimit = 30;
	while (!$feof(file1)) begin 
		$fscanf(file1,"%d",dataWeight[i][j][k]); //write as decimal
		k = k+1;
		if(k == klimit) begin
			j = j+1;
			k = 0;
		end
		if(j == jlimit) begin
			if(i == 3) break;
			i = i+1;
			j = 0;
			if(i == 1) begin
				klimit = 30;
				jlimit = 10;
			end
			if(i == 2) klimit = 10;
		end
    end 
	
	//read bias
	file1=$fopen("bias.txt","r");
	i = 0;
	j = 0;
	jlimit = 30;
	while (!$feof(file2)) begin 
		$fscanf(file2,"%d",dataBias[i][j]); //write as decimal
		j=j+1;
		if(j == jlimit) begin
			if(i==3) break;
			i=i+1;
			jlimit = 10;
			j=0;
		end
    end 
	
	
    counter=0;
	//conf bias
	k=0;
	for(j = 1; j < heightFirst+1; j = j + 1)
	begin
		for(i = j*16; i < j*16+widthLayer; i = i + 1)
		begin
			sendpacket(CONF_INB, counter, i, 784, d(dataBias[0][k], BIAS_WIDTH, BFRACTION, BINT));	
			k=k+1;
		end
	end
	k=0;
	for(j = heightFirst+1; j < heightSecond+1; j = j + 1)
	begin
		for(i = j*16; i < j*16+widthLayer; i = i + 1)
		begin
			sendpacket(CONF_INB, counter, i, 30, d(dataBias[1][k], BIAS_WIDTH, BFRACTION, BINT));	
			k=k+1;
		end
	end
	k=0;
	for(j = heightSecond+1; j < heightThird+1; j = j + 1)
	begin
		for(i = j*16; i < j*16+widthLayer; i = i + 1)
		begin
			sendpacket(CONF_INB, counter, i, 10, d(dataBias[2][k], BIAS_WIDTH, BFRACTION, BINT));	
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
		for(i = 16*u; i < u*16+widthLayer; i = i + 1)
		begin
			for(j = 0; j < 784; j=j+1) 
			begin
				sendpacket(CONF_W, counter, i, j, d(dataWeight[0][k][j],WEIGHT_WIDTH, WFRACTION, WINT));
			end
			//weight first and second layers
			for(j = 64; j < 74; j=j+1) 
			begin
				sendpacket(CONF_W, counter, j, i, d(dataWeight[1][j-64][k],WEIGHT_WIDTH, WFRACTION, WINT));
			end
			k = k + 1;
		end
	end
	
	
	//weight second and output layers
	for(i = 80; i < 80+widthLayer; i = i + 1)
	begin
		for(j = 64; j < 64+widthLayer; j=j+1) 
		begin
			sendpacket(CONF_W, counter, i, j, d(dataWeight[2][i-80][j-64],WEIGHT_WIDTH, WFRACTION, WINT));
		end
	end
	
	//end
	
	//SEND INPUTS
	
	input_ready<=1;
	repeat(1)
	begin
	   counter=counter+1;
		for(k = 0; k < 48; k=k+1)
            sendpacket(DATA, counter, k, 0, d(1.5, INPUT_WIDTH, IFRACTION, IINT));
            
        
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

