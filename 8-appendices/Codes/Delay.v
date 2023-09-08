`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2023 01:56:39 PM
// Design Name: 
// Module Name: Delay
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


 module Delay(
  input clk,        // input clock signal
  input reset,      // reset signal
  output reg out    // output signal
);

parameter DELAY_CYCLES = 1000; // number of clock cycles to delay

reg [7:0] count = 0; // counter to count clock cycles

always @(posedge clk or posedge reset) begin
  if (reset) begin
    count <= 0; // reset counter on reset signal
    out <= 0;   // reset output signal on reset signal
  end
  else begin
    count <= count + 1; // increment counter on every clock cycle
    if (count == DELAY_CYCLES) begin
      count <= 0;  // reset counter when it reaches DELAY_CYCLES
      out <= 1;    // toggle output signal after delay
    end
  end
end

endmodule
