`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/20 09:14:07
// Design Name:
// Module Name: pc_reg
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


module pc_reg(
           input wire clk,
           input wire rst,
           input wire[5:0] stall,// 来自控制模块ctrl

           output reg[`InstAddrBus] pc,//pc的宽度为6,对应rom的地址宽度为6位
           output reg ce,//指令存储器使能信号

           // 来自id
           input wire branch_flag_i,// 转移发生标志
           input wire[`RegBus] branch_target_address_i// 转移目的地址
       );

always @(posedge clk) begin//在时钟信号上升沿触发
    if (rst == `RstEnable) begin
        ce <= `ChipDisable; //复位信号有效时指令存储器使能信号无效
    end
    else begin
        ce <= `ChipEnable; //复位信号无效时指令存储器使能信号有效
    end
end

always @(posedge clk) begin
    if (ce == `ChipDisable) begin
        pc <= 32'h0;//指令存储器使能信号无效时pc保持为0
    end
    else if(stall[0]==`NoStop) begin// 这里改了
        if (branch_flag_i==`Branch) begin
            pc <= branch_target_address_i;
        end
        else begin
            pc <= pc + 32'h4; //指令存储器使能信号有效时,pc在每个时钟加4
        end
    end
end
endmodule
