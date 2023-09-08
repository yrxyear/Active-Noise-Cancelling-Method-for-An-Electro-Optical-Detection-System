`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2023 01:11:53 PM
// Design Name: 
// Module Name: Debouce
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


module Debounce (
    input clk,
    input rst,
    input inputSig,
    output reg debounced_signal
);

parameter COUNT_MAX = 5000; //number of clock cycles
reg [15:0] count = 0;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 0;
        debounced_signal <= 0;
    end else begin
        if (inputSig != debounced_signal) begin
            count <= count + 1;
            if (count == COUNT_MAX) begin
                count <= 0;
                debounced_signal <= inputSig;
            end
        end else begin
            count <= 0;
        end
    end
end

endmodule

