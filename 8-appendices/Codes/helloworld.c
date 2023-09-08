/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xparameters.h"
#include "ff.h"

#define DIGIPOT_W0_READ_MASK  			0x0FFF		//pot2 & pot0 for second stage amp, 100-140dB at 1k-100kohm
#define DIGIPOT_W0_WRITE_140dB_MASK  	0x0000		//140dB->0x00	stage 2 gain reduces
#define DIGIPOT_W0_WRITE_130dB_MASK  	0x00AF		//130dB->0xAF
#define DIGIPOT_W0_WRITE_120dB_MASK  	0x00E6		//120dB->0xE6
#define DIGIPOT_W0_WRITE_110dB_MASK  	0x00F8		//110dB->0xF8
#define DIGIPOT_W0_WRITE_100dB_MASK  	0x00FD		//100dB->0xFD

#define DIGIPOT_W1_READ_MASK  			0x1FFF		//pot3 & pot1 for first stage amp, 100-140dB at 100kohm
#define DIGIPOT_W1_WRITE_140dB_MASK  	0x1000		//140dB->0x00	stage 1 stays max gain
#define DIGIPOT_W1_WRITE_130dB_MASK  	0x1000		//130dB->0x00
#define DIGIPOT_W1_WRITE_120dB_MASK  	0x1000		//120dB->0x00
#define DIGIPOT_W1_WRITE_110dB_MASK  	0x1000		//110dB->0x00
#define DIGIPOT_W1_WRITE_100dB_MASK  	0x1000		//100dB->0x00

#define DIGIPOT_W2_READ_MASK  			0x6FFF		//pot2 & pot0 for second stage amp, 100-140dB at 1k-100kohm
#define DIGIPOT_W2_WRITE_140dB_MASK  	0x6000		//140dB->0x00	stage 2 gain reduces
#define DIGIPOT_W2_WRITE_130dB_MASK  	0x60AF		//130dB->0xAF
#define DIGIPOT_W2_WRITE_120dB_MASK  	0x60E6		//120dB->0xE6
#define DIGIPOT_W2_WRITE_110dB_MASK  	0x60F8		//110dB->0xF8
#define DIGIPOT_W2_WRITE_100dB_MASK  	0x60FD		//100dB->0xFD

#define DIGIPOT_W3_READ_MASK  			0x7FFF		//pot3 & pot1 for first stage amp, 100-140dB at 100kohm
#define DIGIPOT_W3_WRITE_140dB_MASK  	0x7000		//140dB->0x00	stage 1 stays max gain
#define DIGIPOT_W3_WRITE_130dB_MASK  	0x7000		//130dB->0x00
#define DIGIPOT_W3_WRITE_120dB_MASK  	0x7000		//120dB->0x00
#define DIGIPOT_W3_WRITE_110dB_MASK  	0x7000		//110dB->0x00
#define DIGIPOT_W3_WRITE_100dB_MASK  	0x7000		//100dB->0x00

//fatfs openfile mode
#define	FA_READ				0x01
#define	FA_WRITE			0x02
#define	FA_OPEN_EXISTING	0x00
#define	FA_CREATE_NEW		0x04
#define	FA_CREATE_ALWAYS	0x08
#define	FA_OPEN_ALWAYS		0x10
#define	FA_OPEN_APPEND		0x30

//sdcard test
FATFS  fatfs;
static int SD_Init();
static int SD_Eject();
static int ReadFile(char *FileName, u32 DestinationAddress);
static int WriteFile(char *FileName, u32 size, u32 SourceAddress, BYTE open_mode);
#define inputImageWidth 512
#define inputImageHeight 512
char imageBuffer[inputImageWidth*inputImageHeight*3];
//

void wait_clk_cycles(int cycles, uint clk);
u32 SPI_DigiPot(u32 Input, int Byte_num);
u32 gain_set(int digipot_buffer, int digipot_channel);
u32 SPI_ADC_1(u32 Input, int Byte_num);
u32 SPI_ADC_2(u32 Input, int Byte_num);

