%Load the test image. This can be replaced by webcam input
Test = imread('C:\Users\marti\Desktop\2. semester Control and Automation\Robot Vision\test1.jpg'); 

%Each color channel of the image, these can later be used.
R = imcomplement(Test(:, :, 1));
G = imcomplement(Test(:, :, 2));
B = imcomplement(Test(:, :, 3));

classes = zeros(length(Test(:,1,1)), length(Test(1,:,1)));

for ii=1:size(Test,1) %Inspect each pixel of the image
    for jj=1:size(Test,2)
        % These ratios are used to identify what color each lego brick is.
        % This disregards brightness in the image and can therefore
        % reliably find the lego bricks.
        ratioRB = double(Test(ii,jj,1)+1)/double(Test(ii,jj,3)+1); %Ratio between the Red and blue color.
        ratioGB = double(Test(ii,jj,3)+1)/double(Test(ii,jj,2)+1); %Ratio between the Green and blue color.
        ratioBG = double(Test(ii,jj,2)+1)/double(Test(ii,jj,3)+1); %Ratio between the blue and green color. 
        pixel = Test(ii, jj);
          % check pixel value and assign new value
          if 1.45 > ratioBG && ratioRB > 2  %RED                %YELLOW: 1 < ratioBG && ratioRB > 2 RED: 1 > ratioBG && ratioRB > 2 BLUE: 0.5 > ratioBG && ratioRB < 2 Green: 0.9 > ratioGB && ratioRB < 1                                   
              new_pixel=cat(3, 255, 0, 0);
              classc = 1;
          elseif 0.8 > ratioGB && ratioRB < 1.1 %GREEN
              new_pixel = cat(3, 0, 255, 0);
              classc = 2;
          elseif 0.7 > ratioBG && ratioRB < 2 %BLUE
              new_pixel = cat(3, 0, 0, 255);
              classc = 3;
          elseif 1.1 < ratioBG && ratioRB > 2 %YELLOW
              new_pixel = cat(3, 0, 60, 210);
              classc = 4;
          else
              new_pixel = cat(3, 0, 0, 0);
              classc = 0;
          end
          % save new pixel value in thresholded image
          image_thresholded(ii,jj,:)=new_pixel;
          classes(ii, jj) = classc;
          %ratioBGv(ii, jj) = ratioBG;
     end
end
  %Use isMember to make binary images for each color and find the bounding
  %boxes for the lego bricks and the center point.
%level = 0.99; %Used with the imbinarize() function.
%binary2 = imbinarize(image_thresholded, level); %The image has been thresholded, but this changes the 0 and 256 -> 0 and 1


%Make binary images for each class
R = ismember(classes, 1); %RED
G = ismember(classes, 2); %GREEN
B = ismember(classes, 3); %BLUE
Y = ismember(classes, 4); %YELLOW

class = cat(3, ismember(classes, 1), ismember(classes, 2), ismember(classes, 3), ismember(classes, 4));


SE = strel('square',5); %Structuring element of the dialation
SE2 = strel('square',7); %Structuring element of the erosion

for k = 1:4
    J(:, :, k) = imdilate(class(:, :, k), SE); %First dialate and the erode the image.
    T(:, :, k) = imerode(J(:, :, k), SE2); %Filter the image such that most of the noise is removed
    CC(k) = bwconncomp(T(:, :, k), 8);
    S = regionprops(CC(k), 'Area');
    L(:, :, k) = labelmatrix(CC(k));
    BW2(:, :, k) = ismember(L(:, :, k), find([S.Area] >= 300)); %Find the BLOBs larger than 50 pixels and use these as the lego bricks
end

for k = 1:4 %Find boundaries and centroids
    bounds{k} = bwboundaries(BW2(:, :, k), 'noholes');
    
    region{k} = regionprops(BW2(:, :, k),'centroid');
    
    centroid{k} = cat(1, region(k));
end

figure(1)
subplot(1, 3, 1)
imshow(Test)
title('Original')
subplot(1, 3, 2)
imshow(BW2(:, :, 4)+BW2(:, :, 1)+BW2(:, :, 2)+BW2(:, :, 3))
title('Thresholded by color ratio')
subplot(1, 3, 3)
imshow(Test)
title('Classification of Lego Bricks')
hold on

for k = 1:4
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
                text(centroids(:,1),centroids(:,2), 'RED', 'FontSize', 14)
            end
            if k == 2
                plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on
                text(centroids(:,1),centroids(:,2), 'GREEN', 'FontSize', 14)
            end
            if k == 3
                plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'BLUE', 'FontSize', 14)
            end
            if k == 4
                plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'YELLOW', 'FontSize', 14)
            end
        end
    end
end

%%
Rb = bwboundaries(R, 'noholes'); %Find boundaries of the BLOBs
Gb = bwboundaries(G, 'noholes');
Bb = bwboundaries(B, 'noholes');
Yb = bwboundaries(Y, 'noholes');

Rc = regionprops(R,'centroid'); %Find centroids for each object
Gc = regionprops(G,'centroid');
Bc = regionprops(B,'centroid');
Yc = regionprops(Y,'centroid');

Rcentroids = cat(1, Rc.Centroid); % Find the centroids of the BLOBs, these can be used to assign coordinate systems to the lego bricks.
Gcentroids = cat(1, Gc.Centroid);
Bcentroids = cat(1, Bc.Centroid);
Ycentroids = cat(1, Yc.Centroid);