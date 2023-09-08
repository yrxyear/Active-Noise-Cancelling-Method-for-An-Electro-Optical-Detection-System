%%

%%%%%%%%%%%%%%%%%
%set up signal
%%%%%%%%%%%%%%%%%

clear
close all
clc
load '20201117(rec23)-Cardiac Measurement Optrode Only (D311).mat';
SNoiseRef = data(datastart(1):datastart(2)-1);
SOptrode = data(dataend(1)+1:dataend(2));

fs = 100000;
t = 1/fs:1/fs:length(SNoiseRef)/fs;

DSOptrode = detrend(SOptrode,2);    %2nd degree polynomial trend
DSNoiseRef = detrend(SNoiseRef,2);
DSOptrode = DSOptrode - (1.5e-3);    %for rec23 D311

figure;
hold on
title('Original signals');
plot(t,SOptrode,'g');
plot(t,SNoiseRef,'r');
legend('SOptrode','SNoiseRef');

figure;
hold on
title('Detrended signals');
plot(t,DSOptrode,'g');
plot(t,DSNoiseRef,'r');
legend('Detrend SOptrode','Detrend SNoiseRef');
%{
figure;
cpsd(DSNoiseRef,DSOptrode)


%PSD of DSNoiseRef
x = DSNoiseRef;
Fs = 100000;
t = 0:1/Fs:1-1/Fs;
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(x):Fs/2;

figure;
plot(freq,10*log10(psdx))
grid on
title('Periodogram of DSNoiseRef Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')

%PSD of DSOptrode
x = DSOptrode;
Fs = 100000;
t = 0:1/Fs:1-1/Fs;
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(x):Fs/2;

figure;
plot(freq,10*log10(psdx))
grid on
title('Periodogram of DSOptrode Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
%}

%%
%%%%%%%%%%%%%%%%
%down sampling by factor of NF
%%%%%%%%%%%%%%%%
NF = 10;
DDSOptrode = movmean(DSOptrode,NF);
DDSOptrode = DDSOptrode(1:NF:end);

DDSNoiseRef = movmean(DSNoiseRef,NF);
DDSNoiseRef = DDSNoiseRef(1:NF:end);

fs = 100000/NF;
t = 1/fs:1/fs:length(DDSNoiseRef)/fs;

figure;
hold on
title('Downsampled Detrended signals');
plot(t,DDSOptrode,'g');
plot(t,DDSNoiseRef,'r');
legend('DDSOptrode','DDSNoiseRef');

%%

%%%%%%%%%%%%%%%%%
%correlation calculation
%%%%%%%%%%%%%%%%%

[c,lags] = xcorr(DSNoiseRef,DSOptrode,10,'normalized');
figure;
stem(lags,c)

[c,lags] = xcorr(DSNoiseRef,DSNoiseRef,10,'normalized');
figure;
stem(lags,c)

%%%%%%%%%%%%%%%%%
%scale does not matter in cross correlation
%%%%%%%%%%%%%%%%%
%{
for i = 0.5:0.1:1.5         
    SDSNoiseRef = i * DSNoiseRef;
    [c,lags] = xcorr(SDSNoiseRef,DSOptrode,0);
    c
end
%}




%%

%%%%%%%%%%%%%%%%%
%1s of signal, estimated signal is estimated noise, residue signal is
%noise+message signal subtract estimated noise
%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%
%shift x1 to the right for Nshift samples
%%%%%%%%%%%%%%%%%
Nshift = 5;
j(1:Nshift) = DDSOptrode(1:Nshift);
DDSOptrode(1:end-Nshift) = DDSOptrode(Nshift+1:end);
DDSOptrode(end-Nshift+1:end) = j(1:Nshift);

framelen = 30000;
y = DDSNoiseRef(220001/NF:(220000+framelen)/NF);      %noise
x = DDSOptrode(220001/NF:(220000+framelen)/NF);       %noise+message
N = 1000;
%[xest,B,MSE] = wienerFilt(x,y,N);
[B,xest] = myWiener(x,y,5,Nshift);

%%%%%%%%%
%plot code from test_wiener
figure;
plot(B);
title('filter coefficients');

figure;
plot(x);
title('Downsampled Detrended Signal');

figure;
plot(y);
title('Downsampled Detrended Noise Ref');

figure;
plot(xest);
title('estimated signal');

figure;
B = B';
plot(x-xest);
title('noise + message signal subtract estimated signal');
%
figure;
plot(xest-y);
title('estimated signal subtract noise signal');
%%%%%%%%%


%%%%%%%%%
%find the best coefficient number by test on fit data
for i = 1:10
    [B,xest] = myWiener(x,y,i,Nshift);
    rms(i) = sqrt(sum((x-xest).^2)/length(x));
end
rms
rmsoriginal = sqrt(sum(x.^2)/length(x));
%%%%%%%%%


%{
%%%%%%%%%
%Fit-Test
y = DDSNoiseRef((220001+framelen)/NF:(220000+2*framelen)/NF);      %noise
x = DDSOptrode((220001+framelen)/NF:(220000+2*framelen)/NF);       %noise+message

for i = 1:10
    %[B,xest] = myWiener(x,y,i,Nshift);
    xest = filter(B,1,x);
    rms(i) = sqrt(sum((x-xest).^2)/length(x));
end
rms
rmsoriginal = sqrt(sum(x.^2)/length(x));

%%%%%%%%%
%}

%plot downsampled signal

fs = 100000 / NF;
t = 1/fs:1/fs:length(x)/fs;

figure;
hold on
title('Downsampled Detrended signals');
plot(t,x,'g');
plot(t,y,'r');
legend('Detrend SOptrode','Detrend SNoiseRef');

%plot undownsampled signal
y = DSNoiseRef(220001:(220000+framelen));      %noise
x = DSOptrode(220001:(220000+framelen));       %noise+message

fs = 100000 ;
t = 1/fs:1/fs:length(x)/fs;

figure;
hold on
title('Undownsampled Detrended signals');
plot(t,x,'g');
plot(t,y,'r');
legend('Detrend SOptrode','Detrend SNoiseRef');

%{
tt = (0:length(x)-1)/10000;

figure
subplot(311)
plot(tt,x,'k'), hold on, plot(tt,y,'r')
title('Wiener filtering example')
legend('noisy signal','reference')
subplot(312)
plot(tt,xest,'k')
legend('estimated signal')
subplot(313)
plot(tt,(x - xest),'k')
legend('residue signal')
xlabel('time (s)')
%}

%{
%PSD of DDSNoiseRef
x = DDSNoiseRef(220001:230000);
Fs = 10000;
t = 0:1/Fs:1-1/Fs;
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(x):Fs/2;

figure;
plot(freq,10*log10(psdx))
grid on
title('Periodogram of DDSNoiseRef Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')

%PSD of xest
x = xest;
Fs = 10000;
t = 0:1/Fs:1-1/Fs;
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(x):Fs/2;

figure;
plot(freq,10*log10(psdx))
grid on
title('Periodogram of xest Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
%}

%%

%%%%%%%%%%%%%%%%%
%simulink input setup
%%%%%%%%%%%%%%%%%

%shift x1 to the right for 5 samples
Nshift = 5;
j(1:Nshift) = DDSOptrode(end-Nshift+1:end);
DDSOptrode(Nshift+1:end) = DDSOptrode(1:end-Nshift);
DDSOptrode(1:Nshift) = j(1:Nshift);

framestart = 220001;
framelen = 20*60000-1;
y = DDSNoiseRef((framestart)/NF:(framestart+framelen)/NF);      %noise
x = DDSOptrode((framestart)/NF:(framestart+framelen)/NF);       %noise+message

%%%%%%%%%
fs = 100000 / NF;
t = 1/fs:1/fs:length(x)/fs;

xsim = timeseries(x,t);
ysim = timeseries(y,t);

%%

%%%%%%%%%%%%%%%%%
%noise+message as reference
%%%%%%%%%%%%%%%%%

%shift x1 to the right for 5 samples
Nshift = 5;
j(1:Nshift) = DDSOptrode(end-Nshift+1:end);
DDSOptrode(Nshift+1:end) = DDSOptrode(1:end-Nshift);
DDSOptrode(1:Nshift) = j(1:Nshift);

framestart = 220001;
framelen = 2*60000-1;
y = DDSNoiseRef((framestart)/NF:(framestart+framelen)/NF);      %noise
x = DDSOptrode((framestart)/NF:(framestart+framelen)/NF);       %noise+message
N = 1000;
%[xest,B,MSE] = wienerFilt(x,y,N);
%[B,xest] = myWiener(y,x,3,Nshift);
[B,xest] = myWiener(y,x,3,Nshift);
% filter twice
%[B,xest] = myWiener(xest,x,3,Nshift);

%
[c,lags] = xcorr(x,y,10,'normalized');
figure;
stem(lags,c)

[c,lags] = xcorr(x-xest,y,10,'normalized');
figure;
stem(lags,c)
%

%%%%%%%%%
%plot code from test_wiener
figure;
plot(B);
title('filter coefficients');

figure;
plot(x);
title('Downsampled Detrended Signal');

figure;
plot(y);
title('Downsampled Detrended Noise Ref');

figure;
plot(x-y);
title('Downsampled Detrended Signal subtract Noise Ref');

figure;
plot(xest);
title('estimated signal (noise only)');

figure;
B = B';
plot(x-xest);
title('noise + message signal subtract estimated signal');
%
figure;
plot(xest(1:end-Nshift)-y(Nshift+1:end));
title('estimated signal subtract noise signal');
%%%%%%%%%
fs = 100000 / NF;
t = 1/fs:1/fs:length(x)/fs;

xsim = timeseries(x,t);
ysim = timeseries(y,t);

figure;
hold on
title('Undownsampled Detrended signals vs estimated signal vs noise + message signal subtract estimated signal');
plot(t,x,'g');
plot(t,xest,'r');
plot(t,x-xest,'b');
plot(t,[0,0,0,0,0,y(1:end-5)],'k');
legend('Detrend SOptrode','Estimated Noise','noise + message signal subtract estimated signal','Detrend SNoiseRef');

%%%%%%%%%
%find the best coefficient number by test on fit data
x2 = DDSOptrode((framestart+framelen)/NF:(framestart+framelen+framelen)/NF);       %noise+message
for i = 1:10
%test
    [B,xest] = myWiener(y,x,i,Nshift);
    xsq = (x-xest);
    %{
    for j = 1:length(xsq)
        if xsq(j) > 0.002
            xsq(j) = 0;
        elseif xsq(j) < -0.003
            xsq(j) = 0;
        end
    end
    %}
    %xsq = xsq.^2;
    rms(i) = rmscalc(xsq(3200:4600));
%fit
    xest2 = filter(B,1,x2);
    xsq2 = (x2-xest2);
    %{
    for k = 1:length(xsq2)
        if xsq2(k) > 0.002
            xsq2(k) = 0;
        elseif xsq2(k) < -0.003
            xsq2(k) = 0;
        end
    end
    %}
    %xsq2 = xsq2.^2;
    rms2(i) = rmscalc(xsq2(3200:4600));
end
rms
rms2

%original rms
xsqo = (x);
%{
for k = 1:length(xsqo)
    if xsqo(k) > 0.002
        xsqo(k) = 0;
    elseif xsqo(k) < -0.003
        xsqo(k) = 0;
    end
end
%}
%xsqo = xsqo.^2;
rmsoriginal = rmscalc(xsqo(3200:4600))

%original rms for x2
xsqo2 = (x2);
%{
for k = 1:length(xsqo2)
    if xsqo2(k) > 0.002
        xsqo2(k) = 0;
    elseif xsqo2(k) < -0.003
        xsqo2(k) = 0;
    end
end
%}
%xsqo2 = xsqo2.^2;
rmsoriginal2 = rmscalc(xsqo2(3200:4600))
%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%
%scale the filter coefficient
%%%%%%%%%%%%%%%%%%%%%%%

[B,xest] = myWiener(y,x,3,Nshift);
for i = 1:10
    B = B.*(0.5+i/10);
    xest = filter(B,1,x);
    xsq = x - xest;
    rms(i) = rmscalc(xsq(3200:4600));
end
rms

%%


%{
% Demo on Wiener filter based on Wiener-Hopf equations
%   This demo shows how Wiener filtering works for recovering the reference signal
%   from a noisy measured signal
%
% M. Buzzoni
% May 2019

clear
close all
clc

[S, Fs] = audioread("Sample_4.wav");
for i = 1:3*Fs
    Sample(i) = S(i+9*Fs);
end

Ls = length(Sample);
Noise = 1:Ls;
Noise = Noise';
for i = 1:Ls
    Noise(i) = 0;
end
Wnoise = awgn(Noise,10);
for i = 1:10
    Nsample(i) = Sample(i);
end
for i = 10:Ls
    Nsample(i) = Sample(i) + Wnoise(i-9);
end
%
figure;
plot(Noise)
figure;
plot(Wnoise)
figure
plot(Sample)
figure
plot(Nsample)
%
%}

%%
%{
Fs = 100000;
Ls = length(DSNoiseRef);
y = DSNoiseRef;  %sample
x = DSOptrode;   %sample&noise

%fs = 4000; % sampling frequency
T = Ls/Fs;% total recording time
L = T .* Fs; % signal length
tt = (0:Ls-1)/Fs; % time vector
ff = (0:Ls-1)*Fs/L;
%y = sin(2*pi*120 .* tt); y = y(:); % reference sinusoid
%x = 0.50*randn(L,1) + y; x = x(:); % sinusoiud with additive Gaussian noise
N = 200; % filter order
%}

%%
%{
[xest,b,MSE] = wienerFilt(x,y,N);
% plot results
figure
subplot(311)
plot(tt,x,'k'), hold on, plot(tt,y,'r')
title('Wiener filtering example')
legend('noisy signal','reference')
subplot(312)
plot(tt(N+1:end),xest,'k')
legend('estimated signal')
subplot(313)
plot(tt(N+1:end),(x(N+1:end) - xest),'k')
legend('residue signal')
xlabel('time (s)')
%audiowrite('EstSample.wav',xest,Fs);
%audiowrite('NoisySample.wav',Nsample,Fs);

[c,lags] = xcorr(DSNoiseRef(1:6294800),xest,400,'normalized');
figure;
stem(lags,c)
%}