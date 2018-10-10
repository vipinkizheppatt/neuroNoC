module NoC #(parameter X=2,Y=2, data_width=41)(
    input wire i_clk,
	input wire i_rst,
	input [X*Y - 1:0] i_pe_valid,
	input [X*Y-1:0] o_pe_ready,
	input [X*Y*41:0] i_pe_data,
	input [X*Y - 1:0] o_pe_valid,
    input [X*Y-1:0] i_pe_ready,
    input [X*Y*41:0] o_pe_data,
    //output for NoC of switches at zero zero position switch from west    
    input i_noc_valid,
    output o_noc_ready,
    input [41:0] i_noc_data,
    output o_noc_valid,
    input i_noc_ready,
    output [41:0] o_noc_data
);

wire ewValid [X*Y - 1 : 0];
wire weReady [X*Y - 1 : 0];
wire [41: 0] ewData [X*Y - 1 : 0];

wire weValid [X*Y - 1 : 0];
wire ewReady [X*Y - 1 : 0];
wire [41: 0] weData [X*Y - 1 : 0];

wire nsValid [X*Y - 1 : 0];
wire snReady [X*Y - 1 : 0];
wire [41: 0] nsData [X*Y - 1 : 0];

wire snValid [X*Y - 1 : 0];
wire nsReady [X*Y - 1 : 0];
wire [41: 0] snData [X*Y - 1 : 0];

