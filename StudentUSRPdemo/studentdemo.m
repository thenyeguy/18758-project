% Demonstrates basic transmission and reception using USRP
%
% Place the included transmitsignal.mat file into your USRP user folder via SFTP.
% Once the receivedsignal.mat file is received, transfer it to your current
% Matlab folder.
% Then, run this program to display the transmit and received signals.

clc
disp(' ')

% Received file name
received_filename = 'receivedsignalEXAMPLE.mat'; % Choose as 'receivedsignal.mat' in your code

% Transmit signal
load transmitsignal.mat; % The variable transmitsignal is the transmit signal

% Received signal
if exist(received_filename,'file')
    load(received_filename);
else
    disp(['Error! Did not find ' received_filename ' file.'])
    return
end

if ~exist('receivedsignal','var')
    disp('Error! Loaded file does not contain the receivedsignal variable.')
    return;
end


% Display signals
figure(1)
clf
subplot(2,1,1)
plot(real(transmitsignal),'b')
hold on
plot(imag(transmitsignal),'r')
legend('real','imag')
ylabel('xI(t)  and  xQ(t)')
xlabel('Time in samples')
subplot(2,1,2)
plot(real(receivedsignal),'b')
hold on
plot(imag(receivedsignal),'r')
legend('real','imag')
ylabel('yI(t)  and  yQ(t)')
xlabel('Time in samples')

figure(2)
clf
subplot(2,1,1)
plot([0:length(transmitsignal)-1]/length(transmitsignal)-0.5, abs(fftshift(fft(transmitsignal))))
ylabel('abs(X(f))')
xlabel('Frequency in 1/samples')
subplot(2,1,2)
plot([0:length(receivedsignal)-1]/length(receivedsignal)-0.5, abs(fftshift(fft(receivedsignal))))
ylabel('abs(Y(f))')
xlabel('Frequency in 1/samples')

% Display information
disp('Notice that the USRP returns a  received signal whose length is larger than the transmit signal.')
disp('This is because it does not know exactly where your signal is placed in the received stream.')
disp(' ')
disp('Notice also that the received signal is delayed (with an unknown delay) w.r.t. transmit signal.')
disp(' ')
disp('Aligning the received signal with the transmit signal automatically is called synchronization.')
disp('So, synchronization is the first job of the receiver.')



