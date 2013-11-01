function x = create_transmit_signal(bits, plots)
    % Load constants
    constants;
    
    % Fill variables
    if nargin < 2
        plots = false;
    end
    
    
    % Pad bits to full length
    if(length(bits) > L)
        error('Provided packet exceeds max packet size');
    end
    M = length(bits);
    bits = [bits zeros(1,L-M)];
    
    
    % Display message, pulse and pilot
    if plots
        figure(1); clf(1);
        subplot(3,1,1); hold on;
        stem(bits,'c');
        stem(bits(1:M));
        title('Bits to transmit');
        legend('Message','Padding');
        
        subplot(3,1,2);
        plot([pulse zeros(1,T/2)]);
        title('Pulse waveform');
    end
    
    
    % Map to symbols
    % Uses BPSK (i.e. +/- 1)
    syms = 2*bits-1;
    
    
    % Expand in time and convolve with pulse sequence
    x = zeros(1,T*length(syms));
    x(1:T:end) = syms;
    x = conv(x,pulse);
    
    
    % Place pilot sequence at head
    x = [pilot x];
    
    if plots
        subplot(3,1,3); hold on;
        plot(x);
        plot(pilot,'c');
        title('Transmit signal');
        legend('Pilot','Message');
    end
end