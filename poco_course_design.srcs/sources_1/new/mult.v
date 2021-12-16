`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/08 18:31:32
// Design Name:
// Module Name: mult
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


module mult(
           input wire clk,
           input wire rst,

           input wire signed_mult_i,// 是否为有符号乘法,为1是表示有符号
           input wire[31:0] opdata1_i,// 乘数1(被乘数)
           input wire[31:0] opdata2_i,// 乘数2(乘数)
           input wire start_i,// 是否开始乘法运算

           output reg[63:0] result_o,
           output reg ready_o
       );

reg[5:0] count;// 当count等于32时,表示迭代过程结束,需要做最后一个加法或者减法
reg[1:0] state;// 状态 MultFree=00,MultOn=01,MultEnd=10
reg[33:0] reg_A;
reg[33:0] reg_X;// X存放被乘数的补码(含两位符号位)
reg[33:0] reg_Q;// 存放乘数的补码(含最高1位符号位和最末1位附加位)

reg[33:0] neg_data1;// 被乘数的相反数的补码
// wire[32:0] regA_temp;
// wire[32:0] regQ_temp;
// reg flag;

// assign neg_data1 = {~(opdata1_i[31]),(~opdata1_i)+1};

always @(posedge clk) begin
    if(rst==`RstEnable) begin
        state <= `MultFree;
        ready_o <= `MultResultNotReady;
        result_o <= {`ZeroWord,`ZeroWord};
    end
    else begin
        case(state)
            /*
                MultFree状态
            */
            `MultFree: begin
                if(start_i==`MultStart) begin
                    state <= `MultOn;
                    count <= 6'b000000;
                    reg_A <= 34'b0;// 乘法运算前A寄存器被清零,作为初始部分积
                    if (signed_mult_i!=1'b1) begin
                        reg_X <= {{2{1'b0}},opdata1_i};
                        reg_Q <= {1'b0,opdata2_i,1'b0};
                    end
                    else begin
                        reg_X <= {{2{opdata1_i[31]}},opdata1_i};
                        reg_Q <= {opdata2_i[31],opdata2_i,1'b0};
                    end
                    
                    // reg_X <= {opdata1_i[31],opdata1_i[31:0]};// 被乘数的补码(双符号位)
                    // reg_Q <= {opdata2_i[31:0],1'b0};
                    neg_data1 <= {{2{~(opdata1_i[31])}},(~opdata1_i)+1};
                end
                else begin
                    ready_o <= `MultResultNotReady;
                    result_o <= {`ZeroWord,`ZeroWord};
                end
            end
            /*
                MultOn状态
            */
            `MultOn: begin
                if(count!=6'b100000) begin
                    case(reg_Q[1:0])
                        2'b10: begin
                            reg_A = reg_A + neg_data1;
                            // flag <= 1'b1;
                        end
                        2'b01: begin
                            reg_A = reg_A + reg_X;
                        end
                    endcase
                    reg_Q = {reg_A[0],reg_Q[33:1]};
                    reg_A = {reg_A[33],reg_A[33:1]};//算术右移一位
                    // reg_Q <= reg_Q >> 1;
                    // reg_A <= reg_A >> 1;
                    count <= count + 1;
                end
                else begin
                    // if(signed_mult_i!=1'b1) begin
                    // 最后还要再判断一次Qn和Qn+1
                    case(reg_Q[1:0])
                        2'b10: begin
                            reg_A <= reg_A + neg_data1;
                        end
                        2'b01: begin
                            reg_A <= reg_A + reg_X;
                        end
                    endcase
                    // end

                    state <= `MultEnd;
                    count <= 6'b000000;
                end
            end
            /*
                MultEnd(乘法运算结束)
                result_o的宽度64,
            */
            `MultEnd: begin
                result_o <= {reg_A[31:0],reg_Q[33:2]};
                ready_o <= `MultResultReady;//乘法结束
                if(start_i==`MultStop) begin
                    state <= `MultFree;
                    ready_o <= `MultResultNotReady;
                    result_o <= {`ZeroWord,`ZeroWord};
                    reg_A <= 34'b0;
                    reg_X <= 34'b0;
                    reg_Q <= 34'b0;
                    neg_data1 = 34'b0;
                end
            end
        endcase
    end
end

endmodule
