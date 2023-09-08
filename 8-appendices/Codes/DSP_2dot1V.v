`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2023 03:46:49 PM
// Design Name: 
// Module Name: DSP_2dot1V
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


module DSP_2dot1V(
    input signed [23:0] in1,
    input clk,
    input rst,
    output reg signed [63:0] out1
    );
    
    wire signed [63:0] buffer;
    reg signed [63:0] buffer_2;
    
    assign buffer [63:32] = 0;
    assign buffer [7:0] = 0;
    assign buffer [31:8] = in1[23:0];
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out1 <= 0;
        end
        else begin
            buffer_2 [63:0] <= buffer [63:0];
            //out1 [63:0] = buffer [63:0] - 64'h00000000A8000000; //2.1V sitting at 31:8
            out1 [63:0] <= buffer_2 [63:0] - 64'h00000000AACCCCCD; //2.135V sitting at 31:8
        end
    end
    
endmodule
