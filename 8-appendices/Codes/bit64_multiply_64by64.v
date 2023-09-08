`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2022 14:12:59
// Design Name: 
// Module Name: bit64_multiply_64by64
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


module bit64_multiply_64by64(
    input signed [63:0] in1,
    input signed [63:0] in2,
    output wire signed [63:0] out1
    );
    
    wire signed [127:0] calc;
    assign calc = in1 * in2;
    assign out1[63:0] = calc[95:32];
    
    
endmodule
