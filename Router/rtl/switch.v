module switch(
    input   i_clk,
    input   i_rst_n,
    // north input
    input i_n_valid,
    output o_n_ready,
    input [41:0] i_n_data,
    // north output
    output o_n_valid,
    input i_n_ready,
    output [41:0] o_n_data,
    
	// south input
    input i_s_valid,
    output o_s_ready,
    input [41:0] i_s_data,
    // south output
    output o_s_valid,
    input i_s_ready,
    output [41:0] o_s_data,
    
    // east input
    input i_e_valid,
    output o_e_ready,
    input [41:0] i_e_data,
    // east output
    output o_e_valid,
    input i_e_ready,
    output [41:0] o_e_data,
    
	// west input
    input i_w_valid,
    output o_w_ready,
    input [41:0] i_w_data,
    // west output
    output o_w_valid,
    input i_w_ready,
    output [41:0] o_w_data,
	
	// pe input
    input i_pe_valid,
    output o_pe_ready,
    input [41:0] i_pe_data,
    // pe output
    output o_pe_valid,
    input i_pe_ready,
    output [41:0] o_pe_data

);

reg [2:0] currFifo;
reg [2:0] prevFifo;

wire [4:0] mFifoValid;
reg  [4:0] mFifoReady;
wire [41:0] mFifoData [4:0];


reg  [4:0] sFifoValid;
wire [4:0] sFifoReady;
reg  [41:0] sFifoData [4:0];


reg [4:0] RT [99:0];
reg [2:0] currState, prevState;
localparam 	IDLE = 3'b000,
			CheckNorth = 3'b001,
			CheckSouth =  3'b010,
			CheckEast = 3'b011,
			CheckWest = 3'b100,
			WaitReady = 3'b101,
			CheckFifo = 3'b110,
			CheckPE = 3'b111;
integer i = 0;
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

