
function [xvalues, yvalues] = detect_labels(gray, xaxis, yaxis, ylinear)

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
    confVal = results.CharacterConfidences(confidentIdx); % Get confidence values

    % Annotate image with character confidences
    %im_conf = insertObjectAnnotation(xCropped, 'rectangle', confBBoxes, confVal);
    %figure, imshow(im_conf);

    commonY = mode(confBBoxes(:, 2));
    commonHeight = mode(confBBoxes(:, 4));

    withoutAxisLabel = xCropped(1:commonY + commonHeight,:);

    xResults = ocr(withoutAxisLabel, 'TextLayout','Block');
    xnumBBs = xResults.WordBoundingBoxes;
    wordConf = xResults.WordConfidences;
    xNums = xResults.Words;

    Iocr = insertObjectAnnotation(withoutAxisLabel, 'rectangle', xnumBBs, xNums);
    figure; imshow(Iocr);

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

    % crop out x axis to focus just on y labels
    yCropped = gray(1:yaxis(1)+(label_margin/2), :);

    % Perform OCR to get axis number labels
    results = ocr(yCropped, 'CharacterSet', '0123456789', 'TextLayout','Block');

    % Weed out low confidence 
    confidentIdx = find(results.CharacterConfidences > 0.70);

    % Get the bounding box locations of the low confidence characters
    confBBoxes = results.CharacterBoundingBoxes(confidentIdx, :);

    commonX = mode(confBBoxes(:, 1));

    withoutAxisLabel = yCropped(:, commonX - 20:end);
    
    yResults = ocr(withoutAxisLabel, 'TextLayout','Block');
    ynumBBs = yResults.WordBoundingBoxes;
    wordConf = yResults.WordConfidences;
    yNums = yResults.Words;
    
    Iocr = insertObjectAnnotation(withoutAxisLabel, 'rectangle', ynumBBs, yNums);
    figure; imshow(Iocr);

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
    xvalues = {};
    yvalues = {};
    
    %if ocr wasn't successful, ask for user's input
    if isempty(str2num(xNums{1})) || isempty(str2num(xNums{end}))
        x1 = input('Enter minimum x value: ');
        x2 = input('Enter maximum x value: ');
        xvalues = [x1 x2];  
    else
        if leftNumOnXstart
            xvalues{1} = str2num(xNums{1});
        else 
            %find range of labeled values
            valueDiff = str2num(xNums{end}) - str2num(xNums{1});
            %find dist those labeled values span over
            labelDist = abs(xnumBBs(1, 1) - xnumBBs(end, 1));
            % determine how far the first number is from the beginnning of the x
            % axis (include width/2 of bounding box)
            firstNumOffset = abs(xnumBBs(1, 1) + xnumBBs(1, 3)/2 - label_margin/2); 
            xvalues{1} = str2num(xNums{1}) - (firstNumOffset/labelDist) * valueDiff;
        end

        if rightNumOnXend
            xvalues{2} = str2num(xNums{end});
        else 
            %find range of labeled values
            valueDiff = str2num(xNums{end}) - str2num(xNums{1});
            %find dist those labeled values span over 
            labelDist = abs(xnumBBs(1, 1) - xnumBBs(end, 1));
            % determine how far the last number is from the end of the x axis
            lastNumOffset = abs(xaxis(2) - (xaxis(1)-(label_margin/2)) - xnumBBs(end, 1) + xnumBBs(end, 3)/2); 
            xvalues{2} = str2num(xNums{end}) + (lastNumOffset/labelDist) * valueDiff;
        end
        xvalues = cell2mat(xvalues);
    end
    
    if isempty(str2num(yNums{1})) || isempty(str2num(yNums{end}))
        y1 = input('Enter minimum y value: ');
        y2 = input('Enter maximum y value: ');
        yvalues = [y1 y2];
    else
        if bottomNumOnYstart
            yvalues{1} = str2num(yNums{end});
        else
            %find range of labeled values
            valueDiff = abs(str2num(yNums{end}) - str2num(yNums{1}));
            %find dist those labeled values span over 
            labelDist = abs(ynumBBs(1, 2) - ynumBBs(end, 2));
            % determine dist btwn lowest num and end of the y axis near origin
            lowNumOffset = abs(yaxis(1) - ynumBBs(end, 2) + ynumBBs(end, end)/2);
            if ylinear 
                yvalues{1} = str2num(yNums{end}) - (lowNumOffset/labelDist) * valueDiff;
            else 
                f = labelDist/(labelDist + lowNumOffset);
                % <-x1-------x2--x3--> x3 = fRoot(x2/(x1^(1-f)))
                yvalues{1} = nthroot(str2num(yNums{1}) / (str2num(yNums{end})^(f)), 1-f);
            end
        end

        if topNumOnYend
            yvalues{2} = str2num(yNums{1});
        else 
            %find range of labeled values
            valueDiff = abs(str2num(yNums{end}) - str2num(yNums{1}));
            %find dist those labeled values span over 
            labelDist = abs(ynumBBs(1, 2) - ynumBBs(end, 2));
            % determine dist btwn lowest num and end of the y axis near origin
            highNumOffset = abs(yaxis(2) - ynumBBs(1, 2) + ynumBBs(1, end)/2); 
            if ylinear 
                yvalues{2} = str2num(yNums{1}) + (highNumOffset/labelDist) * valueDiff;    
            else 
                f = labelDist/(labelDist + highNumOffset);
                % <-x1-------x2--x3--> x3 = fRoot(x2/(x1^(1-f)))
                yvalues{2} = nthroot(str2num(yNums{end}) / (str2num(yNums{1})^(f)), 1-f);    
            end
        end
        yvalues = cell2mat(yvalues);
    end    
end


