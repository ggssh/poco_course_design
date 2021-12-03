`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/26 08:04:13
// Design Name:
// Module Name: mips_sopc
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


module mips_sopc(
           input wire clk,
           input wire rst
       );

wire[`InstAddrBus] inst_addr;
wire[`InstBus] inst;
wire rom_ce;

single_cycle_cpu single_cycle_cpu0(.rst(rst),
                                   .clk(clk),
                                   .rom_data_i(inst),
                                   .rom_ce_o(rom_ce),
                                   .rom_addr_o(inst_addr));

inst_rom inst_rom0(.ce(rom_ce),
                   .addr(inst_addr),
                   .inst(inst));
endmodule
