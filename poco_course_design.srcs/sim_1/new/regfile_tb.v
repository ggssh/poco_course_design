`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/22 09:06:17
// Design Name:
// Module Name: regfile_tb
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


module regfile_tb();
reg rst;
reg clk;
reg[4:0] waddr;
reg[31:0] wdata;
reg we;
reg[4:0] raddr1;
reg re1;
wire[31:0] rdata1;
reg[4:0] raddr2;
reg re2;
wire[31:0] rdata2;
integer i;
regfile regfile0(
            .rst(rst),
            .clk(clk),
            .waddr(waddr),
            .wdata(wdata),
            .we(we),
            .raddr1(raddr1),
            .re1(re1),
            .rdata1(rdata1),
            .raddr2(raddr2),
            .re2(re2),
            .rdata2(rdata2)
        );
initial begin
    clk <= 1'b1;
    rst <= 1'b0;
    $monitor($time,"raddr1=%h,rdata1=%h,raddr2=%h,rdata2=%h",
             raddr1,rdata1,raddr2,rdata2);
    #50
     rst <= 1'b1;
    #50
     rst <= 1'b0;
    we <= 1'b1;
    for (i = 0;i<32 ;i=i+1 ) begin
        waddr <= i;
        wdata <= i;
        #30;
    end
    we <= 1'b0;
    re1 <= 1'b1;
    re2 <= 1'b1;
    for (i =0 ;i<32 ;i=i+1 ) begin
        raddr1 <= i;
        raddr2 <= 31-i;
        #30;
    end
    re1 <= 0;
    re2 <= 0;
    #30
     we <= 1'b1;
    waddr <= 15;
    wdata <= 32'h0af;
    re1 <= 1;
    raddr1 <= 15;
    #30
     $stop;
end
always #10 clk <= ~clk;
endmodule
