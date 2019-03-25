function [position, orientation] = hogorientation(image)

%image = testimg4;

%binimg = imbinarize(image(:,:,1), 0.3);
%binimg = imopen(binimg, strel('disk',10));


%corners   = detectFASTFeatures(binimg);

%plot(corners.Location(:,1),corners.Location(:,2))
immid = [320,240];
blurred = imgaussfilt(image+1-1, 10);
%blurred = binimg;

[hogdata, visualization] = extractHOGFeatures(blurred, 'BlockSize', [1 1], 'CellSize', [480 640], 'NumBins', 180);
imshow(cat(3,image * 0, image * 1, image * 0))
hold on
plot (visualization)

[~, orientation] = max(hogdata);
CC = bwconncomp(image, 8);
centroid = regionprops(CC,'centroid');
hold on
plot(centroid(1).Centroid)
position = immid - centroid(1).Centroid;