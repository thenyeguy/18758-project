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
    corrs = fftshift(xcorr(y,pilot));
    [~,delta] = max(abs(corrs));
    delta = delta-1;
    
    if plots; figure(2); scatter(delta,0,'r.'); end
    
    % Grab pilot sequence, match filter and sample
    p = y(delta : delta + length(pilot)-1);
    p = conv(p, pulse(end:-1:1), 'same'); %#ok
    zs = p(T/2:T:end);
    
    % Determine EQ from there
    ps = 2*pilotBits - 1;
    eq = (ps*transpose(zs))/(ps*ps');

    
    % Drop the offset, pilot and trailing end
    L = min(L,len);
    delta = delta + length(pilot);
    y = y(delta : delta + T*L - 1);
    
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
    y = conv(y, pulse(end:-1:1), 'same'); %#ok
    yi = real(y); yq = imag(y);
    z = y(T/2:T:end);
    
    if plots
        subplot(4,1,4); hold on;
        plot(yi);
        stem(T/2:T:length(y), z, 'ro');
        title('Filtered signal, inphase only');
        legend('y^I', 'Sample Points');
        
        figure(3);
        subplot(2,1,2); hold on;
        spec = fftshift(fft(y));
        plot(linspace(-pi,pi,length(spec)),20*log10(abs(spec)));
        title('Filtered signal spectrum');
        xlabel('\omega'); ylabel('Spectral power (dB)');
    end
    
    
    % Detect symbols
    % Return only the requested symbols
    bits = z > 0;
    bits = bits(1:len);
end