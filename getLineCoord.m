%% Returns values of points in an image
% origin, xaxis, yaxis: cells containing (row,col) coordinate vector
% xvalues: array containing min and max values of x axis
% yvalues: "                                   "  y axis
% imgFile: string of file name of image
% linear: 0/1 based on whether linear scale or log scale axes
% line: 0/1 whether line or set of points
% coord: x,y values of point(s)
function coord = getLineCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,linear)
    % crop and binarize image   
    img = imread(imgFile);
    img_gray = rgb2gray(img);
    img_crop = img_gray(yaxis(2):yaxis(1),xaxis(2):xaxis(2));

    % detect number of regions
    img_bw = im2bw(img_crop,graythresh(img_crop));

    % generate set of x coordinates (at specified resolution)

    % search for zero value in each x coordinate column

end
