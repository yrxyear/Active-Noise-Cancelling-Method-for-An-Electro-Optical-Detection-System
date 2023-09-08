`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2023 01:24:58 PM
// Design Name: 
// Module Name: SPI_ADC_read_loop
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


module SPI_ADC_Read_Loop(
    //to ucontroller
    input wire clk,
    input wire i_rst,
    input wire i_en1, //for initialize ADC
    input wire i_en2, //for reading data
    input wire i_RDYB,    //data ready
    output reg o_SYNC,
    output reg [23:0] o_ADC_data,   //received ADC data 24bit
    output reg o_ADC_data_DV,   //ADC data ready for buffer
    
    //to SPI master
    input wire i_o_Tx_Ready,
    input wire [2:0] i_o_Rx_Count,
    input wire i_o_Rx_Dv,
    input wire [7:0] i_o_Rx_Byte,
    output reg o_i_Rst_L,
    output reg [2:0] o_i_TX_Count,
    output reg [7:0] o_i_TX_Byte,
    output reg o_i_TX_Dv
);

    reg [31:0] send_data;
    reg [31:0] receive_data;
    reg [7:0] rx_byte;
    reg [2:0] spi_state = 0;
    reg [7:0] spi_init_state = 0;
    reg [7:0] spi_read_state = 127;
    reg [7:0] wait_counter = 0;
    reg init_ADC = 0;
    wire spi_clk;
    wire en1;
    
    assign spi_clk = clk;
    assign en1 = i_en1;
    
    reg adc_a = 0;
    reg adc_b = 0;
    always @(posedge spi_clk or posedge i_rst) begin
        if (i_rst) begin 
            adc_a <= 0;
        end else begin
            adc_a <= i_RDYB;
            adc_b <= adc_a;
        end
    end

    always @(posedge spi_clk or posedge i_rst) begin
        if(i_rst) begin
            init_ADC <= 0;
            spi_init_state <= 0;
            spi_read_state <= 127;
            o_SYNC <= 0;
            o_ADC_data <= 0;
            o_ADC_data_DV <= 0;
            o_i_Rst_L <= 1;
            o_i_TX_Count <= 0;
            o_i_TX_Byte <= 0;
            o_i_TX_Dv <= 0;
        end else begin
            if(en1) begin
                init_ADC <= 1;
            end
            if (adc_b > adc_a & spi_read_state > 20) begin // check for negedge of RDYB
                spi_read_state <= 0; // reset the state machine
            end
            if(init_ADC) begin
                case (spi_init_state)
                    //send D003
                    //1)a. SEQ:MODE[1:0] = 00 for sequencer mode 1
                    //1)b. SEQ:MUX[2:0] = 00 for channel 0
                    //1)c. Enable SEQ:MDREN
                    0: begin
                        o_ADC_data_DV <= 0;
                        o_i_Rst_L <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    1: begin
                        o_i_Rst_L <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    2: begin
                        o_i_TX_Count <= 2;
                        spi_init_state <= spi_init_state + 1;
                    end
                    3: begin
                        o_i_TX_Byte <= 8'hD0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    4: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    5: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    6: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    7: begin
                        o_i_TX_Byte <= 8'h03;
                        spi_init_state <= spi_init_state + 1;
                    end
                    8: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    9: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    10: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    //send C204
                    //1)d. CTRL1:SCYCLE = 0 for continuous conversion - 64kHz
                    // U/B = 0 for bipolar input
                    // offset data format
                    11: begin
                        o_i_Rst_L <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    12: begin
                        o_i_Rst_L <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    13: begin
                        o_i_TX_Byte <= 8'hC2;
                        spi_init_state <= spi_init_state + 1;
                    end
                    14: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    15: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    16: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    17: begin
                        o_i_TX_Byte <= 8'h0C;
                        spi_init_state <= spi_init_state + 1;
                    end
                    18: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    19: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    20: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    //send C4A0
                    //1)d. CTRL2:EXTCLK = 1 external clk 8.192MHz
                    21: begin
                        o_i_Rst_L <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    22: begin
                        o_i_Rst_L <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    23: begin
                        o_i_TX_Byte <= 8'hC4;
                        spi_init_state <= spi_init_state + 1;
                    end
                    24: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    25: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    26: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    27: begin
                        o_i_TX_Byte <= 8'hA0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    28: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    29: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    30: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    //send C224
                    //1)f. CTRL1:PD[1:0] to STANDBY
                    31: begin
                        o_i_Rst_L <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    32: begin
                        o_i_Rst_L <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    33: begin
                        o_i_TX_Byte <= 8'hC2;
                        spi_init_state <= spi_init_state + 1;
                    end
                    34: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    35: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    36: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    37: begin
                        o_i_TX_Byte <= 8'h2C;
                        spi_init_state <= spi_init_state + 1;
                    end
                    38: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    39: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    40: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    //send C63C
                    // CTRL3:SYNC_MODE to 1
                    41: begin
                        o_i_Rst_L <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    42: begin
                        o_i_Rst_L <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    43: begin
                        o_i_TX_Byte <= 8'hC6;
                        spi_init_state <= spi_init_state + 1;
                    end
                    44: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    45: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    46: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    47: begin
                        o_i_TX_Byte <= 8'h3C;
                        spi_init_state <= spi_init_state + 1;
                    end
                    48: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    49: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    50: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    //send C800
                    // GPI_CTRL:GPIO0_EN to 0
                    // GPI_CTRL:GPIO1_EN to 0
                    51: begin
                        o_i_Rst_L <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    52: begin
                        o_i_Rst_L <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    53: begin
                        o_i_TX_Byte <= 8'hC8;
                        spi_init_state <= spi_init_state + 1;
                    end
                    54: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    55: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    56: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    57: begin
                        o_i_TX_Byte <= 8'h00;
                        spi_init_state <= spi_init_state + 1;
                    end
                    58: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    59: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    60: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    //send 8F
                    //2)a. RATE[3:0] = 1111 for 64kHz
                    61: begin
                        o_i_Rst_L <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    62: begin
                        o_i_Rst_L <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    63: begin
                        o_i_TX_Count <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    64: begin
                        o_i_TX_Byte <= 8'h8F;
                        spi_init_state <= spi_init_state + 1;
                    end
                    65: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    66: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    67: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    //send BF
                    //2)b. MODE[1:0] = 11 for sequencer mode
                    68: begin
                        o_i_Rst_L <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    69: begin
                        o_i_Rst_L <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    70: begin
                        o_i_TX_Byte <= 8'hBF;
                        spi_init_state <= spi_init_state + 1;
                    end
                    71: begin
                        o_i_TX_Dv <= 1;
                        spi_init_state <= spi_init_state + 1;
                    end
                    72: begin
                        o_i_TX_Dv <= 0;
                        spi_init_state <= spi_init_state + 1;
                    end
                    73: begin
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_init_state <= spi_init_state + 1;
                        end
                    end
                    74: begin
                        init_ADC <= 0;
                        spi_init_state <= 0;
                    end
                endcase
            end else if (i_en2) begin
                case (spi_read_state)
                    //send DD000000
                    //read data and write to [31:0] o_ADC_data
                    0: begin
                        o_ADC_data_DV <= 0;
                        o_i_Rst_L <= 0;
                        spi_read_state <= spi_read_state + 1;
                    end
                    1: begin
                        o_i_Rst_L <= 1;
                        spi_read_state <= spi_read_state + 1;
                    end
                    2: begin
                        o_i_TX_Count <= 4;
                        spi_read_state <= spi_read_state + 1;
                    end
                    3: begin
                        o_i_TX_Byte <= 8'hDD;
                        spi_read_state <= spi_read_state + 1;
                    end
                    4: begin
                        o_i_TX_Dv <= 1;
                        spi_read_state <= spi_read_state + 1;
                    end
                    5: begin
                        o_i_TX_Dv <= 0;
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            spi_read_state <= spi_read_state + 1;
                        end
                    end
                    6: begin
                        spi_read_state <= spi_read_state + 1;
                    end
                    7: begin
                        o_i_TX_Byte <= 8'h00;
                        spi_read_state <= spi_read_state + 1;
                    end
                    8: begin
                        o_i_TX_Dv <= 1;
                        spi_read_state <= spi_read_state + 1;
                    end
                    9: begin
                        o_i_TX_Dv <= 0;
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            o_ADC_data = o_ADC_data << 8;
                            spi_read_state <= spi_read_state + 1;
                        end
                    end
                    10: begin
                        o_ADC_data = o_ADC_data | ((rx_byte) & 24'h0000FF);
                        spi_read_state <= spi_read_state + 1;
                    end
                    11: begin
                        o_i_TX_Byte <= 8'h00;
                        spi_read_state <= spi_read_state + 1;
                    end
                    12: begin
                        o_i_TX_Dv <= 1;
                        spi_read_state <= spi_read_state + 1;
                    end
                    13: begin
                        o_i_TX_Dv <= 0;
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            o_ADC_data = o_ADC_data << 8;
                            spi_read_state <= spi_read_state + 1;
                        end
                    end
                    14: begin
                        o_ADC_data = o_ADC_data | ((rx_byte) & 24'h0000FF);
                        spi_read_state <= spi_read_state + 1;
                    end
                    15: begin
                        o_i_TX_Byte <= 8'h00;
                        spi_read_state <= spi_read_state + 1;
                    end
                    16: begin
                        o_i_TX_Dv <= 1;
                        spi_read_state <= spi_read_state + 1;
                    end
                    17: begin
                        o_i_TX_Dv <= 0;
                        if (i_o_Tx_Ready) begin
                            rx_byte <= i_o_Rx_Byte;
                            o_ADC_data = o_ADC_data << 8;
                            spi_read_state <= spi_read_state + 1;
                        end
                    end
                    18: begin
                        o_ADC_data = o_ADC_data | ((rx_byte) & 24'h0000FF);
                        spi_read_state <= spi_read_state + 1;
                    end
                    19: begin
                        o_ADC_data_DV <= 1;
                        spi_read_state <= spi_read_state + 1;
                    end
                    20: begin
                        o_ADC_data_DV <= 0;
                        spi_read_state <= spi_read_state + 1;
                    end
                    21: begin
                        
                    end
                    default: begin
                        
                    end
                endcase
            end
        end
    end
    
endmodule


