`timescale 1ns / 1ps

module blockedRAM_simpleDualPort#(parameter BRAM_WIDTH=32, BRAM_DEPTH=256)(
input [BRAM_WIDTH-1:0] din,
input [$clog(BRAM_DEPTH)-1:0] addrin,
input [$clog(BRAM_DEPTH)-1:0] addrout,
input we, clk,
output [BRAM_WIDTH-1:0] dout
);
reg [BRAM_WIDTH-1:0] mem[BRAM_DEPTH-1:0];
reg [$clog(BRAM_DEPTH)- 1:0] addrout_reg;

always @(posedge clk)
begin
addrout_reg <= addrout;
if (we)
mem[addrin] <= din;
end

assign dout = mem[addrout_reg];

endmodule
    

