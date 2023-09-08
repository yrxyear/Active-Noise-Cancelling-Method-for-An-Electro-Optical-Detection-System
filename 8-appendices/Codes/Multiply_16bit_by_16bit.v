`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2022 11:01:32
// Design Name: 
// Module Name: Multiply_16bit_by_16bit
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

module Multiply_16bit_by_16bit(
    input signed [15:0] in1,
    input signed [15:0] in2,
    output wire signed [31:0] out1
    );
    
    wire signed [31:0] calc;
    assign calc = in1 * in2;
    /*
    //normal multiply
    assign out1[31:8] = calc[23:0];
    assign out1[7:0] = 8'h00;
    */
    //multiply with 16bits shift to right
    assign out1[23:0] = calc[31:8];
    //assign out1[31:16] = 8'h00;
    
    always @(*) begin
        if(out1[23]) begin
            out1[31:24] <= 8'hF;
        end
        else begin
            out1[31:24] <= 8'h0;
        end
    end
    
endmodule

/*
module Multiply_16bit_by_16bit(
    input [15:0] in1,
    input [15:0] in2,
    input rst,
    input clk,
    output reg [15:0] out1
    );
    
    reg signed [31:0] calc;
    
    initial begin
        assign calc = in1 * in2;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out1 = 0;
        end
        else begin
            out1 = calc[23:8];
        end
    end
    
endmodule
*/