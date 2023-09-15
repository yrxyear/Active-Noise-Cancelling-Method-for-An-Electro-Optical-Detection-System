str = 'ADC.TXT';


fileID = fopen(str,'r');
[Q,COUNT] = fread(fileID);
fclose(fileID);
count = floor(COUNT/4);

fileID = fopen(str,'r');
FirstDataZero = fread(fileID,1,'uint32');
SecDataZero = fread(fileID,1,'uint32');
ADC_1_24b = zeros(count/2-1,1);
ADC_2_24b = zeros(count/2-1,1);
ADC_1 = zeros(count/2-1,1);
ADC_2 = zeros(count/2-1,1);
z1 = zeros(count/2-1,1);
z2 = zeros(count/2-1,1);
for i = 1:(count/2-1)
    %ADC_1_24b(i) = fread(fileID,1,'bit24'); %DSP
    ADC_1_24b(i) = fread(fileID,1,'ubit24'); %two channel direct
    z1(i) = fread(fileID,1,'uint8');
    %ADC_1_24b(i) = fread(fileID,1,'uint32');
    ADC_1(i) = ADC_1_24b(i)/(2^24)*3.2;

    %ADC_2_24b(i) = fread(fileID,1,'ubit24');
    ADC_2_24b(i) = fread(fileID,1,'bit24'); %DSP
    z2(i) = fread(fileID,1,'uint8');
    %ADC_2_24b(i) = fread(fileID,1,'uint32');
    ADC_2(i) = ADC_2_24b(i)/(2^24)*3.2;
end
fclose(fileID);

x = 1/64140:1/64140:(count/2-1)/64140;

figure;
grid on;
hold on;
plot(x,ADC_1-2.135,"r");
plot(x,ADC_2,"g");
xlabel('Time (s)');
ylabel('Voltage (V)');
title("ADC Channels");
legend('Channel_1 (AC coupled)', 'DSP');
DSP_rms = rms(ADC_2(64000:2*64000))
CH1_rms = rms((ADC_1(64000:2*64000)-2.135))
