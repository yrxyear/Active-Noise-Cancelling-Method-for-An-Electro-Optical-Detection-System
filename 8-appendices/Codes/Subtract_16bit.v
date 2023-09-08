`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2022 11:14:16
// Design Name: 
// Module Name: Subtract_16bit
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

module Subtract_16bit(
    input signed [15:0] in1,
    input signed [15:0] in2,
    //input rst,
    output wire signed [15:0] out1
    );
    
    assign out1 = in1 - in2;
    /*
    always @(posedge rst) begin
        out1 = 0;
    end
    */
endmodule

/*
module Subtract_16bit(
    input signed [15:0] in1,
    input signed [15:0] in2,
    input clk,
    input rst,
    output reg signed [15:0] out1
    );
    
    wire signed [15:0] subtracter;
    assign subtracter = in1 - in2;
    
    initial begin
        //assign subtracter = in1 - in2;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out1 = 0;
        end
        else begin
            out1 = subtracter;
        end
    end
    
endmodule
*/