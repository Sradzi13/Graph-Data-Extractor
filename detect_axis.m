function [origin,xaxis,yaxis] = detect_axis(image)

[~, threshold] = edge(image, 'sobel');
fudgeFactor = .5;
BWhorz = edge(image,'sobel', threshold * fudgeFactor, 'horizontal');
%figure, imshow(BWhorz), title('binary gradient mask horz');

fudgeFactor = .5;
BWvert = edge(image,'sobel', threshold * fudgeFactor, 'vertical');
%figure, imshow(BWvert), title('binary gradient mask vert');


[~, threshold] = edge(image, 'sobel');
fudgeFactor = .5;
BWhorz = edge(image,'sobel', threshold * fudgeFactor, 'horizontal');
%figure, imshow(BWhorz), title('binary gradient mask horz');

fudgeFactor = .5;
BWvert = edge(image,'sobel', threshold * fudgeFactor, 'vertical');
%figure, imshow(BWvert), title('binary gradient mask vert');


% coordinates of the origin, endpts of x and y axis

[h, w] = size(BWhorz);

%find y axis
startCol = 1;
axisCol = 1;
while axisCol == 1
    currCol = BWvert(:, startCol);
    condIndsY = find(currCol == 1);
    numPixelsTrue = size(condIndsY, 1);
    if numPixelsTrue > h/2
        %disp(numPixelsTrue)
        axisCol = startCol;
        break;
    end 
    startCol = startCol + 1;
end

%find x axis (assumption that there is an X axis on bottom of graph)
startRow = h;
axisRow = 1;
while axisRow == 1
    currRow = BWhorz(startRow, :);
    condIndsX = find(currRow);
    numPixelsTrue = size(condIndsX, 2);
    if numPixelsTrue > w/2
        %disp(numPixelsTrue)
        axisRow = startRow;
        break;
    end 
    startRow = startRow - 1;
end


xStart = 0;
yStart = 0;
xEnd = 0;
yEnd = 0;


%find y axis start and end
if axisCol < w * (2/3)
    justYAxis = imopen(BWvert,ones(35, 1));
    yaxisInds = find(BWvert(:,axisCol) == 1);
    yMax = yaxisInds(1);
    %yEnd = yaxisInds(end);
end

%find x axis start and end
if axisRow > h * (2/3) 
    justXAxis = imopen(BWhorz,ones(1, 35));
    xAxisInds = find(BWhorz(axisRow,:) == 1);
    %xStart = xAxisInds(1);
    xMax = xAxisInds(end);
end

%let starts be at the origin


% determine origin
originx = axisCol;
originy = axisRow;

xMin = originx;
yMin = originy;

disp(originx)
disp(originy)


figure, imshow(BWvert);
hold on;
plot(originx, originy, 'b*');

%cropped = image(yMax:yMin, xMin:xMax);
%figure, imshow(cropped);
%title('Cropped Graph');

origin = [originx,originy];

xaxis = [xMin xMax];
yaxis = [yMin yMax];

end


%% find tic marks

%iterate along detected axis and make an array or where ticks are 
%get rid of threshold

%region labeling to get rid of minor ticks

%{
tic_margin = 35;
axis_margin = 0;
%find y axis start and end
if axisCol < w/2
    justYAxis = imclose(BWvert,ones(h-5, 1));
    imshow(justYAxis)
    yAxisCrop = justYAxis(:, axisCol - axis_margin:axisCol + tic_margin);
    yaxisInds = find(yAxisCrop(:,axisCol) == 1);
end

%find x axis start and end
if axisRow < h/2 
    justXAxis = imopen(BWhorz,ones(1, 35));
    xAxisCrop = justXAxis(axisRow - axis_margin:axisRow + tic_margin, :);
    xAxisInds = find(xAxisCrop(axisRow,:) == 1);
    xStart = xAxisInds(1);
    xEnd = xAxisInds(end);
    disp(xStart)
    disp(xEnd)
end
%}

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