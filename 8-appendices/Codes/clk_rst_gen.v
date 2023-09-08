`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2023 05:16:10 PM
// Design Name: 
// Module Name: clk_rst_gen
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


module clk_rst_gen(
    output reg clk,
    output reg rst
    );
    
    initial begin
        clk = 0;
        rst = 0;
        #20;
        rst = 1;
        #20;
        rst = 0;
    end
    
    always begin
        clk = ~clk;
        #10;
    end
    
endmodule
