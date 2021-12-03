`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/29 09:09:15
// Design Name:
// Module Name: inst_fetch_tb
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


module inst_fetch_tb();
reg clk;
reg rst;
wire[31:0] inst_o;

inst_fetch inst_fetch0(.rst(rst),.clk(clk),.inst_o(inst_o));
initial begin
    clk <= 1;
    rst <= 0;
    #30
     rst <= 1;
    #100
     rst <= 0;
    #1000 $finish;
end
always begin
    #10 clk <= ~clk;
end
endmodule
