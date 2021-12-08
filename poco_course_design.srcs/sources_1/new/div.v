`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/08 13:13:35
// Design Name:
// Module Name: div
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


module div(
           input wire clk,
           input wire rst,

           input wire signed_div_i,// 是否为有符号除法,为1表示为有符号除法
           input wire[31:0] opdata1_i,// 被除数
           input wire[31:0] opdata2_i,// 除数
           input wire start_i,
           input wire annul_i,// 是否取消除法运算,为1表示取消

           output reg[63:0] result_o,
           output reg ready_o// 表示除法运算是否结束
       );

/*
    DivFree:表示除法模块空闲
    DivByZero:表示除数为0
    DivOn:除法运算进行中
    DivEnd:除法运算结束
*/

wire[32:0] div_temp;
reg[5:0] count; // 记录迭代法次数
reg[1:0] state;
reg[64:0] dividend;
reg[31:0] divisor;
reg[31:0] temp_op1;
reg[31:0] temp_op2;

/*
    dividend
*/
assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};

always @(posedge clk) begin
    if(rst == `RstEnable) begin
        state <= `DivFree;
        ready_o <= `DivResultNotReady;
        result_o <= {`ZeroWord,`ZeroWord};
    end
    else begin
        case(state)
            /*
                DivFree状态
            */
            `DivFree: begin
                // 开始做除法运算
                if(start_i==`DivStart && annul_i==1'b0) begin
                    if(opdata2_i==`ZeroWord) begin
                        state <= `DivByZero;
                    end
                    else begin
                        state <= `DivOn;
                        count <= 6'b000000;
                        // 是否为有符号运算
                        // 被除数
                        if(signed_div_i==1'b1 && opdata1_i[31]==1'b1) begin
                            temp_op1 = ~opdata1_i + 1;
                        end
                        else begin
                            temp_op1 = opdata1_i;
                        end
                        // 除数
                        if (signed_div_i==1'b1 && opdata2_i[31]==1'b1) begin
                            temp_op2 = ~opdata2_i + 1;
                        end
                        else begin
                            temp_op2 = opdata2_i;
                        end
                        dividend <= {`ZeroWord,`ZeroWord};
                        dividend[32:1] <= temp_op1;
                        divisor <= temp_op2;
                    end
                end
                // 没有开始除法运算
                else begin
                    ready_o <= `DivResultNotReady;
                    result_o <= {`ZeroWord,`ZeroWord};
                end
            end // case DivFree

            /*
                DivByZero状态
            */
            `DivByZero: begin
                dividend <= {`ZeroWord,`ZeroWord};
                state <= `DivEnd;
            end
            /*
                DivOn状态(进行除法运算)
            */
            `DivOn: begin
                if(annul_i == 1'b0) begin
                    if(count!=6'b100000) begin // 表示试商法还没有结束
                        if(div_temp[32]==1'b1) begin
                            // 如果div_temp[32]为1,表示(minuend-n)结果小于0
                            dividend <= {dividend[63:0],1'b0};
                        end
                        else begin
                            dividend <= {div_temp[31:0],dividend[31:0],1'b1};
                        end
                        count <= count + 1;
                    end
                    else begin// 试商法结束
                        if((signed_div_i==1'b1) && ((opdata1_i[31]^opdata2_i[31])==1'b1)) begin
                            dividend[31:0] <= (~dividend[31:0]+1); // 求补码
                        end
                        if((signed_div_i==1'b1) && ((opdata1_i[31]^dividend[64])==1'b1)) begin
                            dividend[64:33] <= (~dividend[64:33]+1);// 求补码
                        end
                        state <= `DivEnd; // 进入DivEnd状态
                        count <= 6'b0000000;// count清零
                    end

                end
                else begin
                    state <= `DivFree;// 如果annul_i为1,那么直接回到DivFree状态
                end
            end
            /*
                DivEnd状态(除法运算结束)
                result_o的宽度是64位,其高32位存储余数,低32位存储商
                设置输出信号ready_o为DivResultReady,表示除法结束
                等待EX模块送来DivStop信号,当EX模块送到DivStop信号,Div模块回到DivFree状态
            */
            `DivEnd: begin
                result_o <= {dividend[64:33],dividend[31:0]};
                ready_o <= `DivResultReady;// 除法结束
                if(start_i==`DivStop) begin
                    state <= `DivFree;
                    ready_o <= `DivResultNotReady;
                    result_o <= {`ZeroWord,`ZeroWord};
                end
            end
        endcase
    end
end
endmodule
