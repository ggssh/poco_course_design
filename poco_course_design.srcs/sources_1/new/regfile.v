`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/22 08:50:28
// Design Name:
// Module Name: regfile
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


module regfile(
           input wire rst,// 复位信号,高电平有效
           input wire clk,// 时钟信号

           // 写端口
           input wire[`RegAddrBus] waddr,//要写入的寄存器地址
           input wire[`RegBus] wdata,//要写入的数据
           input wire we,//写使能信号

           // 读端口1
           input wire[`RegAddrBus] raddr1,//第一个读寄存器端口要读取的寄存器的地址
           input wire re1,//第一个读寄存器端口读使能信号
           output reg[`RegBus] rdata1,//第一个读寄存器端口输出的寄存器值

           // 读端口2
           input wire[`RegAddrBus] raddr2,//第二个读寄存器端口要读取的寄存器的地址
           input wire re2,//第二个读寄存器端口读使能信号
           output reg[`RegBus] rdata2//第二个读寄存器端口输出的寄存器值
       );

reg[`RegBus] regs[0:`RegNum-1];
integer i;

// 往寄存器里先存入数据
initial begin
    // regs[0]=32'h0;
    // // regs[1]=32'h12345678;
    // regs[1]=32'h00000001;
    // for(i=2;i<`RegNum;i=i+1) begin
    //     regs[i]=regs[i-1]+32'h00000001;
    // end
end

always @(posedge clk) begin
    if(rst==`RstDisable) begin
        if((we==`WriteEnable)&&(waddr!=`RegNumLog2'h0)) begin
            regs[waddr] <= wdata;
        end
    end
end

// 读端口1
always @(*) begin
    if(rst == `RstEnable) begin
        rdata1 <= `ZeroWord;
    end
    else if ((raddr1==`RegNumLog2'h0)&&(re1==`ReadEnable)) begin
        rdata1 <= `ZeroWord;
    end
    // 解决数据相关问题(相隔两条指令)
    // 如果要读取的寄存器是在下一个时钟上升沿要写入的寄存器
    // 那么就将要写入的数据作为结果直接输出(读端口2与之相同)
    else if ((raddr1==waddr)&&(we==`WriteEnable)&&(re1==`ReadEnable)) begin
        rdata1 <= wdata;
    end
    else if (re1 == `ReadEnable) begin
        rdata1 <= regs[raddr1];
    end
    else begin
        rdata1 <= `ZeroWord;
    end
end

// 读端口2
always @(*) begin
    if(rst== `RstEnable) begin
        rdata2 <= `ZeroWord;
    end
    else if ((raddr2==`RegNumLog2'h0)&&(re2==`ReadEnable)) begin
        rdata2 <= `ZeroWord;
    end
    // 数据相关
    else if ((raddr2==waddr)&&(we==`WriteEnable)&&(re2==`ReadEnable)) begin
        rdata2 <= wdata;
    end
    else if (re2==`ReadEnable) begin
        rdata2 <= regs[raddr2];
    end
    else begin
        rdata2 <= `ZeroWord;
    end
end
endmodule
