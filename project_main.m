I = imread('data/Logscale_onedot.jpg');
figure, imshow(I), title('original image');
detect_axis(rgb2gray(I))
