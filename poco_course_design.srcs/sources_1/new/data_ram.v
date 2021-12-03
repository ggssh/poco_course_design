`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/05 08:30:53
// Design Name:
// Module Name: data_ram
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


module data_ram(
           input wire clk,
           input wire ce, // 数据存储器使能信号
           input wire we, // 是否为写操作,为1表示写操作
           input wire[`DataAddrBus] addr, // 要访问的地址
           input wire[3:0] sel, // 字节选择信号
           input wire[`DataBus] data_i, // 要写入的数据
           output reg [`DataBus] data_o // 读出的数据
       );

reg[`ByteWidth] data_mem0[0:`DataMemNum-1];
reg[`ByteWidth] data_mem1[0:`DataMemNum-1];
reg[`ByteWidth] data_mem2[0:`DataMemNum-1];
reg[`ByteWidth] data_mem3[0:`DataMemNum-1];

always @(posedge clk) begin
    if(ce == `ChipDisable) begin
        data_o <= `ZeroWord;
    end
    else if (we == `WriteEnable) begin
        if(sel[3] == 1'b1) // 1000
        begin
            data_mem3[addr[`DataMemNumLog2+1:2]] <= data_i[31:24];
        end
        if(sel[2] == 1'b1) // 0100
        begin
            data_mem2[addr[`DataMemNumLog2+1:2]] <= data_i[23:16];
        end
        if(sel[1] == 1'b1) // 0010
        begin
            data_mem1[addr[`DataMemNumLog2+1:2]] <= data_i[15:8];
        end
        if(sel[0] == 1'b1) // 0001
        begin
            data_mem0[addr[`DataMemNumLog2+1:2]] <= data_i[7:0];
        end
    end
end

always @(*) begin
    if (ce == `ChipDisable) begin
        data_o <= `ZeroWord;
    end
    else if (we == `WriteDisable) begin
        data_o <= {
                   data_mem3[addr[`DataMemNumLog2+1:2]],
                   data_mem2[addr[`DataMemNumLog2+1:2]],
                   data_mem1[addr[`DataMemNumLog2+1:2]],
                   data_mem0[addr[`DataMemNumLog2+1:2]]
               };
    end
    else begin
        data_o <= `ZeroWord;
    end
end
endmodule
