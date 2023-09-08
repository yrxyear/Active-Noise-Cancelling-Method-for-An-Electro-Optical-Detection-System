`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2022 10:50:24
// Design Name: 
// Module Name: Divide_32bit_to_16bit
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


module Divide_32bit_to_16bit(
    input signed [31:0] in1,
    input signed [31:0] in2,
    //input rst,
    output wire signed [15:0] out1
    );
    
    wire signed [55:0] calc;
    wire signed [55:0] calc2;
    
    assign calc[55:24] = in1;
    assign calc[23:0] = 24'h000000;
    assign calc2 = calc / in2;
    assign out1 = calc2[31:16];
    
    /*
    always @(posedge rst) begin
        out1 = 0;
    end
    */
endmodule
