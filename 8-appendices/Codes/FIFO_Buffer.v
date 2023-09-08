`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2023 01:26:50 PM
// Design Name: 
// Module Name: FIFO_Buffer
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
// A 10 position FIFO buffer, when data_valid pulse, it enters a 24bit number
// when there are numbers in the buffer, data_ready will be high to indicate
// number available for reading
//////////////////////////////////////////////////////////////////////////////////


module fifo_buffer (
    input clk,                // Clock input
    input reset,                // Reset input
    input data_valid,         // Input data valid signal
    input read_start,         // Start a reading cycle
    output data_ready,    // Output data ready signal
    input [23:0] data_in,     // Data input
    output [23:0] data_out, // Data output
    output data_full,
    output srst,
    output [23:0] din,
    output wr_en,
    output rd_en,
    input [23:0] dout,
    input full,
    input almost_full,
    input empty,
    input almost_empty
);

reg data_valid_a = 0;
reg data_valid_b = 0;
reg data_valid_r = 0;
reg read_start_a = 0;
reg read_start_b = 0;
reg read_start_r = 0;

assign srst = reset;
assign din[23:0] = data_in[23:0];
assign data_out[23:0] = dout[23:0];
assign wr_en = data_valid_r;
assign rd_en = read_start_r;
assign data_full = full;
assign data_ready = ~almost_empty;

always @(posedge clk or posedge reset) begin
    if (reset) begin 
        data_valid_a <= 0;
    end else begin
        data_valid_a <= data_valid;
        data_valid_b <= data_valid_a;
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin 
        data_valid_r <= 0;
    end else begin
        if(data_valid_a == 1 && data_valid_b == 0) begin
            data_valid_r <= 1;
        end else begin
            data_valid_r <= 0;
        end
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin 
        read_start_a <= 0;
    end else begin
        read_start_a <= read_start;
        read_start_b <= read_start_a;
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin 
        read_start_r <= 0;
    end else begin
        if(read_start_a == 1 && read_start_b == 0) begin
            read_start_r <= 1;
        end else begin
            read_start_r <= 0;
        end
    end
end

endmodule

