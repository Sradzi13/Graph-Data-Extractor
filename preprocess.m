function imgFile_out = preprocess(imgFile)
    img = imread(imgFile);
    img_gray = rgb2gray(img);
    
    % remove noise
    
    % rectify axes
    img_edge = edge(img_gray, 'Canny');
    [H,T,R] = hough(img_edge);
    peaks = houghpeaks(H,4); %4 bounding lines of graph
    rhos = R(peaks(:,1));
    thetas = T(peaks(:,2));
    rho1 = rhos(1);
    theta1 = thetas(1);
    for i=2:4
        if thetas(i)~=theta1
            theta2 = thetas(i);
            break
        end
    end
    %{
    mask1 = thetas==theta1;
    if sum(mask1(:))>1
        rho1 = min(rhos(mask1));
    end
    mask2 = thetas==theta2;
    if sum(mask2(:))>1
        rho2 = min(rhos(mask2));
    end
    
    houghlines(img_edge,
    %}
    theta = min(abs(theta1),abs(theta2));
    img_out = imrotate(img,theta);
    %figure; imshow(img_out);
    [~,file,ext] = fileparts(imgFile);
    imgFile_out = strcat(file,'_out.jpg');
    imwrite(img_out,imgFile_out);
end