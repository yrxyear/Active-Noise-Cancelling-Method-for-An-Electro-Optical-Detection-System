`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2022 14:13:35
// Design Name: 
// Module Name: bit64_multiply_0dot9999
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


module bit64_multiply_0dot9999(
    input signed [63:0] in1,
    output wire signed [63:0] out1
    );
    
    reg signed [63:0] coef1 = 64'd9999;
    reg signed [63:0] coef2 = 64'd10000;
    wire signed [127:0] calc;
    assign calc = in1 * coef1;
    assign out1 = calc / coef2;
        
    initial begin
        coef1 = 64'd9999;   //0.9999*coef2
        coef2 = 64'd10000;
    end
    
endmodule