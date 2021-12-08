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

           // 来自id/ex
           input wire[`AluOpBus] alu_control,// ALU控制信号(aluop_i)
           input wire[`RegBus] alu_src1,// ALU操作数1,为补码(reg1_i)
           input wire[`RegBus] alu_src2,// ALU操作数2,为补码(reg2_i)
           input wire wreg_i,
           input wire[`RegAddrBus] wd_i,
           input wire[`RegBus] inst_i,// 当前阶段执行的指令,即id的inst_i
           input wire[`RegBus] link_addr_i,// 处于执行阶段的转移指令要保存的返回地址
           input wire is_in_delayslot_i,// 当前处于执行阶段的转移指令是否在延迟槽内

           // HILO模块给出的HI,LO寄存器的值
           input wire[`RegBus] hi_i,
           input wire[`RegBus] lo_i,

           // 回写阶段的指令是否要写HI,LO,用于检测HI,LO寄存器带来的数据相关问题
           input wire[`RegBus] wb_hi_i,
           input wire[`RegBus] wb_lo_i,
           input wire wb_whilo_i,
           // 访存阶段的指令是否要写HI,LO,用于检测HI,LO寄存器带来的数据相关问题
           input wire[`RegBus] mem_hi_i,
           input wire[`RegBus] mem_lo_i,
           input wire mem_whilo_i,
           // 处于执行阶段的指令对HI,LO寄存器的写操作要求
           output reg[`RegBus] hi_o,
           output reg[`RegBus] lo_o,
           output reg whilo_o,

           // 送到mem
           output reg [`RegBus] alu_result,// AlU运算结果
           output reg[`RegAddrBus] wd_o,
           output reg wreg_o,

           // store && load 送到ex/mem
           output wire[`AluOpBus] aluop_o,
           output wire[`RegBus] mem_addr_o,
           output wire[`RegBus] reg2_o,

           // 送到ctrl
           output reg stallreq,

           // 来自除法模块的输入
           input wire[`DoubleRegBus] div_result_i,
           input wire div_ready_i,

           // 到除法模块的输出
           output reg[`RegBus] div_opdata1_o,
           output reg[`RegBus] div_opdata2_o,
           output reg div_start_o,
           output reg signed_div_o,

           // 来自乘法模块的输入
           input wire[`DoubleRegBus] mult_result_i,
           input wire mult_ready_i,

           // 到乘法模块的输出
           output reg[`RegBus] mult_opdata1_o,
           output reg[`RegBus] mult_opdata2_o,
           output reg mult_start_o,
           output reg signed_mult_o
       );

wire[`RegBus] alu_src2_mux;
wire[`RegBus] result_sum;
wire src1_lt_src2;

reg stallreq_for_div;// 是否由于除法运算导致流水线暂停
reg stallreg_for_mult;// 是否由于乘法运算导致流水线暂停

// 存储,加载
assign aluop_o = alu_control;// 传递aluop直到mem模块
assign mem_addr_o = alu_src1 + {{16{inst_i[15]}},inst_i[15:0]};// 计算offset(base)
assign reg2_o = alu_src2;// LW:reg2_o=0;SW:reg2_o=rt寄存器中的值

assign alu_src2_mux = ((alu_control==`SUB_OP)||
                       (alu_control==`SLT_OP)||
                       (alu_control==`SUBU_OP))?
       (~alu_src2)+1:alu_src2; // 取反加一:不变

assign result_sum = alu_src1 + alu_src2_mux;
assign src1_lt_src2 = (alu_control==`SLT_OP||alu_control==`SLTI_OP)? // signed : unsigned
       ((alu_src1[31]&&!alu_src2[31])||// 操作数1为负且操作数2为正
        (!alu_src1[31]&&!alu_src2[31]&&result_sum[31])||// 操作数1和操作数2都为正,且操作数1-操作数2的结果为负
        (alu_src1[31]&&alu_src2[31]&&result_sum[31]))// 操作数1和操作数2都为负,且操作数1-操作数2的结果为正
       : (alu_src1<alu_src2);

reg[`RegBus] HI;// 保存HI寄存器的最新值
reg[`RegBus] LO;// 保存LO寄存器的最新值

