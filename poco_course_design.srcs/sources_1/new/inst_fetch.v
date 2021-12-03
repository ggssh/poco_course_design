`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/29 09:05:12
// Design Name:
// Module Name: inst_fetch
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


module inst_fetch(
           input wire rst,
           input wire clk,
           output wire[31:0] inst_o //元件例化输出使用wire连接
       );

wire[31:0] pc;
wire ce;
pc pc0(.clk(clk),.rst(rst),.pc(pc),.ce(ce));
inst_rom inst_rom0(.ce(ce),.addr(pc),.inst(inst_o));
endmodule
