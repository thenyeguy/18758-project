%
% constants.m
%    Defines the set of constants to be used for the comm system
%

% Constants defined by the radio
Fs = 2e6;     % transmit rate of USRP in Hz
maxL = 10000; % max samples in output signal


% Transmit constants
T = 10;  % samples per symbol
L = 50; % packet size in symbols


% Rectangular pulse for modulation. Normalize to unit energy
pulse = ones(1,T/2);
pulse = pulse/norm(pulse);


% De Bruijn sequence of order 5 for timing sequence
% Using a BPSK modulation 
pilotBits = [0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, ...
             0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1];

pilot = zeros(1,T*length(pilotBits));
pilot(1:T:end) = 2*pilotBits-1;
pilot = conv(pilot,pulse);


% Channel constants for simulation
SNR = 20;                 % dB
Ex = 1;                   % expected symbol energy
sigN = Ex / 10.^(SNR/10); % noise variance

maxdelay = 2000; % max delay before transmit in samples
atten = [2 10]; % factor of attenuation during transmit