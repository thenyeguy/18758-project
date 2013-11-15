function BER = show_image(bitshat)
    shannon = imread('shannon3036.bmp');
    shannonhat = reshape(bitshat, 66, 46);
    
    figure(4); clf(4);
    subplot(1,2,1); imshow(shannon);
    subplot(1,2,2); imshow(shannonhat);
    
    BER = compute_BER(bitshat, shannon(:)');
end