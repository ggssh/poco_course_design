`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/02 20:09:26
// Design Name:
// Module Name: pipeline_cpu
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


module pipeline_cpu(
           input wire clk,
           input wire rst,
           // 来自inst_rom
           input wire[`RegBus] rom_data_i,

           // 发送到inst_rom
           output wire[`RegBus] rom_addr_o,
           output wire rom_ce_o,

           // 来自data_ram
           input wire[`RegBus] ram_data_i,
           // 发送到data_ram
           output wire[`RegBus] mem_addr_o,
           output wire[`RegBus] mem_data_o,
           output wire[3:0] mem_sel_o,
           output wire mem_we_o,
           output wire mem_ce_o
       );

// 连接IF/ID和ID模块
wire[`InstBus] id_inst_i;
wire[`InstAddrBus] id_pc_i;

// 连接ID和pc_reg
wire branch_flag;
wire[`RegBus] branch_target_address;

// 连接ID和ID/EX模块
wire[`AluOpBus] id_aluop_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire[`RegAddrBus] id_wd_o;
wire id_wreg_o;
wire[`RegBus]  id_inst_o;
wire next_inst_in_delayslot_o;
wire[`RegBus] id_is_in_delayslot_o;
wire[`RegBus] id_link_addr_o;
wire is_in_delayslot_i;

// 连接ID/EX模块和EX模块
wire[`AluOpBus] ex_aluop_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire[`RegAddrBus] ex_wd_i;
wire ex_wreg_i;
wire[`RegBus]  ex_inst_i;
wire[`RegBus] ex_link_address_i;
wire ex_is_in_delayslot_i;

// 连接EX模块和EX/MEM模块(只写输出部分就行)
wire[`RegBus] ex_wdata_o;
wire[`RegAddrBus] ex_wd_o;
wire ex_wreg_o;
wire[`AluOpBus] ex_aluop_o;
wire[`RegBus] ex_mem_addr_o;
wire[`RegBus] ex_reg2_o;

// 连接EX/MEM模块和MEM模块
wire[`RegBus] mem_wdata_i;
wire[`RegAddrBus] mem_wd_i;
wire mem_wreg_i;
wire[`AluOpBus] mem_aluop_i;
wire[`RegBus] mem_mem_addr_i;
wire[`RegBus] mem_reg2_i;

// 连接MEM模块和MEM/WB模块
wire[`RegBus] mem_wdata_o;
wire[`RegAddrBus] mem_wd_o;
wire mem_wreg_o;

// 连接MEM/WB模块和Regfile模块
wire[`RegBus] wb_wdata_i;
wire[`RegAddrBus] wb_wd_i;
wire wb_wreg_i;

// 连接ID模块和RegFile模块
wire reg1_read;
wire reg2_read;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;

// 连接MEM和data RAM
// 来自mem
// wire ram_ce;
// wire ram_we;
// wire[`DataAddrBus] ram_addr;
// wire[3:0] ram_sel;
// wire[`DataBus] ram_data_i;
// // 送到mem
// wire[`DataBus] ram_data_o;

pc_reg pc_reg0(
           .clk(clk),
           .rst(rst),
           .branch_flag_i(branch_flag),
           .branch_target_address_i(branch_target_address),
           .pc(rom_addr_o),// pc的值同样也要送到id和ex中,进行跳转
           .ce(rom_ce_o)
       );

// 流水线寄存器
// 时钟上升沿,输出变成输入
if_id if_id0(
          .rst(rst),
          .clk(clk),
          .if_pc(rom_addr_o),
          .if_inst(rom_data_i),
          .id_pc(id_pc_i),
          .id_inst(id_inst_i)
      );

id id0(
       .rst(rst),
       .pc_i(id_pc_i),
       .inst_i(id_inst_i),
       .is_in_delayslot_i(is_in_delayslot_i),
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
       .reg2_data_i(reg2_data),
       .inst_o(id_inst_o),
       .branch_flag_o(branch_flag),
       .branch_target_address_o(branch_target_address),
       // todo
       .next_inst_in_delayslot_o(next_inst_in_delayslot_o),
       .is_in_delayslot_o(id_is_in_delayslot_o),
       .link_addr_o(id_link_addr_o)
   );

