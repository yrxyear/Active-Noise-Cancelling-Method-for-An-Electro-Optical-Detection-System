`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2022 10:44:11
// Design Name: 
// Module Name: Divide_16_bit
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

module Divide_16_bit(
    input signed [15:0] in1,
    input signed [15:0] in2,
    //input rst,
    output wire signed [15:0] out1
    );
    
    wire signed [23:0] calc;
    wire signed [23:0] calc2;
    
    assign calc[23:8] = in1;
    assign calc[7:0] = 8'h00;
    assign calc2 = calc / in2;
    assign out1 = calc2[15:0];
    
    /*
    always @(posedge rst) begin
        out1 = 0;
    end
    */
endmodule

/*
module Divide_16_bit(
    input [15:0] in1,
    input [15:0] in2,
    input rst,
    input clk,
    output reg [15:0] out1
    );
    
    reg signed [31:0] calc;
    reg signed [15:0] calc2;
    
    initial begin
        assign calc[23:8] = in1;
        assign calc2 = calc / in2;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out1 = 0;
        end
        else begin
            out1 = calc2;
        end
    end
    
endmodule
*/