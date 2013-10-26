function y = simulate_channel(x)
    % Load constants
    constants;
    
    % Populate our noise
    y = sigN/2*randn(1,maxL) + 1j*sigN/2*randn(1,maxL);
    
    % Attenuate and delay our symbol
    idx = randi(maxdelay);
    y(idx : idx+length(x)-1) = ...
        y(idx : idx+length(x)-1) + x./randi(atten);
end