function x = create_transmit_signal(bits)
    % Load constants
    constants;
    
    % Pad bits to full length
    if(length(bits) > L)
        error('Provided packet exceeds max packet size');
    end
    bits = [bits zeros(1,L-length(bits))];
    
    % Map to symbols
    % Uses BPSK (i.e. +/- 1)
    syms = 2*bits-1;
    
    % Expand in time and convolve with pulse sequence
    x = zeros(1,T*length(syms));
    x(1:T:end) = syms;
    x = conv(x,pulse);
    
    % Place pilot sequence at head
    x = [pilot x];
end