id_ex id_ex0(
          .rst(rst),
          .clk(clk),
          .id_aluop(id_aluop_o),
          .id_reg1(id_reg1_o),
          .id_reg2(id_reg2_o),
          .id_wd(id_wd_o),
          .id_wreg(id_wreg_o),
          .id_inst(id_inst_o),
          .id_link_address(id_link_addr_o),
          .id_is_in_delayslot(id_is_in_delayslot_o),
          .next_inst_in_delayslot_i(next_inst_in_delayslot_o),
          .ex_aluop(ex_aluop_i),
          .ex_reg1(ex_reg1_i),
          .ex_reg2(ex_reg2_i),
          .ex_wd(ex_wd_i),
          .ex_wreg(ex_wreg_i),
          .ex_inst(ex_inst_i),
          .ex_link_address(ex_link_address_i),
          .ex_is_in_delayslot(ex_is_in_delayslot_i),
          .is_in_delayslot_o(is_in_delayslot_i)
      );

ex ex0(
       .rst(rst),
       .alu_control(ex_aluop_i),
       .alu_src1(ex_reg1_i),
       .alu_src2(ex_reg2_i),
       .wd_i(ex_wd_i),
       .wreg_i(ex_wreg_i),
       .inst_i(ex_inst_i),
       .link_addr_i(ex_link_address_i),
       .is_in_delayslot_i(ex_is_in_delayslot_i),
       .alu_result(ex_wdata_o),
       .wd_o(ex_wd_o),
       .wreg_o(ex_wreg_o),
       .aluop_o(ex_aluop_o),
       .mem_addr_o(ex_mem_addr_o),
       .reg2_o(ex_reg2_o)
   );

ex_mem ex_mem0(
           .rst(rst),
           .clk(clk),
           .ex_wdata(ex_wdata_o),
           .ex_wd(ex_wd_o),
           .ex_wreg(ex_wreg_o),
           .mem_wdata(mem_wdata_i),
           .mem_wd(mem_wd_i),
           .mem_wreg(mem_wreg_i),
           .ex_aluop(ex_aluop_o),
           .ex_mem_addr(ex_mem_addr_o),
           .ex_reg2(ex_reg2_o),
           .mem_aluop(mem_aluop_i),
           .mem_mem_addr(mem_mem_addr_i),
           .mem_reg2(mem_reg2_i)
       );

mem mem0(
        .rst(rst),
        // 来自ex
        .wdata_i(mem_wdata_i),
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .aluop_i(mem_aluop_i),
        .mem_addr_i(mem_mem_addr_i),
        .reg2_i(mem_reg2_i),
        // 送到wb
        .wdata_o(mem_wdata_o),
        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        // 来自data RAM
        .mem_data_i(ram_data_i),
        // 送到data RAM
        .mem_addr_o(mem_addr_o),
        .mem_data_o(mem_data_o),
        .mem_sel_o(mem_sel_o),
        .mem_we_o(mem_we_o),
        .mem_ce_o(mem_ce_o)
    );

mem_wb mem_wb0(
           .rst(rst),
           .clk(clk),
           .mem_wdata(mem_wdata_o),
           .mem_wd(mem_wd_o),
           .mem_wreg(mem_wreg_o),
           .wb_wdata(wb_wdata_i),
           .wb_wd(wb_wd_i),
           .wb_wreg(wb_wreg_i)
       );

regfile regfile0(
            .clk(clk),
            .rst(rst),
            .re1(reg1_read),
            .raddr1(reg1_addr),
            .re2(reg2_read),
            .raddr2(reg2_addr),
            .we(wb_wreg_i),
            .waddr(wb_wd_i),
            .wdata(wb_wdata_i),
            .rdata1(reg1_data),
            .rdata2(reg2_data)
        );
endmodule
