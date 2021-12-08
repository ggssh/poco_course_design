`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/03 08:39:15
// Design Name:
// Module Name: mips_sopc1_tb
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


module mips_sopc1_tb();
reg clk;
reg rst;

initial begin
    clk=1'b0;
    forever
        #10 clk=~clk;
end

initial begin
    rst=1;
    #100 rst=0;
    #3000 $stop;// 给的时间要足够长,方便测试
end
mips_sopc1 mips_sopc10(
               .clk(clk),
               .rst(rst)
           );
endmodule
