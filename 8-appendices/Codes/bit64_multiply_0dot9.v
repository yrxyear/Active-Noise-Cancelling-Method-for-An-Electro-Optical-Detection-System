`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2022 14:00:01
// Design Name: 
// Module Name: bit64_multiply_0dot9
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


module bit64_multiply_0dot9(
    input signed [63:0] in1,
    output wire signed [63:0] out1
    );
    
    reg signed [63:0] coef1 = 64'd90;
    reg signed [63:0] coef2 = 64'd100;
    wire signed [127:0] calc;
    wire signed [127:0] calc2;
    assign calc = in1 * coef1;
    assign calc2 = calc / coef2;
    assign out1 = calc2[63:0];
        
    initial begin
        coef1 = 64'd90;
        coef2 = 64'd100;
    end
endmodule
