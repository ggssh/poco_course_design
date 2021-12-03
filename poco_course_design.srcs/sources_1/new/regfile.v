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
           input wire[4:0] waddr,//要写入的寄存器地址
           input wire[31:0] wdata,//要写入的数据
           input wire we,//写使能信号
           input wire[4:0] raddr1,//第一个读寄存器端口要读取的寄存器的地址
           input wire re1,//第一个读寄存器端口读使能信号
           output reg[31:0] rdata1,//第一个读寄存器端口输出的寄存器值
           input wire[4:0] raddr2,//第二个读寄存器端口要读取的寄存器的地址
           input wire re2,//第二个读寄存器端口读使能信号
           output reg[31:0] rdata2//第二个读寄存器端口输出的寄存器值
       );
reg[31:0] regs[0:31];
integer i;
initial begin
    regs[0]=32'h0;
    regs[1]=32'h12345678;
    for(i=2;i<32;i=i+1) begin
        regs[i]=regs[i-1]+32'h01010101;
    end
end

always @(posedge clk) begin
    if(rst==1'b0) begin
        if((we==1'b1)&&(waddr!=5'b0)) begin
            regs[waddr] <= wdata;
        end
    end
end

always @(*) begin
    if(rst == 1'b1) begin
        rdata1 <= 32'h0;
    end
    else if ((raddr1==5'b0)&&(re1==1'b1)) begin
        rdata1 <= 32'h0;
    end
    // 解决数据相关问题
    else if ((raddr1==waddr)&&(we==1'b1)&&(re1==1'b1)) begin
        rdata1 <= wdata;
    end
    else if (re1 == 1'b1) begin
        rdata1 <= regs[raddr1];
    end
    else begin
        rdata1 <= 32'h0;
    end
end

always @(*) begin
    if(rst== 1'b1) begin
        rdata2 <= 32'h0;
    end
    else if ((raddr2==5'b0)&&(re2=='b1)) begin
        rdata2 <= 32'h0;
    end
    else if ((raddr2==waddr)&&(we==1'b1)&&(re2==1'b1)) begin
        rdata2 <= wdata;
    end
    else if (re2==1'b1) begin
        rdata2 <= regs[raddr2];
    end
    else begin
        rdata2 <= 32'h0;
    end
end
endmodule