// 得到最新的HI,LO寄存器的值,解决数据相关问题
always @(*) begin
    if(rst==`RstEnable) begin
        {HI,LO} <= {`ZeroWord,`ZeroWord};
    end
    else if (mem_whilo_i==`WriteEnable) begin
        {HI,LO} <= {mem_hi_i,mem_lo_i};//访存阶段的指令要写HI,LO寄存器
    end
    else if(wb_whilo_i == `WriteEnable) begin
        {HI,LO} <= {wb_hi_i,wb_lo_i};// 回写阶段指令要写HI,LO寄存器
    end
    else begin
        {HI,LO} <= {hi_i,lo_i};
    end
end

always @(*) begin
    if(rst == `RstEnable) begin
        alu_result <= `ZeroWord;
        wd_o<=`NOPRegAddr;
        wreg_o<=`WriteDisable;
        whilo_o<=`WriteDisable;
        hi_o<=`ZeroWord;
        lo_o<=`ZeroWord;
        stallreq_for_div <= `NoStop;
        stallreg_for_mult <= `NoStop;
        div_opdata1_o <= `ZeroWord;
        div_opdata2_o <= `ZeroWord;
        div_start_o <= `DivStop;
        signed_div_o <= 1'b0;
        signed_mult_o <= 1'b0;
    end
    else begin
        wd_o<=wd_i;
        wreg_o<=wreg_i;
        stallreq_for_div <= `NoStop;
        stallreg_for_mult <= `NoStop;
        div_opdata1_o <= `ZeroWord;
        div_opdata2_o <= `ZeroWord;
        div_start_o <= `DivStop;
        signed_div_o <= 1'b0;
        signed_mult_o <= 1'b0;
        case(alu_control)
            `ADD_OP,`SUB_OP,`ADDU_OP,`ADDIU_OP,`ADDI_OP,`SUBU_OP: begin
                alu_result <= result_sum;
            end
            `SLT_OP,`SLTU_OP,`SLTI_OP,`SLTIU_OP: begin
                alu_result <= src1_lt_src2;
            end
            `AND_OP,`ANDI_OP: begin
                alu_result <= alu_src1 & alu_src2;
            end
            `NOR_OP: begin
                alu_result <= ~(alu_src1 | alu_src2);
            end
            `OR_OP,`ORI_OP: begin
                alu_result <= alu_src1 | alu_src2;
            end
            `XOR_OP,`XORI_OP: begin
                alu_result <= alu_src1 ^ alu_src2;
            end
            `SLL_OP,`SLLV_OP: begin
                alu_result <= alu_src2<<alu_src1[4:0]; // 移位量为5位立即数
            end
            `SRL_OP,`SRLV_OP: begin
                alu_result <= alu_src2>>alu_src1[4:0];
            end
            `SRA_OP,`SRAV_OP:// 算术右移
            begin
                alu_result <= ({32{alu_src2[31]}} << (6'd32-{1'b0,alu_src1[4:0]})) // 0xFFFF左移(32-移位量)
                | alu_src2>> alu_src1[4:0]; // 将前者运算结果和alu_src2右移结果进行或运算
            end
            `LUI_OP: begin
                alu_result <= alu_src2;
            end
            `JAL_OP: begin
                alu_result <= link_addr_i;
            end
            `MFHI_OP: begin
                alu_result <= HI;
            end
            `MFLO_OP: begin
                alu_result <= LO;
            end
            `MTHI_OP: begin
                whilo_o <= `WriteEnable;
                hi_o <= alu_src1;
                lo_o <= LO;
            end
            `MTLO_OP: begin
                whilo_o <= `WriteEnable;
                hi_o <= HI;
                lo_o <= alu_src1;
            end
            `DIV_OP: begin
                if (div_ready_i==`DivResultNotReady) begin
                    div_opdata1_o <= alu_src1;// 被除数
                    div_opdata2_o <= alu_src2;// 除数
                    div_start_o <= `DivStart;// 开始除法运算
                    signed_div_o <= 1'b1;// 有符号除法
                    stallreq_for_div <= `Stop;// 请求流水线暂停
                end
                else if (div_ready_i==`DivResultReady) begin
                    div_opdata1_o <= alu_src1;
                    div_opdata2_o <= alu_src2;
                    div_start_o <= `DivStop;
                    signed_div_o <= 1'b1;
                    stallreq_for_div <= `NoStop;// 不再请求流水线暂停
                    //往HI,LO里面写
                    whilo_o <= `WriteEnable;
                    hi_o <= div_result_i[63:32];
                    lo_o <= div_result_i[31:0];
                end
                else begin
                    div_opdata1_o <= `ZeroWord;
                    div_opdata2_o <= `ZeroWord;
                    div_start_o <= `DivStop;
                    signed_div_o <= 1'b0;
                    stallreq_for_div <= `NoStop;
                end
            end
            `DIVU_OP: begin
                if (div_ready_i==`DivResultNotReady) begin
                    div_opdata1_o <= alu_src1;// 被除数
                    div_opdata2_o <= alu_src2;// 除数
                    div_start_o <= `DivStart;// 开始除法运算
                    signed_div_o <= 1'b0;// 有符号除法
                    stallreq_for_div <= `Stop;// 请求流水线暂停
                end
                else if (div_ready_i==`DivResultReady) begin
                    div_opdata1_o <= alu_src1;
                    div_opdata2_o <= alu_src2;
                    div_start_o <= `DivStop;
                    signed_div_o <= 1'b0;
                    stallreq_for_div <= `NoStop;// 不再请求流水线暂停
                    //往HI,LO里面写
                    whilo_o <= `WriteEnable;
                    hi_o <= div_result_i[63:32];
                    lo_o <= div_result_i[31:0];
                end
                else begin
                    div_opdata1_o <= `ZeroWord;
                    div_opdata2_o <= `ZeroWord;
                    div_start_o <= `DivStop;
                    signed_div_o <= 1'b0;
                    stallreq_for_div <= `NoStop;
                end
            end
            `MULT_OP: begin
                if(mult_ready_i==`MultResultNotReady) begin
                    mult_opdata1_o <= alu_src1;
                    mult_opdata2_o <= alu_src2;
                    signed_mult_o <= 1'b1;
                    mult_start_o <= `MultStart;
                    stallreg_for_mult <= `Stop;//请求流水线暂停
                end
                else if(mult_ready_i==`MultResultReady) begin
                    mult_opdata1_o <= alu_src1;
                    mult_opdata2_o <= alu_src2;
                    signed_mult_o <= 1'b0;
                    mult_start_o <= `MultStop;
                    stallreg_for_mult <= `NoStop;
                    // 往HI,LO里面写
                    whilo_o <= `WriteEnable;
                    hi_o <= mult_result_i[63:32];
                    lo_o <= mult_result_i[31:0];
                end
                else begin
                    signed_mult_o <= 1'b0;
                    mult_opdata1_o <= `ZeroWord;
                    mult_opdata2_o <= `ZeroWord;
                    mult_start_o <= `MultStop;
                    stallreg_for_mult <= `NoStop;
                end
            end
            `MULTU_OP: begin
                if(mult_ready_i==`MultResultNotReady) begin
                    mult_opdata1_o <= alu_src1;
                    mult_opdata2_o <= alu_src2;
                    signed_mult_o <= 1'b0;
                    mult_start_o <= `MultStart;
                    stallreg_for_mult <= `Stop;//请求流水线暂停
                end
                else if(mult_ready_i==`MultResultReady) begin
                    mult_opdata1_o <= alu_src1;
                    mult_opdata2_o <= alu_src2;
                    signed_mult_o <= 1'b0;
                    mult_start_o <= `MultStop;
                    stallreg_for_mult <= `NoStop;
                    // 往HI,LO里面写
                    whilo_o <= `WriteEnable;
                    hi_o <= mult_result_i[63:32];
                    lo_o <= mult_result_i[31:0];
                end
                else begin
                    signed_mult_o <= 1'b0;
                    mult_opdata1_o <= `ZeroWord;
                    mult_opdata2_o <= `ZeroWord;
                    mult_start_o <= `MultStop;
                    stallreg_for_mult <= `NoStop;
                end
            end
            default: begin
                alu_result <= `ZeroWord;
                whilo_o <= `WriteDisable;
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
                stallreq_for_div <= `NoStop;
                stallreg_for_mult <= `NoStop;
                div_opdata1_o <= `ZeroWord;
                div_opdata2_o <= `ZeroWord;
                div_start_o <= `DivStop;
                signed_div_o <= 1'b0;
                mult_opdata1_o <= `ZeroWord;
                mult_opdata2_o <= `ZeroWord;
                mult_start_o <= `MultStop;
            end
        endcase
    end
end

// 暂停流水线
always @(*) begin
    stallreq <= stallreq_for_div||stallreg_for_mult;
end

// 修改HI,LO
endmodule
