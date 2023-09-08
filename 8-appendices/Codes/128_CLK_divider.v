`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2023 12:46:26 PM
// Design Name: 
// Module Name: 128_CLK_divider
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


module clock_divider (
    input clk,
    input rst,
    output reg clk_out
);

reg [6:0] count;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        clk_out <= 0;
        count <= 0;
    end
    else begin
        count <= count + 1;
        if (count == 63) begin
            count <= 0;
            clk_out <= ~clk_out;
        end
    end
end

endmodule
