function bits = decode_received_signal(y, len, plots)
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
        
        figure(3); clf(3);
        subplot(2,1,1); hold on;
        spec = fftshift(fft(y));
        plot(linspace(-pi,pi,length(spec)),20*log10(abs(spec)));
        title('Received signal spectrum');
        xlabel('\omega'); ylabel('Spectral power (dB)');
    end
   
    
    % Determine offset
    [corrs,lags] = xcorr(y,pilot);
    [~,I] = max(abs(corrs));
    delta = lags(I);
    
    if plots; figure(2); scatter(delta,y(delta),'r.'); end
    
    % Grab pilot sequence, match filter and sample
    p = y(delta+1 : delta + length(pilot));
    p = filter(pilotPulse(end:-1:1), 1, p); %#ok
    zs = p(pilotT/2:pilotT:end);
    
    % Determine EQ from there
    ps = 2*pilotBits - 1;
    eq = (ps*transpose(zs))/(ps*ps');

    
    % Drop the offset, pilot and trailing end
    L = min(L,len)*R/M; % number of bits to read in 
    delta = delta + length(pilot);
    y = y(delta+1 : delta + T*L);
    
    if plots
        subplot(4,1,2); hold on;
        plot(imag(y),'g'); plot(real(y));
        legend('y^Q', 'y^I');
        title('Windowed signal');
    end
    
    
    % Equalize
    y = y/eq;
    
    if plots
        subplot(4,1,3); hold on;
        plot(imag(y),'g'); plot(real(y));
        title('Equalized signal');
        legend('y^Q', 'y^I');
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
        
        figure(3);
        subplot(2,1,2); hold on;
        spec = fftshift(fft(y));
        plot(linspace(-pi,pi,length(spec)),20*log10(abs(spec)));
        title('Filtered signal spectrum');
        xlabel('\omega'); ylabel('Spectral power (dB)');
    end
    
    
    % Hard detect the coded symbols
    oddbits = zi > 0; evenbits = zq > 0;
    detectedbits = zeros(1,length(oddbits) + length(evenbits));
    detectedbits(1:2:end) = oddbits;
    detectedbits(2:2:end) = evenbits;
    
    
    % Correct the coded bits using viterbi    
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
    bits = zeros(1,length(codedbits)/2);
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
    
    
    % Return only the requested symbols
    bits = bits(1:len);
end