XGpio 	ADC_sync_out,
		//ADC1
		ADC1_i_rst_out,
		ADC1_i_en1_out,
		ADC1_i_en2_out,
		ADC1_data_ready_in,
		ADC1_data_out_24_in,
		ADC1_read_start_out,
		ADC1_reset_out,
		//ADC2
		ADC2_i_rst_out,
		ADC2_i_en1_out,
		ADC2_i_en2_out,
		ADC2_data_ready_in,
		ADC2_data_out_24_in,
		ADC2_read_start_out,
		ADC2_reset_out,
		//DIGIPOT
		DIGIPOT_o_RX_Byte_8_in,
		DIGIPOT_i_TX_Byte_8_out,
		DIGIPOT_o_TX_Ready_in,
		DIGIPOT_o_RX_count_2_in,
		DIGIPOT_o_RX_DV_in,
		DIGIPOT_i_Rst_L_out,
		DIGIPOT_i_TX_Count_2_out,
		DIGIPOT_i_TX_DV_out,
		//GPIO
		led_4_out,
		led4_3_out,
		led5_3_out,
		clk_out1_in,
		btn_4_in,
		sw_2_in,
		test_1_out;

uint clk_addr = &clk_out1_in;

int main()
{
    init_platform();

    XGpio_Initialize(&ADC_sync_out, XPAR_AXI_GPIO_34_DEVICE_ID);

    //ADC1
    XGpio_Initialize(&ADC2_i_rst_out, XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_Initialize(&ADC2_i_en1_out, XPAR_AXI_GPIO_1_DEVICE_ID);
    XGpio_Initialize(&ADC2_i_en2_out, XPAR_AXI_GPIO_2_DEVICE_ID);
    XGpio_Initialize(&ADC2_data_ready_in, XPAR_AXI_GPIO_3_DEVICE_ID);
    XGpio_Initialize(&ADC2_data_out_24_in, XPAR_AXI_GPIO_4_DEVICE_ID);
    XGpio_Initialize(&ADC2_read_start_out, XPAR_AXI_GPIO_5_DEVICE_ID);
    XGpio_Initialize(&ADC2_reset_out, XPAR_AXI_GPIO_32_DEVICE_ID);

    XGpio_Initialize(&test_1_out, XPAR_AXI_GPIO_30_DEVICE_ID);

    //ADC2
    XGpio_Initialize(&ADC1_i_rst_out, XPAR_AXI_GPIO_20_DEVICE_ID);
    XGpio_Initialize(&ADC1_i_en1_out, XPAR_AXI_GPIO_21_DEVICE_ID);
    XGpio_Initialize(&ADC1_i_en2_out, XPAR_AXI_GPIO_22_DEVICE_ID);
    XGpio_Initialize(&ADC1_data_ready_in, XPAR_AXI_GPIO_23_DEVICE_ID);
    XGpio_Initialize(&ADC1_data_out_24_in, XPAR_AXI_GPIO_24_DEVICE_ID);
    XGpio_Initialize(&ADC1_read_start_out, XPAR_AXI_GPIO_25_DEVICE_ID);
    XGpio_Initialize(&ADC1_reset_out, XPAR_AXI_GPIO_33_DEVICE_ID);

    XGpio_Initialize(&DIGIPOT_o_RX_Byte_8_in, XPAR_AXI_GPIO_12_DEVICE_ID);	//DIGIPOT
    XGpio_Initialize(&DIGIPOT_i_TX_Byte_8_out, XPAR_AXI_GPIO_13_DEVICE_ID);
    XGpio_Initialize(&DIGIPOT_o_TX_Ready_in, XPAR_AXI_GPIO_14_DEVICE_ID);
    XGpio_Initialize(&DIGIPOT_o_RX_count_2_in, XPAR_AXI_GPIO_15_DEVICE_ID);
    XGpio_Initialize(&DIGIPOT_o_RX_DV_in, XPAR_AXI_GPIO_16_DEVICE_ID);
    XGpio_Initialize(&DIGIPOT_i_Rst_L_out, XPAR_AXI_GPIO_17_DEVICE_ID);
    XGpio_Initialize(&DIGIPOT_i_TX_Count_2_out, XPAR_AXI_GPIO_18_DEVICE_ID);
    XGpio_Initialize(&DIGIPOT_i_TX_DV_out, XPAR_AXI_GPIO_19_DEVICE_ID);

    XGpio_Initialize(&led_4_out, XPAR_AXI_GPIO_8_DEVICE_ID);		//gpio
    XGpio_Initialize(&led4_3_out, XPAR_AXI_GPIO_9_DEVICE_ID);
    XGpio_Initialize(&led5_3_out, XPAR_AXI_GPIO_28_DEVICE_ID);
    XGpio_Initialize(&clk_out1_in, XPAR_AXI_GPIO_10_DEVICE_ID);
    XGpio_Initialize(&btn_4_in, XPAR_AXI_GPIO_11_DEVICE_ID);
    XGpio_Initialize(&sw_2_in, XPAR_AXI_GPIO_29_DEVICE_ID);


    XGpio_SetDataDirection(&ADC_sync_out, 1, 0);

    //ADC1
    XGpio_SetDataDirection(&ADC1_i_rst_out, 1, 0);
    XGpio_SetDataDirection(&ADC1_i_en1_out, 1, 0);
    XGpio_SetDataDirection(&ADC1_i_en2_out, 1, 0);
    XGpio_SetDataDirection(&ADC1_data_ready_in, 1, 1);
    XGpio_SetDataDirection(&ADC1_data_out_24_in, 1, 1);
    XGpio_SetDataDirection(&ADC1_read_start_out, 1, 0);
    XGpio_SetDataDirection(&ADC1_reset_out, 1, 0);

    XGpio_SetDataDirection(&test_1_out, 1, 0);

    //ADC2
    XGpio_SetDataDirection(&ADC2_i_rst_out, 1, 0);
    XGpio_SetDataDirection(&ADC2_i_en1_out, 1, 0);
    XGpio_SetDataDirection(&ADC2_i_en2_out, 1, 0);
    XGpio_SetDataDirection(&ADC2_data_ready_in, 1, 1);
    XGpio_SetDataDirection(&ADC2_data_out_24_in, 1, 1);
    XGpio_SetDataDirection(&ADC2_read_start_out, 1, 0);
    XGpio_SetDataDirection(&ADC2_reset_out, 1, 0);

    //DIGIPOT
    XGpio_SetDataDirection(&DIGIPOT_o_RX_Byte_8_in, 1, 1);
    XGpio_SetDataDirection(&DIGIPOT_i_TX_Byte_8_out, 1, 0);
    XGpio_SetDataDirection(&DIGIPOT_o_TX_Ready_in, 1, 1);
    XGpio_SetDataDirection(&DIGIPOT_o_RX_count_2_in, 1, 1);
    XGpio_SetDataDirection(&DIGIPOT_o_RX_DV_in, 1, 1);
    XGpio_SetDataDirection(&DIGIPOT_i_Rst_L_out, 1, 0);
    XGpio_SetDataDirection(&DIGIPOT_i_TX_Count_2_out, 1, 0);
    XGpio_SetDataDirection(&DIGIPOT_i_TX_DV_out, 1, 0);

    //gpio
    XGpio_SetDataDirection(&led_4_out, 1, 0);
    XGpio_SetDataDirection(&led4_3_out, 1, 0);
    XGpio_SetDataDirection(&led5_3_out, 1, 0);
    XGpio_SetDataDirection(&clk_out1_in, 1, 1);
    XGpio_SetDataDirection(&btn_4_in, 1, 1);
    XGpio_SetDataDirection(&sw_2_in, 1, 1);

    print("Successfully ran project 6 application\n\r");

    int sw_0_a = 0;
    int sw_0_b = 0;
    int sw_1_a = 0;
    int sw_1_b = 0;
    int sw_1_w = 0;
    int btn_0_a = 0;
    int btn_0_b = 0;
    int btn_1_a = 0;
    int btn_1_b = 0;
    int digipot_buffer = 1;
    int digipot_buffer_1 = 1;
    u32 data_s;
    u32 data_r;
    u32 data_r_ADC1;
    u32 data_r_ADC2;
    char buff_ADC_1[8] = {'0', '0', '0', '0', '0', '0', '0', '0'};
    char buff_ADC_2[8] = {'0', '0', '0', '0', '0', '0', '0', '0'};
    u32 led4;
    int counter = 0;
    int digipot_channel;
    int file_counter = 0;
    char file_name[16];
    int Status;
    UINT bw;
    static FIL fil; // File instance
    FRESULT rc; // FRESULT variable
    u32 ADC_buffer[32];
    int i;
    int j;


    while(1)
    {
    	//set all button&switch flags
    	sw_1_b = sw_1_a;
    	sw_0_b = sw_0_a;
    	btn_0_b = btn_0_a;
    	btn_1_b = btn_1_a;

    	//read all button&switch
    	sw_0_a = XGpio_DiscreteRead(&sw_2_in, 1);
    	sw_0_a = (sw_0_a >> 0) & 0b1;	//sw_0_a = sw0

    	sw_1_a = XGpio_DiscreteRead(&sw_2_in, 1);
    	sw_1_a = (sw_1_a >> 1) & 0b1;	//sw_1_a = sw1

    	btn_0_a = XGpio_DiscreteRead(&btn_4_in, 1);
    	btn_0_a = (btn_0_a >> 0) & 0b1;	//btn_0_a = btn0

    	btn_1_a = XGpio_DiscreteRead(&btn_4_in, 1);
    	btn_1_a = (btn_1_a >> 1) & 0b1;	//btn_1_a = btn1

    	//if btn_0 pressed, increase digipot_buffer and change light
    	if(btn_1_a == 1 && btn_1_b == 0){
    		if(digipot_buffer < 4){
    			digipot_buffer++;
    		}
        	switch(digipot_buffer){
        		case 1:
            		XGpio_DiscreteWrite(&led_4_out, 1, 0b0001);
            		xil_printf("LED: 0001\n\r");
            		break;
        		case 2:
            		XGpio_DiscreteWrite(&led_4_out, 1, 0b0011);
            		xil_printf("LED: 0011\n\r");
            		break;
        		case 3:
            		XGpio_DiscreteWrite(&led_4_out, 1, 0b0111);
            		xil_printf("LED: 0111\n\r");
            		break;
        		case 4:
            		XGpio_DiscreteWrite(&led_4_out, 1, 0b1111);
            		xil_printf("LED: 1111\n\r");
            		break;
        	}
    	}

    	//if btn_1 pressed, increase digipot_buffer and change light
    	if(btn_0_a == 1 && btn_0_b == 0){
    		if(digipot_buffer > 1){
    			digipot_buffer--;
    		}
        	switch(digipot_buffer){
        		case 1:
            		XGpio_DiscreteWrite(&led_4_out, 1, 0b0001);
            		xil_printf("LED: 0001\n\r");
            		break;
        		case 2:
            		XGpio_DiscreteWrite(&led_4_out, 1, 0b0011);
            		xil_printf("LED: 0011\n\r");
            		break;
        		case 3:
            		XGpio_DiscreteWrite(&led_4_out, 1, 0b0111);
            		xil_printf("LED: 0111\n\r");
            		break;
        		case 4:
            		XGpio_DiscreteWrite(&led_4_out, 1, 0b1111);
            		xil_printf("LED: 1111\n\r");
            		break;
        	}
    	}


    	//when sw0 is 0, don't update digipot gain, show not updated as red light on led4
    	//when sw0 is 1, update digipot gain
    	if(sw_0_a == 0){
    		if(digipot_buffer != digipot_buffer_1){
    			XGpio_DiscreteWrite(&led4_3_out, 1, 0b100);
    		}else{
    			XGpio_DiscreteWrite(&led4_3_out, 1, 0b010);
    		}
    		if(sw_0_b == 1){
    			data_r = SPI_DigiPot(DIGIPOT_W0_READ_MASK, 2);
    			xil_printf("W0_READ: %x\n\r", data_r);
    			data_r = SPI_DigiPot(DIGIPOT_W1_READ_MASK, 2);
    			xil_printf("W1_READ: %x\n\r", data_r);
    			data_r = SPI_DigiPot(DIGIPOT_W2_READ_MASK, 2);
    			xil_printf("W2_READ: %x\n\r", data_r);
    			data_r = SPI_DigiPot(DIGIPOT_W3_READ_MASK, 2);
    			xil_printf("W3_READ: %x\n\r", data_r);
    		}
    	}else if(sw_0_a == 1){
    		if(digipot_buffer != digipot_buffer_1){
    			for(j = 0; j < 4; j++){
					digipot_channel = j;
					data_s = gain_set(digipot_buffer, digipot_channel);
					xil_printf("Sending: %x\n\r", data_s);
					data_r = SPI_DigiPot(data_s, 2);
    			}
    			digipot_buffer_1 = digipot_buffer;
    			XGpio_DiscreteWrite(&led4_3_out, 1, 0b010);
        		xil_printf("Gain set for 1%d0dB\n\r", digipot_buffer);
    		}else{
    			XGpio_DiscreteWrite(&led4_3_out, 1, 0b010);
    		}
    	}

    	//when turn on sw1, reset the ADCs
    	//when sw1 is on, keep reading ADCs and update status on led5
    	//when sw1 is off, stop reading ADCs
    	if(sw_1_a == 1 && sw_1_b == 0){	//when sw1 is being turned on
    		XGpio_DiscreteWrite(&ADC1_reset_out, 1, 0b0);
    		XGpio_DiscreteWrite(&ADC2_reset_out, 1, 0b0);
    		wait_clk_cycles(10, clk_addr);
    		XGpio_DiscreteWrite(&ADC1_reset_out, 1, 0b1);
    		XGpio_DiscreteWrite(&ADC2_reset_out, 1, 0b1);
    		wait_clk_cycles(10, clk_addr);

    		//Initialize SDcard
    		int Status;
    		Status = SD_Init();
    		if (Status != XST_SUCCESS) {
    			print("file system init failed\n\r");
    			return XST_FAILURE;
    		}
    		file_counter++;
    		//file_name = strcat((char)file_counter, "_ADC_output.txt");
    		strcpy(file_name, "ADC_outputs.txt");
    		//Status = WriteFile(file_name, 3, 0xFFF, FA_CREATE_NEW);
    		/////////////////////

    		rc = f_open(&fil, "ADC.txt", FA_CREATE_ALWAYS | FA_WRITE); //f_open
    		if (rc) {
    			xil_printf(" ERROR : f_open returned %d\r\n", rc);
    			return XST_FAILURE;
    		}
    		print("Start reading\n\r");
    		///////////////////////////

    		XGpio_DiscreteWrite(&ADC1_i_rst_out, 1, 0b1);
    		XGpio_DiscreteWrite(&ADC2_i_rst_out, 1, 0b1);
    		XGpio_DiscreteWrite(&ADC1_i_rst_out, 1, 0b0);
    		XGpio_DiscreteWrite(&ADC2_i_rst_out, 1, 0b0);
    		//Initialize ADCs
    		XGpio_DiscreteWrite(&ADC1_i_en1_out, 1, 0b1);
    		XGpio_DiscreteWrite(&ADC2_i_en1_out, 1, 0b1);
    		counter = 0;
    		wait_clk_cycles(1, clk_addr);
    		XGpio_DiscreteWrite(&led5_3_out, 1, 0b010);
    		XGpio_DiscreteWrite(&ADC1_i_en1_out, 1, 0b0);
    		XGpio_DiscreteWrite(&ADC2_i_en1_out, 1, 0b0);

    		wait_clk_cycles(100, clk_addr);

    		XGpio_DiscreteWrite(&ADC2_i_en2_out, 1, 0b1);
    		XGpio_DiscreteWrite(&ADC1_i_en2_out, 1, 0b1);

    	}else if(sw_1_a == 1 && sw_1_b == 1){
    		while(XGpio_DiscreteRead(&sw_2_in, 1) > 1){
    			if(XGpio_DiscreteRead(&ADC1_data_ready_in, 1) && XGpio_DiscreteRead(&ADC2_data_ready_in, 1)){
    				XGpio_DiscreteWrite(&test_1_out, 1, 0b1);
    				XGpio_DiscreteWrite(&ADC1_read_start_out, 1, 0b1);
    				XGpio_DiscreteWrite(&ADC2_read_start_out, 1, 0b1);
    				XGpio_DiscreteWrite(&ADC1_read_start_out, 1, 0b0);
    				XGpio_DiscreteWrite(&ADC2_read_start_out, 1, 0b0);
    				data_r_ADC1 = XGpio_DiscreteRead(&ADC1_data_out_24_in, 1);
    				data_r_ADC2 = XGpio_DiscreteRead(&ADC2_data_out_24_in, 1);
    				//write data to file
    				rc = f_write(&fil,&data_r_ADC1,4,&bw);
    				rc = f_write(&fil,&data_r_ADC2,4,&bw);
    				XGpio_DiscreteWrite(&test_1_out, 1, 0b0);
    			}
    		}
    	}else if(sw_1_a == 0 && sw_1_b == 1){	//when sw1 is off
    		XGpio_DiscreteWrite(&ADC2_i_en2_out, 1, 0b0);
    		XGpio_DiscreteWrite(&ADC1_i_en2_out, 1, 0b0);
    		XGpio_DiscreteWrite(&led5_3_out, 1, 0b100);

    		rc = f_close(&fil);
    		if (rc) {
    			xil_printf(" ERROR : f_close returned %d\r\n", rc);
    			return XST_FAILURE;
    		}

    		Status=SD_Eject();
    	    if (Status != XST_SUCCESS) {
    	    print("SD card unmount failed\n\r");
    	    	return XST_FAILURE;
    	    }
    	    xil_printf("done...\n\r");
    	}

    }

    cleanup_platform();
    return 0;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

u32 gain_set(int digipot_buffer, int digipot_channel){
	u32 gain;
	switch(digipot_channel){
		case 0:
			switch(digipot_buffer){
				case 1:
					gain = 0xFFFF & DIGIPOT_W0_WRITE_110dB_MASK;
            		break;
				case 2:
					gain = 0xFFFF & DIGIPOT_W0_WRITE_120dB_MASK;
            		break;
				case 3:
					gain = 0xFFFF & DIGIPOT_W0_WRITE_130dB_MASK;
            		break;
				case 4:
					gain = 0xFFFF & DIGIPOT_W0_WRITE_140dB_MASK;
            		break;
			}
    		break;
		case 1:
			switch(digipot_buffer){
				case 1:
					gain = 0xFFFF & DIGIPOT_W1_WRITE_110dB_MASK;
            		break;
				case 2:
					gain = 0xFFFF & DIGIPOT_W1_WRITE_120dB_MASK;
            		break;
				case 3:
					gain = 0xFFFF & DIGIPOT_W1_WRITE_130dB_MASK;
            		break;
				case 4:
					gain = 0xFFFF & DIGIPOT_W1_WRITE_140dB_MASK;
            		break;
			}
    		break;
		case 2:
			switch(digipot_buffer){
				case 1:
					gain = 0xFFFF & DIGIPOT_W2_WRITE_110dB_MASK;
            		break;
				case 2:
					gain = 0xFFFF & DIGIPOT_W2_WRITE_120dB_MASK;
            		break;
				case 3:
					gain = 0xFFFF & DIGIPOT_W2_WRITE_130dB_MASK;
            		break;
				case 4:
					gain = 0xFFFF & DIGIPOT_W2_WRITE_140dB_MASK;
            		break;
			}
    		break;
		case 3:
			switch(digipot_buffer){
				case 1:
					gain = 0xFFFF & DIGIPOT_W3_WRITE_110dB_MASK;
            		break;
				case 2:
					gain = 0xFFFF & DIGIPOT_W3_WRITE_120dB_MASK;
            		break;
				case 3:
					gain = 0xFFFF & DIGIPOT_W3_WRITE_130dB_MASK;
            		break;
				case 4:
					gain = 0xFFFF & DIGIPOT_W3_WRITE_140dB_MASK;
            		break;
			}
    		break;
		default:
			xil_printf("Digipot_buffer error\n");
    		break;
	}
	return gain;
}

u32 SPI_DigiPot(u32 Input, int Byte_num){
	u32 Send[Byte_num];
	u32 Receive[Byte_num];
	u32 dataRx;

	XGpio_DiscreteWrite(&DIGIPOT_i_Rst_L_out, 1, 0b0);
	wait_clk_cycles(2, clk_addr);
	XGpio_DiscreteWrite(&DIGIPOT_i_Rst_L_out, 1, 0b1);
	wait_clk_cycles(2, clk_addr);
	XGpio_DiscreteWrite(&DIGIPOT_i_TX_Count_2_out, 1, Byte_num);
	wait_clk_cycles(2, clk_addr);

	for(int i = 0; i < Byte_num; i++){
		Send[i] = (Input >> (8 * (Byte_num - i - 1))) & 0xFF;
	}

	for(int i = 0; i < Byte_num; i++){
		XGpio_DiscreteWrite(&DIGIPOT_i_TX_Byte_8_out, 1, Send[i]);
		wait_clk_cycles(2, clk_addr);
		XGpio_DiscreteWrite(&DIGIPOT_i_TX_DV_out, 1, 0b1);
		wait_clk_cycles(2, clk_addr);
		XGpio_DiscreteWrite(&DIGIPOT_i_TX_DV_out, 1, 0b0);
		wait_clk_cycles(2, clk_addr);
		while(!XGpio_DiscreteRead(&DIGIPOT_o_TX_Ready_in, 1)){}
		Receive[i] = XGpio_DiscreteRead(&DIGIPOT_o_RX_Byte_8_in, 1);
	}

	for(int i = 0; i < Byte_num; i++){
		if(Receive[i] == 0){
			xil_printf("00");
		}else{
			xil_printf("%x", Receive[i]);
		}
		dataRx = dataRx << 8;
		dataRx = dataRx | ((Receive[i]) & 0xFF);
	}
	xil_printf("\n\r");
	return dataRx;
}

//wait for cycles number of clock cycles
void wait_clk_cycles(int cycles, uint clk)
{
	for(int i = 0; i < cycles; i++){
		while(XGpio_DiscreteRead(clk, 1)){}
		while(!XGpio_DiscreteRead(clk, 1)){}
	}
}

static int SD_Init()
{
	FRESULT rc;
	TCHAR *Path = "0:/";
	rc = f_mount(&fatfs,Path,0);
	if (rc) {
		xil_printf(" ERROR : f_mount returned %d\r\n", rc);
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

static int SD_Eject()
{
	FRESULT rc;
	TCHAR *Path = "0:/";
	rc = f_mount(&fatfs,Path,1);
	if (rc) {
		xil_printf(" ERROR : f_mount returned %d\r\n", rc);
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}



static int ReadFile(char *FileName, u32 DestinationAddress)
{
	FIL fil;
	FRESULT rc;
	UINT br;
	u32 file_size;
	rc = f_open(&fil, FileName, FA_READ);
	if (rc) {
		xil_printf(" ERROR : f_open returned %d\r\n", rc);
		return XST_FAILURE;
	}
	file_size = fil.obj.objsize;
	rc = f_lseek(&fil, 0);
	if (rc) {
		xil_printf(" ERROR : f_lseek returned %d\r\n", rc);
		return XST_FAILURE;
	}
	rc = f_read(&fil, (void*) DestinationAddress, file_size, &br);
	if (rc) {
		xil_printf(" ERROR : f_read returned %d\r\n", rc);
		return XST_FAILURE;
	}
	rc = f_close(&fil);
	if (rc) {
		xil_printf(" ERROR : f_close returned %d\r\n", rc);
		return XST_FAILURE;
	}
	Xil_DCacheFlush();
	return XST_SUCCESS;
}

static int WriteFile(char *FileName, u32 size, u32 SourceAddress, BYTE open_mode){
	UINT bw;
	static FIL fil; // File instance
	FRESULT rc; // FRESULT variable
	rc = f_open(&fil, (char *)FileName, open_mode | FA_WRITE); //f_open
	if (rc) {
		xil_printf(" ERROR : f_open returned %d\r\n", rc);
		return XST_FAILURE;
	}
	rc = f_write(&fil,(const void*)SourceAddress,size,&bw);
	if (rc) {
		xil_printf(" ERROR : f_write returned %d\r\n", rc);
		return XST_FAILURE;
	}
	rc = f_close(&fil);
	if (rc) {
		xil_printf(" ERROR : f_close returned %d\r\n", rc);
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}
