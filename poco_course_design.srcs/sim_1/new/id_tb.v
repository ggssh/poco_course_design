`timescale 1ns / 1ps
`include "../../sources_1/new/defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/19 08:23:04
// Design Name:
// Module Name: id_tb
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


module id_tb();
reg rst;
reg[`InstBus] inst_i;
reg[`RegBus] reg1_data_i;
reg[`RegBus] reg2_data_i;
// 送到regfile的信息
wire reg1_read_o;
wire reg2_read_o;
wire[`RegAddrBus] reg1_addr_o;
wire[`RegAddrBus] reg2_addr_o;
// 送到执行阶段的信息
wire[`AluOpBus] aluop_o;
wire[`RegBus] reg1_o;
wire[`RegBus] reg2_o;
wire[`RegAddrBus] wd_o;
wire wreg_o;
reg[`InstBus] inst_array[0:11];
integer i;
initial begin
    // $readmemh("F:\\main\\project\\HDL_projects\\lab\\initial_data\\inst_rom1.data",inst_array);
    $readmemh("../../../../initial_data/inst_rom1.data",inst_array);// 使用相对路径比较好些(虽然也没人回去再跑这个代码)
end
id id0(.rst(rst),
       .inst_i(inst_i),
       .reg1_data_i(reg1_data_i),
       .reg2_data_i(reg2_data_i),
       .reg1_read_o(reg1_read_o),
       .reg2_read_o(reg2_read_o),
       .reg1_addr_o(reg1_addr_o),
       .reg2_addr_o(reg2_addr_o),
       .aluop_o(aluop_o),
       .reg1_o(reg1_o),
       .reg2_o(reg2_o),
       .wd_o(wd_o),
       .wreg_o(wreg_o));

initial begin
    rst=`RstEnable;
    #100;
    rst=`RstDisable;
    reg1_data_i=32'h12345678;
    reg2_data_i=32'hfedcba98;
    for(i=0;i<12;i=i+1) begin
        inst_i=inst_array[i];
        #20;
    end
    #20 $stop;
end
endmodule

    // ADD $5,$1,$2
    // 0000 0000 0010 0010 0010 1000 0010 0000 => 00222820
    // SUB $6,$4,$3
    // 000000 00100 00011 00110 00000 100010 => 0000 0000 1000 0011 0011 0000 0010 0010 => 00833022
    // OR $7,$2,$1
    // 000000 00010 00001 00111 00000 100101 => 0000 0000 0100 0001 0011 1000 0010 0101 => 00413825
    // AND $10,$8,$9
    // 000000 01000 01001 01010 00000 100100 => 0000 0001 0000 1001 0101 0000 0010 0100 => 01095024
    // XOR $13,$12,$11
    // 000000 01100 01011 01101 00000 100110 => 0000 0001 1000 1011 0110 1000 0010 0110 => 018B6826
    // NOR $14,$15,$16
    // 000000 01111 10000 01110 00000 100111 => 0000 0001 1111 0000 0111 0000 0010 0111 => 01F07027
    // SLT $17,$18,$19
    // 000000 10010 10011 10001 00000 101010 => 0000 0010 0101 0011 1000 1000 0010 1010 => 0253882A
    // SLTU $20,$21,$22
    // 000000 10101 10110 10100 00000 101011 => 0000 0010 1011 0110 1010 0000 0010 1011 => 02B6A02B
    // SLL $23,$24,6
    // 000000 00000 11000 10111 00110 000000 => 0000 0000 0001 1000 1011 1001 1000 0000 => 0018B980
    // SRL $25,$25,7
    // 000000 00000 11001 11001 00111 000010 => 0000 0000 0001 1001 1100 1001 1100 0010 => 0019C9C2
    // SRA $26,$26,8
    // 000000 00000 11010 11010 01000 000011 => 0000 0000 0001 1010 1101 0010 0000 0011 => 001AD203
    // LUI $30,0x1100
    // 001111 00000 11110 0001 0001 0000 0000 => 0011 1100 0001 1110 0001 0001 0000 0000 => 3C1E1100
