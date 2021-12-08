`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/03 07:37:32
// Design Name:
// Module Name: ex_mem
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


module ex_mem(
           input wire clk,
           input wire rst,

           // 来自ex
           input wire[`RegAddrBus] ex_wd,
           input wire ex_wreg,
           input wire[`RegBus] ex_wdata,
           input wire[`RegBus] ex_hi,
           input wire[`RegBus] ex_lo,
           input wire ex_whilo,

           // 送到mem
           output reg[`RegAddrBus] mem_wd,
           output reg mem_wreg,
           output reg[`RegBus] mem_wdata,
           output reg[`RegBus] mem_hi,
           output reg[`RegBus] mem_lo,
           output reg mem_whilo,

           // store && load
           input wire[`AluOpBus] ex_aluop,
           input wire[`RegBus] ex_mem_addr,
           input wire[`RegBus] ex_reg2,

           output reg[`AluOpBus] mem_aluop,
           output reg[`RegBus] mem_mem_addr,
           output reg[`RegBus] mem_reg2,

           // 来自ctrl
           input wire[5:0] stall
       );

always @(posedge clk) begin
    if(rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_aluop <= `NOP_OP;
        mem_mem_addr <= `ZeroWord;
        mem_reg2 <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
    end
    else if(stall[3]==`Stop && stall[4]==`NoStop) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_aluop <= `NOP_OP;
        mem_mem_addr <= `ZeroWord;
        mem_reg2 <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
    end
    else if(stall[3]==`NoStop) begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        mem_aluop <= ex_aluop;
        mem_mem_addr <= ex_mem_addr;
        mem_reg2 <= ex_reg2;
        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;
    end
    // else begin
    //     mem_wd <= ex_wd;
    //     mem_wreg <= ex_wreg;
    //     mem_wdata <= ex_wdata;
    //     mem_aluop <= ex_aluop;
    //     mem_mem_addr <= ex_mem_addr;
    //     mem_reg2 <= ex_reg2;
    //     mem_hi <= ex_hi;
    //     mem_lo <= ex_lo;
    //     mem_whilo <= ex_whilo;
    // end
    // if
end // always
endmodule
