`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/26 07:41:55
// Design Name:
// Module Name: single_cycle_cpu
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


module single_cycle_cpu(
           input wire clk,
           input wire rst,
           input wire[`RegBus] rom_data_i,
           input wire[`RegBus] rom_addr_o,
           output wire rom_ce_o
       );

pc_reg pc_reg0(.clk(clk),
               .rst(rst),
               .pc(rom_addr_o),
               .ce(rom_ce_o));

// 连接id和ex模块
wire[`AluOpBus] id_aluop_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire[`RegAddrBus] id_wd_o;
wire id_wreg_o;
// 连接译码阶段id模块和通用寄存器regfile模块
wire reg1_read;
wire reg2_read;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;

id id0(.rst(rst),
       .inst_i(rom_data_i),
       .aluop_o(id_aluop_o),
       .reg1_o(id_reg1_o),
       .reg2_o(id_reg2_o),
       .wd_o(id_wd_o),
       .wreg_o(id_wreg_o),
       .reg1_read_o(reg1_read),
       .reg1_addr_o(reg1_addr),
       .reg2_read_o(reg2_read),
       .reg2_addr_o(reg2_addr),
       .reg1_data_i(reg1_data),
       .reg2_data_i(reg2_data));

// 连接ex模块和regfile
wire[`RegBus] wdata_o;
wire[`RegAddrBus] wd_o;
wire wreg_o;

ex ex0(.rst(rst),
       .alu_control(id_aluop_o),
       .alu_src1(id_reg1_o),
       .alu_src2(id_reg2_o),
       .wd_i(id_wd_o),
       .wreg_i(id_wreg_o),
       .alu_result(wdata_o),
       .wd_o(wd_o),
       .wreg_o(wreg_o));

regfile regfile0(.clk(clk),
                 .rst(rst),
                 .re1(reg1_read),
                 .raddr1(reg1_addr),
                 .re2(reg2_read),
                 .raddr2(reg2_addr),
                 .we(wreg_o),
                 .waddr(wd_o),
                 .wdata(wdata_o),
                 .rdata1(reg1_data),
                 .rdata2(reg2_data));
endmodule
