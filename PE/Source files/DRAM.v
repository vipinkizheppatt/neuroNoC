module distributedRAM_simpleDualPort #(DRAM_DEPTH=4096, DRAM_WIDTH=32)(
input clk,
input we,
input [$clog(DRAM_DEPTH)-1:0] a,
input [$clog(DRAM_DEPTH)-1:0] dpra,
input [DRAM_WIDTH-1:0] d,
output [DRAM_WIDTH-1:0] dpo
); 
    
reg [DRAM_WIDTH-1:0]  mem[0:DRAM_WIDTH]; 
 
always @ (posedge clk)
begin
  if (we) begin     
    mem[a]  <= d;  
  end
end

assign dpo = mem[dpra];  
endmodule
