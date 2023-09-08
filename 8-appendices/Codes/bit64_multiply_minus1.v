`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2022 14:00:01
// Design Name: 
// Module Name: bit64_multiply_minus1
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


module bit64_multiply_minus1(
    input signed [63:0] in1,
    output wire signed [63:0] out1
    );
    
    assign out1 = in1 * -1;
    
endmodule
