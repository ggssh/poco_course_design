`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/12 08:59:09
// Design Name:
// Module Name: ex_tb
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


module ex_tb();
reg[3:0] alu_control;
reg [31:0] alu_src1;
reg [31:0] alu_src2;
wire [31:0] alu_result;

integer i;
reg rst = 'b0;
ex ex0(.rst(rst),
       .alu_control(alu_control),
       .alu_src1(alu_src1),
       .alu_src2(alu_src2),
       .alu_result(alu_result));

always #200 rst = ~rst;

initial begin
    alu_control = 4'b0000;
    alu_src1 = 32'h1257_89Ab;
    alu_src2 = 32'hFEAB_BC76;
    // alu_src1 = 32'h00000001;
    // alu_src2 = 32'h00000002;
    #20;
    for(i=0;i<12;i=i+1) begin
        $monitor("alu_src1=%h, alu_control=%b, alu_src2=%h, alu_result=%h",
                 alu_src1,alu_control,alu_src2,alu_result);
        #20;
        alu_control = alu_control+1;
    end
    #40 $finish;
end

endmodule
