module switch  #(parameter this_x=0,this_y=0)( 
i_clk,i_rst_n, 
i_n_valid,o_n_ready,i_n_data,
o_n_valid,i_n_ready,o_n_data,
i_s_valid,o_s_ready,i_s_data,
o_s_valid,i_s_ready,o_s_data,
i_e_valid,o_e_ready,i_e_data,
o_e_valid,i_e_ready,o_e_data,
i_w_valid,o_w_ready,i_w_data,
o_w_valid,i_w_ready,o_w_data,
i_pe_valid,o_pe_ready,i_pe_data,
o_pe_valid,i_pe_ready,o_pe_data
);

`include "header.vh"
reg  [PACKET_SIZE-1:0] asd;
reg [1:0] qwe;
input   i_clk;
input   i_rst_n;
   // north input
input 	i_n_valid;
output	o_n_ready;   
input [PACKET_SIZE-1:0] i_n_data;
   // north output   
output o_n_valid;
input i_n_ready;
output [PACKET_SIZE-1:0] o_n_data;
   // south input
input i_s_valid;
output o_s_ready;
input [PACKET_SIZE-1:0] i_s_data;
   // south output
output o_s_valid;
input i_s_ready;
output [PACKET_SIZE-1:0] o_s_data;
   // east input
input i_e_valid;
output o_e_ready;
input [PACKET_SIZE-1:0] i_e_data;
   // east output
output o_e_valid;
input i_e_ready;
output [PACKET_SIZE-1:0] o_e_data;
   // west input
input i_w_valid;
output o_w_ready;
input [PACKET_SIZE-1:0] i_w_data;
   // west output
output o_w_valid;
input i_w_ready;
output [PACKET_SIZE-1:0] o_w_data;   
   // pe input
input i_pe_valid;
output o_pe_ready;
input [PACKET_SIZE-1:0] i_pe_data;
   // pe output
output o_pe_valid;
input i_pe_ready;
output [PACKET_SIZE-1:0] o_pe_data;


reg [2:0] currFifo;
reg [2:0] prevFifo;
reg [2:0] destFifo;

wire [4:0] mFifoValid;
reg  [4:0] mFifoReady;
wire [PACKET_SIZE-1:0] mFifoData [4:0];


reg  [4:0] sFifoValid;
wire [4:0] sFifoReady;
reg  [PACKET_SIZE-1:0] sFifoData [4:0];
//0 north 1 south 2 east 3 west 4 pe

reg [4:0] RT [NETWORK_SIZE-1:0];
reg [3:0] currState, prevState;
localparam 	IDLE = 3'b0000,
			CheckNorth= 4'b0001,
			CheckSouth= 4'b0010,
			CheckEast = 4'b0011,
			CheckWest = 4'b0100,
			WaitReady = 4'b0101,
			CheckFifo = 4'b0110,
			CheckPE   = 4'b0111,
			RegularSwitch 	= 4'b1000,
			ForwardingTableSwitch = 4'b1001,
			SendPacket=    4'b1010,
			CheckQueue = 4'b1011;
/*integer i = 0;
initial
begin
	RT[0] = 'b01111;
	RT[1] = 'b00010;
	RT[2] = 'b00100;
	RT[3] = 'b01000;
	RT[4] = 'b00001;
	for (i=5; i<=100; i=i+1)
		RT[i] = $urandom()%32; 
end
*/

always @(posedge i_clk)
begin
    if(i_rst_n)
    begin
        currState <= IDLE;
        currFifo <= 3'b000;
        mFifoReady <= 5'h0;  
    end
    else
    begin
		case(currState)
            IDLE:begin
                mFifoReady <= 0;
                sFifoValid <= 0;
				prevFifo <= currFifo;
				currState <= CheckQueue;
			end	
			CheckQueue:begin
				case(currFifo)
				    0:begin
				        if(mFifoValid[1] == 1)
						begin
				            if(mFifoData[1][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[1][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;	
							currFifo <= 1;
						end
						else if(mFifoValid[2] == 1)
				        begin
							if(mFifoData[2][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[2][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA) 
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 2;
						end
						else if(mFifoValid[3] == 1)
				        begin
							if(mFifoData[3][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[3][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 3;
						end
						else if(mFifoValid[4] == 1)
						begin
							
							if(mFifoData[4][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[4][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 4;
						end
						else if(mFifoValid[0] == 1)
						begin
							if(mFifoData[0][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[0][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 0;
						end
				    end
				    1:begin
				        if(mFifoValid[2] == 1)
						begin
				            if(mFifoData[2][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[2][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 2;
						end
						else if(mFifoValid[3] == 1)
				        begin    
							if(mFifoData[3][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[3][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;	
							currFifo <= 3;
						end
						else if(mFifoValid[4] == 1)
				        begin
							if(mFifoData[4][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[4][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;	
							currFifo <= 4;							
						end
						else if(mFifoValid[0] == 1)
						begin
							if(mFifoData[0][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[0][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 0;
						end
						else if(mFifoValid[1] == 1)
						begin
							if(mFifoData[1][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[1][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
								currFifo <= 1;
						end
					end	
				    2:begin
						if(mFifoValid[3] == 1)
						begin
				            if(mFifoData[3][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[3][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else
								currState <= RegularSwitch;
							currFifo <= 3;
							
						end
						else if(mFifoValid[4] == 1)
				        begin    
							if(mFifoData[4][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[4][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 4;	
						end
						else if(mFifoValid[0] == 1)
				        begin
							if(mFifoData[0][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[0][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 0;
						end
						else if(mFifoValid[1] == 1)
						begin
							if(mFifoData[1][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[1][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 1;
						end
						else if(mFifoValid[2] == 1)
						begin
							if(mFifoData[2][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[2][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 2;
						end
					end
				    3: begin
						if(mFifoValid[4] == 1)
						begin
				            if(mFifoData[4][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[4][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 4;	
						end
						else if(mFifoValid[0] == 1)
				        begin    
							if(mFifoData[0][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[0][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 0;	
						end
						else if(mFifoValid[1] == 1)
				        begin
							if(mFifoData[1][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[1][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 1;								
						end
						else if(mFifoValid[2] == 1)
						begin
							if(mFifoData[2][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[2][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else
								currState <= RegularSwitch;
							currFifo <= 2;
						end
						else if(mFifoValid[3] == 1)
						begin
							if(mFifoData[3][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[3][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
								currFifo <= 3;
						end
					end
				    4:begin
						if(mFifoValid[0] == 1)
						begin
				            if(mFifoData[0][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[0][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 0;
						end
						else if(mFifoValid[1] == 1)
				        begin    
							if(mFifoData[1][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[1][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 1;
						end
						else if(mFifoValid[2] == 1)
				        begin
							if(mFifoData[2][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[2][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 2;
						end
						else if(mFifoValid[3] == 1)
						begin
							if(mFifoData[3][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT)
								currState <= ForwardingTableSwitch;
							else if(mFifoData[3][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
							currFifo <= 3;
						end
						else if(mFifoValid[4] == 1)
						begin
							if(mFifoData[4][TYPE_START+TYPE_WIDTH-1:TYPE_START] == CONF_FT) 
								currState <= ForwardingTableSwitch;
							else if(mFifoData[4][TYPE_START+TYPE_WIDTH-1:TYPE_START] == DATA)
								currState <= CheckFifo;
							else 
								currState <= RegularSwitch;
						    currFifo <= 4;
						end
					end
				    default:
				        currState <= IDLE;
				endcase
			end
			SendPacket:begin
				if(prevState == ForwardingTableSwitch) 
				begin
					currState <= IDLE;
					sFifoData[destFifo] <= mFifoData[currFifo];
					mFifoReady[currFifo] <= 1'b1;
					sFifoValid[destFifo] <= 1'b1;
				end
				else if(prevState == RegularSwitch)
				begin
					currState <= IDLE;
					sFifoData[destFifo] <= mFifoData[currFifo];
					mFifoReady[currFifo] <= 1'b1;
					sFifoValid[destFifo] <= 1'b1;
				end 
				else
				begin
					if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][0] == 1'b1)
					begin
						sFifoData[0] <= mFifoData[currFifo];
						sFifoValid[0] <= 1'b1;
					end
					if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][1] == 1'b1)
					begin
						sFifoData[1] <= mFifoData[currFifo];
						sFifoValid[1] <= 1'b1;
					end
					if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][2] == 1'b1)
					begin
						sFifoData[2] <= mFifoData[currFifo];
						sFifoValid[2] <= 1'b1;
					end
					if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][3] == 1'b1)
					begin
						sFifoData[3] <= mFifoData[currFifo];
						sFifoValid[3] <= 1'b1;
					end
					if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][4] == 1'b1)
					begin
						sFifoData[4] <= mFifoData[currFifo];	
						sFifoValid[4] <= 1'b1;
					end
					mFifoReady[currFifo] <= 1'b1;
					currState <= IDLE;
				end
			end
			ForwardingTableSwitch:begin
				
				if(mFifoData[currFifo][SWITCHNUMBER_START+SWITCHNUMBER_WIDTH-1:SWITCHNUMBER_START] == this_x*Y_SIZE + this_y)
				begin
					RT[mFifoData[currFifo][ENTRYNUMBER_START+ENTRYNUMBER_WIDTH-1:ENTRYNUMBER_START]] <= mFifoData[currFifo][DATA_START+DATA_WIDTH-1:DATA_START];
					mFifoReady[currFifo] <= 1'b1;
					currState <= IDLE;
				end
				else 
				begin
					if(mFifoData[currFifo][SWITCHNUMBER_START+SWITCHNUMBER_WIDTH-1:SWITCHNUMBER_START]/Y_SIZE > this_x)
					begin
						if(sFifoReady[0])
                        begin
							destFifo <= 0;
							prevState <= currState;
                            currState <= SendPacket; 
                        end		
					end
					else if(mFifoData[currFifo][SWITCHNUMBER_START+SWITCHNUMBER_WIDTH-1:SWITCHNUMBER_START]/Y_SIZE < this_x)
					begin
						if(sFifoReady[1])
                        begin
                            destFifo <= 1;
							prevState <= currState;
                            currState <= SendPacket;  
                        end
					end
					else if(mFifoData[currFifo][SWITCHNUMBER_START+SWITCHNUMBER_WIDTH-1:SWITCHNUMBER_START]%Y_SIZE > this_y)
					begin
						if(sFifoReady[2])
                        begin
                            destFifo <= 2;
							prevState <= currState;
                            currState <= SendPacket; 
                        end
					end
					else if(mFifoData[currFifo][SWITCHNUMBER_START+SWITCHNUMBER_WIDTH-1:SWITCHNUMBER_START]%Y_SIZE < this_y)
					begin
						if(sFifoReady[3])
                        begin
                            destFifo <= 3;
							prevState <= currState;
                            currState <= SendPacket;  
                        end
					end	
				end			
			end
			
			RegularSwitch:begin
				if(mFifoData[currFifo][DEST_START+DEST_WIDTH-1:DEST_START] == this_x*Y_SIZE + this_y)
				begin
					if(sFifoReady[4])
					begin
						destFifo <= 4;
						prevState <= currState;
						currState <= SendPacket; 
				    end
				end
				else 
				begin
					if(mFifoData[currFifo][DEST_START+DEST_WIDTH-1:DEST_START]/Y_SIZE > this_x)
					begin
						if(sFifoReady[0])
                        begin
                            destFifo <= 0;
							prevState <= currState;
							currState <= SendPacket; 
                        end
					end
					else if(mFifoData[currFifo][DEST_START+DEST_WIDTH-1:DEST_START]/Y_SIZE < this_x)
					begin
						if(sFifoReady[1])
                        begin
                            destFifo <= 1;
							prevState <= currState;
							currState <= SendPacket; 
                        end
					end
					else if(mFifoData[currFifo][DEST_START+DEST_WIDTH-1:DEST_START]%Y_SIZE > this_y)
					begin
						if(sFifoReady[2])
                        begin
                            destFifo <= 2;
							prevState <= currState;
							currState <= SendPacket;  
                        end
					end
					else if(mFifoData[currFifo][DEST_START+DEST_WIDTH-1:DEST_START]%Y_SIZE < this_y)
					begin
						if(sFifoReady[3])
                        begin
                            destFifo <= 3;
							prevState <= currState;
							currState <= SendPacket; 
                        end
					end	
				end			
			end
			CheckFifo:begin
				if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][0] == 1'b1)
				begin
					currState <= CheckNorth;
				end
				else if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][1] == 1'b1)
				begin
					currState <= CheckSouth;
				end
				else if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][2] == 1'b1)
				begin
					currState <= CheckEast;
				end
				else if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][3] == 1'b1)
				begin
					currState <= CheckWest;
				end
				else if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][4] == 1'b1)
				begin
					currState <= CheckPE;
				end
				else
				begin
					currState <= IDLE;	
					mFifoReady[currFifo] <= 1'b1;
				end
			end
			CheckNorth: begin		
				prevState <= currState;
				if(!sFifoReady[0])
				begin
					currState <= WaitReady;
				end
				else
				begin
					if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][1] == 1'b1)
					begin
						currState <= CheckSouth;
					end
					else if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][2] == 1'b1)
					begin
						currState <= CheckEast;
					end
					else if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][3] == 1'b1)
					begin
						currState <= CheckWest;
					end
					else if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][4] == 1'b1)
					begin
						currState <= CheckPE;
					end
					else
						currState <= SendPacket;	
				end
			end
			CheckSouth:
			begin
				prevState <= currState;
				if(!sFifoReady[1])
				begin
					currState <= WaitReady;
				end
				else 
				begin
				    if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][2] == 1'b1)
					begin
						currState <= CheckEast;
					end
					else if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][3] == 1'b1)
					begin
						currState <= CheckWest;
					end
					else if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][4] == 1'b1)
					begin
						currState <= CheckPE;
					end
					else
						currState <= SendPacket;	
				end
			end
			CheckEast:
			begin
				prevState <= currState;
				if(!sFifoReady[2])
				begin
					currState <= WaitReady;
				end
				else 
				begin
					if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][3] == 1'b1)
					begin
						currState <= CheckWest;
					end
					else if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][4] == 1'b1)
					begin
						currState <= CheckPE;
					end
					else
						currState <= SendPacket;	
				end
			end
			CheckWest:
			begin
				prevState <= currState;
				if(!sFifoReady[3])
				begin
					currState <= WaitReady;
				end
				else 
				begin
					if(RT[mFifoData[currFifo][SOURCE_START+SOURCE_WIDTH-1:SOURCE_START]][4] == 1'b1)
					begin
						currState <= CheckPE;
					end
					else
						currState <= SendPacket;	
				end
			end
			CheckPE:begin
				prevState <= currState;
				if(!sFifoReady[4])
				begin
					currState <= WaitReady;
				end
				else
					currState <= SendPacket;		
			end
			WaitReady:begin
				case(prevState)
					CheckNorth:
					begin
						if(sFifoReady[0])
							currState <= prevState;
					end
					CheckSouth:
					begin
						if(sFifoReady[1])
							currState <= prevState;
					end
					CheckEast:
					begin	
						if(sFifoReady[2])
							currState <= prevState;
					end
					CheckWest:
					begin	
						if(sFifoReady[3])
							currState <= prevState;
					end
					CheckPE:
					begin
						if(sFifoReady[4])
							currState <= prevState;
					end
					default: currState <= IDLE;
				endcase
            end
        endcase
    end
end

fifo North_i (
  //.wr_rst_busy(),      // output wire wr_rst_busy
 // .rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(!i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(i_n_valid),  // input wire s_axis_tvalid
  .s_axis_tready(o_n_ready),  // output wire s_axis_tready
  .s_axis_tdata(i_n_data),    // input wire [32 : 0] s_axis_tdata
  .m_axis_tvalid(mFifoValid[0]),  // output wire m_axis_tvalid
  .m_axis_tready(mFifoReady[0]),  // input wire m_axis_tready
  .m_axis_tdata(mFifoData[0])    // output wire [32 : 0] m_axis_tdata
);

fifo South_i (
 // .wr_rst_busy(),      // output wire wr_rst_busy
 // .rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(!i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(i_s_valid),  // input wire s_axis_tvalid
  .s_axis_tready(o_s_ready),  // output wire s_axis_tready
  .s_axis_tdata(i_s_data),    // input wire [32 : 0] s_axis_tdata
  .m_axis_tvalid(mFifoValid[1]),  // output wire m_axis_tvalid
  .m_axis_tready(mFifoReady[1]),  // input wire m_axis_tready
  .m_axis_tdata(mFifoData[1])    // output wire [32 : 0] m_axis_tdata
);

fifo East_i (
  //.wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(!i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(i_e_valid),  // input wire s_axis_tvalid
  .s_axis_tready(o_e_ready),  // output wire s_axis_tready
  .s_axis_tdata(i_e_data),    // input wire [32 : 0] s_axis_tdata
  .m_axis_tvalid(mFifoValid[2]),  // output wire m_axis_tvalid
  .m_axis_tready(mFifoReady[2]),  // input wire m_axis_tready
  .m_axis_tdata(mFifoData[2])    // output wire [32 : 0] m_axis_tdata
);

fifo West_i (
 // .wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(!i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(i_w_valid),  // input wire s_axis_tvalid
  .s_axis_tready(o_w_ready),  // output wire s_axis_tready
  .s_axis_tdata(i_w_data),    // input wire [32 : 0] s_axis_tdata
  .m_axis_tvalid(mFifoValid[3]),  // output wire m_axis_tvalid
  .m_axis_tready(mFifoReady[3]),  // input wire m_axis_tready
  .m_axis_tdata(mFifoData[3])    // output wire [32 : 0] m_axis_tdata
);


fifo PE_i (
 // .wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(!i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(i_pe_valid),  // input wire s_axis_tvalid
  .s_axis_tready(o_pe_ready),  // output wire s_axis_tready
  .s_axis_tdata(i_pe_data),    // input wire [32 : 0] s_axis_tdata
  .m_axis_tvalid(mFifoValid[4]),  // output wire m_axis_tvalid
  .m_axis_tready(mFifoReady[4]),  // input wire m_axis_tready
  .m_axis_tdata(mFifoData[4])    // output wire [32 : 0] m_axis_tdata
);



fifo North_o (
  //.wr_rst_busy(),      // output wire wr_rst_busy
 // .rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(!i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(sFifoValid[0]),  // input wire s_axis_tvalid
  .s_axis_tready(sFifoReady[0]),  // output wire s_axis_tready
  .s_axis_tdata(sFifoData[0]),    // input wire [32 : 0] s_axis_tdata
  .m_axis_tvalid(o_n_valid),  // output wire m_axis_tvalid
  .m_axis_tready(i_n_ready),  // input wire m_axis_tready
  .m_axis_tdata(o_n_data)    // output wire [32 : 0] m_axis_tdata
);

fifo South_o (
 // .wr_rst_busy(),      // output wire wr_rst_busy
 // .rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(!i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(sFifoValid[1]),  // input wire s_axis_tvalid
  .s_axis_tready(sFifoReady[1]),  // output wire s_axis_tready
  .s_axis_tdata(sFifoData[1]),    // input wire [32 : 0] s_axis_tdata
  .m_axis_tvalid(o_s_valid),  // output wire m_axis_tvalid
  .m_axis_tready(i_s_ready),  // input wire m_axis_tready
  .m_axis_tdata(o_s_data)    // output wire [32 : 0] m_axis_tdata
);

fifo East_o (
  //.wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(!i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(sFifoValid[2]),  // input wire s_axis_tvalid
  .s_axis_tready(sFifoReady[2]),  // output wire s_axis_tready
  .s_axis_tdata(sFifoData[2]),    // input wire [32 : 0] s_axis_tdata
  .m_axis_tvalid(o_e_valid),  // output wire m_axis_tvalid
  .m_axis_tready(i_e_ready),  // input wire m_axis_tready
  .m_axis_tdata(o_e_data)    // output wire [32 : 0] m_axis_tdata
);

fifo West_o (
 // .wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(!i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(sFifoValid[3]),  // input wire s_axis_tvalid
  .s_axis_tready(sFifoReady[3]),  // output wire s_axis_tready
  .s_axis_tdata(sFifoData[3]),    // input wire [32 : 0] s_axis_tdata
  .m_axis_tvalid(o_w_valid),  // output wire m_axis_tvalid
  .m_axis_tready(i_w_ready),  // input wire m_axis_tready
  .m_axis_tdata(o_w_data)    // output wire [32 : 0] m_axis_tdata
);
fifo PE_o (
 // .wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(!i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(sFifoValid[4]),  // input wire s_axis_tvalid
  .s_axis_tready(sFifoReady[4]),  // output wire s_axis_tready
  .s_axis_tdata(sFifoData[4]),    // input wire [32 : 0] s_axis_tdata
  .m_axis_tvalid(o_pe_valid),  // output wire m_axis_tvalid
  .m_axis_tready(i_pe_ready),  // input wire m_axis_tready
  .m_axis_tdata(o_pe_data)    // output wire [32 : 0] m_axis_tdata
);




endmodule