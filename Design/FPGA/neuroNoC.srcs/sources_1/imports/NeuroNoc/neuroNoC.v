module neuroNoC (
i_clk,i_rst,
i_nn_valid,o_nn_ready,i_nn_data,
o_nn_valid,i_nn_ready,o_nn_data
);
`include "header.vh"

input wire i_clk;
input wire i_rst;
	   
input i_nn_valid;
output o_nn_ready;
input [PACKET_SIZE-1:0] i_nn_data;
output o_nn_valid;
input i_nn_ready;
output [PACKET_SIZE-1:0] o_nn_data;


wire [NETWORK_SIZE-1:1] SP_valid;
wire [NETWORK_SIZE-1:1] PS_ready;
wire [NETWORK_SIZE*PACKET_SIZE-1:PACKET_SIZE] SP_data;
wire [NETWORK_SIZE-1:1] PS_valid;
wire [NETWORK_SIZE-1:1] SP_ready;
wire [NETWORK_SIZE*PACKET_SIZE-1:PACKET_SIZE] PS_data;
 
   
SwitchGen Switches (
    .i_clk(i_clk),
	.i_rst(i_rst),
	.i_pe_valid(PS_valid),
	.o_pe_ready(SP_ready),
	.i_pe_data(PS_data),
	.o_pe_valid(SP_valid),
    .i_pe_ready(PS_ready),
    .o_pe_data(SP_data),
    //output for NoC of switches at zero zero position switch from west    
    .o_noc_valid(o_nn_valid),
    .i_noc_ready(i_nn_ready),
    .o_noc_data(o_nn_data),
    
    .i_noc_valid(i_nn_valid),
    .o_noc_ready(o_nn_ready),
    .i_noc_data(i_nn_data)
    
);
processingElementGeneration  PEGEN(
    .clk(i_clk), 
    .rst(i_rst), 
    .NI_PE_valid(SP_valid), 
    .NI_PE_ready(PS_ready), 
    .NI_PE_packet(SP_data),
    
    .PE_NI_valid(PS_valid),
    .PE_NI_ready(SP_ready), 
    .PE_NI_packet(PS_data)
    
);

endmodule