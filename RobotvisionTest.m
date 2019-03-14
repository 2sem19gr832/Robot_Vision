

%Load the test image. This can be replaced by webcam input
Test = imread('C:\Users\marti\Desktop\2. semester Control and Automation\Robot Vision\test1.jpg'); 
subplot(2,2,1)
imshow(Test)

%Each color channel of the image, these can later be used.
R = imcomplement(Test(:, :, 1));
G = imcomplement(Test(:, :, 2));
B = imcomplement(Test(:, :, 3));


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
          if 0.7 > ratioBG && ratioRB < 2                    %YELLOW: 1 < ratioBG && ratioRB > 2 RED: 1 > ratioBG && ratioRB > 2 BLUE: 0.5 > ratioBG && ratioRB < 2 Green: 0.9 > ratioGB && ratioRB < 1                                   
              new_pixel=256;    
          else
              new_pixel = 0;
          end
          % save new pixel value in thresholded image
          image_thresholded(ii,jj)=new_pixel;
          ratioBGv(ii, jj) = ratioBG;
      end
end

level = 0.99; %Used with the imbinarize() function.
binary2 = imbinarize(image_thresholded, level); %The image has been thresholded, but this changes the 0 and 256 -> 0 and 1
 
subplot(2,2,2)
imshow(image_thresholded)
subplot(2,2,3)
imshow(binary2)

subplot(2,2,4)
SE = strel('square',11); %Structuring element of the dialation
J = imdilate(binary2, SE); %First dialate and the erode the image.
SE2 = strel('square',15); %Structuring element of the erosion 
T = imerode(J, SE2); %Filter the image such that most of the noise is removed
imshow(T)

CC = bwconncomp(T, 8);
S = regionprops(CC, 'Area');
L = labelmatrix(CC);
BW2 = ismember(L, find([S.Area] >= 50)); %Find the BLOBs larger than 50 pixels and use these as the lego bricks
figure(2)
imshow(BW2)
hold on
B = bwboundaries(BW2); %Find boundaries of the BLOBs

for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end
c = regionprops(BW2,'centroid');
centroids = cat(1, c.Centroid); % Find the centroids of the BLOBs, these can be used to assign coordinate systems to the lego bricks.
hold on
plot(centroids(:,1),centroids(:,2), 'bo')
