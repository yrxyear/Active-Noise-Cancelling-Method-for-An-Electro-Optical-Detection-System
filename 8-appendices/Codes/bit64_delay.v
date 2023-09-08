`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2022 13:58:17
// Design Name: 
// Module Name: bit64_delay
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


module bit64_delay(
    input signed [63:0] in1,
    input clk,
    input rst,
    output reg signed [63:0] out1
    );
    

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            out1 <= 64'h0000000000000000;
        end
        else begin
            out1 <= in1;
        end
    end
    
endmodule
