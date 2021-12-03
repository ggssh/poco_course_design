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
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131072
`define InstMemNumLog2 17
`define ChipEnable 1'b1
`define ChipDisable 1'b0

// 数据存储器 data_rom
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131072
`define DataMemNumLog2 17 // 为什么是17位 引脚号为a0-a16
`define ByteWidth 7:0

`define InstValid 1'b0
`define InstInvalid 1'b1
`define AluOpBus 3:0

// alu_op
`define ADD_OP 4'b0000
`define SUB_OP 4'b0001
`define SLT_OP 4'b0010
`define SLTU_OP 4'b0011
`define AND_OP 4'b0100
`define NOR_OP 4'b0101
`define OR_OP 4'b0110
`define XOR_OP 4'b0111
`define SLL_OP 4'b1000
`define SRL_OP 4'b1001
`define SRA_OP 4'b1010
`define LUI_OP 4'b1011
`define NOP_OP 4'b1111

// 操作码
// 逻辑运算指令
`define EXE_AND 6'b100100
`define EXE_OR 6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111
`define EXE_LUI 6'b001111

// 移位指令
`define EXE_SLL 6'b000000
`define EXE_SRL 6'b000010
`define EXE_SRA 6'b000011

// 算数运算指令
`define EXE_ADD 6'b100000
`define EXE_ADDU 6'b100001 // ADDU
`define EXE_SUB 6'b100010
`define EXE_SUBU 6'b100011 // SUBU
`define EXE_SLT 6'b101010
`define EXE_SLTU 6'b101011 // SLTU 

`define EXE_SPECIAL_INST 6'b000000
