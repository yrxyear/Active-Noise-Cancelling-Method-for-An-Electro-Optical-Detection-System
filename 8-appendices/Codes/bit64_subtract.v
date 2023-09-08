`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2022 12:29:43
// Design Name: 
// Module Name: bit64_subtract
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


module bit64_subtract(
    input signed [63:0] in1,
    input signed [63:0] in2,
    output wire signed [63:0] out1
    );
    
    assign out1 = in1 - in2;
    
endmodule
