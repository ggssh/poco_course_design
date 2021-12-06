`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/18 08:29:40
// Design Name:
// Module Name: id
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


module id(
           input wire rst,

           // 来自if/id
           input wire[`InstBus]        inst_i,
           input wire[`InstAddrBus]    pc_i,

           // 来自regfile
           input wire[`RegBus]         reg1_data_i,// 从regfile读入数据1
           input wire[`RegBus]         reg2_data_i,// 从regfile读入数据2

           // 来自id/ex
           input wire is_in_delayslot_i, // 如果上一条指令是转移指令,那么下一条指令进入译码阶段时,该值为true表示是延迟槽指令

           // 送到regfile
           output reg                  reg1_read_o,
           output reg                  reg2_read_o,
           output reg[`RegAddrBus]     reg1_addr_o,
           output reg[`RegAddrBus]     reg2_addr_o,

           // 送到id/ex
           output reg[`AluOpBus]       aluop_o,// 译码阶段运算类型
           output reg[`RegBus]         reg1_o,// 译码阶段源操作数1
           output reg[`RegBus]         reg2_o,// 译码阶段源操作数2
           output reg[`RegAddrBus]     wd_o,// 目的寄存器地址, inst_i[15:11]
           output reg                  wreg_o,// 是否要写入寄存器
           output wire[`RegBus]        inst_o, // 将inst_i输出至执行阶段
           output reg next_inst_in_delayslot_o,
           output reg[`RegBus] is_in_delayslot_o,
           output reg[`RegBus] link_addr_o,

           // 送到 pc
           output reg branch_flag_o,
           output reg[`RegBus] branch_target_address_o
       );

wire[5:0] op = inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];

reg[`RegBus] imm;// 32位立即数
reg instvalid;// 标志指令是否有效

assign inst_o = inst_i;// inst_o的值就是从inst_rom中取出来的指令inst_i

wire[`RegBus] pc_plus_8;
wire[`RegBus] pc_plus_4;

wire[`RegBus] imm_sll2_signedext;

assign pc_plus_8 = pc_i + 8; // 当前译码阶段指令后面第二条指令
assign pc_plus_4 = pc_i + 4; // 后面紧跟着的那条指令
assign imm_sll2_signedext = {{14{inst_i[15]}},inst_i[15:0],2'b00};// 立即数offset左移两位并进行有符号扩展

always @(*) begin
    if(rst == `RstEnable) begin
        aluop_o <= `NOP_OP;
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instvalid <= `InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= `ZeroWord;
        link_addr_o <= `ZeroWord;
        branch_target_address_o <= `ZeroWord;
        branch_flag_o <= `NotBranch;
        next_inst_in_delayslot_o <= `NotInDelaySlot;
    end// end (rst == `RstEnable)
    else begin
        aluop_o <= `NOP_OP;
        wd_o <= inst_i[15:11];
        wreg_o <= `WriteDisable;
        instvalid <= `InstInvalid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[25:21];
        reg2_addr_o <= inst_i[20:16];
        imm <= `ZeroWord;
        link_addr_o <= `ZeroWord;
        branch_target_address_o <= `ZeroWord;
        branch_flag_o <= `NotBranch;
        next_inst_in_delayslot_o <= `NotInDelaySlot;
        case (op)
            `EXE_SPECIAL_INST: begin
                case(op2)
                    5'b00000: begin
                        case(op3)
                            `EXE_OR: begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `OR_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_AND: begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `AND_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_XOR: begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `XOR_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_NOR: begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `NOR_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_SLT: begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `SLT_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_SLTU: begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `SLTU_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_ADD: begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `ADD_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_ADDU: begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `ADDU_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_SUB: begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `SUB_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_SUBU: begin
                                wreg_o <= `WriteEnable;
                                aluop_o <= `SUBU_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_JR: begin
                                wreg_o <= `WriteDisable;
                                aluop_o <= `JR_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b0;
                                instvalid <= `InstValid;
                                link_addr_o <= `ZeroWord;
                                branch_target_address_o <= reg1_o; // 跳转目标为寄存器中的值
                                branch_flag_o <= `Branch;
                                next_inst_in_delayslot_o <= `InDelaySlot;
                            end
                            default: begin
                            end
                        endcase
                    end
                    default: begin
                    end
                endcase
            end
            `EXE_LUI: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `LUI_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                imm <= {inst_i[15:0],16'h0};
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end
            `EXE_ADDIU: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `ADDIU_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                imm <= {{16{inst_i[15]}},inst_i[15:0]};
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end
            `EXE_LW: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `LW_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end
            `EXE_SW: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `SW_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b1;// 需要得到rt寄存器中的数
                wd_o <= inst_i[20:16];//其实没啥用
                instvalid <= `InstValid;
            end
            `EXE_JAL: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `JAL_OP;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b0;
                wd_o <= 5'b11111; // 31号寄存器
                instvalid <= `InstValid;
                link_addr_o <= pc_plus_8; // 将该分支对应延迟槽指令之后的指令的PC值保存到31号寄存器中
                branch_flag_o <= `Branch;
                next_inst_in_delayslot_o <= `InDelaySlot;
                branch_target_address_o <= {pc_plus_4[31:28],inst_i[25:0],2'b00};
            end
            `EXE_BNE: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `BNE_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b1;
                instvalid <= `InstValid;
                if(reg1_o != reg2_o) begin
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                end
            end
            `EXE_BEQ: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `BEQ_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b1;
                instvalid <= `InstValid;
                if(reg1_o == reg2_o) begin
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                end
            end
            default: begin
            end
        endcase

        // 3条移位指令
        if (inst_i[31:21]==11'b00000000000) begin
            if (op3==`EXE_SLL) begin
                wreg_o <= `WriteEnable;
                aluop_o <= `SLL_OP;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <= inst_i[10:6];
                wd_o <= inst_i[15:11];
                instvalid <= `InstValid;
            end
            else if (op3 == `EXE_SRL) begin
                wreg_o <= `WriteEnable;
                aluop_o <= `SRL_OP;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <= inst_i[10:6];
                wd_o <= inst_i[15:11];
                instvalid <= `InstValid;
            end
            else if (op3 == `EXE_SRA) begin
                wreg_o <= `WriteEnable;
                aluop_o <= `SRA_OP;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <= inst_i[10:6];
                wd_o <= inst_i[15:11];
                instvalid <= `InstValid;
            end
        end
    end// end (rst != `RstEnable)
end// end always

// 源操作数1
always @(*) begin
    if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end
    else if (reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i;
    end
    else if (reg1_read_o == 1'b0) begin
        reg1_o <= imm;
    end
    else begin
        reg1_o <= `ZeroWord;
    end
end// end always

// 源操作数2
always @(*) begin
    if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end
    else if (reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i;
    end
    else if (reg2_read_o == 1'b0) begin
        reg2_o <= imm;
    end
    else begin
        reg2_o <= `ZeroWord;
    end
end// end always

// is_in_delayslot_o表示当前译码阶段指令是否是延迟槽指令
always @(*) begin
    if(rst==`RstEnable) begin
        is_in_delayslot_o <= `NotInDelaySlot;
    end
    else begin
        is_in_delayslot_o <= is_in_delayslot_i;
    end
end
endmodule
