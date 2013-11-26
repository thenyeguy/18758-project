function X = dtft(x,ws)
    if size(x,2) == 1, x = x.'; end
    N = length(x);
    
    Ws = exp(-1j * ws' * (0:(N-1)));
    X = 1/N * Ws * x.';
end