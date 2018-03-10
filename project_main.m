clear all; close all;
imgFile = 'data/Linearscale_onedot.jpg';
I = imread(imgFile);
figure, imshow(I), title('original image');
image = rgb2gray(I);

%% User Input

% ask user for axis type
ylinear = input('Enter 1 for linear y axis, 0 for log axis: ');
%{
% ask user for axis values
x1 = input('Enter minimum x value: ');
x2 = input('Enter maximum x value: ');
xvalues = [x1 x2];
y1 = input('Enter minimum y value: ');
y2 = input('Enter maximum y value: ');
yvalues = [y1 y2];
%}

%% Detect Axes
[origin,xaxis,yaxis] = detect_axis(image);

%% Detecting Labels

imgFile = 'data/Linearscale_onedot.jpg';
I = imread(imgFile);
figure, imshow(I);

gray = rgb2gray(I);

label_margin = 60;

% crop out y axis to focus just on x labels
xCropped = gray(:, xaxis(1)-(label_margin/2):end);
%figure, imshow(cropped);

% Perform OCR to get axis number labels
results = ocr(xCropped, 'CharacterSet', '0123456789', 'TextLayout','Block');

% Weed out low confidence 
confidentIdx = find(results.CharacterConfidences > 0.70);

% Get the bounding box locations of the low confidence characters
confBBoxes = results.CharacterBoundingBoxes(confidentIdx, :);

labelCrop = mode(confBBoxes(:, 2));

withoutAxisLabel = xCropped(1:labelCrop + label_margin,:);

xResults = ocr(withoutAxisLabel, 'TextLayout','Block');
numBBs = xResults.WordBoundingBoxes;
wordConf = xResults.WordConfidences;
xNums = xResults.Words;

% crop out y axis to focus just on x labels
yCropped = gray(1:yaxis(1)+(label_margin/2), :);

% Perform OCR to get axis number labels
results = ocr(yCropped, 'CharacterSet', '0123456789', 'TextLayout','Block');

% Weed out low confidence 
confidentIdx = find(results.CharacterConfidences > 0.70);

% Get the bounding box locations of the low confidence characters
confBBoxes = results.CharacterBoundingBoxes(confidentIdx, :);

commonY = mode(confBBoxes(:, 1));

withoutAxisLabel = yCropped(:, commonY - label_margin:end);

yResults = ocr(withoutAxisLabel, 'TextLayout','Block');
numBBs = yResults.WordBoundingBoxes;
wordConf = yResults.WordConfidences;
yNums = yResults.Words;


xvalues = [str2num(xNums{1}) str2num(xNums{end})];
yvalues = [str2num(yNums{end}) str2num(yNums{1})];

%% Data Extraction
line = classifyGraph(origin,xaxis,yaxis,imgFile);

if line
    coord = getLineCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear);
else
    coord = getMultCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear);
end