generate
	genvar x, y; 
	for (x=0;x<X;x=x+1) begin:xs
		for (y=0; y<Y; y=y+1) begin:ys
			
			if(x==0 & y==0)
			begin: corners
				switch sw1(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y*(x + 1) + y]),
					.o_n_ready(nsReady[Y*x + y]),
					.i_n_data(snData[Y*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y*x + y]),
					.i_n_ready(snReady[Y*(x + 1) + y]),
					.o_n_data(nsData[Y*x + y]),
					
					// east input
					.i_e_valid(weValid[Y*x + y + 1]),
					.o_e_ready(ewReady[Y*x + y]),
					.i_e_data(weData[Y*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y*x + y]),
					.i_e_ready(weReady[Y*x + y + 1]),
					.o_e_data(ewData[Y*x + y]),
					//connect West interface to the top
					// west input
                    .i_w_valid(weValid[i_noc_valid]),
                    .o_w_ready(ewReady[o_noc_ready]),
                    .i_w_data(weData[i_noc_data]),
                    // west output
                    .o_w_valid(ewValid[o_noc_valid]),
                    .i_w_ready(weReady[i_noc_ready]),
                    .o_w_data(ewData[o_noc_data]),
                    
                    // pe input
                    .i_pe_valid(i_pe_valid[X*y + x]),
                    .o_pe_ready(o_pe_ready[X*y + x]),
                    .i_pe_data(i_pe_data[X*y + x]),
                    // pe output
                    .o_pe_valid(o_pe_valid[X*y + x]),
                    .i_pe_ready(i_pe_ready[X*y + x]),
                    .o_pe_data(o_pe_data[X*y + x])
				);
			end
			else if(x == X & y == 0)
			begin: corners
				switch sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
				
					// south input
					.i_s_valid(nsValid[(x-1)*Y + y]),
					.o_s_ready(snReady[Y*x + y]),
					.i_s_data(nsData[(x-1)*Y + y]),
					// south output
					.o_s_valid(snValid[Y*x + y]),
					.i_s_ready(nsReady[(x-1)*Y + y]),
					.o_s_data(snData[Y*x + y]),
					
					// east input
					.i_e_valid(weValid[Y*x + y + 1]),
					.o_e_ready(ewReady[Y*x + y]),
					.i_e_data(weData[Y*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y*x + y]),
					.i_e_ready(weReady[Y*x + y + 1]),
					.o_e_data(ewData[Y*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[X*y + x]),
                    .o_pe_ready(o_pe_ready[X*y + x]),
                    .i_pe_data(i_pe_data[X*y + x]),
                    // pe output
                    .o_pe_valid(o_pe_valid[X*y + x]),
                    .i_pe_ready(i_pe_ready[X*y + x]),
                    .o_pe_data(o_pe_data[X*y + x])
						// pe input
                    /*.i_pe_valid,
                    .o_pe_ready,
                    input [41:0] i_pe_data,
                    // pe output
                    output o_pe_valid,
                    input i_pe_ready,
                    output [41:0] o_pe_data
					*/
				);
				
			end
			else if(x == 0 & y == Y)
			begin: corners
				switch sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y*(x + 1) + y]),
					.o_n_ready(nsReady[Y*x + y]),
					.i_n_data(snData[Y*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y*x + y]),
					.i_n_ready(snReady[Y*(x + 1) + y]),
					.o_n_data(nsData[Y*x + y]),
					
					// west input
					.i_w_valid(weValid[Y*x + y - 1]),
					.o_w_ready(ewReady[Y*x + y]),
					.i_w_data(weData[Y*x + y - 1]),
					// west output
					.o_w_valid(ewValid[Y*x + y]),
					.i_w_ready(weReady[Y*x + y - 1]),
					.o_w_data(ewData[Y*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[X*y + x]),
                    .o_pe_ready(o_pe_ready[X*y + x]),
                    .i_pe_data(i_pe_data[X*y + x]),
                    // pe output
                    .o_pe_valid(o_pe_valid[X*y + x]),
                    .i_pe_ready(i_pe_ready[X*y + x]),
                    .o_pe_data(o_pe_data[X*y + x])
				);
			end
			else if(x == X & y == Y)
			begin: corners
				switch sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// south input
					.i_s_valid(nsValid[(x-1)*Y + y]),
					.o_s_ready(snReady[Y*x + y]),
					.i_s_data(nsData[(x-1)*Y + y]),
					// south output
					.o_s_valid(snValid[Y*x + y]),
					.i_s_ready(nsReady[(x-1)*Y + y]),
					.o_s_data(snData[Y*x + y]),
					
					// west input
					.i_w_valid(weValid[Y*x + y - 1]),
					.o_w_ready(ewReady[Y*x + y]),
					.i_w_data(weData[Y*x + y - 1]),
					// west output
					.o_w_valid(ewValid[Y*x + y]),
					.i_w_ready(weReady[Y*x + y - 1]),
					.o_w_data(ewData[Y*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[X*y + x]),
                    .o_pe_ready(o_pe_ready[X*y + x]),
                    .i_pe_data(i_pe_data[X*y + x]),
                    // pe output
                    .o_pe_valid(o_pe_valid[X*y + x]),
                    .i_pe_ready(i_pe_ready[X*y + x]),
                    .o_pe_data(o_pe_data[X*y + x])
				);
			end
			else if(x == 0)
			begin: edge0
				switch sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y*(x + 1) + y]),
					.o_n_ready(nsReady[Y*x + y]),
					.i_n_data(snData[Y*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y*x + y]),
					.i_n_ready(snReady[Y*(x + 1) + y]),
					.o_n_data(nsData[Y*x + y]),
					
					// east input
					.i_e_valid(weValid[Y*x + y + 1]),
					.o_e_ready(ewReady[Y*x + y]),
					.i_e_data(weData[Y*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y*x + y]),
					.i_e_ready(weReady[Y*x + y + 1]),
					.o_e_data(ewData[Y*x + y]),
					
					// west input
					.i_w_valid(weValid[Y*x + y - 1]),
					.o_w_ready(ewReady[Y*x + y]),
					.i_w_data(weData[Y*x + y - 1]),
					// west output
					.o_w_valid(ewValid[Y*x + y]),
					.i_w_ready(weReady[Y*x + y - 1]),
					.o_w_data(ewData[Y*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[X*y + x]),
                    .o_pe_ready(o_pe_ready[X*y + x]),
                    .i_pe_data(i_pe_data[X*y + x]),
                    // pe output
                    .o_pe_valid(o_pe_valid[X*y + x]),
                    .i_pe_ready(i_pe_ready[X*y + x]),
                    .o_pe_data(o_pe_data[X*y + x])
				);
			end
			else if(y == Y)
			begin: edge1
				switch sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y*(x + 1) + y]),
					.o_n_ready(nsReady[Y*x + y]),
					.i_n_data(snData[Y*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y*x + y]),
					.i_n_ready(snReady[Y*(x + 1) + y]),
					.o_n_data(nsData[Y*x + y]),
					
					// south input
					.i_s_valid(nsValid[(x-1)*Y + y]),
					.o_s_ready(snReady[Y*x + y]),
					.i_s_data(nsData[(x-1)*Y + y]),
					// south output
					.o_s_valid(snValid[Y*x + y]),
					.i_s_ready(nsReady[(x-1)*Y + y]),
					.o_s_data(snData[Y*x + y]),
					
					// west input
					.i_w_valid(weValid[Y*x + y - 1]),
					.o_w_ready(ewReady[Y*x + y]),
					.i_w_data(weData[Y*x + y - 1]),
					// west output
					.o_w_valid(ewValid[Y*x + y]),
					.i_w_ready(weReady[Y*x + y - 1]),
					.o_w_data(ewData[Y*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[X*y + x]),
                    .o_pe_ready(o_pe_ready[X*y + x]),
                    .i_pe_data(i_pe_data[X*y + x]),
                    // pe output
                    .o_pe_valid(o_pe_valid[X*y + x]),
                    .i_pe_ready(i_pe_ready[X*y + x]),
                    .o_pe_data(o_pe_data[X*y + x])
				);
			end
			else if(x == X)
			begin: edge2
				switch sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// south input
					.i_s_valid(nsValid[(x-1)*Y + y]),
					.o_s_ready(snReady[Y*x + y]),
					.i_s_data(nsData[(x-1)*Y + y]),
					// south output
					.o_s_valid(snValid[Y*x + y]),
					.i_s_ready(nsReady[(x-1)*Y + y]),
					.o_s_data(snData[Y*x + y]),
					
					// east input
					.i_e_valid(weValid[Y*x + y + 1]),
					.o_e_ready(ewReady[Y*x + y]),
					.i_e_data(weData[Y*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y*x + y]),
					.i_e_ready(weReady[Y*x + y + 1]),
					.o_e_data(ewData[Y*x + y]),
					
					// west input
					.i_w_valid(weValid[Y*x + y - 1]),
					.o_w_ready(ewReady[Y*x + y]),
					.i_w_data(weData[Y*x + y - 1]),
					// west output
					.o_w_valid(ewValid[Y*x + y]),
					.i_w_ready(weReady[Y*x + y - 1]),
					.o_w_data(ewData[Y*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[X*y + x]),
                    .o_pe_ready(o_pe_ready[X*y + x]),
                    .i_pe_data(i_pe_data[X*y + x]),
                    // pe output
                    .o_pe_valid(o_pe_valid[X*y + x]),
                    .i_pe_ready(i_pe_ready[X*y + x]),
                    .o_pe_data(o_pe_data[X*y + x])
				);
			end
			else if(y == 0)
			begin: edge3
				switch sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y*(x + 1) + y]),
					.o_n_ready(nsReady[Y*x + y]),
					.i_n_data(snData[Y*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y*x + y]),
					.i_n_ready(snReady[Y*(x + 1) + y]),
					.o_n_data(nsData[Y*x + y]),
					
					// south input
					.i_s_valid(nsValid[(x-1)*Y + y]),
					.o_s_ready(snReady[Y*x + y]),
					.i_s_data(nsData[(x-1)*Y + y]),
					// south output
					.o_s_valid(snValid[Y*x + y]),
					.i_s_ready(nsReady[(x-1)*Y + y]),
					.o_s_data(snData[Y*x + y]),
					
					// east input
					.i_e_valid(weValid[Y*x + y + 1]),
					.o_e_ready(ewReady[Y*x + y]),
					.i_e_data(weData[Y*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y*x + y]),
					.i_e_ready(weReady[Y*x + y + 1]),
					.o_e_data(ewData[Y*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[X*y + x]),
                    .o_pe_ready(o_pe_ready[X*y + x]),
                    .i_pe_data(i_pe_data[X*y + x]),
                    // pe output
                    .o_pe_valid(o_pe_valid[X*y + x]),
                    .i_pe_ready(i_pe_ready[X*y + x]),
                    .o_pe_data(o_pe_data[X*y + x])
				);
			end
			else 
			begin: others
				switch sw(
					.i_clk(i_clk),
					.i_rst_n(i_rst),
					
					// north input
					.i_n_valid(snValid[Y*(x + 1) + y]),
					.o_n_ready(nsReady[Y*x + y]),
					.i_n_data(snData[Y*(x + 1) + y]),
					// north output
					.o_n_valid(nsValid[Y*x + y]),
					.i_n_ready(snReady[Y*(x + 1) + y]),
					.o_n_data(nsData[Y*x + y]),
					// south input
					.i_s_valid(nsValid[(x-1)*Y + y]),
					.o_s_ready(snReady[Y*x + y]),
					.i_s_data(nsData[(x-1)*Y + y]),
					// south output
					.o_s_valid(snValid[Y*x + y]),
					.i_s_ready(nsReady[(x-1)*Y + y]),
					.o_s_data(snData[Y*x + y]),
					// east input
					.i_e_valid(weValid[Y*x + y + 1]),
					.o_e_ready(ewReady[Y*x + y]),
					.i_e_data(weData[Y*x + y + 1]),
					// east output
					.o_e_valid(ewValid[Y*x + y]),
					.i_e_ready(weReady[Y*x + y + 1]),
					.o_e_data(ewData[Y*x + y]),
					// west input
					.i_w_valid(weValid[Y*x + y - 1]),
					.o_w_ready(ewReady[Y*x + y]),
					.i_w_data(weData[Y*x + y - 1]),
					// west output
					.o_w_valid(ewValid[Y*x + y]),
					.i_w_ready(weReady[Y*x + y - 1]),
					.o_w_data(ewData[Y*x + y]),
					// pe input
                    .i_pe_valid(i_pe_valid[X*y + x]),
                    .o_pe_ready(o_pe_ready[X*y + x]),
                    .i_pe_data(i_pe_data[X*y + x]),
                    // pe output
                    .o_pe_valid(o_pe_valid[X*y + x]),
                    .i_pe_ready(i_pe_ready[X*y + x]),
                    .o_pe_data(o_pe_data[X*y + x])
				);
			end
		end
	end
endgenerate


endmodule