function [T, bounds, centroid] = getCentroid(Test) 

R = Test(:, :, 1);
G = Test(:, :, 2);
B = Test(:, :, 3);


classes = zeros(length(Test(:,1,1)), length(Test(1,:,1)));

for ii=1:size(Test,1) %Inspect each pixel of the image
    for jj=1:size(Test,2)
        % These ratios are used to identify what color each lego brick is.
        % This disregards brightness in the image and can therefore
        % reliably find the lego bricks.
        ratioRB = double(Test(ii,jj,1)+1)/double(Test(ii,jj,3)+1); %Ratio between the Red and blue color.
        ratioBG = double(Test(ii,jj,3)+1)/double(Test(ii,jj,2)+1); %Ratio between the Green and blue color.
        ratioGB = double(Test(ii,jj,2)+1)/double(Test(ii,jj,3)+1); %Ratio between the blue and green color. 
        ratioRG = double(Test(ii,jj,1)+1)/double(Test(ii,jj,2)+1);
        pixel = Test(ii, jj);
          % check pixel value and assign new value
          if ratioRG > 10 && ratioRB > 2 && R(ii, jj) < 150 %RED            RED: ratioBG > 1 && ratioRB > 2
              new_pixel=cat(3, 255, 0, 0);
              classc = 1;
          elseif ratioGB > 1.5 && ratioRG < 1.5 && G(ii, jj) < 100%GREEN      Green: 0.9 > ratioGB && ratioRB < 1
              new_pixel = cat(3, 0, 255, 0);
              classc = 2;
          elseif ratioBG > 1.3 && ratioRB < 0.5 && B(ii,jj) > 50 %BLUE         BLUE: ratioBG > 0.5 && ratioRB < 2
              new_pixel = cat(3, 0, 0, 255);
              classc = 3;
          elseif ratioRG > 1.3 && ratioRB > 2 && G(ii, jj) > 85 %YELLOW       %YELLOW: ratioBG < 1 && ratioRB > 2
              new_pixel = cat(3, 0, 60, 210);
              classc = 4;
          elseif ratioRB > 1.5 && ratioBG < 1.5 && R(ii, jj) > 160 %Orange
              new_pixel = cat(3,60,60,210);
              classc = 5;
          elseif R(ii,jj) < 30 && G(ii,jj) < 30 && B(ii,jj) < 30
              new_pixel = cat(3,0,0,0);
              classc = 6;
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