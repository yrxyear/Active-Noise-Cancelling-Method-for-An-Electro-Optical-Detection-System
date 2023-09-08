`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2022 10:55:33
// Design Name: 
// Module Name: Multiply_3_16bit
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

module Multiply_minus1_16bit(
    input signed [15:0] in1,
    //input rst,
    output wire signed [15:0] out1
    );
    
    assign out1 = in1 * -1;
    /*
    always @(posedge rst) begin
        out1 = 0;
    end
    */
endmodule

/*
module Multiply_minus1_16bit(
    input signed [15:0] in1,
    input rst,
    input clk,
    output reg signed [15:0] out1
    );
    
    reg signed [15:0] calc;
    
    initial begin;
        assign calc = in1 * -1;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out1 = 0;
        end
        else begin
            out1 = calc;
        end
    end
    
endmodule
*/