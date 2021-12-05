`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/03 08:34:44
// Design Name:
// Module Name: mem
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


module mem(
           input wire rst,

           // 来自ex
           input wire[`RegAddrBus] wd_i,
           input wire wreg_i,
           input wire[`RegBus] wdata_i,
           input wire[`AluOpBus] aluop_i,
           input wire[`RegBus] mem_addr_i,
           input wire[`RegBus] reg2_i,

           // 送到wb
           output reg[`RegAddrBus] wd_o,
           output reg wreg_o,
           output reg[`RegBus] wdata_o,

           // 来自data RAM
           input wire[`RegBus] mem_data_i,

           // 送到data RAM
           output reg[`RegBus] mem_addr_o,
           output reg[`RegBus] mem_data_o,
           output reg[3:0] mem_sel_o,
           output wire mem_we_o,
           output reg mem_ce_o
       );

// have problem
reg mem_we;
assign mem_we_o = mem_we;

always @(*) begin
    if(rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `ZeroWord;
        mem_addr_o <= `ZeroWord;
        mem_data_o <= `ZeroWord;
        mem_sel_o <= 4'b0000;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipDisable;
    end
    else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        mem_addr_o <= `ZeroWord;
        // mem_data_o <= `ZeroWord;
        mem_sel_o <= 4'b1111;
        mem_we <= `WriteDisable;
        mem_ce_o <= `ChipDisable;
        case(aluop_i)
        `LW_OP: begin
            mem_addr_o <= mem_addr_i;
            mem_we <= `WriteDisable;// 不需要data RAM中写入
            mem_sel_o <= 4'b1111;
            mem_ce_o <= `ChipEnable;
            wdata_o <= mem_data_i;
        end
        `SW_OP:begin
            mem_addr_o <= mem_addr_i;
            mem_we <= `WriteEnable;
            mem_ce_o <= `ChipEnable;
            mem_sel_o <= 4'b1111;
            mem_data_o <= reg2_i;
        end
        default:begin
        end
    endcase
    end // if
end // always
endmodule
