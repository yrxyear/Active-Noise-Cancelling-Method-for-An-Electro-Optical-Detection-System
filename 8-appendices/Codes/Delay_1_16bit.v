`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2022 14:01:38
// Design Name: 
// Module Name: Delay_1_16bit
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


module Delay_1_16bit(
    input signed [15:0] in1,
    input clk,
    input rst,
    output reg signed [15:0] out1
    );
    
    //reg signed LastSample;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            //LastSample = 0;
            out1 <= 0;
        end
        else begin
            out1 <= in1;
        end
    end
    
endmodule
