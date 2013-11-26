function y = simulate_channel(x)
    % Load constants
    constants;
    
    % Populate our noise
    y = sigN/2*randn(1,maxL+maxdelay) + 1j*sigN/2*randn(1,maxL+maxdelay);
    
    % Attenuate and delay our symbol
    idx = randi(maxdelay);
    y(idx : idx+length(x)-1) = y(idx : idx+length(x)-1) + x;
    y = y./randi(atten);
    
    % Multiply by random angle
    angle = pi/2*rand();
    y = y*exp(1j*angle);
    
    % Add carrier offset
    f = 1/25000;
    y = y .* exp(1j*2*pi*(1:length(y))*f);
end