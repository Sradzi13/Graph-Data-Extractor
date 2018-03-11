clear all; close all;
imgFile = 'data/Template20_log_multiple_corner.jpg';
I = imread(imgFile);
figure, imshow(I), title('original image');
image = rgb2gray(I);

%% User Input

% ask user for axis type
ylinear = input('Enter 1 for linear y axis, 0 for log axis: ');
% {
% ask user for axis values
x1 = input('Enter minimum x value: ');
x2 = input('Enter maximum x value: ');
xvalues = [x1 x2];
y1 = input('Enter minimum y value: ');
y2 = input('Enter maximum y value: ');
yvalues = [y1 y2];
% }

%% Detect Axes
[origin,xaxis,yaxis] = detect_axis(image);

%% Detecting Labels
[xvalues, yvalues] = detect_labels(image, xaxis, yaxis, ylinear);

%% Data Extraction
line = classifyGraph(origin,xaxis,yaxis,imgFile);

if line
    coord = getLineCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear);
else
    coord = getMultCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear);
end
coord = sort(coord);
