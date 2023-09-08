`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2022 10:31:46
// Design Name: 
// Module Name: Adder_32bit
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


module Adder_32bit(
    input signed [31:0] in1,
    input signed [31:0] in2,
    output wire signed [31:0] out1
    );
    
    assign out1 = in1 + in2;
    
endmodule
