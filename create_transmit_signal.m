function [x,codedbits] = create_transmit_signal(bits, plots)
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
    N = length(bits);
    bits = [bits zeros(1,L-N)];
    
    
    % Display message, pulse and pilot
    if plots
        figure(1); clf(1);
        subplot(4,1,1);
        stem(bits(1:N));
        title('Uncoded message');
    end
    
    
    % Generate coded bits from the input
    % Uses a 4-state rate 1/2 convolutional code
    if coded
        codedbits = zeros(1,R*length(bits));
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
        
        % Interleave the coded bits
        codedbits = reshape(codedbits,interleaveA,interleaveB).';
        codedbits = codedbits(:).';
    else
        codedbits = bits;
    end
    
    if plots
        subplot(4,1,2);
        stem(codedbits(1:R*N));
        title('Coded bits');
    end
    
    % Map coded bits to symbols
    % Uses 16PSK
    M = 2^B;
    ints = bi2de(reshape(codedbits,B,length(codedbits)/B).').';
    syms = exp(2*pi*1j*ints/M);
    
    
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
        legend('x^Q', 'x^I','Pilot', 'Location','NorthWest');
        stem(0,'marker','none');
        
        spec = fftshift(fft(x));
        subplot(4,3,10:11); hold on;
        plot(linspace(-pi,pi,length(spec)),20*log10(abs(spec)+.01));
        title('Transmit spectrum');
        xlabel('\omega'); ylabel('Spectral power (dB)');
        
        subplot(4,3,12); hold on;
        plot([-2 2],[0 0], 'k');
        plot([0 1e-10], [-2 2], 'k');
        scatter(real(syms), imag(syms), 'bx');
        axis([-1.5 1.5 -1.5 1.5]); axis square;
        title('Signal space');
        xlabel('x^I'); ylabel('x^Q');
    end
    
    % Normaliae x to maximize power
    x = x/max(abs(x));
    
    % Error if x is too large
    if(length(x) > maxL)
        error('Computed message exceeds maximum message size');
    end
end