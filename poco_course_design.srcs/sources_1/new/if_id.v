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
           input[`InstBus] if_inst,
           output reg[`InstBus] id_inst
       );
always @(posedge clk) begin
    if(rst==`RstEnable) begin
        id_inst <= `ZeroWord;
    end
    else begin
        id_inst <= if_inst;
    end
end
endmodule
