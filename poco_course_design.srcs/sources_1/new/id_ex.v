`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/03 07:29:00
// Design Name:
// Module Name: id_ex
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


module id_ex(
           input wire clk,
           input wire rst,

           // 来自id
           input wire[`AluOpBus] id_aluop,
           input wire[`RegBus] id_reg1,
           input wire[`RegBus] id_reg2,
           input wire[`RegAddrBus] id_wd,
           input wire id_wreg,
           input wire[`RegBus] id_inst,// 来自id模块的信号inst_o

           // 送到ex
           output reg[`AluOpBus] ex_aluop,
           output reg[`RegBus] ex_reg1,
           output reg[`RegBus] ex_reg2,
           output reg[`RegAddrBus] ex_wd,
           output reg ex_wreg,
           output reg[`RegBus] ex_inst// 送到ex模块
       );

always @(posedge clk) begin
    if(rst==`RstEnable) begin
        ex_aluop <= `NOP_OP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
        ex_inst <= `ZeroWord;
    end
    else begin
        ex_aluop <= id_aluop;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;
        ex_inst <= id_inst;
    end
end
endmodule
