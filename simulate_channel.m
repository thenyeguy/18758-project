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
    angle = pi/4*rand();
    y = y*exp(1j*angle);
end