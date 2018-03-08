%% Returns values of points in an image (assuming circular with radius 2)
% origin, xaxis, yaxis: cells containing (row,col) coordinate vector
% xvalues: array containing min and max values of x axis
% yvalues: "                                   "  y axis
% imgFile: string of file name of image
% linear: 0/1 based on whether linear scale or log scale axes
% line: 0/1 whether line or set of points
% coord: x,y values of point(s)
function coord = getMultCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear)
    % crop and binarize image 
    img = imread(imgFile);  
    img_gray = rgb2gray(img);
    img_bin = ~im2bw(img_gray, graythresh(img_gray));
    img_crop = img_bin(yaxis(2):yaxis(1),xaxis(1):xaxis(2));
    
    radius_range = [10 20];
%     for radii = 2:2:40
%         centers = imfindcircles(img_gray,radius); % col, row
%         if length(centers) > 0
%             radius = radii
%             break;
%         end
%     end

    [centers,radii] = imfindcircles(img_crop,radius_range); % col, row
    [h_crop,w_crop] = size(img_crop);
    for j = 1:length(centers)-1
        xdist = centers(j,1);
        ydist = h_crop - centers(j,2);
        xrange = xvalues(2) - xvalues(1);
        coord(j,1) = xrange*(xdist/w_crop) + xvalues(1);
        if ylinear
            yrange = yvalues(2) - yvalues(1);
            coord(j,2) = yrange*(ydist/h_crop) + yvalues(1);   
        else
            yrange = log10(yvalues(2)) - log10(yvalues(1)); %0.1 to 1000-> 3-(-1) = 4
            coord(j,2) = 10^(log10(yvalues(1)) + yrange*(ydist/h_crop));
        end
    end
end
