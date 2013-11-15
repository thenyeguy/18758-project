function bits = load_image()
    shannon = imread('shannon3036.bmp');
    bits = shannon(:)';
end