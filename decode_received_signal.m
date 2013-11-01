function bits = decode_received_signal(y, len)
    % Load constant factors and prep to display
    constants;
    
    if nargin < 2
        len = L; %#ok
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
    delta = delta-1;
    
    
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
    y = y/eq;
    
    subplot(3,1,2); hold on;
    plot(imag(y),'g'); plot(real(y));
    legend('y^Q', 'y^I');
    title('Windowed signal');
    
    % Equalize, match filter and grab inphase and quadrature components
    y = conv(y, pulse(end:-1:1), 'same'); %#ok
    yi = real(y); yq = imag(y);
    
    subplot(3,1,3); hold on;
    plot(yi);
    title('Filtered signal, inphase only');
    
    
    % Sample
    z = y(T/2:T:end);
    
    
    % Detect symbols
    bits = z > 0;
    
    
    % Return only the requested symbols
    bits = bits(1:len);
end