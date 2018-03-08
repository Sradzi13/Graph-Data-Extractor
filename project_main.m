clear all; close all;
imgFile = 'data/Linearscale_onedot.jpg';
I = imread(imgFile);
figure, imshow(I), title('original image');
image = rgb2gray(I);

%% User Input
% ask user for axis type
ylinear = input('Enter 1 for linear y axis, 0 for log axis: ');

% ask user for axis values
x1 = input('Enter minimum x value: ');
x2 = input('Enter maximum x value: ');
xvalues = [x1 x2];
y1 = input('Enter minimum y value: ');
y2 = input('Enter maximum y value: ');
yvalues = [y1 y2];

%% Data Extraction
[origin,xaxis,yaxis] = detect_axis(image);

line = classifyGraph(origin,xaxis,yaxis,imgFile);

if line
    coord = getLineCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear);
else
    coord = getMultCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear);
end

%% Detecting Labels

% Perform OCR
results = ocr(image);

% Display one of the recognized words
disp(size(results.Words))
word = results.Words{1};

% Location of the word in I
wordBBox = results.WordBoundingBoxes(2,:);

% Show the location of the word in the original image
figure;
Iname = insertObjectAnnotation(image, 'rectangle', wordBBox, word);
imshow(Iname);