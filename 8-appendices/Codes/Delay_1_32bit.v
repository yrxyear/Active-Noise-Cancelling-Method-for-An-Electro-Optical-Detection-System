`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2022 10:39:27
// Design Name: 
// Module Name: Delay_1_32bit
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


module Delay_1_32bit(
    input signed [31:0] in1,
    input clk,
    input rst,
    output reg signed [31:0] out1
    );
    
    //reg signed LastSample;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            //LastSample = 0;
            out1 <= 32'h00000000;
        end
        else begin
            out1 <= in1;
        end
    end
    
endmodule