function line = classifyGraph(origin,xaxis,yaxis,imgFile)
    img = imread(imgFile);
    img_gray = rgb2gray(img);
    img_crop = img_gray(yaxis(2):yaxis(1),xaxis(1):xaxis(2));
    figure; imshow(img_crop);
    
    % detect number of regions
    img_bw = ~im2bw(img_crop,graythresh(img_crop));
    reg_label = bwlabel(img_bw);
    num_reg = max(reg_label(:));
    
    % detect 1 line vs multiple points
    if num_reg > 2
        line = 0;
    else
        % check if 1 point or a line
        [row,col] = find(reg_label == 2); %indices of region, assuming axes will be region 1
        if abs(col(1) - col(end)) < 30 % need to figure out general threshold
            line = 0;
        else
            line = 1;
        end
    end
end

