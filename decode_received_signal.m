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
    L = min(L,len);
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
    
    
    % Detect symbols
    oddbits = zi > 0; evenbits = zq > 0;
    bits = zeros(1,length(oddbits) + length(evenbits));
    bits(1:2:end) = oddbits;
    bits(2:2:end) = evenbits;
    
    % Return only the requested symbols
    bits = bits(1:len);
end