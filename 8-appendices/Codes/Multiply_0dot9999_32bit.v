`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2022 10:41:49
// Design Name: 
// Module Name: Multiply_0dot9999_32bit
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


module Multiply_0dot9999_32bit(
    input signed [31:0] in1,
    output wire signed [31:0] out1
    );
    
    reg signed [31:0] coef1 = 32'h7FDF3B63;
    reg signed [31:0] coef2 = 32'h7FFFFFFF;
    wire signed [63:0] calc;
    assign calc = in1 * coef1;
    assign out1 = calc / coef2;
        
    initial begin
        coef1 = 32'h7FDF3B63;   //0.999*coef2
        coef2 = 32'h7FFFFFFF;
    end
    
endmodule
