`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/03 07:23:54
// Design Name:
// Module Name: if_id
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


module if_id(
           input wire clk,
           input wire rst,
           
           // 来自取指阶段信号
           input[`InstBus] if_inst,
           input[`InstAddrBus] if_pc,

           // 发送到id
           output reg[`InstBus] id_inst,
           output reg[`InstAddrBus] id_pc
       );
always @(posedge clk) begin
    if(rst==`RstEnable) begin
        id_inst <= `ZeroWord;
        id_pc <= `ZeroWord;
    end
    else begin
        id_inst <= if_inst;
        id_pc <= if_pc;
    end
end
endmodule
