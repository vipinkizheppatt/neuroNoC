//////////////////////////////////////////////////////////////////////////////////
// Company: Nazarbayev University
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 18.10.2018 
// Design Name: PEGEN
// Module Name: processingElementGeneration
// Project Name: NeuroNoc
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module processingElementGeneration(clk, rst, NI_PE_valid, NI_PE_packet, NI_PE_ready, PE_NI_ready, PE_NI_packet, PE_NI_valid);

`include "header.vh"

input clk;
input rst;
input [(NETWORK_SIZE-1)-1:0] NI_PE_valid;
input [(NETWORK_SIZE-1)*PACKET_SIZE-1:0] NI_PE_packet;
output [(NETWORK_SIZE-1)-1:0] NI_PE_ready;
input [(NETWORK_SIZE-1)-1:0] PE_NI_ready;
output [(NETWORK_SIZE-1)*PACKET_SIZE-1:0] PE_NI_packet;
output [(NETWORK_SIZE-1)-1:0] PE_NI_valid;

genvar j;
generate

for(j=0; j<NETWORK_SIZE-1; j=j+1)
    begin: PE_LOOP
        processingElement #(.SOURCE_ADDRESS(j+1)) pe(clk, rst, NI_PE_valid[j], NI_PE_packet[(j+1)*PACKET_SIZE-1:j*PACKET_SIZE], NI_PE_ready[j], PE_NI_ready[j], PE_NI_packet[(j+1)*PACKET_SIZE-1:j*PACKET_SIZE], PE_NI_valid[j]);
    end

endgenerate


endmodule
