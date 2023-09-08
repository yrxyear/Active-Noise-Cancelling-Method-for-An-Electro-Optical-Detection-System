`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2022 10:57:26
// Design Name: 
// Module Name: Multiply_0dot9_16bit
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

module Multiply_0dot9_16bit(
    input signed [15:0] in1,
    //input rst,
    output wire signed [15:0] out1
    );
    
    reg signed [15:0] coef1 = 16'd26123;
    reg signed [15:0] coef2 = 16'd32767;
    wire signed [31:0] calc;
    assign calc = in1 * coef1;
    assign out1 = calc / coef2;
        
    initial begin
        coef1 = 16'd26123;
        coef2 = 16'd32767;
    end
    /*
    always @(posedge rst) begin
        out1 = 0;
    end
    */
endmodule

/*
module Multiply_0dot9_16bit(
    input signed [15:0] in1,
    input rst,
    input clk,
    output reg signed [15:0] out1
    );
    
    reg signed [23:0] calc;
    reg signed [7:0] coef;
    
    initial begin
        coef = 8'd119;
        assign calc = in1 * coef;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out1 = 0;
        end
        else begin
            out1 = calc[23:7];
        end
    end
    
endmodule
*/
