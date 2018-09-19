`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.08.2018 15:50:17
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb(

    );
    
reg clk, rst;
reg valid1, valid2, valid3, valid4, valid5;
reg [41:0] data1, data2, data3, data4, data5;
initial
begin
    clk = 0;
    forever
    begin
        clk = ~clk;
        #10;
    end
end
initial
begin
    rst = 0;
	#50;
	rst = 1;
	@(posedge clk);
	@(posedge clk);
    @(posedge clk);
	data1 = 11;
	data2 = 12;
	data3 = 13;
    data4 = 14;
    valid2 = 1;
    valid1 = 1;
	wait(f1Ready);
    //data2[32] = 1;
	//data3[33] = 1;
	//data4[33:32] = 'b11;
	
	
	wait(f2Ready);

	
	@(posedge clk);
	valid1 = 0;
	valid2 = 0;
	
	@(posedge clk);
	@(posedge clk);
	valid3 = 1;
	wait(f3Ready);
	@(posedge clk);
	valid3 = 0;
	
	@(posedge clk);
	@(posedge clk);
	valid4 = 1;
	wait(f4Ready);
	@(posedge clk);
	valid4 = 0;
	
	
	/*
	valid3 = 1;
	data3 = 11;
	wait(f3Ready);
	@(posedge clk);
	valid3 = 0;
	
	valid4 = 1;
	data4 = 11;
	wait(f4Ready);
	@(posedge clk);
	valid4 = 0;			
	
	*/
	/*i_data_n = 11;
	@(posedge clk);
	i_data_n = 12;
	@(posedge clk);
	i_data_n = 13;
	@(posedge clk);
	i_data_n = 14;
	@(posedge clk);
	i_data_n = 15;
	@(posedge clk);
	i_data_n = 16;*/	
	//#80;
end



wire [41:0] o_data_n;
wire [41:0] o_data_s;
wire [41:0] o_data_e;
wire [41:0] o_data_w;
wire [41:0] o_data_pe;

wire ovalid1, ovalid2, ovalid3, ovalid4, ovalid5;
wire f1Ready, f2Ready, f3Ready, f4Ready, f5Ready;

always @(posedge clk)
begin
    if(ovalid1)
        $display($time,,"Data received from north port %0x",o_data_n);
	
end



switch mySwitch(
	.i_clk(clk),
	.i_rst_n(rst),
	
    .i_n_valid(valid1),
    .o_n_ready(f1Ready),
    .i_n_data(data1),
        // north output
    .o_n_valid(ovalid1),
    .i_n_ready(1'b1),
    .o_n_data(o_data_n),
        
        // south input
    .i_s_valid(valid2),
    .o_s_ready(f2Ready),
    .i_s_data(data2),
        // south output
     .o_s_valid(ovalid2),
     .i_s_ready(1'b1),
     .o_s_data(o_data_s),
        
        // east input
      .i_e_valid(valid3),
      .o_e_ready(f3Ready),
      .i_e_data(data3),
        // east output
      .o_e_valid(ovalid3),
      .i_e_ready(1'b1),
      .o_e_data(o_data_e),
        
        // west input
       .i_w_valid(valid4),
       .o_w_ready(f4Ready),
       .i_w_data(data4),
        // west output
       .o_w_valid(ovalid4),
       .i_w_ready(1'b1),
       .o_w_data(o_data_w),
        
        // pe input
       .i_pe_valid(valid5),
       .o_pe_ready(f5Ready),
       .i_pe_data(data5),
        // pe output
       .o_pe_valid(ovalid5),
       .i_pe_ready(1'b1),
       .o_pe_data(o_data_pe)
    
);
/*
pe myPE(
.clk()
.rst()
valid()
ready()
*/
endmodule
