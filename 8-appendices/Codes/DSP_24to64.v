`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2023 06:19:58 PM
// Design Name: 
// Module Name: DSP_Block_24bit_to_64bit_conveter
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


module DSP_24to64(
    input signed [39:0] in1,
    output wire signed [63:0] out1
    );
    
    assign out1[63:24] = in1[39:0];
    assign out1[23:0] = 0;
    
endmodule