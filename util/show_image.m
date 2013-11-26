function BER = show_image(bitshat)
    % Read in actual and received image
    shannon = imread('shannon3036.bmp');
    shannonhat = reshape(bitshat, 66, 46);
    
    % Create errors in red channel of RGB image
    errors = double(shannon ~= shannonhat);
    errors(:,:,2:3) = zeros(66,46,2);
    
    % Display images
    figure(5); clf(5);
    subplot(1,3,1); imshow(shannon); title('Original image');
    
    subplot(1,3,2); imshow(shannonhat); title('Received image');
    
    subplot(1,3,3); imshow(errors); title('Error locations in red');
 
    % Display calculated BER
    BER = compute_BER(bitshat, shannon(:)');
    disp(['Image received with BER of: ' num2str(BER)]);
    disp ' ';
end