`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/02 20:05:31
// Design Name:
// Module Name: mips_sopc1
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


module mips_sopc1(
           input wire clk,
           input wire rst
       );
// 连接inst_rom和cpu
wire[`InstAddrBus] inst_addr;
wire[`InstBus] inst;
wire rom_ce;

// 连接data_ram和cpu
wire[`RegBus] mem_addr_o;
wire[`RegBus] mem_data_o;
wire[3:0] mem_sel_o;
wire mem_we_o;
wire mem_ce_o;
wire[`RegBus] ram_data_i;

    pipeline_cpu pipeline_cpu0(
        .rst(rst),
        .clk(clk),
        .rom_data_i(inst),
        .rom_ce_o(rom_ce),
        .rom_addr_o(inst_addr),
        .ram_data_i(ram_data_i),
        .mem_addr_o(mem_addr_o),
        .mem_data_o(mem_data_o),
        .mem_sel_o(mem_sel_o),
        .mem_we_o(mem_we_o),
        .mem_ce_o(mem_ce_o)
    );
inst_rom inst_rom0(
             .ce(rom_ce),
             .addr(inst_addr),
             .inst(inst)
         );

data_ram data_ram0(
             .clk(clk),
             // 来自mem
             .ce(mem_ce_o),
             .we(mem_we_o),
             .addr(mem_addr_o),
             .sel(mem_sel_o),
             .data_i(mem_data_o),
             // 送到mem
             .data_o(ram_data_i)
         );
endmodule
