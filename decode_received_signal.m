function [bits,detectedbits] = decode_received_signal(y, len, plots)
    % Load constant factors and prep to display
    constants;
    
    % Fill variables
    if nargin < 2
        len = L; %#ok
    end
    if nargin < 3
        plots = false;
    end
    
    
    % Display received signal
    if plots
        figure(2); clf(2);
        subplot(4,1,1); hold on;
        plot(imag(y),'g'); plot(real(y));
        legend('y^Q', 'y^I');
        title('Raw received signal');
        stem(0,'marker','none');
        
        figure(3); clf(3);
        subplot(2,1,1); hold on;
        spec = fftshift(fft(y));
        plot(linspace(-pi,pi,length(spec)),20*log10(abs(spec)));
        title('Signal Spectra');
        xlabel('\omega'); ylabel('Spectral power (dB)');
    end
   
    
    % Determine offset
    [corrs,lags] = xcorr(y,pilot);
    [~,I] = max(abs(corrs));
    delta = lags(I);
    
    if plots; figure(2); scatter(delta,y(delta),'r.'); end
    
    
    % Regrab pilot sequence, then match filter and sample
    p = y(delta+1 : delta + length(pilot));
    p = filter(pilotPulse(end:-1:1), 1, p); %#ok
    zs = p(pilotT/2:pilotT:end);
    
    % Determine EQ from there
    ps = 2*pilotBits - 1;
    eq = (ps*transpose(zs))/(ps*ps');

    
    % Drop the offset, pilot and trailing end
    L = min(L,len)*R/B; % number of symbols to read in 
    delta = delta + length(pilot);
    y = y(delta+1 : delta + T*L);
    
    if plots
        subplot(4,1,2); hold on;
        plot(imag(y),'g'); plot(real(y));
        legend('y^Q', 'y^I');
        title('Windowed signal');
        stem(0,'marker','none');
    end
    
    
    % Equalize
    y = y/eq;
    
    if plots
        subplot(4,1,3); hold on;
        plot(imag(y),'g'); plot(real(y));
        title('Equalized signal');
        legend('y^Q', 'y^I');
        stem(0,'marker','none');
    end
    
    
    % Match filter, grab inphase and quadrature components, sample
    y = conv(y, pulse(end:-1:1)); %#ok
    yi = real(y);     yq = imag(y);
    zi = yi(T:T:end); zq = yq(T:T:end);
    
    if plots
        subplot(4,1,4); hold on;
        plot(yq, 'g'); plot(yi);
        stem(T:T:length(y), zq, 'cx');
        stem(T:T:length(y), zi, 'ro');
        title('Filtered signal, inphase only');
        legend('y^Q', 'y^I', 'z^Q', 'z^I');
        stem(0,'marker','none');
        
        figure(3);
        subplot(2,1,1); hold on;
        spec = fftshift(fft(y));
        plot(linspace(-pi,pi,length(spec)),20*log10(abs(spec)),'r');
        legend('Received spectrum','Filtered spectrum');
        
        subplot(2,1,2); hold on;
        plot([-2 2],[0 0], 'k');
        plot([0 1e-10], [-2 2], 'k');
        scatter(zi, zq, 'bx');
        scatter(real(exp(2*pi*1j*(0:(2^B-1))/2^B)), ...
                imag(exp(2*pi*1j*(0:(2^B-1))/2^B)), ...
                'ro', 'MarkerFaceColor','r');
        axis([-1.5 1.5 -1.5 1.5]); axis square;
        title('Signal space');
        xlabel('x^I'); ylabel('x^Q');
    end
    
    
    % Hard detect the coded symbols from MPSK
    M = 2^B;
    angs = angle(zi + 1j*zq);
    decs = mod(round(angs*M/(2*pi)),16);
    detectedbits = de2bi(decs,4)';
    detectedbits = detectedbits(:)';
    
    
    % Correct the coded bits using viterbi
    if coded
        % Deinterleave the received bits
        detectedbits = reshape(detectedbits,interleaveB,interleaveA)';
        detectedbits = detectedbits(:)';
        
        
        % Create empty trelli
        oldtrellis = struct('errors', {0, Inf, Inf, Inf}, ...
                            'bits', {[], [], [], []});
        newtrellis = struct('errors', {0, 0, 0, 0}, ...
                            'bits', {[], [], [], []});

        % Score the whole trellis
        for ii=1:2:length(detectedbits)
            bits = detectedbits(ii:ii+1);

            % State 00
            error1 = oldtrellis(1).errors + sum(bits ~= [0 0]);
            error2 = oldtrellis(3).errors + sum(bits ~= [1 1]);
            if error1 < error2
                newtrellis(1).errors = error1;
                newtrellis(1).bits = [oldtrellis(1).bits 0 0];
            else
                newtrellis(1).errors = error2;
                newtrellis(1).bits = [oldtrellis(3).bits 1 1];
            end

            % State 01
            error1 = oldtrellis(1).errors + sum(bits ~= [1 1]);
            error2 = oldtrellis(3).errors + sum(bits ~= [0 0]);
            if error1 < error2
                newtrellis(2).errors = error1;
                newtrellis(2).bits = [oldtrellis(1).bits 1 1];
            else
                newtrellis(2).errors = error2;
                newtrellis(2).bits = [oldtrellis(3).bits 0 0];
            end

            % State 11
            error1 = oldtrellis(2).errors + sum(bits ~= [1 0]);
            error2 = oldtrellis(4).errors + sum(bits ~= [0 1]);
            if error1 < error2
                newtrellis(3).errors = error1;
                newtrellis(3).bits = [oldtrellis(2).bits 1 0];
            else
                newtrellis(3).errors = error2;
                newtrellis(3).bits = [oldtrellis(4).bits 0 1];
            end

            % State 10
            error1 = oldtrellis(2).errors + sum(bits ~= [0 1]);
            error2 = oldtrellis(4).errors + sum(bits ~= [1 0]);
            if error1 < error2
                newtrellis(4).errors = error1;
                newtrellis(4).bits = [oldtrellis(2).bits 0 1];
            else
                newtrellis(4).errors = error2;
                newtrellis(4).bits = [oldtrellis(4).bits 1 0];
            end

            % Make the new trellis the old trellis and continue
            oldtrellis = newtrellis;
        end

        % Select the lowest error path
        [~,I] = min([oldtrellis.errors]);
        codedbits = oldtrellis(I).bits;
    
    
        % Decode the found bits
        bits = zeros(1,length(codedbits)/R);
        state = [0 0];
        for ii=1:length(bits)
            % Get the current coded bits
            cbits = codedbits(2*ii-1 : 2*ii);

            % Find the data bit depending on the state
            if isequal(state, [0 0])
                bits(ii) = isequal(cbits, [1 1]);
            elseif isequal(state, [0 1])
                bits(ii) = isequal(cbits, [0 1]);
            elseif isequal(state, [1 0])
                bits(ii) = isequal(cbits, [0 0]);
            else % isequal(state, [1 1])
                bits(ii) = isequal(cbits, [1 0]);
            end

            % Update the state
            state = [state(2) bits(ii)];
        end
    else
        bits = detectedbits;
    end
    
    
    % Return only the requested symbols
    bits = bits(1:len);
end