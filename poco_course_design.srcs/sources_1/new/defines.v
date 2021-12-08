//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/05 08:01:05
// Design Name:
// Module Name: defines
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

// 全局
`define RstEnable 1'b1 // 复位信号
`define RstDisable 1'b0
`define ZeroWord 32'h00000000 // 零字
`define WriteEnable 1'b1 // 写信号
`define WriteDisable 1'b0
`define ReadEnable 1'b1 // 读信号
`define ReadDisable 1'b0

// pc模块
`define Branch 1'b1// 转移
`define NotBranch 1'b0// 不转移

// 通用寄存器regfile
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000

// 指令存储器inst_rom
`define InstAddrBus 31:0// 指令地址线宽度为32
`define InstBus 31:0// 指令长度为32
`define InstMemNum 131072
`define InstMemNumLog2 17
`define ChipEnable 1'b1
`define ChipDisable 1'b0

// id模块
`define InDelaySlot 1'b1 // 在延迟槽中
`define NotInDelaySlot 1'b0 //不在

// 数据存储器 data_rom
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131072
`define DataMemNumLog2 17 // 为什么是17位 引脚号为a0-a16
`define ByteWidth 7:0

`define InstValid 1'b0
`define InstInvalid 1'b1
`define AluOpBus 5:0 // 提前预留好之后指令的位置

// ctrl模块
`define Stop 1'b1// 流水线暂停
`define NoStop 1'b0// 流水线继续

// div除法模块
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0

// alu_op
`define ADD_OP 6'b000000
`define SUB_OP 6'b000001
`define SLT_OP 6'b000010
`define SLTU_OP 6'b000011
`define AND_OP 6'b000100
`define NOR_OP 6'b000101
`define OR_OP 6'b000110
`define XOR_OP 6'b000111
`define SLL_OP 6'b001000
`define SRL_OP 6'b001001
`define SRA_OP 6'b001010
`define LUI_OP 6'b001011
`define ADDU_OP 6'b001100
`define ADDIU_OP 6'b001101
`define SUBU_OP 6'b001110
`define LW_OP 6'b001111
`define SW_OP 6'b010000
`define BEQ_OP 6'b010001
`define BNE_OP 6'b010010
`define JAL_OP 6'b010011
`define JR_OP 6'b010100
//
`define ADDI_OP 6'b010101
`define SLTI_OP 6'b010110
`define SLTIU_OP 6'b010111
`define ANDI_OP 6'b011000
`define ORI_OP 6'b011001
`define XORI_OP 6'b011010
`define SLLV_OP 6'b011011
`define SRAV_OP 6'b011100
`define SRLV_OP 6'b011101
`define DIV_OP 6'b011110
`define DIVU_OP 6'b011111
`define MULT_OP 6'b100000
`define MULTU_OP 6'b100001
`define MFHI_OP 6'b100010
`define MFLO_OP 6'b100011
`define MTHI_OP 6'b100100
`define MTLO_OP 6'b100101
//
`define NOP_OP 6'b111111

// 操作码
// 逻辑运算指令
`define EXE_AND 6'b100100
`define EXE_OR 6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111
`define EXE_LUI 6'b001111
`define EXE_ANDI 6'b001100
`define EXE_ORI 6'b001101
`define EXE_XORI 6'b001110

// 移位指令
`define EXE_SLL 6'b000000
`define EXE_SRL 6'b000010
`define EXE_SRA 6'b000011
`define EXE_SLLV 6'b000100
`define EXE_SRAV 6'b000111
`define EXE_SRLV 6'b000110

// 算数运算指令
`define EXE_ADD 6'b100000
`define EXE_ADDU 6'b100001 // ADDU
`define EXE_SUB 6'b100010
`define EXE_SUBU 6'b100011 // SUBU
`define EXE_SLT 6'b101010
`define EXE_SLTU 6'b101011 // SLTU
`define EXE_ADDIU 6'b001001 // ADDIU
`define EXE_ADDI 6'b001000
`define EXE_SLTI 6'b001010
`define EXE_SLTIU 6'b001011


// 加载存储指令
`define EXE_LW 6'b100011
`define EXE_SW 6'b101011

// 转移指令
`define EXE_BEQ 6'b000100
`define EXE_BNE 6'b000101
`define EXE_JAL 6'b000011
`define EXE_JR 6'b001000

// 移动指令
`define EXE_MFHI 6'b010000
`define EXE_MFLO 6'b010010
`define EXE_MTHI 6'b010001
`define EXE_MTLO 6'b010011

`define EXE_SPECIAL_INST 6'b000000
