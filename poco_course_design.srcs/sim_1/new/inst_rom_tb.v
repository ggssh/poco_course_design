`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/29 08:35:53
// Design Name:
// Module Name: inst_rom_tb
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


module inst_rom_tb();
reg clk;
reg ce;
reg[31:0] addr;
wire[31:0] inst;
integer i;
inst_rom inst_rom0(.ce(ce),.addr(addr),.inst(inst));
initial begin
    $monitor("addr=%h,instdata=%h",addr,inst);
    clk <= 1;
    ce <= 0;
    #20;
    ce <= 1;
    for(i = 0;i<=40;i=i+1) begin
        addr=i;
        #20;
    end
end
always begin
    #10 clk <= ~clk;
end
endmodule
