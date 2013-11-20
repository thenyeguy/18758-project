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
        subplot(4,1,1);
        stem(bits(1:M));
        title('Uncoded message');
    end
    
    
    % Generate coded bits from the input
    % Uses a 4-state rate 1/2 convolutional code
    codedbits = zeros(1,2*length(bits));
    state = [0 0];
    for ii=1:length(bits)
        % Get the current data bit
        bit = bits(ii);
        
        % Add the coded bits depending on the state
        if isequal(state, [0 0])
            codedbits(2*ii-1 : 2*ii) = xor(bit, [0 0]);
        elseif isequal(state, [0 1])
            codedbits(2*ii-1 : 2*ii) = xor(bit, [1 0]);
        elseif isequal(state, [1 0])
            codedbits(2*ii-1 : 2*ii) = xor(bit, [1 1]);
        else % isequal(state, [1 1])
            codedbits(2*ii-1 : 2*ii) = xor(bit, [0 1]);
        end
        
        % Update the state
        state = [state(2) bit];
    end
    
    if plots
        subplot(4,1,2);
        stem(codedbits(1:2*M));
        title('Coded bits');
    end
    
    
    % Map coded bits to symbols
    % Uses 4QAM, by assining odd bits to the real components and even bits
    % to the imaginary components
    syms = 2*codedbits-1;
    syms = syms(1:2:end) + 1j*syms(2:2:end);
    
    
    % Expand in time and convolve with pulse sequence
    x = upsample(syms,T);
    x = conv(x,pulse);
    
    
    % Place pilot sequence at head
    x = [pilot x];
    
    if plots
        subplot(4,1,3); hold on;
        plot(imag(x),'g'); plot(real(x));
        plot(pilot,'c');
        title('Transmit signal');
        legend('x^Q', 'x^I','Pilot');
        
        spec = fftshift(fft(x));
        subplot(4,1,4); hold on;
        plot(linspace(-pi,pi,length(spec)),20*log10(abs(spec)+.01));
        title('Transmit spectrum');
        xlabel('\omega'); ylabel('Spectral power (dB)');
    end
    
    
    if(length(x) > maxL)
        error('Computed message exceeds maximum message size');
    end
end