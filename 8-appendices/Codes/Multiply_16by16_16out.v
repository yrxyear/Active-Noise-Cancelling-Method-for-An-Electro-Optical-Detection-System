`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2022 11:09:04
// Design Name: 
// Module Name: Multiply_16by16_16out
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


module Multiply_16by16_16out(
    input signed [15:0] in1,
    input signed [15:0] in2,
    //input rst,
    output wire signed [15:0] out1
    );
    
    wire signed [31:0] calc;
    assign calc = in1 * in2;
    assign out1 = calc[23:8];
    /*
    always @(posedge rst) begin
        out1 = 0;
    end
    */
endmodule