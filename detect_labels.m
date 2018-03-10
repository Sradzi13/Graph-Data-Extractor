%{
function detect_labels(image)


end
%}

clear all90; close all;
imgFile = 'data/Linearscale_onedot.jpg';
I = imread(imgFile);

level = graythresh(I);
BW = im2bw(I, level);

% Perform OCR
%results = ocr(I);
results = ocr(BW, 'CharacterSet', '0123456789', 'TextLayout','Block');

%{
figure;
imshow(I);
text(600, 150, results.Text, 'BackgroundColor', [1 1 1]);
%}

disp('hi')
disp(size(results.CharacterConfidences))
% Weed out low confidence 
confidentIdx = find(results.CharacterConfidences > 0);%.75);

disp(size(confidentIdx))


% Get the bounding box locations of the low confidence characters
confBBoxes = results.CharacterBoundingBoxes(confidentIdx, :);

% Get confidence values
confVal = results.CharacterConfidences(confidentIdx);

% Annotate image with character confidences
im_conf = insertObjectAnnotation(I, 'rectangle', confBBoxes, confVal);

figure;
imshow(im_conf);

%narrow results down to those that we are confident in
disp(size(results.WordBoundingBoxes))
results.WordBoundingBoxes
numBBs = results.WordBoundingBoxes;
wordConf = results.WordConfidences;
nums = results.Words;


im_confWord = insertObjectAnnotation(I, 'rectangle', numBBs, wordConf);
figure;
imshow(im_confWord);

figure;
Iname = insertObjectAnnotation(I, 'rectangle', numBBs, 1:19);
imshow(Iname);
title('word');
%{

% Display one of the recognized words
disp(size(results.Words))
for i = 1:size(results.Words, 1)
    word = results.Words{i};
    % Location of the word in I
    wordBBox = results.WordBoundingBoxes(i,:);

    % Show the location of the word in the original image
    figure;
    Iname = insertObjectAnnotation(I, 'rectangle', wordBBox, word);
    imshow(Iname);
    title(word);
end
%}

%{
%rotate to get rotated y-axis label
rotI = imrotate(I,270, 'bilinear');
imshow(rotI);
results = ocr(rgb2gray(I));
%}

%{
If your ocr results are not what you expect, try one or more of the following options:

Increase the image 2-to-4 times the original size.

If the characters in the image are too close together or their edges are touching, use morphology to thin out the characters. Using morphology to thin out the characters separates the characters.

Use binarization to check for non-uniform lighting issues. Use the graythresh and imbinarize functions to binarize the image. If the characters are not visible in the results of the binarization, it indicates a potential non-uniform lighting issue. Try top hat, using the imtophat function, or other techniques that deal with removing non-uniform illumination.

Use the region of interest roi option to isolate the text. Specify the roi manually or use text detection.

If your image looks like a natural scene containing words, like a street scene, rather than a scanned document, try using an ROI input. Also, you can set the TextLayout property to 'Block' or 'Word'.

%}
