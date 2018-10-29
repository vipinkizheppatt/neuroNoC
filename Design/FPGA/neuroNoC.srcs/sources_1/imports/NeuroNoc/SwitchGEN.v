module SwitchGen (
i_clk, i_rst, 
i_pe_valid, o_pe_ready, i_pe_data, 
o_pe_valid, i_pe_ready, o_pe_data,
//output for NoC of switches at zero zero position switch from west 
i_noc_valid,o_noc_ready,i_noc_data,
o_noc_valid,i_noc_ready,o_noc_data
);

`include "header.vh"

input wire i_clk;
input wire i_rst;
input [NETWORK_SIZE - 1:1] i_pe_valid;
output [NETWORK_SIZE - 1:1] o_pe_ready;
input [NETWORK_SIZE*PACKET_SIZE - 1:PACKET_SIZE] i_pe_data;
output [NETWORK_SIZE - 1:1] o_pe_valid;
input [NETWORK_SIZE - 1:1] i_pe_ready;
output [NETWORK_SIZE*PACKET_SIZE - 1:PACKET_SIZE] o_pe_data;
//output for NoC of switches at zero zero position switch from west    
input i_noc_valid;
output o_noc_ready;
input [PACKET_SIZE-1:0] i_noc_data;
output o_noc_valid;
input i_noc_ready;
output [PACKET_SIZE-1:0] o_noc_data;



wire ewValid [NETWORK_SIZE - 1 : 0];
wire weReady [NETWORK_SIZE - 1 : 0];
wire [PACKET_SIZE-1: 0] ewData [NETWORK_SIZE - 1 : 0];

wire weValid [NETWORK_SIZE - 1 : 0];
wire ewReady [NETWORK_SIZE - 1 : 0];
wire [PACKET_SIZE-1: 0] weData [NETWORK_SIZE - 1 : 0];

wire nsValid [NETWORK_SIZE - 1 : 0];
wire snReady [NETWORK_SIZE - 1 : 0];
wire [PACKET_SIZE-1: 0] nsData [NETWORK_SIZE - 1 : 0];

wire snValid [NETWORK_SIZE - 1 : 0];
wire nsReady [NETWORK_SIZE - 1 : 0];
wire [PACKET_SIZE-1: 0] snData [NETWORK_SIZE - 1 : 0];

generate
	genvar x, y; 
	for (x=0;x<X_SIZE;x=x+1) begin:xs
		for (y=0; y<Y_SIZE; y=y+1) begin:ys
			if(x==0 & y==0)
			begin: corners
				switch #(.this_x(x),.this_y(y)) sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y_SIZE*(x + 1) + y]),
					.o_n_ready(nsReady[Y_SIZE*x + y]),
					.i_n_data(snData[Y_SIZE*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y_SIZE*x + y]),
					.i_n_ready(snReady[Y_SIZE*(x + 1) + y]),
					.o_n_data(nsData[Y_SIZE*x + y]),
					
					// east input
					.i_e_valid(weValid[Y_SIZE*x + y + 1]),
					.o_e_ready(ewReady[Y_SIZE*x + y]),
					.i_e_data(weData[Y_SIZE*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y_SIZE*x + y]),
					.i_e_ready(weReady[Y_SIZE*x + y + 1]),
					.o_e_data(ewData[Y_SIZE*x + y]),
					//connect West interface to the nn
					// west input
                    /*.i_w_valid(i_noc_valid),
                    .o_w_ready(o_noc_ready),
                    .i_w_data(i_noc_data),
                    // west output
                    .o_w_valid(o_noc_valid),
                    .i_w_ready(i_noc_ready),
                    .o_w_data(o_noc_data)
                    */
                    // pe input
                    .i_pe_valid(i_noc_valid),
                    .o_pe_ready(o_noc_ready),
                    .i_pe_data(i_noc_data),
                    // pe output
                    .o_pe_valid(o_noc_valid),
                    .i_pe_ready(i_noc_ready),
                    .o_pe_data(o_noc_data)
				);
			end
			else if(x == X_SIZE-1 & y == 0)
			begin: corners
				switch #(.this_x(x),.this_y(y)) sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
				
					// south input
					.i_s_valid(nsValid[(x-1)*Y_SIZE + y]),
					.o_s_ready(snReady[Y_SIZE*x + y]),
					.i_s_data(nsData[(x-1)*Y_SIZE + y]),
					// south output
					.o_s_valid(snValid[Y_SIZE*x + y]),
					.i_s_ready(nsReady[(x-1)*Y_SIZE + y]),
					.o_s_data(snData[Y_SIZE*x + y]),
					
					// east input
					.i_e_valid(weValid[Y_SIZE*x + y + 1]),
					.o_e_ready(ewReady[Y_SIZE*x + y]),
					.i_e_data(weData[Y_SIZE*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y_SIZE*x + y]),
					.i_e_ready(weReady[Y_SIZE*x + y + 1]),
					.o_e_data(ewData[Y_SIZE*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[Y_SIZE*x + y]),
                    .o_pe_ready(o_pe_ready[Y_SIZE*x + y]),
                    .i_pe_data(i_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE]),
                    // pe output
                    .o_pe_valid(o_pe_valid[Y_SIZE*x + y]),
                    .i_pe_ready(i_pe_ready[Y_SIZE*x + y]),
                    .o_pe_data(o_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE])
				);
				
			end
			else if(x == 0 & y == Y_SIZE-1)
			begin: corners
				switch #(.this_x(x),.this_y(y))sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y_SIZE*(x + 1) + y]),
					.o_n_ready(nsReady[Y_SIZE*x + y]),
					.i_n_data(snData[Y_SIZE*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y_SIZE*x + y]),
					.i_n_ready(snReady[Y_SIZE*(x + 1) + y]),
					.o_n_data(nsData[Y_SIZE*x + y]),
					
					// west input
					.i_w_valid(ewValid[Y_SIZE*x + y - 1]),
					.o_w_ready(weReady[Y_SIZE*x + y]),
					.i_w_data(ewData[Y_SIZE*x + y - 1]),
					// west output
					.o_w_valid(weValid[Y_SIZE*x + y]),
					.i_w_ready(ewReady[Y_SIZE*x + y - 1]),
					.o_w_data(weData[Y_SIZE*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[Y_SIZE*x + y]),
                    .o_pe_ready(o_pe_ready[Y_SIZE*x + y]),
                    .i_pe_data(i_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE]),
                    // pe output
                    .o_pe_valid(o_pe_valid[Y_SIZE*x + y]),
                    .i_pe_ready(i_pe_ready[Y_SIZE*x + y]),
                    .o_pe_data(o_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE])
				);
			end
			else if(x == X_SIZE-1 & y == Y_SIZE-1)
			begin: corners
				switch #(.this_x(x),.this_y(y))sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// south input
					.i_s_valid(nsValid[(x-1)*Y_SIZE + y]),
					.o_s_ready(snReady[Y_SIZE*x + y]),
					.i_s_data(nsData[(x-1)*Y_SIZE + y]),
					// south output
					.o_s_valid(snValid[Y_SIZE*x + y]),
					.i_s_ready(nsReady[(x-1)*Y_SIZE + y]),
					.o_s_data(snData[Y_SIZE*x + y]),
					
					// west input
					.i_w_valid(ewValid[Y_SIZE*x + y - 1]),
					.o_w_ready(weReady[Y_SIZE*x + y]),
					.i_w_data(ewData[Y_SIZE*x + y - 1]),
					// west output
					.o_w_valid(weValid[Y_SIZE*x + y]),
					.i_w_ready(ewReady[Y_SIZE*x + y - 1]),
					.o_w_data(weData[Y_SIZE*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[Y_SIZE*x + y]),
                    .o_pe_ready(o_pe_ready[Y_SIZE*x + y]),
                    .i_pe_data(i_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE]),
                    // pe output
                    .o_pe_valid(o_pe_valid[Y_SIZE*x + y]),
                    .i_pe_ready(i_pe_ready[Y_SIZE*x + y]),
                    .o_pe_data(o_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE])
				);
			end
			else if(x == 0)
			begin: edge0
				switch #(.this_x(x),.this_y(y))sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y_SIZE*(x + 1) + y]),
					.o_n_ready(nsReady[Y_SIZE*x + y]),
					.i_n_data(snData[Y_SIZE*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y_SIZE*x + y]),
					.i_n_ready(snReady[Y_SIZE*(x + 1) + y]),
					.o_n_data(nsData[Y_SIZE*x + y]),
					
					// east input
					.i_e_valid(weValid[Y_SIZE*x + y + 1]),
					.o_e_ready(ewReady[Y_SIZE*x + y]),
					.i_e_data(weData[Y_SIZE*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y_SIZE*x + y]),
					.i_e_ready(weReady[Y_SIZE*x + y + 1]),
					.o_e_data(ewData[Y_SIZE*x + y]),
					
					// west input
					.i_w_valid(ewValid[Y_SIZE*x + y - 1]),
					.o_w_ready(weReady[Y_SIZE*x + y]),
					.i_w_data(ewData[Y_SIZE*x + y - 1]),
					// west output
					.o_w_valid(weValid[Y_SIZE*x + y]),
					.i_w_ready(ewReady[Y_SIZE*x + y - 1]),
					.o_w_data(weData[Y_SIZE*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[Y_SIZE*x + y]),
                    .o_pe_ready(o_pe_ready[Y_SIZE*x + y]),
                    .i_pe_data(i_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE]),
                    // pe output
                    .o_pe_valid(o_pe_valid[Y_SIZE*x + y]),
                    .i_pe_ready(i_pe_ready[Y_SIZE*x + y]),
                    .o_pe_data(o_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE])
				);
			end
			else if(y == Y_SIZE-1)
			begin: edge1
				switch #(.this_x(x),.this_y(y)) sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y_SIZE*(x + 1) + y]),
					.o_n_ready(nsReady[Y_SIZE*x + y]),
					.i_n_data(snData[Y_SIZE*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y_SIZE*x + y]),
					.i_n_ready(snReady[Y_SIZE*(x + 1) + y]),
					.o_n_data(nsData[Y_SIZE*x + y]),
					
					// south input
					.i_s_valid(nsValid[(x-1)*Y_SIZE + y]),
					.o_s_ready(snReady[Y_SIZE*x + y]),
					.i_s_data(nsData[(x-1)*Y_SIZE + y]),
					// south output
					.o_s_valid(snValid[Y_SIZE*x + y]),
					.i_s_ready(nsReady[(x-1)*Y_SIZE + y]),
					.o_s_data(snData[Y_SIZE*x + y]),
					
					// west input
					.i_w_valid(ewValid[Y_SIZE*x + y - 1]),
					.o_w_ready(weReady[Y_SIZE*x + y]),
					.i_w_data(ewData[Y_SIZE*x + y - 1]),
					// west output
					.o_w_valid(weValid[Y_SIZE*x + y]),
					.i_w_ready(ewReady[Y_SIZE*x + y - 1]),
					.o_w_data(weData[Y_SIZE*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[Y_SIZE*x + y]),
                    .o_pe_ready(o_pe_ready[Y_SIZE*x + y]),
                    .i_pe_data(i_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE]),
                    // pe output
                    .o_pe_valid(o_pe_valid[Y_SIZE*x + y]),
                    .i_pe_ready(i_pe_ready[Y_SIZE*x + y]),
                    .o_pe_data(o_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE])
				);
			end
			else if(x == X_SIZE-1)
			begin: edge2
				switch #(.this_x(x),.this_y(y)) sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// south input
					.i_s_valid(nsValid[(x-1)*Y_SIZE + y]),
					.o_s_ready(snReady[Y_SIZE*x + y]),
					.i_s_data(nsData[(x-1)*Y_SIZE + y]),
					// south output
					.o_s_valid(snValid[Y_SIZE*x + y]),
					.i_s_ready(nsReady[(x-1)*Y_SIZE + y]),
					.o_s_data(snData[Y_SIZE*x + y]),
					
					// east input
					.i_e_valid(weValid[Y_SIZE*x + y + 1]),
					.o_e_ready(ewReady[Y_SIZE*x + y]),
					.i_e_data(weData[Y_SIZE*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y_SIZE*x + y]),
					.i_e_ready(weReady[Y_SIZE*x + y + 1]),
					.o_e_data(ewData[Y_SIZE*x + y]),
					
					// west input
					.i_w_valid(ewValid[Y_SIZE*x + y - 1]),
					.o_w_ready(weReady[Y_SIZE*x + y]),
					.i_w_data(ewData[Y_SIZE*x + y - 1]),
					// west output
					.o_w_valid(weValid[Y_SIZE*x + y]),
					.i_w_ready(ewReady[Y_SIZE*x + y - 1]),
					.o_w_data(weData[Y_SIZE*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[Y_SIZE*x + y]),
                    .o_pe_ready(o_pe_ready[Y_SIZE*x + y]),
                    .i_pe_data(i_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE]),
                    // pe output
                    .o_pe_valid(o_pe_valid[Y_SIZE*x + y]),
                    .i_pe_ready(i_pe_ready[Y_SIZE*x + y]),
                    .o_pe_data(o_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE])
				);
			end
			else if(y == 0)
			begin: edge3
				switch #(.this_x(x),.this_y(y)) sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y_SIZE*(x + 1) + y]),
					.o_n_ready(nsReady[Y_SIZE*x + y]),
					.i_n_data(snData[Y_SIZE*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y_SIZE*x + y]),
					.i_n_ready(snReady[Y_SIZE*(x + 1) + y]),
					.o_n_data(nsData[Y_SIZE*x + y]),
					
					// south input
					.i_s_valid(nsValid[(x-1)*Y_SIZE + y]),
					.o_s_ready(snReady[Y_SIZE*x + y]),
					.i_s_data(nsData[(x-1)*Y_SIZE + y]),
					// south output
					.o_s_valid(snValid[Y_SIZE*x + y]),
					.i_s_ready(nsReady[(x-1)*Y_SIZE + y]),
					.o_s_data(snData[Y_SIZE*x + y]),
					
					// east input
					.i_e_valid(weValid[Y_SIZE*x + y + 1]),
					.o_e_ready(ewReady[Y_SIZE*x + y]),
					.i_e_data(weData[Y_SIZE*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y_SIZE*x + y]),
					.i_e_ready(weReady[Y_SIZE*x + y + 1]),
					.o_e_data(ewData[Y_SIZE*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[Y_SIZE*x + y]),
                    .o_pe_ready(o_pe_ready[Y_SIZE*x + y]),
                    .i_pe_data(i_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE]),
                    // pe output
                    .o_pe_valid(o_pe_valid[Y_SIZE*x + y]),
                    .i_pe_ready(i_pe_ready[Y_SIZE*x + y]),
                    .o_pe_data(o_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE])
				);
			end
			else 
			begin: others
				switch #(.this_x(x),.this_y(y)) sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
			
					// north input
					.i_n_valid(snValid[Y_SIZE*(x + 1) + y]),
					.o_n_ready(nsReady[Y_SIZE*x + y]),
					.i_n_data(snData[Y_SIZE*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y_SIZE*x + y]),
					.i_n_ready(snReady[Y_SIZE*(x + 1) + y]),
					.o_n_data(nsData[Y_SIZE*x + y]),
					// south input
					.i_s_valid(nsValid[(x-1)*Y_SIZE + y]),
					.o_s_ready(snReady[Y_SIZE*x + y]),
					.i_s_data(nsData[(x-1)*Y_SIZE + y]),
					// south output
					.o_s_valid(snValid[Y_SIZE*x + y]),
					.i_s_ready(nsReady[(x-1)*Y_SIZE + y]),
					.o_s_data(snData[Y_SIZE*x + y]),
					// east input
					.i_e_valid(weValid[Y_SIZE*x + y + 1]),
					.o_e_ready(ewReady[Y_SIZE*x + y]),
					.i_e_data(weData[Y_SIZE*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y_SIZE*x + y]),
					.i_e_ready(weReady[Y_SIZE*x + y + 1]),
					.o_e_data(ewData[Y_SIZE*x + y]),
					// west input
					.i_w_valid(ewValid[Y_SIZE*x + y - 1]),
					.o_w_ready(weReady[Y_SIZE*x + y]),
					.i_w_data(ewData[Y_SIZE*x + y - 1]),
					// west output
					.o_w_valid(weValid[Y_SIZE*x + y]),
					.i_w_ready(ewReady[Y_SIZE*x + y - 1]),
					.o_w_data(weData[Y_SIZE*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[Y_SIZE*x + y]),
                    .o_pe_ready(o_pe_ready[Y_SIZE*x + y]),
                    .i_pe_data(i_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE]),
                    // pe output
                    .o_pe_valid(o_pe_valid[Y_SIZE*x + y]),
                    .i_pe_ready(i_pe_ready[Y_SIZE*x + y]),
                    .o_pe_data(o_pe_data[(Y_SIZE*x + y + 1)*PACKET_SIZE - 1:(Y_SIZE*x + y)*PACKET_SIZE])
				);
			end
		end
	end
endgenerate
endmodule