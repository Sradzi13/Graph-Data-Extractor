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

imgFile = 'data/Template4_linear_number_not_ corner.jpg';
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
xnumBBs = xResults.WordBoundingBoxes;
wordConf = xResults.WordConfidences;
xNums = xResults.Words;

errorThresh = 10;
%determine if first detected x axis number label is at xStart 
if xnumBBs(1, 1) < errorThresh
    leftNumOnXstart = true;
else
    leftNumOnXstart = false;
end

%determine if last detected x axis number label is at xEnd
xEndNumAlignment = xnumBBs(end, 1) + xaxis(1)-(label_margin/2) + xnumBBs(end, 3)/2;
if abs(xEndNumAlignment - xaxis(2)) < errorThresh
    rightNumOnXend = true;
else
    rightNumOnXend = false;
end
    
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
ynumBBs = yResults.WordBoundingBoxes;
wordConf = yResults.WordConfidences;
yNums = yResults.Words;

%determine if first detected x axis number label is at xStart 
yStartNumAlignment = ynumBBs(1, 2) + ynumBBs(1, 4)/2;
if (yStartNumAlignment - yaxis(2)) < errorThresh
    topNumOnYend = true;
else
    topNumOnYend = false;
end

%determine if last detected x axis number label is at xEnd
yEndNumAlignment = ynumBBs(end, 2) + ynumBBs(end, 4)/2;
if abs(yEndNumAlignment - yaxis(1)) < errorThresh
    bottomNumOnYstart = true;
else
    bottomNumOnYstart = false;
end
    
% define min and max of x and y ranges
xvalues = [];
yvalues = [];

if leftNumOnXstart
    xvalues(1) = str2num(xNums{1});
else 
    %find range of labeled values
    valueDiff = str2num(xNums{end}) - str2num(xNums{1});
    %find dist those labeled values span over
    labelDist = abs(xnumBBs(1, 1) - xnumBBs(end, 1));
    % determine how far the first number is from the beginnning of the x
    % axis (include width/2 of bounding box)
    firstNumOffset = abs(xnumBBs(1, 1) + xnumBBs(1, 3)/2 - label_margin/2); 
    xvalues(1) = str2num(xNums{1}) - (firstNumOffset/labelDist) * valueDiff;
end

if rightNumOnXend
    xvalues(2) = str2num(xNums{end});
else 
    %find range of labeled values
    valueDiff = str2num(xNums{end}) - str2num(xNums{1});
    %find dist those labeled values span over 
    labelDist = abs(xnumBBs(1, 1) - xnumBBs(end, 1));
    % determine how far the last number is from the end of the x axis
    lastNumOffset = abs(xaxis(2) - (xaxis(1)-(label_margin/2)) - xnumBBs(end, 1) + xnumBBs(end, 3)/2); 
    xvalues(2) = str2num(xNums{end}) + (lastNumOffset/labelDist) * valueDiff;
end

if bottomNumOnYstart
    yvalues(1) = str2num(yNums{end});
else
    %find range of labeled values
    valueDiff = abs(str2num(yNums{end}) - str2num(yNums{1}));
    %find dist those labeled values span over 
    labelDist = abs(ynumBBs(1, 2) - ynumBBs(end, 2));
    % determine dist btwn lowest num and end of the y axis near origin
    lowNumOffset = abs(yaxis(1) - ynumBBs(end, 2) + ynumBBs(end, end)/2); 
    yvalues(1) = str2num(yNums{end}) - (lowNumOffset/labelDist) * valueDiff; 
end

if topNumOnYend
    yvalues(2) = str2num(yNums{1});
else 
    %find range of labeled values
    valueDiff = abs(str2num(yNums{end}) - str2num(yNums{1}));
    %find dist those labeled values span over 
    labelDist = abs(ynumBBs(1, 2) - ynumBBs(end, 2));
    % determine dist btwn lowest num and end of the y axis near origin
    highNumOffset = abs(yaxis(2) - ynumBBs(1, 2) + ynumBBs(1, end)/2); 
    yvalues(2) = str2num(yNums{1}) + (highNumOffset/labelDist) * valueDiff;    
end

%% Data Extraction
line = classifyGraph(origin,xaxis,yaxis,imgFile);

if line
    coord = getLineCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear);
else
    coord = getMultCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear);
end

