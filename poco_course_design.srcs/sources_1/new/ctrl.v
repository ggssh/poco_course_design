`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/08 07:55:16
// Design Name:
// Module Name: ctrl
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


module ctrl(
           input wire rst,
           input wire stallreq_from_id,// 来自译码阶段的暂停请求
           input wire stallreq_from_ex,// 来自执行阶段的暂停请求
           output reg[5:0] stall
       );

always @(*) begin
    if(rst==`RstEnable) begin
        stall <= 6'b000000;
    end
    else if (stallreq_from_ex==`Stop) begin
        stall <= 6'b001111;
    end
    else if(stallreq_from_id==`Stop) begin
        stall <= 6'b000111;
    end
    else begin
        stall <= 6'b000000;
    end
end
endmodule
