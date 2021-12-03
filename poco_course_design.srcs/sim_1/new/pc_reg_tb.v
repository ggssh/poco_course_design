`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/22 08:26:14
// Design Name:
// Module Name: pc_reg_tb
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


module pc_reg_tb();

reg clk;
reg rst;
wire ce;
wire [31:0] pc;
pc_reg pc0(.clk(clk),.rst(rst),.ce(ce),.pc(pc));
initial begin
    clk <=1;
    rst <=0;
    #50
     rst <=1;
    #50
     rst <=0;
end
always begin
    #20
     clk <= ~clk;
end
endmodule
