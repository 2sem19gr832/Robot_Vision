%Load the test image. This can be replaced by webcam input
clear
Test = imread('C:\Users\marti\Desktop\2. semester Control and Automation\Robot Vision\test5.jpg'); 
%clear cam;% clc;
%cam = webcam('c922 Pro Stream Webcam');
%for i = 1:10
%    snapshot(cam);
%end
% = snapshot(cam);
%Each color channel of the image, these can later be used.
R = Test(:, :, 1);
G = Test(:, :, 2);
B = Test(:, :, 3);

HSV = rgb2hsv(Test);

figure(5)
subplot(1, 3, 1)
imshow(R)
title('Red')
subplot(1, 3, 2)
imshow(G)
title('Green')
subplot(1, 3, 3)
imshow(B)
title('Blue')



figure(7)
subplot(1, 3, 1)
imshow(HSV(:, :, 1))
title('Hue')
subplot(1, 3, 2)
imshow(HSV(:, :, 2))
title('Saturation')
subplot(1, 3, 3)
imshow(HSV(:, :, 3))
title('Value')

%[idx, C] = kmeans(HSV, 6);

classes = zeros(length(Test(:,1,1)), length(Test(1,:,1)));

for ii=1:size(Test,1) %Inspect each pixel of the image
    for jj=1:size(Test,2)
        if HSV(ii, jj, 2) > 0.3
                
            newpixel(ii, jj) = 1; 
            if  0.8 < HSV(ii, jj, 1)%RED
                classc = 1;
            elseif HSV(ii, jj, 1) > 0.55 %GREEN
                classc = 2;
            elseif 0.19 < HSV(ii, jj, 1) < 0.54 %BLUE
                classc = 3;
            elseif HSV(ii, jj, 1) < 0.067 %YELLOW
                classc = 4;
            elseif 0.07 < HSV(ii, jj, 1) < 0.15 % ORANGE
                classc = 5;
            elseif HSV(ii, jj, 3) < 0.2 %BLACK
            newpixel(ii, jj) = 1;
            classc = 6;
            end 
        else
            classc = 0;
            newpixel(ii, jj) = 0;
        end
        classes(ii, jj) = classc;
     end
end
figure(6)
imshow(newpixel)
title('Thresholded Image')
%figure(3)
%imshow(newpixel)

  %Use isMember to make binary images for each color and find the bounding
  %boxes for the lego bricks and the center point.
%level = 0.99; %Used with the imbinarize() function.
%binary2 = imbinarize(image_thresholded, level); %The image has been thresholded, but this changes the 0 and 256 -> 0 and 1


%Make binary images for each class
R = ismember(classes, 1); %RED
G = ismember(classes, 2); %GREEN
B = ismember(classes, 3); %BLUE
Y = ismember(classes, 4); %YELLOW
O = ismember(classes, 5); %ORANGE

class = cat(3, ismember(classes, 1), ismember(classes, 2), ismember(classes, 3), ismember(classes, 4), ismember(classes, 5), ismember(classes, 6));

SE = strel('square',5); %Structuring element of the dialation
SE2 = strel('square',7); %Structuring element of the erosion

for k = 1:length(class(1,1,:))
    J(:, :, k) = imdilate(class(:, :, k), SE); %First dilate and then erode the image.
    T(:, :, k) = imerode(J(:, :, k), SE2); %Filter the image such that most of the noise is removed
    CC(k) = bwconncomp(T(:, :, k), 8);
    S = regionprops(CC(k), 'Area');
    L(:, :, k) = labelmatrix(CC(k));
    BW2(:, :, k) = ismember(L(:, :, k), find([S.Area] >= 300)); %Find the BLOBs larger than 50 pixels and use these as the lego bricks
end

for k = 1:length(class(1,1,:)) %Find boundaries and centroids
    bounds{k} = bwboundaries(BW2(:, :, k), 'noholes');
    
    region{k} = regionprops(BW2(:, :, k),'centroid');
    
    centroid{k} = cat(1, region(k));
end

figure(1)
%subplot(1, 3, 1)
%imshow(Test)
%title('Original')
%subplot(1, 3, 2)
%imshow(BW2(:, :, 4)+BW2(:, :, 1)+BW2(:, :, 2)+BW2(:, :, 3))
%title('Thresholded by color ratio')
%subplot(1, 3, 3)
imshow(Test)
title('Classification of Lego Bricks')
hold on

for k = 1:length(class(1,1,:))
    A = cat(1, bounds{k});
    for x = 1:length(bounds{k})
        boundary = cell2mat(A(x));
        centroidd = cell2mat(centroid{k});
        for u = 1:length(centroidd) 
            centroids = struct2array(centroidd(u));
            if k == 1
                plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on
                text(centroids(:,1),centroids(:,2), 'RED', 'FontSize', 14, 'color', 'w')
            end
            if k == 2
                plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on
                text(centroids(:,1),centroids(:,2), 'GREEN', 'FontSize', 14, 'color', 'w')
            end
            if k == 3
                plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'BLUE', 'FontSize', 14, 'color', 'w')
            end
            if k == 4
                plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'YELLOW', 'FontSize', 14, 'color', 'w')
            end
            if k == 5
                plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'ORANGE', 'FontSize', 14, 'color', 'w')
            end
            if k == 6
                plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'BLACK', 'FontSize', 14, 'color', 'w')
            end
        end
    end
end
