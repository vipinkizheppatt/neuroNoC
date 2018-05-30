`timescale 1ns / 1ps


module blockedRAM_singlePort#(parameter BRAM_WIDTH=32, BRAM_DEPTH=64)(
input [BRAM_WIDTH-1:0] din,
input [$clog(BRAM_DEPTH)-1:0] addr,
input we, clk,
output [BRAM_WIDTH-1:0] dout
);
reg [BRAM_WIDTH-1:0] mem[BRAM_DEPTH-1:0];


reg [$clog(BRAM_DEPTH)- 1:0] addr_reg;

always @(posedge clk)
begin
addr_reg <= addr;
if (we)
mem[addr] <= din;
end

assign dout = mem[addr_reg];

endmodule
    

