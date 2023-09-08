`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2023 04:31:40 PM
// Design Name: 
// Module Name: DSP_64to24
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


module DSP_64to24(
    input signed [63:0] in1,
    input clk,
    input rst,
    output reg signed [23:0] out1
    );
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out1 <= 0;
        end
        else begin
            out1[23:0] <= in1[31:8];
        end
    end
endmodule

