function BER = compute_BER(bits,bitshat)
    % Pad to same length
    n1 = length(bits);
    n2 = length(bitshat);
    
    if n1 < n2
        bits = [bits zeros(1,n2-n1)];
    end
    if n2 < n1
        bitshat = [bitshat zeros(1,n1-n2)];
    end
    
    % Compute differences
    BER = sum(bits ~= bitshat)/length(bits);
end