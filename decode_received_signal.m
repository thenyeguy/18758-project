function bits = decode_received_signal(y, len)
    % Load constant factors and prep to display
    constants;
    
    if nargin < 2
        len = L;
    end
    
    figure(2); clf(2);
    
    % Display received signal
    subplot(3,1,1); hold on;
    plot(imag(y),'g'); plot(real(y));
    legend('y^Q', 'y^I');
    title('Raw received signal');
    
    % Determine offset
    corrs = fftshift(xcorr(y,pilot));
    [~,delta] = max(abs(corrs));

    % Drop the offset, pilot and trailing end
    % Break out to in phase and quadrature components
    delta = delta+length(pilot);
    y = y(delta : delta + T*L - 1);
    yi = real(y); yq = imag(y);
    
    subplot(3,1,2); hold on;
    plot(yq,'g'); plot(yi);
    legend('y^Q', 'y^I');
    title('Windowed signal');
    
    % Match filter
    yi = conv(yi, pulse(end:-1:1),'same'); %#ok
    subplot(3,1,3); hold on;
    plot(real(y));
    title('Filtered signal, inphase only');
    
    % Sample
    z = y(T/2:T:end);
    
    % Detect symbols
    bits = z > 0;
    
    % Return only the requested symbols
    bits = bits(1:len);
end