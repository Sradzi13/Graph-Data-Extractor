function detect_axis(image)

[~, threshold] = edge(image, 'sobel');
fudgeFactor = .5;
BWhorz = edge(image,'sobel', threshold * fudgeFactor, 'horizontal');
figure, imshow(BWhorz), title('binary gradient mask horz');

fudgeFactor = .5;
BWvert = edge(image,'sobel', threshold * fudgeFactor, 'vertical');
figure, imshow(BWvert), title('binary gradient mask vert');


%iterate along detected axis and make an array or where ticks are 
%get rid of threshold

%region labeling to get rid of minor ticks

% coordinates of the origin, endpts of x and y axis


%{
%Fix vertical
fixedVert = imclose(imopen(rotatedIm,ones(35, 1)), ones(201, 1));
figure(), imshow(fixedVert);
title('Vertical Lines');

Im_vert = max(rotatedIm, fixedVert);
figure(), imshow(Im_vert);
title('Rotated Form with vert line repair');

%Fix horizontal
fixedHorz = imclose(imopen(rotatedIm,ones(1, 49)), ones(1, 301));
figure(), imshow(fixedHorz);
title('Horizontal Lines');

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

BWsdil = imdilate(BWs, [se90 se0]);
figure, imshow(BWsdil), title('dilated gradient mask');

BWoutline = bwperim(BWfinal);
Segout = I; 
Segout(BWoutline) = 255; 
figure, imshow(Segout), title('outlined original image');
%}