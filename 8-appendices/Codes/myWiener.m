function [FilterVector,xest] = myWiener(x,y,N,NS)
%
% Wiener filter based on Wiener-Hopf equations
%   This function takes as inputs a noisy signal, x, and a reference signal, y,
%   in order to compute a N-order linear filter that provides an estimate of y
%   from x
%  
% INPUTS
% x = noise + message signal
% y = noise signal
% N = filter order
% Ns = filter shift
%
% OUTPUTS
% xest = estimated signal
% b = Wiener filter coefficents
% MSE = mean squared error
%
% M. Buzzoni
% May 2019
% -------------
% Rev. Feb. 2020: the function can be performed by using column or row
% vectors as inputs

%{  
    %original code
%X = 1/N .* fft(x(1:N));
%Y = 1/N .* fft(y(1:N));
%X = X(:);
%Y = Y(:);

Rxx = N .* real(ifft(X .* conj(X))); % Autocorrelation function            %probably cross PSD
Rxy = N .* real(ifft(X .* conj(Y))); % Crosscorrelation function
Rxx = toeplitz(Rxx);
Rxy = Rxy';
B = Rxy / Rxx; B = B(:); % Wiener-Hopf eq. B = inv(Rxx) Rxy
xest = fftfilt(B,x);
xest = xest(N+1:end); % cut first N samples due to distorsion during filtering operation
MSE = mean(y(N+1:end) - xest) .^2; % mean squared error
%}

%
% Autocorrelation function
for i = 1:length(x)
    Rxx(i) = 0;
    for j = 1:length(x)
        if i + j <= (length(x) + 1)
            Rxx(i) = Rxx(i) + x(j) * x(j+i-1);
        else
            Rxx(i) = Rxx(i) + x(j) * x(j+i-length(x)-1);
        end
    end
end
% Crosscorrelation function
for i = 1:length(x)
    Rxy(i) = 0;
    for j = 1:length(x)
        if i + j <= (length(x) + 1)
            Rxy(i) = Rxy(i) + x(j) * y(j+i-1);
        else
            Rxy(i) = Rxy(i) + x(j) * y(j+i-length(x)-1);
        end
    end
end
%

%{
N = length(x);
X = 1/N .* fft(x);
Y = 1/N .* fft(y);
Rxx = N .* real(ifft(X .* conj(X))); % Autocorrelation function
Rxy = N .* real(ifft(X .* conj(Y))); % Crosscorrelation function
%}

Rxx = toeplitz(Rxx);
%%%%%%%%% limit the matrix size to number of coefficients
%Rxx = Rxx(1:(NS+N), 1:(NS+N));
%Rxy = Rxy(1:(NS+N));
%%%%%%%%%
Rxy = Rxy';
B = Rxx \ Rxy;
%B = B';
%xest = fftfilt(B(1:4000),x);
%xest = filter(B(1:N),[1,0,0,0,0],x);

% Create filter window centered at 1
FilterVector = zeros(1,NS-floor(N/2));
WorkingFilter = (B(NS+1-floor(N/2):NS+1-floor(N/2)+N-1))';
FilterVector = cat(2, FilterVector, WorkingFilter);

xest = filter(FilterVector,1,x);