always @(posedge i_clk)
begin
    if(!i_rst_n)
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
                //if(mFifoValid[currFifo]) currState <= CheckFifo;
				//else
				//begin
				//prevFifo <= currFifo;
				case(currFifo)
				    0:begin
				        if(mFifoValid[1] == 1)
						begin
				            currFifo <= 1;
							currState <= CheckFifo;
						end
						else if(mFifoValid[2] == 1)
				        begin    
							currFifo <= 2;
				        	currState <= CheckFifo;
						end
						else if(mFifoValid[3] == 1)
				        begin
							currFifo <= 3;
							currState <= CheckFifo;
						end
						else if(mFifoValid[4] == 1)
						begin
							currFifo <= 4;
							currState <= CheckFifo;
						end
						else if(mFifoValid[0] == 1)
						begin
							currState <= CheckFifo;
						end
				    end
				    1:begin
				        if(mFifoValid[2] == 1)
						begin
				            currFifo <= 2;
							currState <= CheckFifo;
						end
						else if(mFifoValid[3] == 1)
				        begin    
							currFifo <= 3;
				        	currState <= CheckFifo;
						end
						else if(mFifoValid[4] == 1)
				        begin
							currFifo <= 4;
							currState <= CheckFifo;
						end
						else if(mFifoValid[0] == 1)
						begin
							currFifo <= 0;
							currState <= CheckFifo;
						end
						else if(mFifoValid[1] == 1)
						begin
							currState <= CheckFifo;
						end
					end	
				    2:begin
						if(mFifoValid[3] == 1)
						begin
				            currFifo <= 3;
							currState <= CheckFifo;
						end
						else if(mFifoValid[4] == 1)
				        begin    
							currFifo <= 4;
				        	currState <= CheckFifo;
						end
						else if(mFifoValid[0] == 1)
				        begin
							currFifo <= 0;
							currState <= CheckFifo;
						end
						else if(mFifoValid[1] == 1)
						begin
							currFifo <= 1;
							currState <= CheckFifo;
						end
						else if(mFifoValid[2] == 1)
						begin
							currState <= CheckFifo;
						end
					end
				    3: begin
						if(mFifoValid[4] == 1)
						begin
				            currFifo <= 4;
							currState <= CheckFifo;
						end
						else if(mFifoValid[0] == 1)
				        begin    
							currFifo <= 0;
				        	currState <= CheckFifo;
						end
						else if(mFifoValid[1] == 1)
				        begin
							currFifo <= 1;
							currState <= CheckFifo;
						end
						else if(mFifoValid[2] == 1)
						begin
							currFifo <= 2;
							currState <= CheckFifo;
						end
						else if(mFifoValid[3] == 1)
						begin
							currState <= CheckFifo;
						end
					end
				    4:begin
						if(mFifoValid[0] == 1)
						begin
				            currFifo <= 0;
							currState <= CheckFifo;
						end
						else if(mFifoValid[1] == 1)
				        begin    
							currFifo <= 1;
				        	currState <= CheckFifo;
						end
						else if(mFifoValid[2] == 1)
				        begin
							currFifo <= 2;
							currState <= CheckFifo;
						end
						else if(mFifoValid[3] == 1)
						begin
							currFifo <= 3;
							currState <= CheckFifo;
						end
						else if(mFifoValid[4] == 1)
						begin
							currState <= CheckFifo;
						end
					end
				    default:
				        currState <= IDLE;
				endcase
				
				//if(mFifoValid[currFifo]) currState <= CheckFifo;
			end	
			CheckFifo:begin
				if(RT[mFifoData[currFifo][38:32]][0] == 1'b1)
				begin
					currState <= CheckNorth;	
					sFifoData[0] <= mFifoData[currFifo];
					sFifoValid[0] <= 1'b1;
				end
				else if(RT[mFifoData[currFifo][38:32]][1] == 1'b1)
				begin
					currState <= CheckSouth;
					sFifoData[1] <= mFifoData[currFifo];
					sFifoValid[1] <= 1'b1;
				end
				else if(RT[mFifoData[currFifo][38:32]][2] == 1'b1)
				begin
					currState <= CheckEast;
					sFifoData[2] <= mFifoData[currFifo];
					sFifoValid[2] <= 1'b1;
				end
				else if(RT[mFifoData[currFifo][38:32]][3] == 1'b1)
				begin
					currState <= CheckWest;
					sFifoData[3] <= mFifoData[currFifo];
					sFifoValid[3] <= 1'b1;
				end
				else if(RT[mFifoData[currFifo][38:32]][4] == 1'b1)
				begin
					currState <= CheckPE;
					sFifoData[4] <= mFifoData[currFifo];
					sFifoValid[4] <= 1'b1;
				end
				else
				begin
					currState <= IDLE;	
				end
			end
			CheckNorth: begin				                  
				if(!sFifoReady[0])
				begin
					currState <= WaitReady;
					prevState <= currState;
				end
				else
				begin
					//mFifoValid[currFifo] <= 1'b0;
					if(RT[mFifoData[currFifo][38:32]][1] == 1'b1)
					begin
						currState <= CheckSouth;
						sFifoData[1] <= mFifoData[currFifo];
						sFifoValid[1] <= 1'b1;
					end
					else if(RT[mFifoData[currFifo][38:32]][2] == 1'b1)
					begin
						currState <= CheckEast;
						sFifoData[2] <= mFifoData[currFifo];
						sFifoValid[2] <= 1'b1;
					end
					else if(RT[mFifoData[currFifo][38:32]][3] == 1'b1)
					begin
						currState <= CheckWest;
						sFifoData[3] <= mFifoData[currFifo];
						sFifoValid[3] <= 1'b1;
					end
					else if(RT[mFifoData[currFifo][38:32]][4] == 1'b1)
					begin
						currState <= CheckPE;
						sFifoData[4] <= mFifoData[currFifo];
						sFifoValid[4] <= 1'b1;
					end
					else
					begin
						currState <= IDLE;	
						mFifoReady[currFifo] <= 1'b1;
					end
				end
			end
			CheckSouth:
			begin
				if(!sFifoReady[1])
				begin
					prevState <= currState;
					currState <= WaitReady;
				end
				else 
				begin
					//mFifoValid[currFifo] <= 1'b0;
					if(RT[mFifoData[currFifo][38:32]][2] == 1'b1)
					begin
						currState <= CheckEast;
						sFifoData[2] <= mFifoData[currFifo];
						sFifoValid[2] <= 1'b1;
					end
					else if(RT[mFifoData[currFifo][38:32]][3] == 1'b1)
					begin
						currState <= CheckWest;
						sFifoData[3] <= mFifoData[currFifo];
						sFifoValid[3] <= 1'b1;
					end
					else if(RT[mFifoData[currFifo][38:32]][4] == 1'b1)
					begin
						currState <= CheckPE;
						sFifoData[4] <= mFifoData[currFifo];
						sFifoValid[4] <= 1'b1;
					end
					else
					begin
						currState <= IDLE;	
						mFifoReady[currFifo] <= 1'b1;
					end	
				end
			end
			CheckEast:
			begin
				if(!sFifoReady[2])
				begin
					prevState <= currState;
					currState <= WaitReady;
				end
				else 
				begin
					//mFifoValid[currFifo] <= 1'b0;
					if(RT[mFifoData[currFifo][38:32]][3] == 1'b1)
					begin
						currState <= CheckWest;
						sFifoData[3] <= mFifoData[currFifo];
						sFifoValid[3] <= 1'b1;
					end
					else if(RT[mFifoData[currFifo][38:32]][4] == 1'b1)
					begin
						currState <= CheckPE;
						sFifoData[4] <= mFifoData[currFifo];
						sFifoValid[4] <= 1'b1;
					end
					else
					begin
						currState <= IDLE;	
						mFifoReady[currFifo] <= 1'b1;
					end
					
				end
			end
			CheckWest:
			begin
				if(!sFifoReady[3])
				begin
					prevState <= currState;
					currState <= WaitReady;
				end
				else 
				begin
					//mFifoValid[currFifo] <= 1'b0;
					if(RT[mFifoData[currFifo][38:32]][4] == 1'b1)
					begin
						currState <= CheckPE;
						sFifoData[4] <= mFifoData[currFifo];
						sFifoValid[4] <= 1'b1;
					end
					else
					begin
						currState <= IDLE;	
						mFifoReady[currFifo] <= 1'b1;
					end
					
				end
			end
			CheckPE:begin
				if(!sFifoReady[4])
				begin
					prevState <= currState;
					currState <= WaitReady;
				end
				else
				begin
					currState <= IDLE;	
					mFifoReady[currFifo] <= 1'b1;
				end
			end
			WaitReady:begin
				case(prevState)
					CheckNorth: 
						if(sFifoReady[0])
						currState <= prevState;
					CheckSouth:
						if(sFifoReady[1])
						currState <= prevState;
					CheckEast:
						if(sFifoReady[2])
						currState <= prevState;
					CheckWest:
						if(sFifoReady[3])
						currState <= prevState;
					CheckPE:
						if(sFifoReady[4])
						currState <= prevState;
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
  .s_aresetn(i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(i_n_valid),  // input wire s_axis_tvalid
  .s_axis_tready(o_n_ready),  // output wire s_axis_tready
  .s_axis_tdata(i_n_data),    // input wire [41 : 0] s_axis_tdata
  .m_axis_tvalid(mFifoValid[0]),  // output wire m_axis_tvalid
  .m_axis_tready(mFifoReady[0]),  // input wire m_axis_tready
  .m_axis_tdata(mFifoData[0])    // output wire [41 : 0] m_axis_tdata
);

fifo South_i (
 // .wr_rst_busy(),      // output wire wr_rst_busy
 // .rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(i_s_valid),  // input wire s_axis_tvalid
  .s_axis_tready(o_s_ready),  // output wire s_axis_tready
  .s_axis_tdata(i_s_data),    // input wire [41 : 0] s_axis_tdata
  .m_axis_tvalid(mFifoValid[1]),  // output wire m_axis_tvalid
  .m_axis_tready(mFifoReady[1]),  // input wire m_axis_tready
  .m_axis_tdata(mFifoData[1])    // output wire [41 : 0] m_axis_tdata
);

fifo East_i (
  //.wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(i_e_valid),  // input wire s_axis_tvalid
  .s_axis_tready(o_e_ready),  // output wire s_axis_tready
  .s_axis_tdata(i_e_data),    // input wire [41 : 0] s_axis_tdata
  .m_axis_tvalid(mFifoValid[2]),  // output wire m_axis_tvalid
  .m_axis_tready(mFifoReady[2]),  // input wire m_axis_tready
  .m_axis_tdata(mFifoData[2])    // output wire [41 : 0] m_axis_tdata
);

fifo West_i (
 // .wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(i_w_valid),  // input wire s_axis_tvalid
  .s_axis_tready(o_w_ready),  // output wire s_axis_tready
  .s_axis_tdata(i_w_data),    // input wire [41 : 0] s_axis_tdata
  .m_axis_tvalid(mFifoValid[3]),  // output wire m_axis_tvalid
  .m_axis_tready(mFifoReady[3]),  // input wire m_axis_tready
  .m_axis_tdata(mFifoData[3])    // output wire [41 : 0] m_axis_tdata
);


fifo PE_i (
 // .wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(i_pe_valid),  // input wire s_axis_tvalid
  .s_axis_tready(o_pe_ready),  // output wire s_axis_tready
  .s_axis_tdata(i_pe_data),    // input wire [41 : 0] s_axis_tdata
  .m_axis_tvalid(mFifoValid[4]),  // output wire m_axis_tvalid
  .m_axis_tready(mFifoReady[4]),  // input wire m_axis_tready
  .m_axis_tdata(mFifoData[4])    // output wire [41 : 0] m_axis_tdata
);



fifo North_o (
  //.wr_rst_busy(),      // output wire wr_rst_busy
 // .rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(sFifoValid[0]),  // input wire s_axis_tvalid
  .s_axis_tready(sFifoReady[0]),  // output wire s_axis_tready
  .s_axis_tdata(sFifoData[0]),    // input wire [41 : 0] s_axis_tdata
  .m_axis_tvalid(o_n_valid),  // output wire m_axis_tvalid
  .m_axis_tready(i_n_ready),  // input wire m_axis_tready
  .m_axis_tdata(o_n_data)    // output wire [41 : 0] m_axis_tdata
);

fifo South_o (
 // .wr_rst_busy(),      // output wire wr_rst_busy
 // .rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(sFifoValid[1]),  // input wire s_axis_tvalid
  .s_axis_tready(sFifoReady[1]),  // output wire s_axis_tready
  .s_axis_tdata(sFifoData[1]),    // input wire [41 : 0] s_axis_tdata
  .m_axis_tvalid(o_s_valid),  // output wire m_axis_tvalid
  .m_axis_tready(i_s_ready),  // input wire m_axis_tready
  .m_axis_tdata(o_s_data)    // output wire [41 : 0] m_axis_tdata
);

fifo East_o (
  //.wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(sFifoValid[2]),  // input wire s_axis_tvalid
  .s_axis_tready(sFifoReady[2]),  // output wire s_axis_tready
  .s_axis_tdata(sFifoData[2]),    // input wire [41 : 0] s_axis_tdata
  .m_axis_tvalid(o_e_valid),  // output wire m_axis_tvalid
  .m_axis_tready(i_e_ready),  // input wire m_axis_tready
  .m_axis_tdata(o_e_data)    // output wire [41 : 0] m_axis_tdata
);

fifo West_o (
 // .wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(sFifoValid[3]),  // input wire s_axis_tvalid
  .s_axis_tready(sFifoReady[3]),  // output wire s_axis_tready
  .s_axis_tdata(sFifoData[3]),    // input wire [41 : 0] s_axis_tdata
  .m_axis_tvalid(o_w_valid),  // output wire m_axis_tvalid
  .m_axis_tready(i_w_ready),  // input wire m_axis_tready
  .m_axis_tdata(o_w_data)    // output wire [41 : 0] m_axis_tdata
);
fifo PE_o (
 // .wr_rst_busy(),      // output wire wr_rst_busy
  //.rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(i_clk),                // input wire s_aclk
  .s_aresetn(i_rst_n),          // input wire s_aresetn
  .s_axis_tvalid(sFifoValid[4]),  // input wire s_axis_tvalid
  .s_axis_tready(sFifoReady[4]),  // output wire s_axis_tready
  .s_axis_tdata(sFifoData[4]),    // input wire [41 : 0] s_axis_tdata
  .m_axis_tvalid(o_pe_valid),  // output wire m_axis_tvalid
  .m_axis_tready(i_pe_ready),  // input wire m_axis_tready
  .m_axis_tdata(o_pe_data)    // output wire [41 : 0] m_axis_tdata
);




endmodule