`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/29 08:26:02
// Design Name:
// Module Name: inst_rom
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


module inst_rom(
           input wire ce,
           input wire[`InstAddrBus] addr,
           output reg[`InstBus] inst
       );

reg[`InstBus] inst_mem[0:`InstMemNum-1];

initial
    $readmemh("../../../../initial_data/inst_test.data",inst_mem);

always @(*) begin
    if(ce == `ChipDisable) begin
        inst <= `ZeroWord;
    end
    else begin
        inst <= inst_mem[addr[`InstMemNumLog2+1:2]];//字寻址,舍去地址的最低两位字内地址(即0和1位)
    end
end
endmodule
