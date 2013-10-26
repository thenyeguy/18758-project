%
% constants.m
%    Defines the set of constants to be used for the comm system
%

% Constants defined by the radio
Fs = 2e6;     % transmit rate of USRP in Hz
maxL = 10000; % max samples in output signal


% Transmit constants
T = 10;  % samples per symbol
L = 200; % packet size in symbols
P = 100; % pilot size in symbols

pulse = ones(1,T/2); % rectangular pulse for modulation

pilot = rem(0:P-1,8) < 4;
pilot = 2*pilot-1;        % square wave with period 8 samples


% Channel constants
SNR = 20;                 % dB
Ex = 1;                   % expected symbol energy
sigN = Ex / 10.^(SNR/10); % noise variance

maxdelay = 300; % max delay before transmit in samples
atten = [2 10]; % factor of attenuation during transmit