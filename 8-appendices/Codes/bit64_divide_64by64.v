`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2022 12:26:36
// Design Name: 
// Module Name: bit64_divide_64by64
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


module bit64_divide_64by64(
    input signed [63:0] in1,
    input signed [63:0] in2,
    output wire signed [63:0] out1
    );
    
    wire signed [95:0] calc;
    wire signed [95:0] calc2;
    
    assign calc[95:32] = in1;
    assign calc[31:0] = 32'h00000000;
    assign calc2 = calc / in2;
    assign out1 = calc2[64:0];
    
endmodule