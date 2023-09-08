`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2023 01:23:00 PM
// Design Name: 
// Module Name: SPI_Controller_2
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


module SPI_Controller_2(
    input sys_clk,
    input o_TX_Ready,
    input btn_0,
    input btn3,            // to start the output
    output reg [7:0] i_TX_Byte,
    output reg i_TX_DV,
    output reg i_Rst_L,
    output reg [1:0] i_TX_Count,
    output led0,
    output led1,
    output led2,
    output led3,
    output led4r,
    output led5r,
    output jap4,
    output SendByte_test,
    output SendByteOn_test,
    output pauseBtn_3_test
    );
    
    reg led_0;
    assign led0 = led_0;
    
    reg led_1;
    assign led1 = led_1;
    
    reg led_2;
    assign led2 = led_2;
    
    reg led_3;
    assign led3 = led_3;
    
    wire btn_3;
    assign btn_3 = btn3;
    
    reg led4_r;
    assign led4r = led4_r;
    
    reg led5_r;
    assign led5r = led5_r;
    
    reg ja_p4;
    assign jap4 = ja_p4;
    
    wire r_Clk;
    assign r_Clk = sys_clk;
    
    reg [7:0] Clk_counter = 0;
    reg [7:0] Clk_times = 10;
    
    always @(posedge r_Clk) begin
        case (Clk_counter)
            (Clk_times - 1): begin
                Clk_counter <= 0;
            end
            (0): begin
                ja_p4 <= 1;
                Clk_counter <= Clk_counter + 1;
            end
            (Clk_times / 2): begin
                ja_p4 <= 0;
                Clk_counter <= Clk_counter + 1;
            end
            default: Clk_counter <= Clk_counter + 1;
        endcase
    end
    
    reg DelayReset;
    wire DelayOut;
    
    reg [3:0] counter = 4'd0;
    reg flag = 0;
    
    Delay Delay_1(
      .clk(r_Clk),        // input clock signal
      .reset(DelayReset),      // reset signal
      .out(DelayOut)    // output signal
    );
    
    

    parameter MAX_BYTES_PER_CS = 2;   // 2 bytes per chip select
    reg [(MAX_BYTES_PER_CS+1)-1:0] w_Master_RX_Count, r_Master_TX_Count = 2'b01;
    always @(posedge r_Clk) begin
        i_TX_Count = r_Master_TX_Count;
    end

    reg SendByte = 0;
    reg SendByteOn = 0;
    reg [4:0] Counter_2 = 4'd0;
    reg [7:0] data;
    reg pauseBtn_3 = 0;
    
    assign SendByte_test = SendByte;
    assign SendByteOn_test = SendByteOn;
    assign pauseBtn_3_test = pauseBtn_3;
    
    always @(posedge r_Clk & (SendByte | SendByteOn))
    begin
        if (btn_0) begin
            Counter_2 <= 0;
            SendByteOn <= 0;
        end else if(Counter_2 == 4'd0) begin
            SendByteOn <= 1;
            i_TX_Byte <= data;
            Counter_2 <= Counter_2 + 4'd1;
        end
        else if(Counter_2 == 4'd1) begin
            i_TX_DV <= 1'b1;
            Counter_2 <= Counter_2 + 4'd1;
        end
        else if(Counter_2 == 4'd2) begin
            i_TX_DV <= 1'b0;
            Counter_2 <= Counter_2 + 4'd1;
        end
        else if(Counter_2 == 4'd3 && o_TX_Ready) begin
            Counter_2 <= 0;
            SendByteOn <= 0;
        end
    end
    
    
       
    
    reg btn_3_prev = 0;
     
    always @(posedge r_Clk or posedge btn_0) begin
        if (btn_0) begin
            counter <= 0;
            led_0 <= 0;
            led_1 <= 0;
            led_2 <= 0;
            led_3 <= 0;
            SendByte <= 0;
        end else if (SendByteOn) begin
            SendByte <= 0;
        end else begin
            if (!btn_3_prev & btn_3) begin
                btn_3_prev <= 1;
                counter <= counter + 4'd1;
                
                case (counter)
                4'd0: begin
                    i_Rst_L <= 1'b0;
                    led5_r <= 0;
                end
                4'd1: begin
                    i_Rst_L <= 1'b1;
                    led_0 <= 1;
                end
                4'd2: begin
                    // Test single byte
                    data <= 8'h1C;
                end
                4'd3: begin
                    SendByte <= 1;
                    led_1 <= 1;
                end
                4'd4: begin
                    // Test double byte
                    data <= 8'hBE;
                end
                4'd5: begin
                    SendByte <= 1;
                    led_2 <= 1;
                end
                4'd6: begin
                    // Test double byte
                    data <= 8'hEF;
                end
                4'd7: begin
                    SendByte <= 1;
                    led_3 <= 1;
                end
                4'd8: begin
                    counter <= 4'd0;
                    led_0 <= 0;
                    led_1 <= 0;
                    led_2 <= 0;
                    led_3 <= 0;
                end
                default: led5_r <= 1;
            endcase
                
                led4_r <= 1;
            end
            
            if (!btn_3) begin
                btn_3_prev <= 0;
                led4_r <= 0;
            end
            
            
        end
    end    
    
endmodule
