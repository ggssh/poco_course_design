`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/03 07:28:04
// Design Name:
// Module Name: mem_wb
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


module mem_wb(
           input wire clk,
           input wire rst,

           // 来自mem
           input wire[`RegAddrBus] mem_wd,
           input wire mem_wreg,
           input wire[`RegBus] mem_wdata,

           // 送到wb
           output reg[`RegAddrBus] wb_wd,
           output reg wb_wreg,
           output reg[`RegBus] wb_wdata
       );
always @(posedge clk) begin
    if(rst == `RstEnable) begin
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
    end
    else begin
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
    end
end
endmodule
