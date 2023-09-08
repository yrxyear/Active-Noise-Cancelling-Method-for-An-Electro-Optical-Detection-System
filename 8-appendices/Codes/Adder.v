`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2022 13:48:12
// Design Name: 
// Module Name: Adder
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

module Adder(
    input signed [15:0] in1,
    input signed [15:0] in2,
    //input rst,
    output wire signed [15:0] out1
    );
    
    assign out1 = in1 + in2;
    /*
    always @(posedge rst) begin
        out1 = 0;
    end
    */
endmodule

/*
module Adder(
    input signed [15:0] in1,
    input signed [15:0] in2,
    input clk,
    input rst,
    output reg signed [15:0] out1
    );
    
    reg signed [15:0] adder;
    
    initial begin
        assign adder = in1 + in2;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            //adder = 0;
            out1 = 0;
        end
        else begin
            out1 = adder;
        end
    end
    
endmodule
*/