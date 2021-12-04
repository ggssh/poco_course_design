`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/12 08:36:41
// Design Name:
// Module Name: ex
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


module ex(
           input wire rst,

           // 译码阶段送到执行阶段的信息
           input wire[`AluOpBus] alu_control,// ALU控制信号
           input wire[`RegBus] alu_src1,// ALU操作数1,为补码
           input wire[`RegBus] alu_src2,// ALU操作数2,为补码
           input wire wreg_i,
           input wire[`RegAddrBus] wd_i,

           // 执行的结果
           output reg [`RegBus] alu_result,// AlU运算结果
           output reg[`RegAddrBus] wd_o,
           output reg wreg_o

       );

wire[`RegBus] alu_src2_mux;
wire[`RegBus] result_sum;
wire src1_lt_src2;

assign alu_src2_mux = ((alu_control==`SUB_OP)||(alu_control==`SLT_OP))? (~alu_src2)+1:alu_src2; // 取反加一:不变
assign result_sum = alu_src1 + alu_src2_mux;
assign src1_lt_src2 = (alu_control==`SLT_OP)? // signed : unsigned
       ((alu_src1[31]&&!alu_src2[31])||// 操作数1为负且操作数2为正
        (!alu_src1[31]&&!alu_src2[31]&&result_sum[31])||// 操作数1和操作数2都为正,且操作数1-操作数2的结果为负
        (alu_src1[31]&&alu_src2[31]&&result_sum[31]))// 操作数1和操作数2都为负,且操作数1-操作数2的结果为正
       : (alu_src1<alu_src2);

always @(*) begin
    if(rst == `RstEnable) begin
        alu_result = `ZeroWord;
        wd_o=`NOPRegAddr;
        wreg_o=`WriteDisable;
    end
    else begin
        wd_o=wd_i;
        wreg_o=wreg_i;
        case(alu_control)
            `ADD_OP,`SUB_OP,`ADDU_OP,`ADDIU_OP: begin
                alu_result = result_sum;
            end
            `SLT_OP,`SLTU_OP: begin
                alu_result = src1_lt_src2;
            end
            `AND_OP: begin
                alu_result = alu_src1 & alu_src2;
            end
            `NOR_OP: begin
                alu_result = ~(alu_src1 | alu_src2);
            end
            `OR_OP: begin
                alu_result = alu_src1 | alu_src2;
            end
            `XOR_OP: begin
                alu_result = alu_src1 ^ alu_src2;
            end
            `SLL_OP: begin
                alu_result = alu_src2<<alu_src1[4:0]; // 移位量为5位立即数
            end
            `SRL_OP: begin
                alu_result = alu_src2>>alu_src1[4:0];
            end
            `SRA_OP:// 算术右移
            begin
                alu_result = ({32{alu_src2[31]}} << (6'd32-{1'b0,alu_src1[4:0]})) // 0xFFFF左移(32-移位量)
                | alu_src2>> alu_src1[4:0]; // 将前者运算结果和alu_src2右移结果进行或运算
            end
            `LUI_OP: begin
                alu_result = {alu_src2[15:0],16'd0}; // 将立即数写入寄存器
            end
            default: begin
                alu_result = `ZeroWord;
            end
        endcase
    end
end
endmodule
